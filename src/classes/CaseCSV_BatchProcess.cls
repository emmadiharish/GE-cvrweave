public class CaseCSV_BatchProcess  implements Database.Batchable<String>, Database.Stateful {
    final String filename;
    final String attachmentID;
    final String caseID;
    final String accountID;
    String[] messages;
    String[] fields;
    
    String csvOfErrors; 
    
    public CaseCSV_BatchProcess(String filename, String attachmentID, String caseID, String accountID) {
        this.attachmentID = attachmentID;
        this.filename = filename;
        this.caseID = caseID;
        this.accountID = accountID;
        this.messages = new String[] {};
            this.fields = null;
        this.csvOfErrors = ''; 
    }
    
    public Iterable<String> start(Database.BatchableContext bc) {
        System.debug('CaseCSV_BatchProcess START');
        Attachment attach = [SELECT Name, Body FROM Attachment WHERE id = :attachmentID LIMIT 1];
        
        System.Debug('>>>> constructor csvBodies.size ' + attach.Body.size());
        String fileBody = attach.Body.toString();
        System.Debug('>>>> fileBody.size() ' + fileBody.length());
        
        System.Debug('>>>> BEFORE parseCSV');
        System.Debug('>>>> fileBody: ' + fileBody);
        
        List<String> lines = new List<String>();
        try {
            System.debug('BEFORE split');
            
            CVUtil_LineReader lineReader = new CVUtil_LineReader(fileBody);
            while(lineReader.hasNext()) {
                // Read line
                String line = lineReader.next();
                System.debug('}}}}' + line);
                lines.add(line);
            }
            System.debug('lines.size()' + lines.size());
            System.debug('AFTER split');
        } catch (System.ListException e) {
            System.debug('Limits exceeded?' + e.getMessage());
        }
        
        List<String> fileHeaders = parseLine(lines[0]);
        setFields(fileHeaders);
        lines.remove(0); //Remove header fields.
        System.debug('header fields: ' + this.fields);
        return lines;
    }
    
    public void execute(Database.BatchableContext bc, List<String> scope) { 
        List<List<String>> csv = parseCSV(scope);
        
        System.debug('fields for execute: ' + this.fields);
        
        
        System.Debug('Debugging filename: ' + filename);
        
        //Decide which object based on filename
        if(filename.contains('RoyaltyProductData')) {
            System.Debug('>>>> BEFORE addCVRoyaltyData');
            addCVRoyaltyData(csv);                
        } else {
            messages.add('Filename was "' + filename + '," but expected one containing either: "RoyaltyProductData"');
            System.Debug('>>>> DOES NOT HAVE RoyaltyProductData');
        }
        
        System.Debug('>>>> Done with a batch.');
    }
    
    public void finish(Database.BatchableContext bc) {
        //String responseEmailAddress = 'matt.vagnoni@gmail.com';
        
        // Get the ID of the AsyncApexJob representing this batch job
        // from Database.BatchableContext.
        // Query the AsyncApexJob object to retrieve the current job's information.
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
                          TotalJobItems, CreatedBy.Email
                          FROM AsyncApexJob WHERE Id =
                          :BC.getJobId()];
        // Send an email to the Apex job's submitter notifying of job completion.
        
        String[] toAddresses = new String[] {a.CreatedBy.Email};
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        system.debug(toAddresses);
        
        mail.setToAddresses(toAddresses);
        
        
        
        mail.setSubject('Salesforce - Case Process Royalty Data CSV');
        
        String salesforceHost = URL.getSalesforceBaseUrl().toExternalForm().replace('visual.','sales').replace('c.na','na');
        String caseURL = salesforceHost + '/' + caseId.removeEnd('ias');
        
        mail.setSenderDisplayName('Case Upload CSV - Testing CaseCSV batch');
        mail.setUseSignature(false);
        mail.setBccSender(true);
        String body = 'The following case was processed: ' + caseURL + '\n\n The batch Apex job processed ' + a.TotalJobItems + ' batches with '+ a.NumberOfErrors + ' critcal failures.  If any failures occured, you will need to reprocess or contact the COE to review internal logs as to why.\n\n';
        
        if(messages.size() == 0) {
            body += 'Document: ' + fileName + ' was successfully imported.';
        } else {
            body += 'Document: ' + fileName + ' had problems on import. \n Please review the attached error CSV.  Correct the problems and either re-process the entire CSV or just the attached file.\n';
        }
        for(String msg : messages) {
            body += '\t* ' + msg + '\n';
        }
        
        mail.setPlainTextBody(body);   
        mail.setFileAttachments(makeErrorCSVAttachment());
        
        Messaging.SendEmailResult [] r = 
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});  
        System.debug(r);
    }
    
    private void setFields(List<String> fileHeaders) {
        fields = new List<String>();
        for(String header : fileHeaders) {
            String field = header.replace(' ', '_') + '__c';
            fields.add(field);
        }
    }
    
    public void addCVRoyaltyData(List<List<String>> csvFile) {
        System.debug('csvFile: ' + csvFile);
        System.debug('csvFile.size(): ' + csvFile.size());
        System.debug('addCVRoyaltyData fields: ' + fields);
        
        Boolean isSuccess = true;
        List<String> errors = new List<String>{};
            // Initialize the list of records to insert
            List<CV_Royalty_Data__c> newRecords = new List<CV_Royalty_Data__c>();
        List<Product2> upsertProducts = new List<Product2>();
        Map<String, Product2> cacheProducts = new Map<String, Product2>();
        
        CV_Royalty_Data__c newRec;
        String sku = '';
        Integer Item_Sales_Total = 0;
        Date Period_End_Date = NULL;
        for(Integer row = 0; row < csvFile.size(); row++) {          //For each row
            errors.add('');
            newRec = new CV_Royalty_Data__c();
            System.debug('csvFile['+row+']: ' + csvFile[row]);
            for(Integer col = 0; col < csvFile[row].size(); col++) {           //For each field
                System.debug('csvFile['+row+']['+col+']:'+csvFile[row][col]);
                System.debug('fields[' + col + ']' + fields[col]);
                
                String element = csvFile[row][col];
                
                if(element.length() > 2 && element.startsWith('"') && element.endsWith('"')) {
                    element = element.substring(1, element.length()-1);
                }
                if(fields[col].contains('Item_SKU__c')) {
                    sku = element;
                }
                if(fields[col].contains('Period_End_Date')) {
                    System.debug('(before parse) period end date: ' + element);
                    Period_End_Date = Date.parse(element);    
                    newRec.put('Period_End_Date__c', Period_End_Date); 
                    
                } else if(fields[col].contains('Item_Quantity_Sold__c') || fields[col].contains('Item_Sales_Total__c')) {
                    try {
                        if(element.contains('-')) {
                            newRec.put(fields[col], 0);
                        } else {
                            newRec.put(fields[col], Integer.valueOf(element));                          
                        }
                        
                    } catch (Exception e) {
                        System.debug(e);
                        messages.add(e.getMessage());
                        errors.add(errors.size()-1, e.getMessage());
                    }
                } else {
                    try {
                        newRec.put(fields[col], element);
                    } catch (Exception e) {
                        System.debug(e.getMessage());
                    }
                }
            }
            
            
            System.debug('sku: ' + sku);
            System.debug('period end date: ' + Period_End_Date.format());
            
            String uniqueID = sku+Period_End_Date.format();
            System.debug('Unique_ID__c: ' + uniqueID );
            System.debug('Before the lookups');
            newRec.put('Royalty_Submission_Case__c', caseID); 
            newRec.put('Licensee__c', accountID); //Need to lookup
            newRec.put('Unique_ID__c', uniqueID );
            
            System.debug('Before the SOQL');
            System.debug('accountID: ' + accountID);
            System.debug('caseID: ' + caseID);
            //Put this into the conditional above
            //
            String prodKey = sku + accountID;
            /* 
* REFACTOR for calculating stats at the product level.
*/
            Product2 theProduct = NULL;
            if(cacheProducts.containsKey(prodKey)) {
                theProduct = cacheProducts.get(prodKey);
            } else {
                Product2[] products = [SELECT Id, Name
                                       FROM Product2
                                       WHERE Product_Number__c = :sku AND Licensee__c = :accountID];
                Integer index = errors.size()-1;
                String problem = errors.get(index);
                if(null == products || 0 == products.size()) {
                    problem += 'Unable to locate associated Product with sku and licensee.';
                    products.add(NULL);
                    //TEMPORARY FIX FOR SANDBOX TESTING
                    //1) Make a new product
                    //2) Add it so it can get updated. 
                    messages.add('Error: Unable to located a product with sku (' + sku + ') and accountID (' + accountID + ')');
                    
                } else if (1 < products.size()) {
                    problem += 'More than one Product matches sku and licensee.';
                    messages.add('Error: Duplicate products exist with with sku (' + sku + ') and accountID (' + accountID + ')');
                }
                errors.set(index, problem);
                theProduct = products[0];
                cacheProducts.put(prodKey, theProduct);
            }
            if(null != theProduct) {
                newRec.put('Licensed_Product__c', theProduct.Id);    
            }
            
            newRecords.add(newRec);
            System.debug(' After the lookups');
        }   
        System.debug('newRecords \n' + newRecords);   
        System.debug('newRecords.size \n' + newRecords.size());   
        System.debug('Before Upsert');
        Database.UpsertResult[] results = Database.upsert(newRecords, false); //Upsert on UniqueID, partial upsert is okay  
        //Database.UpsertResult[] results = Database.upsert(newRecords, CV_Royalty_Data__c.Fields.Unique_ID__c, false); //Upsert on UniqueID, partial upsert is okay  
        updateCSVOfErrors(results, newRecords, errors);
        //upsert cacheProducts.values();
    }
    
    /** 
    * Intended to be called by each call of execute()
    * It adds to the CSV state variable csv rows per error. 
    */
    private void updateCSVOfErrors(Database.UpsertResult[] upsertedResults, SObject[] upsertedData, List<String> errors) {
        for(Integer i = 0; i < upsertedData.size(); i++) {
            String row = '';
            
            Database.Error[] upsertErrors = upsertedResults[i].getErrors();
            if(!upsertedResults[i].isSuccess() || (upsertErrors != null && upsertErrors.size() > 0) || !String.isEmpty(errors[i])) {
                row = upsertedResults[i].getId() + ', ';
                for(String field : fields) {
                    try {
                        String value = String.valueOf(upsertedData[i].get(field));
                        row += value.escapeCsv() + ', ';
                    } catch (SObjectException e) {
                        System.debug(e);
                    }
                }
                for(Database.Error error : upsertErrors) {
                    row += '|' + error + '|';
                    messages.add('Error: ' + error);
                }
                if(!String.isEmpty(errors.get(i))) {
                    row += '|' + errors.get(i) + '|';
                }                
                csvOfErrors += row + '\n';
            }
        }
    }
    
    /**
    * Intended to be called by finish() after everything is ran before the email is sent. 
    */
    private Messaging.EmailFileAttachment[] makeErrorCSVAttachment() {
        System.debug('csvOfErrors.length(): ' + csvOfErrors.length());
        if(!String.isEmpty(csvOfErrors)) {
            //1) Make the headers
            String csvHeader = 'ID, ';
            for(String header : fields) {
                csvHeader += header + ',';
            }
            csvHeader += 'errors\n';
            
            //2) Add the body. 
            csvOfErrors = csvHeader + csvOfErrors;
            
            //3) Make the attachment.
            Messaging.EmailFileAttachment csvAttach = new Messaging.EmailFileAttachment();
            //3a) Add filename
            string csvname = filename.replace('.csv', '_errors.csv');
            csvAttach.setFileName(csvname);
            //3b) Add blob
            blob csvBlob = Blob.valueOf(csvOfErrors);
            csvAttach.setBody(csvBlob);
            
            return new Messaging.EmailFileAttachment[]{csvAttach};
                }
        return new Messaging.EmailFileAttachment[]{};
	}
    
    
    
    public static List<List<String>> parseCSV(List<String> lines) {
        List<List<String>> allFields = new List<List<String>>();
        
        // we are not attempting to handle fields with a newline inside of them
        // so, split on newline to get the spreadsheet rows
        Integer num = 0;
        for(String line : lines) {            
            List<String> cleanFields = parseLine(line);
            if(null != cleanFields) {
                allFields.add(cleanFields);
            }
        }
        return allFields;   
    }
    
    public static List<String> parseLine(String line) {
        // replace instances where a double quote begins a field containing a comma
        // in this case you get a double quote followed by a doubled double quote
        // do this for beginning and end of a field
        // 
        line = line.replaceAll(',"""', ',"DBLQT').replaceall('""",', 'DBLQT",');
        // now replace all remaining double quotes - we do this so that we can reconstruct
        // fields with commas inside assuming they begin and end with a double quote
        line = line.replaceAll('""','DBLQT');
        
        // check for blank CSV lines (only commas)
        if (line.replaceAll(',', '').trim().length() == 0) return null;

        List<String> fields = line.split(',');  
        List<String> cleanFields = new List<String>();
        String compositeField;
        Boolean makeCompositeField = false;
        for(String field : fields) {
            System.debug('field: ' + field); 
            if (field.startsWith('"') && !field.endsWith('"') && !makeCompositeField) {
                System.debug('1: ' + field);
                makeCompositeField = true;
                System.debug('compositeField: ' + compositeField);
                compositeField = field;
                System.debug('compositeField: ' + compositeField);
            } else if (field.endsWith('"') && makeCompositeField) {
                System.debug('2: ' + field);
                compositeField += ',' + field;
                cleanFields.add(compositeField.replaceAll('DBLQT','"'));
                makeCompositeField = false;
                System.debug('compositeField: ' + compositeField);

            } else if (makeCompositeField) {
                compositeField +=  ',' + field;
                System.debug('3: ' + field);
                System.debug('compositeField: ' + compositeField);
            } else {
                cleanFields.add(field.replaceAll('DBLQT','"'));
                System.debug('4: ' + field);
            }
        }
        if(makeCompositeField && !String.isEmpty(compositeField)) {
            System.debug('Found a dangling composite field.  Expected nothing but found: (' + compositeField + ')');
        }

        return cleanFields;
		        
    }
}