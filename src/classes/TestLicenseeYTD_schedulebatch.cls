@isTest
private class TestLicenseeYTD_schedulebatch {
	 /**
     * Class wide entry point for creation of test data.
     */
    @testSetup static void dataSetup() {

		Account theAccount = new Account();
    	theAccount.Name = 'LicenseeYTD_schedulebatch UnitTest Account';
    	theAccount.CV_Year_To_Date__c = 89;
        theAccount.CV_Previous_Year_To_Date__c = 11;
        theAccount.CV_Inception_To_Date__c = 100;
	        
    	insert theAccount;


    	List<Contract> allTestContracts = new List<Contract>();
    	for(Integer i = 0; i < 10; i++) {
			Contract con = new Contract();
	        con.AccountId = theAccount.id;
	        con.CV_Year_To_Date__c = 10;
	        con.CV_Previous_Year_To_Date__c = 5;
	        con.CV_Inception_To_Date__c = 15;
	        con.RecordType = [SELECT id, Name from RecordType where Name ='Agreement' AND SobjectType='Contract'];
	    	allTestContracts.add(con);
    	}
    	insert allTestContracts;
    }

	@isTest
	static void itShould() {
		Test.startTest();
		LicenseeYTD_schedulebatch.updateFinancials();
		Test.stopTest();

    	Account testLic = [SELECT Id, CV_Year_To_Date__c, CV_Previous_Year_To_Date__c, CV_Inception_To_Date__c FROM Account LIMIT 1];

		System.assertEquals(100, testLic.CV_Year_To_Date__c);
		System.assertEquals(50, testLic.CV_Previous_Year_To_Date__c);
		System.assertEquals(150, testLic.CV_Inception_To_Date__c);

	}
}