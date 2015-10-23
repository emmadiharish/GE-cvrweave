/******************************************************************************************************************************
* Name - DueDateRuleManagerTest
* @description
* Class contains all unit tests for DueDateRuleManager
* Modification Log :
* ---------------------------------------------------------------------------
* Developer Date Description
* ---------------------------------------------------------------------------
* Siva Gunda 10/18/2015 Created.
******************************************************************************************************************************/
@isTest
private class DueDateRuleManagerTest {
	
	/**
     * Class wide entry point for creation of test data.
     */
    @testSetup static void dataSetup() {

    	List<Account> accounts = TestDataFactory.createAccounts('testAcc', UserInfo.getUserId(), 1);
        insert accounts;

        List<Contract> contracts = TestDataFactory.createContracts(accounts,'testCon', 1);
        for(Contract c : contracts)
        {
        	c.StartDate = Date.newInstance(2030, 01, 01);
        	c.EndDate = Date.newInstance(2030, 12, 31);
        }
        insert contracts;

        // crate standard Due Date rule with all periods.
        List<CV_Due_Date_Rule__c> ddrList = new List<CV_Due_Date_Rule__c>();
        ddrList.addAll(TestDataFactory.createDueDateRules('default month end ddr', DueDateRuleManager.DDR_PERIOD_MONTH_END, 1));
        ddrList.addAll(TestDataFactory.createDueDateRules('default month end ddr', DueDateRuleManager.DDR_PERIOD_QUARTER_START, 1));
        ddrList.addAll(TestDataFactory.createDueDateRules('default month end ddr', DueDateRuleManager.DDR_PERIOD_QUARTER_END, 1));
        insert ddrList; 
	}

	@isTest static void test_getDueDateRulewCustomDatesMapbyId() {
		// Implement test code
		Set<Id> ddrIdSet = new Set<Id>();
		for(CV_Due_Date_Rule__c ddr : [Select Id From CV_Due_Date_Rule__c])
		{
			ddrIdSet.add(ddr.Id);
		}

		Map<Id, CV_Due_Date_Rule__c> ddrMap_result = DueDateRuleManager.getDueDateRulewCustomDatesMapbyId(ddrIdSet);
		System.assertEquals(ddrIdSet.size(), ddrMap_result.size());
		System.assertEquals(ddrIdSet, ddrMap_result.keySet());
	}
	
	@isTest static void test_getSchedulesbasedonDuedateRule_MonthPeriod() {
		// Implement test code
		Contract con = [Select Id From Contract Limit 1];
		con.StartDate = Date.newInstance(2030, 01, 01);
		con.EndDate = Date.newInstance(2030, 12, 31);

		CV_Due_Date_Rule__c ddrule = [Select Id, isStandard__c, Period__c, Days__c
										From CV_Due_Date_Rule__c 
											Where Period__c = :DueDateRuleManager.DDR_PERIOD_MONTH_END Limit 1];
		List<sObject> objs = DueDateRuleManager.getSchedulesbasedonDuedateRule(ddrule, con, CV_Royalty_Payment_Tracking__c.sObjectType);
		System.assertEquals(12, objs.size());

		objs = DueDateRuleManager.getSchedulesbasedonDuedateRule(ddrule, con, CV_Sales_Report_Tracking__c.sObjectType);
		System.assertEquals(12, objs.size());
	}
	
	@isTest static void test_getSchedulesbasedonDuedateRule_QuarterEndPeriod() {
		// Implement test code
		Contract con = [Select Id From Contract Limit 1];
		con.StartDate = Date.newInstance(2030, 01, 01);
		con.EndDate = Date.newInstance(2030, 12, 31);

		CV_Due_Date_Rule__c ddrule = [Select Id, isStandard__c, Period__c, Days__c
										From CV_Due_Date_Rule__c 
											Where Period__c = :DueDateRuleManager.DDR_PERIOD_QUARTER_END Limit 1];
		List<sObject> objs = DueDateRuleManager.getSchedulesbasedonDuedateRule(ddrule, con, CV_Royalty_Payment_Tracking__c.sObjectType);
		System.assertEquals(4, objs.size());

		objs = DueDateRuleManager.getSchedulesbasedonDuedateRule(ddrule, con, CV_Sales_Report_Tracking__c.sObjectType);
		System.assertEquals(4, objs.size());
	}

	@isTest static void test_getSchedulesbasedonDuedateRule_QuarterStartPeriod() {
		// Implement test code
		Contract con = [Select Id From Contract Limit 1];
		con.StartDate = Date.newInstance(2030, 01, 01);
		con.EndDate = Date.newInstance(2030, 12, 31);

		CV_Due_Date_Rule__c ddrule = [Select Id, isStandard__c, Period__c, Days__c
										From CV_Due_Date_Rule__c 
											Where Period__c = :DueDateRuleManager.DDR_PERIOD_QUARTER_START Limit 1];
		List<sObject> objs = DueDateRuleManager.getSchedulesbasedonDuedateRule(ddrule, con, CV_Royalty_Payment_Tracking__c.sObjectType);
		System.assertEquals(4, objs.size());

		objs = DueDateRuleManager.getSchedulesbasedonDuedateRule(ddrule, con, CV_Sales_Report_Tracking__c.sObjectType);
		System.assertEquals(4, objs.size());
	}

	@isTest static void test_getSchedulesbasedonDuedateRul_CustomPeriod() {
		// Implement test code
		Contract con = [Select Id From Contract Limit 1];
		con.StartDate = Date.newInstance(2030, 01, 01);
		con.EndDate = Date.newInstance(2032, 12, 31);

		CV_Due_Date_Rule__c ddrule = [Select Id, isStandard__c, Period__c, Days__c
										From CV_Due_Date_Rule__c 
											Where Period__c = :DueDateRuleManager.DDR_PERIOD_QUARTER_START Limit 1];
		ddrule.isStandard__c = false;
		update ddrule;

		// create 4 custom schedules starting with contract start date.
		List<CV_Custom_Due_Date__c> cduedatesList = new List<CV_Custom_Due_Date__c>();
		Date periodStartDate = con.StartDate.addMonths(3);
		for(Integer i = 0; i < 4; i++)
		{
			CV_Custom_Due_Date__c cdd = new CV_Custom_Due_Date__c();
			cdd.CV_Due_Date_Rule__c = ddrule.Id;
			cdd.Period_Start_Date__c = periodStartDate;
			cdd.Period_End_Date__c = periodStartDate.addMonths(3);
			cdd.Due_Date__c = periodStartDate.addMonths(4);
			periodStartDate = cdd.Period_End_Date__c;
			cduedatesList.add(cdd);
		}
		insert cduedatesList;
		
		ddrule = [select Id, isStandard__c, Days__c, Period__c,
                                (Select Period_Start_Date__c, Period_End_Date__c, Due_Date__c 
                                    From CVCustomDueDates__r
                                        Order by Period_End_Date__c)
                                    From CV_Due_Date_Rule__c 
                                        Where Id = :ddrule.Id Limit 1];

        System.assertEquals(cduedatesList.size(), ddrule.CVCustomDueDates__r.size());

		// for custom schedules tracking count should match the custom schedule count.
		List<sObject> objs = DueDateRuleManager.getSchedulesbasedonDuedateRule(ddrule, con, CV_Royalty_Payment_Tracking__c.sObjectType);
		System.assertEquals(cduedatesList.size(), objs.size());

		objs = DueDateRuleManager.getSchedulesbasedonDuedateRule(ddrule, con, CV_Sales_Report_Tracking__c.sObjectType);
		System.assertEquals(cduedatesList.size(), objs.size());
	}

	// negative test case : Do not create any schedules if contract has no startdate.
	@isTest static void test_getSchedulesbasedonDuedateRule_NoConStartDate() {
		// Implement test code
		Contract con = [Select Id From Contract Limit 1];
		con.StartDate = null;

		CV_Due_Date_Rule__c ddrule = [Select Id, isStandard__c, Period__c, Days__c
										From CV_Due_Date_Rule__c 
											Where Period__c = :DueDateRuleManager.DDR_PERIOD_MONTH_END Limit 1];
		List<sObject> objs = DueDateRuleManager.getSchedulesbasedonDuedateRule(ddrule, con, CV_Royalty_Payment_Tracking__c.sObjectType);
		System.assertEquals(0, objs.size());

		objs = DueDateRuleManager.getSchedulesbasedonDuedateRule(ddrule, con, CV_Sales_Report_Tracking__c.sObjectType);
		System.assertEquals(0, objs.size());
	}

	// negative test case : Do not create any schedules if no due date rule.
	@isTest static void test_getSchedulesbasedonDuedateRule_NoDueDateRule() {
		// Implement test code
		Contract con = [Select Id From Contract Limit 1];
		con.StartDate = Date.newInstance(2030, 01, 01);
		con.EndDate = Date.newInstance(2032, 12, 31);

		List<sObject> objs = DueDateRuleManager.getSchedulesbasedonDuedateRule(null, con, CV_Royalty_Payment_Tracking__c.sObjectType);
		System.assertEquals(0, objs.size());

		objs = DueDateRuleManager.getSchedulesbasedonDuedateRule(null, con, CV_Sales_Report_Tracking__c.sObjectType);
		System.assertEquals(0, objs.size());
	}
}