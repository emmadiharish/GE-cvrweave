/******************************************************************************************************************************
* Name - RoyaltyPaymentManagerTest
* @description
* Class contains all unit tests for RoyaltyPaymentManager
* Modification Log :
* ---------------------------------------------------------------------------
* Developer Date Description
* ---------------------------------------------------------------------------
* Siva Gunda 10/18/2015 Created.
******************************************************************************************************************************/
@isTest
private class RoyaltyPaymentManagerTest {
	
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

        List<CV_Royalty_Payment_Tracking__c> rpts = TestDataFactory.createRoyaltyPaymentTrackings(contracts, 10);
		insert rpts;
	}

	@isTest static void test_getnextdueRoyaltyPayment() {
		// Implement test code
		
		Contract con = [Select Id From Contract Limit 1];

		List<CV_Royalty_Payment_Tracking__c> rpts = [Select Id, isReceived__c 
														From CV_Royalty_Payment_Tracking__c 
															Where Contract__c = :con.Id
																Order by EndDate__c];
		System.assert(rpts.size() > 2, 'Mininmum of 2 Royal Payments are required.');
		System.assertEquals(rpts.get(0).Id, RoyaltyPaymentManager.getnextdueRoyaltyPayment(rpts).Id);

		rpts.get(0).isReceived__c = true;
		System.assertEquals(rpts.get(1).Id, RoyaltyPaymentManager.getnextdueRoyaltyPayment(rpts).Id);
	}
}