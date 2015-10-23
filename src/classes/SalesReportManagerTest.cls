/******************************************************************************************************************************
* Name - SalesReportManagerTest
* @description
* Class contains all unit tests for SalesReportManager
* Modification Log :
* ---------------------------------------------------------------------------
* Developer Date Description
* ---------------------------------------------------------------------------
* Siva Gunda 10/18/2015 Created.
******************************************************************************************************************************/
@isTest
private class SalesReportManagerTest {
	
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

        List<CV_Sales_Report_Tracking__c> srts = TestDataFactory.createSalesReportTrackings(contracts, 10);
		insert srts;
	}

	@isTest static void test_getnextdueSalesReport() {
		// Implement test code
		
		Contract con = [Select Id From Contract Limit 1];

		List<CV_Sales_Report_Tracking__c> srts = [Select Id, isReceived__c 
														From CV_Sales_Report_Tracking__c 
															Where Contract__c = :con.Id
																Order by EndDate__c];
		System.assert(srts.size() > 2, 'Mininmum of 2 sales reports are required.');
		System.assertEquals(srts.get(0).Id, SalesReportManager.getnextdueSalesReport(srts).Id);

		srts.get(0).isReceived__c = true;
		System.assertEquals(srts.get(1).Id, SalesReportManager.getnextdueSalesReport(srts).Id);
	}
	
}