/******************************************************************************************************************************
* Name - ContractManagerTest
* @description
* Class contains all unit tests for ContractManager
* Modification Log :
* ---------------------------------------------------------------------------
* Developer Date Description
* ---------------------------------------------------------------------------
* Siva Gunda 10/18/2015 Created.
******************************************************************************************************************************/
@isTest
private class ContractManagerTest {
	
	/**
     * Class wide entry point for creation of test data.
     */
    @testSetup static void dataSetup(){

        List<Account> accounts = TestDataFactory.createAccounts('testAcc', UserInfo.getUserId(), 1);
        insert accounts;

        // contracts should be of 'Agreement' record type.
        List<Contract> contracts = TestDataFactory.createContracts(accounts,'testCon', 1);
        insert contracts;

        // crate standard Due Date rule with month End.
        List<CV_Due_Date_Rule__c> ddrList = TestDataFactory.createDueDateRules('default month end ddr', DueDateRuleManager.DDR_PERIOD_MONTH_END, 2);
        insert ddrList; 
	}

	@isTest static void test_isContractPeriodSame(){
		// Implement test code
		Contract contract = new Contract(StartDate = Date.today(), EndDate = Date.today().addYears(1));
		Contract secondContract = contract.clone(false);
		System.assertEquals(true, ContractManager.isContractPeriodSame(contract, secondContract));

		System.assertEquals(false, ContractManager.isContractPeriodSame(contract, null));

		secondContract.EndDate = secondContract.EndDate.addYears(1);
		System.assertEquals(false, ContractManager.isContractPeriodSame(contract, secondContract));

		secondContract = contract.clone(false);
		secondContract.StartDate = secondContract.StartDate.addMonths(1);
		System.assertEquals(false, ContractManager.isContractPeriodSame(contract, secondContract));
	}
	
	@isTest static void test_isequalsRoyalPaymentSchedule(){
		// Implement test code
		CV_Due_Date_Rule__c ddr = [Select Id
										From CV_Due_Date_Rule__c Limit 1];

		Contract contract = new Contract(StartDate = Date.today(), EndDate = Date.today().addYears(1), Royalty_Payment_Due_Date_Rule__c = ddr.Id);
		Contract secondContract = contract.clone(false);
		System.assertEquals(true, ContractManager.isequalsRoyalPaymentSchedule(contract, secondContract));

		secondContract.EndDate = secondContract.EndDate.addYears(1);
		System.assertEquals(false, ContractManager.isequalsRoyalPaymentSchedule(contract, secondContract));

		secondContract = contract.clone(false);
		secondContract.Royalty_Payment_Due_Date_Rule__c = null;
		System.assertEquals(false, ContractManager.isequalsRoyalPaymentSchedule(contract, secondContract));
	}

	@isTest static void test_isequalsSalesReportSchedule(){
		// Implement test code
		CV_Due_Date_Rule__c ddr = [Select Id
										From CV_Due_Date_Rule__c Limit 1];

		Contract contract = new Contract(StartDate = Date.today(), EndDate = Date.today().addYears(1), Sales_Report_Due_Date_Rule__c = ddr.Id);
		Contract secondContract = contract.clone(false);
		System.assertEquals(true, ContractManager.isequalsSalesReportSchedule(contract, secondContract));

		secondContract.EndDate = secondContract.EndDate.addYears(1);
		System.assertEquals(false, ContractManager.isequalsSalesReportSchedule(contract, secondContract));

		secondContract = contract.clone(false);
		secondContract.Sales_Report_Due_Date_Rule__c = null;
		System.assertEquals(false, ContractManager.isequalsSalesReportSchedule(contract, secondContract));
	}
	
	@isTest static void test_getAgreements(){
		// Implement test code
		List<Contract> contracts = [Select Id, RecordTypeId 
										From Contract];
		for(Contract c : contracts)
		{
			c.RecordTypeId = Cache.RecordTypeId(ContractManager.RT_AGREEMENT);
		}

		// all passed contracts are of type 'Agreement.'
		System.assertEquals(contracts.size(), ContractManager.getAgreements(contracts).size());
	}
	
	@isTest static void test_getContractswRelListsbycId(){
		// Implement test code
		List<Contract> contracts = [Select Id, RecordTypeId 
										From Contract];
		Set<Id> contractIds = new Set<Id>();
		for(Contract c : contracts)
		{
			contractIds.add(c.Id);
		}

		System.assertEquals(contractIds, ContractManager.getContractswRelListsbycId(contractIds).keyset());								
	}
}