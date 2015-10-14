/******************************************************************************************************************************
* Name - CaseWorkflowExtensionControllerBaseTest
* @description
* NOT TO BE DEPLOYED
* Modification Log :
* ---------------------------------------------------------------------------
* Developer Date Description
* ---------------------------------------------------------------------------
* Zoran Zunko 05/13/2015 Created.
******************************************************************************************************************************/
@isTest public class TEST_Class_unittest {

    public class CaseWorkflowExtensionControllerBaseTestImpl extends CaseWorkflowExtensionControllerBase {
        public CaseWorkflowExtensionControllerBaseTestImpl(ApexPages.StandardController stdCtrl) {
            super(stdCtrl);
        }

        public override String getCurrentUserWorkflowRole() {
            return currentUserWorkflowRole;
        }
    }

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

        Case testCase = TestDataFactory.createNPICase('NPI Case', users[0].Id, accounts[0].Id, contacts[0].Id);
        insert testCase;
    }

    /**
     * tests the functioning of CaseWorkflowExtensionControllerBase doesRoleCaseIssueExist method
     */
    /**
     * tests the functioning of CaseNPIWorkflowCtrlExt reSubmit without adding comments to issues
     */
    /**
     * tests the functioning of CaseNPIWorkflowCtrlExt reSubmit with adding comments to issues
     */
    private static testmethod void test_reSubmit_IssuesWithComments() {
        Case testCase = (Case) (Database.query('SELECT ' + String.join(CVWorkflowManager.fieldsToLoadBase, ',') + ' FROM Case LIMIT 1')[0]);
        testCase.Status = CaseManager.STATUS_T1_GE_APPROVAL_PROCESS;
        update testCase;

        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(testCase);
        CaseNPIWorkflowCtrlExt extensionCtrl = new CaseNPIWorkflowCtrlExt(stdCtrl);
        CVCaseIssueCommentDisplayController componentController = new CVCaseIssueCommentDisplayController();

        componentController.pageController = extensionCtrl;
        extensionCtrl.currentUserWorkflowRole = CVWorkflowSettingsManager.ROLE_PROGRAM;
        componentController.addIssue();
        componentController.cvcicNewIssue.Message__c = 'message';
        componentController.saveIssue();

        PageReference prResponse = extensionCtrl.requestAdditionalInfo();
        System.assert(prResponse != null);
        extensionCtrl.init();

        testCase = (Case) (Database.query('SELECT ' + String.join(CVWorkflowManager.fieldsToLoadBase, ',') + ' FROM Case LIMIT 1')[0]);

        System.assertEquals(CaseManager.STATUS_T1_LICENSEE_FEEDBACK_REQUIRED, testCase.Status);

        stdCtrl = new ApexPages.StandardController(testCase);
        extensionCtrl = new CaseNPIWorkflowCtrlExt(stdCtrl);
        componentController = new CVCaseIssueCommentDisplayController();

        componentController.pageController = extensionCtrl;

        Test.startTest();
        extensionCtrl.currentUserWorkflowRole = CVWorkflowSettingsManager.ROLE_LICENSEE;
        extensionCtrl.init();
        componentController.cvcicNewCommentIssueId = extensionCtrl.cvcicIssesList[0].Id;
        componentController.addComment();
        componentController.cvcicNewComment.Message__c = 'message';
        componentController.saveComment();
        prResponse = extensionCtrl.reSubmit();
        System.assert(prResponse != null);
        Test.stopTest();

        testCase = (Case) (Database.query('SELECT ' + String.join(CVWorkflowManager.fieldsToLoadBase, ',') + ' FROM Case LIMIT 1')[0]);
        //System.assertEquals(CaseManager.STATUS_ROLE_GE_ACTION_REQUIRED, testCase.Program_Management_Workflow_Status__c);
        System.assertEquals(CaseManager.STATUS_T1_RESUBMITTED, testCase.Status);
    }

}