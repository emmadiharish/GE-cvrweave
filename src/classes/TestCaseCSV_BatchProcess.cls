@isTest
private class TestCaseCSV_BatchProcess {

	 /**
     * Class wide entry point for creation of test data.
     */
    @testSetup static void dataSetup() {
    	Account theAccount = new Account();
    	theAccount.Name = 'CaseCSV_BatchProcess UnitTest Account';
    	insert theAccount;

        Contract theContract = new Contract();
        theContract.AccountId = theAccount.id;
        theContract.RecordType = [SELECT id, Name from RecordType where Name ='Agreement' AND SobjectType='Contract'];
        insert theContract;


    	Case theCase = new Case();
    	theCase.AccountId = theAccount.id;
    	theCase.CV_Agreement_No_Name__c = theContract.id;
    	theCase.Subject = 'CaseCSV_BatchProcess UnitTest Case';
    	insert theCase;

    	Product2 prod = new Product2();
    	prod.Name = 'ProductYTD UnitTest';
    	prod.RecordType = [SELECT id from RecordType where Name ='Consumer Ventures' AND SobjectType='Product2'];
    	prod.Account__c = theAccount.id;
    	prod.Product_Number__c = '331000';
    	insert prod;

	}

	
	@isTest
 	static void testRoyaltyProductData() {
    	Case testCase = [SELECT Id, OwnerId, Status, Comments__c, AccountId FROM Case LIMIT 1];

  		String line1 = 'Co Number,Customer Number,Customer Name,Item Class,Item Subclass,Item SKU,Item Description,Item Quantity Sold,Item Sales Total,Period End Date\r';
  		String line2 = '1,331000,OFFICE DEPOT CONSIGNMENT,42,FB,95432,"All In One Foldable Headset,",9,85,12/31/14\r';
  		String line3 = '1,331000,OFFICE DEPOT CONSIGNMENT,42,FB,98934,Headset With Detachable,238,2349,12/31/14\r';
		String line4 = '1,331000,OFFICE DEPOT CONSIGNMENT,42,FB,98946,"All In One Headset, VOIP",162,1011,12/31/14';
  		String testcsv = line1+line2+line3+line4;

		Attachment theAttachment = new Attachment();
		theAttachment.Body = Blob.valueOf(testcsv);
		theAttachment.Name = 'test__RoyaltyProductData.csv';
		theAttachment.Description = 'A small file used for unit testing';
		theAttachment.ContentType = 'text/csv';
		theAttachment.ParentId = testCase.id; 
		insert theAttachment;

		Test.startTest();
		CaseCSV_BatchProcess caseCSVProcess = new CaseCSV_BatchProcess(theAttachment.Name, theAttachment.id, testCase.id, testCase.AccountId);
		Id batchInstanceId = Database.executeBatch(caseCSVProcess, 20); 
		Test.stopTest();

		// Verify merchandise items got deleted 
		Integer testCount = [SELECT COUNT() FROM CV_Royalty_Data__c WHERE Royalty_Submission_Case__c = :testCase.id];
		System.assertEquals(3, testCount);
    }

	@isTest
	static void testRoyaltyCreditSummary() {
    	Case testCase = [SELECT Id, OwnerId, Status, Comments__c, AccountId FROM Case LIMIT 1];

		String line1 = 'Invoice Number,Order Number,Invoice Date,Item Class,Item Number,Item Description,Customer Number,Customer Name,Item Quantity,Item Total Value,Currency Conversion Rate,Period End Date\r';
		String line2 = '9991,H62JD,12/14/2014,2,DEFECT-HEP,Defective Allowance-HEP,8001362, ARMY/AIR FORCE ,-1,-82,1,12/31/14\r';
		String line3 = '9992,H64YV,12/14/2014,2,DEFECT-HEP,Defective Allowance-HEP,8001362, ARMY/AIR FORCE ,-1,-31,1,12/31/14\r';
		String line4 = '9993,H64YT,12/14/2014,2,DEFECT-HEP,Defective Allowance-HEP,8001362, ARMY/AIR FORCE ,-1,-123,1,12/31/14\r';
		String testcsv = line1+line2+line3+line4;

		Attachment theAttachment = new Attachment();
		theAttachment.Body = Blob.valueOf(testcsv);
		theAttachment.Name = 'test__RoyaltyCreditSummary.csv';
		theAttachment.Description = 'A small file used for unit testing';
		theAttachment.ContentType = 'text/csv';
		theAttachment.ParentId = testCase.id; 
		insert theAttachment;

		Test.startTest();
		CaseCSV_BatchProcess caseCSVProcess = new CaseCSV_BatchProcess(theAttachment.Name, theAttachment.id, testCase.id, testCase.AccountId);
		Id batchInstanceId = Database.executeBatch(caseCSVProcess, 20); 
		Test.stopTest();

		Integer testCount = [SELECT COUNT() FROM CV_Royalty_Credit_Summary__c WHERE Data_Submission_Case__c = :testCase.id];		
		System.assertEquals(3, testCount);
    }

    @isTest
	static void testRoyaltyCreditAccrued() {
    	Case testCase = [SELECT Id, OwnerId, Status, Comments__c, AccountId FROM Case LIMIT 1];

    	String line1 = 'Accrued Credit Type,Customer Number,Customer Name,Total Discount Amount,Percent of Royalty Product,Period End Date\r';
		String line2 = 'Allowances,8000962,Amazon.com,65700,100,12/31/14\r';
		String line3 = 'Cash Discount,8002053,Canadian Tire,2246,0,12/31/14\r';
		String line4 = 'Trade Discounts,8002363,B Stock Solutions,0,100,12/31/14\r';

		String testcsv = line1+line2+line3+line4;

		Attachment theAttachment = new Attachment();
		theAttachment.Body = Blob.valueOf(testcsv);
		theAttachment.Name = 'test__RoyaltyCreditAccrued.csv';
		theAttachment.Description = 'A small file used for unit testing';
		theAttachment.ContentType = 'text/csv';
		theAttachment.ParentId = testCase.id; 
		insert theAttachment;

		Test.startTest();
		CaseCSV_BatchProcess caseCSVProcess = new CaseCSV_BatchProcess(theAttachment.Name, theAttachment.id, testCase.id, testCase.AccountId);
		Id batchInstanceId = Database.executeBatch(caseCSVProcess, 20); 
		Test.stopTest();

		Integer testCount = [SELECT COUNT() FROM CV_Royalty_Accrued_Credit__c WHERE Data_Submission_Case__c = :testCase.id];		
		System.assertEquals(3, testCount);
    }
}