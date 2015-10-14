/******************************************************************************************************************************
* Name - CaseAncillaryBrandWorkflowCtrlExtTest
* @description
* Class contains all unit tests for CaseAncillaryBrandWorkflowCtrlExt
* Modification Log :
* ---------------------------------------------------------------------------
* Developer Date Description
* ---------------------------------------------------------------------------
* Zoran Zunko 06/28/2015 Created.
******************************************************************************************************************************/
@isTest public class CaseAncillaryBrandWorkflowCtrlExtTest {

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

        Case testCase = TestDataFactory.createAncillaryBrandChangeCase('ACB Case', users[0].Id, accounts[0].Id, contacts[0].Id);
        insert testCase;
    }

    /**
     * tests the functioning of CaseAncillaryBrandWorkflowCtrlExt constructor
     */
    private static testmethod void test_pageLoad() {
        Case testCase = [SELECT Id, OwnerId, Status, Comments__c FROM Case LIMIT 1];

        Test.startTest();
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(testCase);
        CaseAncillaryBrandWorkflowCtrlExt extensionCtrl = new CaseAncillaryBrandWorkflowCtrlExt(stdCtrl);
        CVCaseIssueCommentDisplayController componentController = new CVCaseIssueCommentDisplayController();
        componentController.pageController = extensionCtrl;
        Test.stopTest();

        System.assertEquals(testCase, extensionCtrl.cLicenseeCase);
    }
}