@isTest
private class TestCaseYTD_schedulebatch {
	 /**
     * Class wide entry point for creation of test data.
     */
    @testSetup static void dataSetup() {

		Account theAccount = new Account();
    	theAccount.Name = 'CaseYTD_schedulebatch UnitTest Account';
    	insert theAccount;

    	Case theCase = new Case();
    	theCase.AccountId = theAccount.id;
    	theCase.Subject = 'CaseYTD_schedulebatch UnitTest Case';
    	theCase.CV_Total_Royalty_Processed__c = 99;
    	insert theCase;


    	Product2 prod = new Product2();
    	prod.Name = 'ProductYTD UnitTest';
    	prod.RecordType = [SELECT id from RecordType where Name ='Consumer Ventures' AND SobjectType='Product2'];
    	prod.CV_Current_Year__c = 1999;
    	prod.CV_Year_To_Date__c = 8;
    	prod.CV_Previous_Year_To_Date__c = 2;
    	prod.CV_Inception_To_Date__c = 10;
    	insert prod;

    	List<CV_Royalty_Data__c> rdata = new List<CV_Royalty_Data__c>();
    	for(Integer i = 0; i < 10; i++) {
    		CV_Royalty_Data__c rd = new CV_Royalty_Data__c();
    		rd.Customer_Name__c = 'No One';
    		rd.Licensee__c = theAccount.id;
	    	rd.Licensed_Product__c = prod.Id;
    		rd.Royalty_Submission_Case__c = theCase.id;
	    	rd.Period_End_Date__c = System.Today();
	    	rd.Item_Sales_Total__c = 10;
	    	rdata.add(rd);
    	}
		for(Integer i = 0; i < 5; i++) {
    		CV_Royalty_Data__c rd = new CV_Royalty_Data__c();
    		rd.Customer_Name__c = 'No One';
    		rd.Licensee__c = theAccount.id;
	    	rd.Licensed_Product__c = prod.Id;
    		rd.Royalty_Submission_Case__c = theCase.id;
	    	rd.Period_End_Date__c = System.Today().addYears(-1);
	    	rd.Item_Sales_Total__c = 10;

	    	rdata.add(rd);
    	}    	
    	insert rdata;
    }

	@isTest
	static void itShould() {
		Test.startTest();
		CaseYTD_schedulebatch.updateFinancials();

		Test.stopTest();

    	Case testCase = [SELECT Id, CV_Total_Royalty_Processed__c FROM Case LIMIT 1];

		System.assertEquals(150, testCase.CV_Total_Royalty_Processed__c);

	}
}