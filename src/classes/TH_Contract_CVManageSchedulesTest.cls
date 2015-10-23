/******************************************************************************************************************************
* Name - TH_Contract_CVManageSchedulesTest
* @description
* Class contains all unit tests for TH_Contract_CVManageSchedules
* Modification Log :
* ---------------------------------------------------------------------------
* Developer Date Description
* ---------------------------------------------------------------------------
* Siva Gunda 10/18/2015 Created.
******************************************************************************************************************************/
@isTest
private class TH_Contract_CVManageSchedulesTest {
	
	/**
     * Class wide entry point for creation of test data.
     */
    @testSetup static void dataSetup() {

        List<Account> accounts = TestDataFactory.createAccounts('testAcc', UserInfo.getUserId(), 1);
        insert accounts;

        // contracts should be of 'Agreement' record type.
        List<Contract> contracts = TestDataFactory.createContracts(accounts,'testCon', 1);
        for(Contract c : contracts)
        {
        	c.StartDate = Date.newInstance(2030, 01, 01);
        	c.EndDate = Date.newInstance(2030, 12, 31);
        }
        insert contracts;

        // crate standard Due Date rule with month End.
        List<CV_Due_Date_Rule__c> ddrList = TestDataFactory.createDueDateRules('default month end ddr', DueDateRuleManager.DDR_PERIOD_MONTH_END, 2);
        insert ddrList; 
	}

	@isTest static void test_setNextRoyaltyPayment() {
		// Implement test code
		// set the next royal payment to null and it should be populated with next non-paid schedule.
		Contract con = [Select Id, StartDate, EndDate From Contract Limit 1];
		
		// create Royalty Payment schedules on contract.
		List<CV_Royalty_Payment_Tracking__c> rpts = new List<CV_Royalty_Payment_Tracking__c>();
		rpts.add(new CV_Royalty_Payment_Tracking__c(Contract__c = con.Id));
		insert rpts;

		// set next royalty payment to null and calculated flag to true so it will be recalculated.
		con.Next_Royalty_Payment__c = null;
		con.Calculate_Next_Royalty_Payment__c = true;
		update con;

		//Map<Id, Contract> agreementsMap = ContractManager.getContractswRelListsbycId(new Set<Id>{con.Id});
		//TH_Contract_CVManageSchedules mngSchedulesCls = new TH_Contract_CVManageSchedules();
		//mngSchedulesCls.setNextRoyaltyPayment(new List<Contract>{con}, agreementsMap);

		con = [Select Id, Next_Royalty_Payment__c, Calculate_Next_Royalty_Payment__c From Contract Where Id = :con.Id];
		System.assertEquals(rpts.get(0).Id, con.Next_Royalty_Payment__c);
		System.assertEquals(false, con.Calculate_Next_Royalty_Payment__c);
	}
	
	@isTest static void test_setNextSalesReport() {
		// Implement test code
		// set the next royal payment to null and it should be populated with next non-paid schedule.
		Contract con = [Select Id, StartDate, EndDate From Contract Limit 1];
		
		// create Sales Report schedules on contract.
		List<CV_Sales_Report_Tracking__c> srts = new List<CV_Sales_Report_Tracking__c>();
		srts.add(new CV_Sales_Report_Tracking__c(Contract__c = con.Id));
		insert srts;

		// set next sales report to null and calculated flag to true so it will be recalculated.
		con.Next_Royalty_Payment__c = null;
		con.Calculate_Next_Sales_Report__c = true;
		update con;

		//Map<Id, Contract> agreementsMap = ContractManager.getContractswRelListsbycId(new Set<Id>{con.Id});
		//TH_Contract_CVManageSchedules mngSchedulesCls = new TH_Contract_CVManageSchedules();
		//mngSchedulesCls.setNextSalesReport(new List<Contract>{con}, agreementsMap);

		con = [Select Id, Next_Sales_Report__c, Calculate_Next_Sales_Report__c From Contract Where Id = :con.Id];
		System.assertEquals(srts.get(0).Id, con.Next_Sales_Report__c);
		System.assertEquals(false, con.Calculate_Next_Sales_Report__c);

	}

	@isTest static void test_deleteRevenuePaymentSchedulesonContractUpdate() {
		// Implement test code
		Contract con = [Select Id, StartDate, EndDate From Contract Limit 1];
		//TH_Contract_CVManageSchedules mngSchedulesCls = new TH_Contract_CVManageSchedules();
		//mngSchedulesCls.contractOldMap = new Map<Id, Contract>{con.Id => con.clone(false)};
		
		// create CV_Royalty_Payment_Tracking__c for con.
		List<CV_Royalty_Payment_Tracking__c> testrpts = TestDataFactory.createRoyaltyPaymentTrackings(new List<Contract>{con}, 5);
		insert testrpts;

		//Map<Id, Contract> agreementsMap = ContractManager.getContractswRelListsbycId(new Set<Id>{con.Id});
		System.assertNotEquals(0, [Select Count() From CV_Royalty_Payment_Tracking__c Where Contract__c = :con.Id]);
		
		// change the start and end date so CV_Royalty_Payment_Tracking__c will be deleted.
		con.StartDate = con.StartDate.addDays(1);
		con.EndDate = con.EndDate.addDays(1);
		update con;

		//mngSchedulesCls.createRevenuePaymentSchedules(new List<Contract>{con}, agreementsMap);
		System.assertEquals(0, [Select Count() From CV_Royalty_Payment_Tracking__c Where Contract__c = :con.Id]);
	}

	@isTest static void test_deleteSalesReportSchedulesonContractUpdate() {
		// Implement test code
		Contract con = [Select Id, StartDate, EndDate From Contract Limit 1];
		//TH_Contract_CVManageSchedules mngSchedulesCls = new TH_Contract_CVManageSchedules();
		//mngSchedulesCls.contractOldMap = new Map<Id, Contract>{con.Id => con.clone(false)};
		
		// create CV_Sales_Report_Tracking__c for con.
		List<CV_Sales_Report_Tracking__c> testsrts = TestDataFactory.createSalesReportTrackings(new List<Contract>{con}, 5);
		insert testsrts;

		//Map<Id, Contract> agreementsMap = ContractManager.getContractswRelListsbycId(new Set<Id>{con.Id});
		System.assertNotEquals(0, [Select Count() From CV_Sales_Report_Tracking__c Where Contract__c = :con.Id]);
		
		// change the start and end date so CV_Sales_Report_Tracking__c will be deleted.
		con.StartDate = con.StartDate.addDays(1);
		con.EndDate = con.EndDate.addDays(1);
		update con;

		//mngSchedulesCls.createRevenuePaymentSchedules(new List<Contract>{con}, agreementsMap);
		System.assertEquals(0, [Select Count() From CV_Sales_Report_Tracking__c Where Contract__c = :con.Id]);
		
	}

	@isTest static void test_createRevenuePaymentSchedules() {
		// Implement test code
		CV_Due_Date_Rule__c ddr = [Select Id, isStandard__c, Period__c, Days__c 
											From CV_Due_Date_Rule__c 
												Where isStandard__c = true limit 1];

		Contract con = [Select Id, StartDate, EndDate From Contract Limit 1];
		con.StartDate = Date.newInstance(2030, 01, 01);
		con.EndDate = Date.newInstance(2030, 12, 31);
		con.Royalty_Payment_Due_Date_Rule__c = ddr.Id;
		// update con;

		System.assertEquals(0, [Select Count() From CV_Royalty_Payment_Tracking__c Where Contract__c = :con.Id]);

		TH_Contract_CVManageSchedules mngSchedulesCls = new TH_Contract_CVManageSchedules();
		mngSchedulesCls.createRevenuePaymentSchedules(new List<Contract>{con}, new Map<Id, CV_Due_Date_Rule__c>{ddr.Id => ddr});
		System.assertNotEquals(0, [Select Count() From CV_Royalty_Payment_Tracking__c Where Contract__c = :con.Id]);
	}

	@isTest static void test_createSalesReportSchedules() {
		// Implement test code
		CV_Due_Date_Rule__c ddr = [Select Id, isStandard__c, Period__c, Days__c 
											From CV_Due_Date_Rule__c 
												Where isStandard__c = true limit 1];

		Contract con = [Select Id, StartDate, EndDate From Contract Limit 1];
		con.StartDate = Date.newInstance(2030, 01, 01);
		con.EndDate = Date.newInstance(2030, 12, 31);
		con.Sales_Report_Due_Date_Rule__c = ddr.Id;
		// update con;

		System.assertEquals(0, [Select Count() From CV_Sales_Report_Tracking__c Where Contract__c = :con.Id]);
		TH_Contract_CVManageSchedules mngSchedulesCls = new TH_Contract_CVManageSchedules();
		mngSchedulesCls.createSalesReportSchedules(new List<Contract>{con}, new Map<Id, CV_Due_Date_Rule__c>{ddr.Id => ddr});
		System.assertNotEquals(0, [Select Count() From CV_Sales_Report_Tracking__c Where Contract__c = :con.Id]);
	}

	@isTest static void test_updateNextDueDateSchedulesonContract(){
		// Implement test code
		CV_Due_Date_Rule__c ddr = [Select Id, isStandard__c, Period__c, Days__c 
											From CV_Due_Date_Rule__c 
												Where isStandard__c = true limit 1];

		Contract con = [Select Id, StartDate, EndDate, Next_Royalty_Payment__c, Next_Sales_Report__c From Contract Limit 1];
		System.assertEquals(0, [Select Count() From CV_Royalty_Payment_Tracking__c Where Contract__c = :con.Id]);
		System.assertEquals(0, [Select Count() From CV_Sales_Report_Tracking__c Where Contract__c = :con.Id]);
		System.assertEquals(null, con.Next_Royalty_Payment__c);
		System.assertEquals(null, con.Next_Sales_Report__c);
		con.StartDate = Date.newInstance(2030, 01, 01);
		con.EndDate = Date.newInstance(2030, 12, 31);
		con.Royalty_Payment_Due_Date_Rule__c = ddr.Id;
		con.Sales_Report_Due_Date_Rule__c = ddr.Id;
		update con;

		con = [Select Id, StartDate, EndDate, Next_Royalty_Payment__c, Next_Sales_Report__c From Contract Limit 1];
		System.assertNotEquals(0, [Select Count() From CV_Royalty_Payment_Tracking__c Where Contract__c = :con.Id]);
		System.assertNotEquals(0, [Select Count() From CV_Sales_Report_Tracking__c Where Contract__c = :con.Id]);
		System.assertNotEquals(null, con.Next_Royalty_Payment__c);
		System.assertNotEquals(null, con.Next_Sales_Report__c);
	}
	
}