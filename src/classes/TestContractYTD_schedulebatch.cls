@isTest
private class TestContractYTD_schedulebatch {
	 /**
     * Class wide entry point for creation of test data.
     */
    @testSetup static void dataSetup() {

		Account theAccount = new Account();
    	theAccount.Name = 'ContractYTD_schedulebatch UnitTest Account';
    	insert theAccount;

        Contract theContract = new Contract();
        theContract.AccountId = theAccount.id;
        theContract.CV_Year_To_Date__c = 10;
        theContract.CV_Previous_Year_To_Date__c = 5;
        theContract.CV_Inception_To_Date__c = 15;
        theContract.RecordType = [SELECT id, Name from RecordType where Name ='Agreement' AND SobjectType='Contract'];
        insert theContract;



    	List<Product2> allTestProducts = new List<Product2>();
    	for(Integer i = 0; i < 10; i++) {
	    	Product2 prod = new Product2();
	    	prod.Name = 'ContractYTD_schedulebatch UnitTest' + i;
	    	prod.Licensee__c = theAccount.id;
	        prod.Contract__c = theContract.id;
	    	prod.RecordType = [SELECT id from RecordType where Name ='Consumer Ventures' AND SobjectType='Product2'];
	    	prod.CV_Year_To_Date__c = 10;
	    	prod.CV_Previous_Year_To_Date__c = 5;
	    	prod.CV_Inception_To_Date__c = 15;
	    	allTestProducts.add(prod);
    	}
    	insert allTestProducts;
    }

	@isTest
	static void itShould() {
		Test.startTest();
		ContractYTD_schedulebatch.updateFinancials();
		Test.stopTest();

    	Contract testCon = [SELECT Id, CV_Year_To_Date__c, CV_Previous_Year_To_Date__c, CV_Inception_To_Date__c FROM Contract LIMIT 1];

		System.assertEquals(100, testCon.CV_Year_To_Date__c);
		System.assertEquals(50, testCon.CV_Previous_Year_To_Date__c);
		System.assertEquals(150, testCon.CV_Inception_To_Date__c);

	}
}