/******************************************************************************************************************************
* Name - CaseNewExternalFromInternalCtrlExtTest
* @description
* Class contains all unit tests for CaseNewExternalFromInternalCtrlExt
* Modification Log :
* ---------------------------------------------------------------------------
* Developer Date Description
* ---------------------------------------------------------------------------
* Zoran Zunko 07/24/2015 Created.
******************************************************************************************************************************/
@isTest public class CaseNewExternalFromInternalCtrlExtTest {

    /**
     * Class wide entry point for creation of test data.
     */
    @testSetup static void dataSetup() {

        List<sObject> workflowConfiguration = Test.loadData(CVWorkflowConfiguration__c.sObjectType, 'TestData_CV_Wokrflow_Configuration');

        List<Account> accounts = TestDataFactory.createAccounts('testAcc', UserInfo.getUserId(), 1);
        insert accounts;

        List<Contact> contacts = TestDataFactory.createContacts('testCon', UserInfo.getUserId(), accounts[0].Id, 1);
        insert contacts;

        List<User> users = TestDataFactory.createCommunityUsers('cp', TestDataFactory.CV_PARTNER_COMMUNITY_PROFILE_NAME, new List<Id> {contacts[0].Id});
        insert users;

        Case testCase = TestDataFactory.createInternalLegalCase('IL Case', UserInfo.getUserId(), accounts[0].Id, contacts[0].Id);
        testCase.Status = CaseManager.STATUS_CLOSED_APPROVED;
        testCase.Request_Type__c = 'Start External';
        insert testCase;
    }

    /**
     * tests the functioning of CaseNewExternalFromInternalCtrlExt constructor
     */
    private static testmethod void test_save_fileAttached() {

        CVInternalLegalParametersManager.cvInternalLegalParameters = new CV_Internal_Legal_Parameters__c(External_Legal_Kickoff_Condition__c = 'Start External');
        Case testCase = [SELECT ContactId
                                 , AccountId
                                 , Request_Type__c
                                 , CV_Agreement_No_Name__c
                                 , Amendment_Change_Type__c
                                 , Description
                                 , Amendment_Change_Other__c
                                 , Subject
                                 , Status
                                 , Id
                                 , Participating_Roles__c FROM Case LIMIT 1];

        Test.startTest();
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(testCase);
        CaseNewExternalFromInternalCtrlExt extensionCtrl = new CaseNewExternalFromInternalCtrlExt(stdCtrl);

        PageReference response = extensionCtrl.createExternalLegalCase();
        Test.stopTest();

        System.assert(response != null);
        System.assertEquals(testCase, extensionCtrl.cInternalLegal);
    }
}