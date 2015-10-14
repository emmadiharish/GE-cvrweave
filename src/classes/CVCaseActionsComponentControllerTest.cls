/******************************************************************************************************************************
* Name - CVCaseActionsComponentControllerTest
* @description
* Class contains all unit tests for CVCaseActionsComponentController
* Modification Log :
* ---------------------------------------------------------------------------
* Developer Date Description
* ---------------------------------------------------------------------------
* Zoran Zunko 06/18/2015 Created.
******************************************************************************************************************************/
@isTest public class CVCaseActionsComponentControllerTest {

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

        Case testCase = TestDataFactory.createRoyaltySubmissionCase('RS Case', users[0].Id, accounts[0].Id, contacts[0].Id);
        insert testCase;
    }

    /**
     * tests the functioning of CaseRoyaltySubmissionWorkflowExtension constructor
     */
    private static testmethod void test_pageLoad() {
        Case testCase = [SELECT Id, OwnerId, Status, Finance_Management_Workflow_Status__c, Program_Management_Workflow_Status__c, Comments__c FROM Case LIMIT 1];

        Test.startTest();

        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(testCase);
        CaseWorkflowExtensionControllerBaseTest.CaseWorkflowExtensionControllerBaseTestImpl extensionCtrl =
        new CaseWorkflowExtensionControllerBaseTest.CaseWorkflowExtensionControllerBaseTestImpl(stdCtrl);
        CVCaseActionsComponentController componentController = new CVCaseActionsComponentController();

        componentController.pageController = extensionCtrl;

        Test.stopTest();

        System.assert(!componentController.displayPopUp);
    }

    /**
     * tests the functioning of CaseRoyaltySubmissionWorkflowExtension reject for both internal roles
     */
    private static testmethod void test_reject_noIssues() {
        Case testCase = [SELECT Id, OwnerId, Status, Finance_Management_Workflow_Status__c, Program_Management_Workflow_Status__c, Comments__c FROM Case LIMIT 1];

        Test.startTest();
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(testCase);
        CaseRoyaltySubmissionWorkflowExtension extensionCtrl = new CaseRoyaltySubmissionWorkflowExtension(stdCtrl);
        CVCaseActionsComponentController componentController = new CVCaseActionsComponentController();

        componentController.pageController = extensionCtrl;
        extensionCtrl.currentUserWorkflowRole = CVWorkflowSettingsManager.ROLE_FINANCE;

        PageReference prResponse = componentController.reject();
        System.assert(prResponse != null);

        extensionCtrl.currentUserWorkflowRole = CVWorkflowSettingsManager.ROLE_PROGRAM;

        prResponse = componentController.reject();
        System.assert(prResponse != null);
        Test.stopTest();

        Case updatedTestCase = [SELECT Id, OwnerId, Status, Finance_Management_Workflow_Status__c, Program_Management_Workflow_Status__c, Comments__c FROM Case LIMIT 1];
        System.assertEquals(CaseManager.STATUS_ROLE_REJECTED, updatedTestCase.Finance_Management_Workflow_Status__c);
        System.assertEquals(CaseManager.STATUS_ROLE_REJECTED, updatedTestCase.Program_Management_Workflow_Status__c);
        System.assertEquals(CaseManager.STATUS_CLOSED_REJECTED, updatedTestCase.Status);
    }


    /**
     * tests the functioning of CaseRoyaltySubmissionWorkflowExtension rejectStart and rejectCancel
     */
    private static testmethod void test_other() {
        Case testCase = [SELECT Id, OwnerId, Status, Finance_Management_Workflow_Status__c, Program_Management_Workflow_Status__c, Comments__c FROM Case LIMIT 1];

        Test.startTest();
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(testCase);
        CaseRoyaltySubmissionWorkflowExtension extensionCtrl = new CaseRoyaltySubmissionWorkflowExtension(stdCtrl);
        CVCaseActionsComponentController componentController = new CVCaseActionsComponentController();
        componentController.pageController = extensionCtrl;

        extensionCtrl.sCVRejectionReason = 'test';
        componentController.rejectStart();
        System.assert(componentController.displayPopUp);
        System.assert(String.isBlank(extensionCtrl.sCVRejectionReason));

        componentController.rejectCancel();
        System.assert(!componentController.displayPopUp);
        Test.stopTest();

    }
}