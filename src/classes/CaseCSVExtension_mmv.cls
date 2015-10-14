public class CaseCSVExtension_mmv {
    public Case theCase {get;set;}
    public List<Attachment> csvAttachmentList {get;set;}
    
    public CaseCSVExtension_mmv(ApexPages.StandardController stdController){
        stdController.addFields(new List<String>{'AccountId', 'Account'});
        
        this.theCase = (Case)stdController.getRecord();
        System.debug('>>>> THECASE: ' + theCase);
        
        try {
            System.debug('>>>> theCase.AccountId: ' + theCase.AccountId);
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
        try {
            System.debug('>>>> theCase.Id: ' + theCase.Id);
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
        
		csvAttachmentList = 
             [SELECT Id,Name,Description,BodyLength,
              		CreatedById,CreatedDate,
              		LastModifiedById,LastModifiedDate,SystemModstamp,
              		OwnerId,ParentID 
              FROM Attachment 
              WHERE ContentType = 'text/csv' AND ParentID = :theCase.id 
              		AND isDeleted = false AND isPrivate = false];

        System.debug('>>>> csvAttachmentList.size: ' + csvAttachmentList.size());
        
    }
    
    public PageReference process() {
         List<Attachment> csvBodies = 
             [SELECT Name, Body 
              FROM Attachment 
              WHERE ContentType = 'text/csv' AND ParentID = :theCase.id 
              		AND isDeleted = false AND isPrivate = false];
        System.Debug('>>>> constructor csvBodies.size ' + csvBodies.size());
        Integer iterate = 0;
        //addCVRoyaltyData();
        for(Attachment attach : csvBodies) {
            System.Debug('>>>> iterate ' + iterate++);
            String fileBody = attach.Body.toString();
            System.Debug('>>>> fileBody.size() ' + fileBody.length());
            
            System.Debug('>>>> BEFORE parseCSV');
            System.Debug('>>>> fileBody: ' + fileBody);
            List<List<String>> csv = parseCSV(fileBody, false);

			System.Debug('>>>> BEFORE addCVRoyaltyData');
            //Decide which object based on filename
            if(attach.Name.contains('RoyaltyProductData')) {
                System.Debug('>>>> addCVRoyaltyData');
	            addCVRoyaltyData(csv);                
            } else {
                System.Debug('>>>> DOES NOT HAVE RoyaltyProductData');
            }
	
            System.Debug('>>>> Done with iteration: ' + iterate);
        }
  //      String docCodeParam = ApexPages.currentpage().getparameters().get('docCodeParam');
  //      System.debug('delete a document :: '+docCodeParam);
        return null;
    }
    
    private List<String> makeCustomFields(List<String> fileHeaders) {
        List<String> fields = new List<String>();
        for(String header : fileHeaders) {
            String field = header.replace(' ', '_') + '__c';
            fields.add(field);
        }
        return fields; 
    }
    
  public void addCVRoyaltyData(List<List<String>> csvFile) {
      System.debug('csvFile: ' + csvFile);
      Boolean isSuccess = true;
      // Initialize the list of records to insert
      List<CV_Royalty_Data__c> newRecords = new List<CV_Royalty_Data__c>();
      List<Product2> upsertProducts = new List<Product2>();
      Map<String, Product2> cacheProducts = new Map<String, Product2>();
      
      
      List<String> fields = makeCustomFields(csvFile.get(0));
      CV_Royalty_Data__c newRec;
      String sku = '';
      Integer Item_Sales_Total = 0;
      Date Period_End_Date = NULL;
      for(Integer row = 1; row < csvFile.size(); row++) {					 //For each row
          newRec = new CV_Royalty_Data__c();
          System.debug('csvFile['+row+']: ' + csvFile[row]);
          for(Integer col = 0; col < csvFile[row].size(); col++) {           //For each field
              System.debug('csvFile['+row+']['+col+']:'+csvFile[row][col]);
              if(fields[col].contains('Item_SKU__c')) {
                  sku = csvFile[row][col];
              }
              if(fields[col].contains('Period_End_Date')) {
                  Period_End_Date = Date.parse(csvFile[row][col]);		
                  newRec.put('Period_End_Date__c', Period_End_Date); 
              } else if(fields[col].contains('Item_Quantity_Sold__c') || fields[col].contains('Item_Sales_Total__c')) {
                  newRec.put(fields[col], Integer.valueOf(csvFile[row][col]));
                  if(fields[col].contains('Item_Sales_Total__c')) {
                      Item_Sales_Total = Integer.valueOf(csvFile[row][col]);
                  }
              } else {
                  try {
                  	newRec.put(fields[col], csvFile[row][col]);
                  } catch (Exception e) {
                      System.debug(e.getMessage());
                  }
              }
          }
          String uniqueID = sku+Period_End_Date.format();
          System.debug('Before the lookups');
	      newRec.put('Royalty_Submission_Case__c', theCase.Id); 
          newRec.put('Licensee__c', theCase.AccountId); //Need to lookup
          newRec.put('Unique_ID__c', uniqueID );
          
          System.debug('Before the SOQL');
          System.debug('Unique_ID__c :' + uniqueID );
          System.debug('sku:' + sku);
          System.debug('theCase.AccountId: ' + theCase.AccountId);
          System.debug('theCase.id: ' + theCase.Id);
          //Put this into the conditional above
          //
          String prodKey = sku + theCase.AccountId;
          Product2 theProduct = NULL;
          if(cacheProducts.containsKey(prodKey)) {
              theProduct = cacheProducts.get(prodKey);
          } else {
          	 theProduct = [SELECT Id, Name, CV_Product_Category__c//, CV_Year_To_Date__c, CV_Inception_To_Date__c, CV_Current_Year__c
                                    FROM Product2
                                    WHERE Product_Number__c = :sku AND Licensee__c = :theCase.AccountId
                                LIMIT 1];//TODO fix
             cacheProducts.put(prodKey, theProduct);
          }
          /**
          //Handle Year To Date calculations for the product.
          if(theProduct.Current_Year__c == NULL || theProduct.Current_Year__c != Period_End_Date.year()) {
              theProduct.Year_To_Date__c = 0;
              theProduct.Current_Year__c = Period_End_Date.year();
              //TODO: Trigger recalculation of Prior_Year_To_Date!!!!
          }
          if(theProduct.CV_Inception_To_Date__c == NULL) {
              theProduct.CV_Inception_To_Date__c = 0;
          }
          theProduct.Year_To_Date__c += Item_Sales_Total;
          theProduct.Inception_To_Date__c += Item_Sales_Total;
          //upsertProducts.add(theProduct);
          */
          
          newRec.put('Licensed_Product__c', theProduct.Id);
          newRecords.add(newRec);
          System.debug(' After the lookups');
      }   
      System.debug('newRecords \n' + newRecords);   
      System.debug('newRecords.size \n' + newRecords.size());   
      System.debug('newRecords[0] \n' + newRecords[0]); 
      System.debug('newRecords[1] \n' + newRecords[1]);   
      System.debug('Before Upsert');
	  upsert newRecords;// Unique_ID__c;  
      upsert cacheProducts.values();
  }
   
	public static List<List<String>> parseCSV(String contents, Boolean skipHeaders) {
        List<List<String>> allFields = new List<List<String>>();
    
        // we are not attempting to handle fields with a newline inside of them
        // so, split on newline to get the spreadsheet rows
        List<String> lines = new List<String>();
        try {
            System.debug('BEFORE split');
            
            CVUtil_LineReader lineReader = new CVUtil_LineReader(contents);
            lines = new List<String>();
            while(lineReader.hasNext() && lines.size() <= 50)
            {
                // Read line
                String line = lineReader.next();
                System.debug('}}}}' + line);
                lines.add(line);
            }
            //lines = contents.split('\n');
            System.debug('ines.size()' + lines.size());
            System.debug('AFTER split');
        } catch (System.ListException e) {
            System.debug('Limits exceeded?' + e.getMessage());
        }
        Integer num = 0;
        for(String line : lines) {
            // replace instances where a double quote begins a field containing a comma
            // in this case you get a double quote followed by a doubled double quote
            // do this for beginning and end of a field
            // 
            line = line.replaceAll(',"""',',"DBLQT').replaceall('""",','DBLQT",');
            // now replace all remaining double quotes - we do this so that we can reconstruct
            // fields with commas inside assuming they begin and end with a double quote
            line = line.replaceAll('""','DBLQT');

            // check for blank CSV lines (only commas)
            if (line.replaceAll(',','').trim().length() == 0) break;
            
            List<String> fields = line.split(',');	
            List<String> cleanFields = new List<String>();
            String compositeField;
            Boolean makeCompositeField = false;
            for(String field : fields) {
                if (field.startsWith('"') && field.endsWith('"')) {
                    cleanFields.add(field.replaceAll('DBLQT','"'));
                } else if (field.startsWith('"')) {
                    makeCompositeField = true;
                    compositeField = field;
                } else if (field.endsWith('"')) {
                    compositeField += ',' + field;
                    cleanFields.add(compositeField.replaceAll('DBLQT','"'));
                    makeCompositeField = false;
                } else if (makeCompositeField) {
                    compositeField +=  ',' + field;
                } else {
                    cleanFields.add(field.replaceAll('DBLQT','"'));
                }
            }
            
            allFields.add(cleanFields);
        }
        if (skipHeaders) allFields.remove(0);
        return allFields;		
    }

/*
     if(csvFiles != null){
         // Read each row and parse the row as value to insert
        List<List<String>> csvFile = csvFiles[0];
        List<String> fieldNames = csvFile.remove(0);
        for (List<String> row : csvFile) {
            // Initialize the new record
            SObject newRecord = objectType.newSObject();
            for(Integer i = 0; i < row.size(); i++) {
                // Read each value, matching it up to the correct field
                // based on the position of the value in the row
                String fieldName = fieldNames.get(i);
                String fieldValue = row.get(i);
                newRecord.put(fieldName, fieldValue);
            }
                
                // Enqueue the record to be created
                newRecords.add(newRecord);
            }
        }

        // Insert the list of records
        insert newRecords;
 */

            
/*
     Folder folder = folderList.get(0);
          document.AuthorId = UserInfo.getUserId();
          document.FolderId =  folder.Id;// put it in running user's folder
          document.name = docCode+'-'+document.name;
    try {

      insert document;

    } catch (DMLException e) {

      isSuccess = false;
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error uploading file'));

    } finally {

      document.body = null; // clears the viewstate
      document = new Document();

    }

    if(isSuccess){
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'File uploaded successfully'));
    }

    return null;
  }
*/
}