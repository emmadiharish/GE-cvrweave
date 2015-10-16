@isTest
private class TestCVProductCategoryYTD_schedulebatch {
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

        CV_Product_Category__c pcat_grandparent = new CV_Product_Category__c();
        pcat_grandparent.CV_Year_To_Date__c = 10;
        pcat_grandparent.CV_Previous_Year_To_Date__c = 5;
        pcat_grandparent.CV_Inception_To_Date__c = 15;
        pcat_grandparent.Category__c = 'PCat Grandparent';
        insert pcat_grandparent;        

		CV_Product_Category__c pcat_parent = new CV_Product_Category__c();
        pcat_parent.CV_Year_To_Date__c = 10;
        pcat_parent.CV_Previous_Year_To_Date__c = 5;
        pcat_parent.CV_Inception_To_Date__c = 15;
        pcat_parent.Parent_Category__c = pcat_grandparent.id;
        pcat_parent.Category__c = 'PCat Grandparent';
        pcat_parent.Sub_Cat_1__c = 'PCat Parent';

        insert pcat_parent;        

        CV_Product_Category__c pcat = new CV_Product_Category__c();
        pcat.CV_Year_To_Date__c = 10;
        pcat.CV_Previous_Year_To_Date__c = 5;
        pcat.CV_Inception_To_Date__c = 15;
        pcat.Parent_Category__c = pcat_parent.id;
        pcat.Category__c = 'PCat Grandparent';
        pcat.Sub_Cat_1__c = 'PCat Parent';
        pcat.Sub_Cat_2__c = 'PCat';
        insert pcat;        



    	List<Product2> allTestProducts = new List<Product2>();
    	for(Integer i = 0; i < 10; i++) {
	    	Product2 prod = new Product2();
	    	prod.CV_Product_Category__c = pcat.id;
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
		CVProductCategoryYTD_schedulebatch.updateFinancials();
		Test.stopTest();

    	List<CV_Product_Category__c> allTestPCATs = [SELECT Id, CV_Year_To_Date__c, CV_Previous_Year_To_Date__c, CV_Inception_To_Date__c FROM CV_Product_Category__c];

    	for(CV_Product_Category__c testPCAT : allTestPCATs) {
			System.assertEquals(100, testPCat.CV_Year_To_Date__c);
			System.assertEquals(50, testPCat.CV_Previous_Year_To_Date__c);
			System.assertEquals(150, testPCat.CV_Inception_To_Date__c);
    	}
	}
}