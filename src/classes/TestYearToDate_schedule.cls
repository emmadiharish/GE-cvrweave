@isTest
private class TestYearToDate_schedule {
	// CRON expression: midnight on March 15.
	// Because this is a test, job executes
	// immediately after Test.stopTest().
	public static String CRON_EXP = '0 0 0 15 3 ? 2022';

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

        Case theCase = new Case();
		theCase.AccountId = theAccount.id;
		theCase.Subject = 'CaseYTD_schedulebatch UnitTest Case';
		theCase.CV_Total_Royalty_Processed__c = 99;
		insert theCase;


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

    	Product2 prod = new Product2();
    	prod.Name = 'Year To Date UnitTest';

    	prod.Licensee__c = theAccount.id;
        prod.Contract__c = theContract.id;
        prod.CV_Product_Category__c = pcat.id;

    	prod.RecordType = [SELECT id from RecordType where Name ='Consumer Ventures' AND SobjectType='Product2'];
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




    	//-----------------------------------------------------------------------
		Test.startTest();
		//-----------------------------------------------------------------------

		// Schedule the test job
		String jobId = System.schedule('TestYearToDate_schedule',
		                CRON_EXP, 
		                new YearToDate_schedule());
		 
		//Or give up and call seperately? 
		//BatchUpdateCase theBatch = new BatchUpdateCase();
		//theBatch.start( (Database.BatchableContext) null );
		//theBatch.execute( (Database.BatchableContext) null, new List<Case>{ cas } );
		//theBatch.finish( (Database.BatchableContext) null );


		// Get the information from the CronTrigger API object
		CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
		 NextFireTime
		 FROM CronTrigger WHERE id = :jobId];

		// Verify the expressions are the same
		System.assertEquals(CRON_EXP, 
		 ct.CronExpression);

		// Verify the job has not run
		System.assertEquals(0, ct.TimesTriggered);

		// Verify the next time the job will run
		System.assertEquals('2022-03-15 00:00:00', String.valueOf(ct.NextFireTime));
		// Verify the scheduled job hasn't run yet.
		Product2 testBeforeProd = [SELECT Id, CV_Year_To_Date__c, CV_Previous_Year_To_Date__c, CV_Inception_To_Date__c FROM Product2 LIMIT 1];
		System.assertEquals(8, testBeforeProd.CV_Year_To_Date__c);
		System.assertEquals(2, testBeforeProd.CV_Previous_Year_To_Date__c);
		System.assertEquals(10, testBeforeProd.CV_Inception_To_Date__c);
		
		//-----------------------------------------------------------------------
		Test.stopTest();  //scheduled job executes immediately after stopTest()
		//-----------------------------------------------------------------------
    }

	@isTest
	static void itShould() {


		// Assert that the Cron job has ran once	
		//CronTrigger cronJob = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE Id = :jobId];
		//System.assertEquals(1, cronJob.TimesTriggered);


		// Now that the scheduled job has executed after Test.stopTest(),
		//   fetch the new merchandise that got added.
		Case testCase = [SELECT Id, CV_Total_Royalty_Processed__c FROM Case LIMIT 1];
	    System.assertEquals(150, testCase.CV_Total_Royalty_Processed__c);

    	Product2 testProd = [SELECT Id, CV_Year_To_Date__c, CV_Previous_Year_To_Date__c, CV_Inception_To_Date__c FROM Product2 LIMIT 1];
		System.assertEquals(100, testProd.CV_Year_To_Date__c);
		System.assertEquals(50, testProd.CV_Previous_Year_To_Date__c);
		System.assertEquals(150, testProd.CV_Inception_To_Date__c);

    	Contract testCon = [SELECT Id, CV_Year_To_Date__c, CV_Previous_Year_To_Date__c, CV_Inception_To_Date__c FROM Contract LIMIT 1];
		System.assertEquals(100, testCon.CV_Year_To_Date__c);
		System.assertEquals(50, testCon.CV_Previous_Year_To_Date__c);
		System.assertEquals(150, testCon.CV_Inception_To_Date__c);

	 	Account testLic = [SELECT Id, CV_Year_To_Date__c, CV_Previous_Year_To_Date__c, CV_Inception_To_Date__c FROM Account LIMIT 1];
	    System.assertEquals(100, testLic.CV_Year_To_Date__c);
	    System.assertEquals(50, testLic.CV_Previous_Year_To_Date__c);
	    System.assertEquals(150, testLic.CV_Inception_To_Date__c);

    	List<CV_Product_Category__c> allTestPCATs = [SELECT Id, CV_Year_To_Date__c, CV_Previous_Year_To_Date__c, CV_Inception_To_Date__c FROM CV_Product_Category__c];

    	for(CV_Product_Category__c testPCAT : allTestPCATs) {
			System.assertEquals(100, testPCat.CV_Year_To_Date__c);
			System.assertEquals(50, testPCat.CV_Previous_Year_To_Date__c);
			System.assertEquals(150, testPCat.CV_Inception_To_Date__c);
    	}
	}

}