/******************************************************************************************************************************
* Name - CaseWorkflowExtensionControllerBaseTest
* @description
* Class contains all unit tests for CaseWorkflowExtensionControllerBase
* Modification Log :
* ---------------------------------------------------------------------------
* Developer Date Description
* ---------------------------------------------------------------------------
* Zoran Zunko 05/13/2015 Created.
******************************************************************************************************************************/
@isTest public class CaseWorkflowExtensionControllerBaseTest {

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

        Case testCase = TestDataFactory.createRoyaltySubmissionCase('RS Case', users[0].Id, accounts[0].Id, contacts[0].Id);
        insert testCase;

        /*List<CV_Case_Issue_Comment__c> issues = TestDataFactory.createCVCaseIssues(testCase.Id, 3);
        insert issues;

        List<CV_Case_Issue_Comment__c> issueComments = new List<CV_Case_Issue_Comment__c>();
        for(CV_Case_Issue_Comment__c cvcic : issues) {
            issueComments.addAll(TestDataFactory.createCVCaseIssueComments(testCase.Id, cvcic.Id, 3));
        }
        insert issueComments;*/
    }

    /**
     * tests the functioning of CaseWorkflowExtensionControllerBase constructor
     */
    private static testmethod void test_pageLoad() {
        Case testCase = (Case) (Database.query('SELECT ' + String.join(CVWorkflowManager.fieldsToLoadBase, ',') + ' FROM Case LIMIT 1')[0]);

        Test.startTest();
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(testCase);
        CaseWorkflowExtensionControllerBaseTestImpl extensionCtrl = new CaseWorkflowExtensionControllerBaseTestImpl(stdCtrl);
        Test.stopTest();

        System.assertEquals(testCase, extensionCtrl.cLicenseeCase);
    }

    /**
     * tests the functioning of CaseWorkflowExtensionControllerBase properties
     */
    private static testmethod void test_properties() {
        Case testCase = (Case) (Database.query('SELECT ' + String.join(CVWorkflowManager.fieldsToLoadBase, ',') + ' FROM Case LIMIT 1')[0]);
        User cvPartnerUsers = [SELECT Id FROM User WHERE Profile.Name = :TestDataFactory.CV_PARTNER_COMMUNITY_PROFILE_NAME AND UserName LIKE '%@test.dev'];

        Test.startTest();
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(testCase);
        CaseWorkflowExtensionControllerBaseTestImpl extensionCtrl = new CaseWorkflowExtensionControllerBaseTestImpl(stdCtrl);
        extensionCtrl.init();
        Test.stopTest();

        System.assert(extensionCtrl.thisInstance == extensionCtrl);
        //System.assert(!extensionCtrl.displayPopup);
        //System.assertEquals(CVWorkflowSettingsManager.ROLE_LICENSEE, extensionCtrl.roleLicensee);
        //System.assertEquals(CVWorkflowSettingsManager.ROLE_PROGRAM, extensionCtrl.roleProgram);
        //System.assertEquals(CVWorkflowSettingsManager.ROLE_FINANCE, extensionCtrl.roleFinance);
    }

    /**
     * tests the functioning of CaseWorkflowExtensionControllerBase doesRoleCaseIssueExist method
     */
    private static testmethod void test_doesRoleCaseIssueExist() {
        Case testCase = (Case) (Database.query('SELECT ' + String.join(CVWorkflowManager.fieldsToLoadBase, ',') + ' FROM Case LIMIT 1')[0]);

        Test.startTest();
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(testCase);
        CaseWorkflowExtensionControllerBaseTestImpl extensionCtrl = new CaseWorkflowExtensionControllerBaseTestImpl(stdCtrl);
        CVCaseIssueCommentDisplayController componentController = new CVCaseIssueCommentDisplayController();
        extensionCtrl.init();

        componentController.pageController = extensionCtrl;
        extensionCtrl.currentUserWorkflowRole = CVWorkflowSettingsManager.ROLE_FINANCE;
        componentController.addIssue();
        componentController.cvcicNewIssue.Message__c = 'message';
        componentController.saveIssue();
        Test.stopTest();

        //test data factory creates finance issues
        extensionCtrl.currentUserWorkflowRole = CVWorkflowSettingsManager.ROLE_FINANCE;
        extensionCtrl.init();
        System.assert(extensionCtrl.doesRoleCaseIssueExist());

        extensionCtrl.currentUserWorkflowRole = CVWorkflowSettingsManager.ROLE_PROGRAM;
        System.assert(!extensionCtrl.doesRoleCaseIssueExist());
    }

    /**
     * tests the functioning of CaseWorkflowExtensionControllerBase areRoleCaseIssuesResolved method
     */
    private static testmethod void test_areRoleCaseIssuesResolved() {
        Case testCase = (Case) (Database.query('SELECT ' + String.join(CVWorkflowManager.fieldsToLoadBase, ',') + ' FROM Case LIMIT 1')[0]);

        Test.startTest();
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(testCase);
        CaseWorkflowExtensionControllerBaseTestImpl extensionCtrl = new CaseWorkflowExtensionControllerBaseTestImpl(stdCtrl);
        CVCaseIssueCommentDisplayController componentController = new CVCaseIssueCommentDisplayController();
        extensionCtrl.init();

        componentController.pageController = extensionCtrl;
        extensionCtrl.currentUserWorkflowRole = CVWorkflowSettingsManager.ROLE_FINANCE;
        componentController.addIssue();
        componentController.cvcicNewIssue.Message__c = 'message';
        componentController.saveIssue();
        Test.stopTest();

        //test data factory creates finance issues
        extensionCtrl.currentUserWorkflowRole = CVWorkflowSettingsManager.ROLE_FINANCE;
        System.assert(!extensionCtrl.areRoleCaseIssuesResolved());

        extensionCtrl.currentUserWorkflowRole = CVWorkflowSettingsManager.ROLE_PROGRAM;
        System.assert(extensionCtrl.areRoleCaseIssuesResolved());
    }

    /**
     * tests the functioning of CaseWorkflowExtensionControllerBase areAllIssuesResponded method
     */
    private static testmethod void test_areAllIssuesResponded() {
        Case testCase = (Case) (Database.query('SELECT ' + String.join(CVWorkflowManager.fieldsToLoadBase, ',') + ' FROM Case LIMIT 1')[0]);

        Test.startTest();
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(testCase);
        CaseWorkflowExtensionControllerBaseTestImpl extensionCtrl = new CaseWorkflowExtensionControllerBaseTestImpl(stdCtrl);
        CVCaseIssueCommentDisplayController componentController = new CVCaseIssueCommentDisplayController();
        extensionCtrl.init();

        componentController.pageController = extensionCtrl;
        extensionCtrl.currentUserWorkflowRole = CVWorkflowSettingsManager.ROLE_FINANCE;
        componentController.addIssue();
        componentController.cvcicNewIssue.Message__c = 'message';
        componentController.saveIssue();
        Test.stopTest();

        extensionCtrl.currentUserWorkflowRole = CVWorkflowSettingsManager.ROLE_LICENSEE;
        System.assert(!extensionCtrl.areAllIssuesResponded());

        List<CV_Case_Issue_Comment__c> cvcicCommentsList = new List<CV_Case_Issue_Comment__c>();
        for(CV_Case_Issue_Comment__c cvcicIssue: extensionCtrl.cvcicIssesList) {
            CV_Case_Issue_Comment__c newComment =  CVCaseIssueCommentManager.createCommentForUserId(CVWorkflowSettingsManager.ROLE_LICENSEE, testCase.Id);
            newComment.Related_Issue__c = cvcicIssue.Id;
            newComment.Message__c = 'message';

            cvcicCommentsList.add(newComment);
        }
        insert cvcicCommentsList;
        extensionCtrl.init();
        extensionCtrl.currentUserWorkflowRole = CVWorkflowSettingsManager.ROLE_LICENSEE;

        for(Integer i = 0; i < extensionCtrl.cvcicIssesList.size(); i++) {
            System.debug(LoggingLevel.DEBUG, 'case issue: ' + extensionCtrl.cvcicIssesList[i]);
            for(Integer j = 0; j < extensionCtrl.cvcicIssesList[i].Comments__r.size(); j++) {
                System.debug(LoggingLevel.DEBUG, 'case issue comment: ' + extensionCtrl.cvcicIssesList[i].Comments__r[j]);
            }
        }


        System.assert(extensionCtrl.areAllIssuesResponded());
    }

    /**
     * tests the functioning of approve for royalty submission process
     */
    private static testmethod void test_approve_noIssues() {
        Case testCase = (Case) (Database.query('SELECT ' + String.join(CVWorkflowManager.fieldsToLoadBase, ',') + ' FROM Case LIMIT 1')[0]);

        Test.startTest();
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(testCase);
        CaseWorkflowExtensionControllerBaseTestImpl extensionCtrl = new CaseWorkflowExtensionControllerBaseTestImpl(stdCtrl);
        CVCaseIssueCommentDisplayController componentController = new CVCaseIssueCommentDisplayController();

        componentController.pageController = extensionCtrl;
        extensionCtrl.currentUserWorkflowRole = CVWorkflowSettingsManager.ROLE_FINANCE;

        PageReference prResponse = extensionCtrl.approve();
        System.assert(prResponse != null);

        extensionCtrl.currentUserWorkflowRole = CVWorkflowSettingsManager.ROLE_PROGRAM;

        prResponse = extensionCtrl.approve();
        System.assert(prResponse != null);
        Test.stopTest();

        Case updatedTestCase = [SELECT Id, OwnerId, Status, Finance_Management_Workflow_Status__c, Program_Management_Workflow_Status__c, Comments__c FROM Case LIMIT 1];
        System.assertEquals(CaseManager.STATUS_ROLE_APPROVED, updatedTestCase.Finance_Management_Workflow_Status__c);
        System.assertEquals(CaseManager.STATUS_ROLE_APPROVED, updatedTestCase.Program_Management_Workflow_Status__c);
        System.assertEquals(CaseManager.STATUS_CLOSED_APPROVED, updatedTestCase.Status);
    }

    /**
     * tests the functioning of CaseWorkflowExtensionControllerBaseTestImpl approve for both internal roles, finance role has unresolved issues
     */
    private static testmethod void test_approve_withIssues() {
        Case testCase = (Case) (Database.query('SELECT ' + String.join(CVWorkflowManager.fieldsToLoadBase, ',') + ' FROM Case LIMIT 1')[0]);

        Test.startTest();
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(testCase);
        CaseWorkflowExtensionControllerBaseTestImpl extensionCtrl = new CaseWorkflowExtensionControllerBaseTestImpl(stdCtrl);
        CVCaseIssueCommentDisplayController componentController = new CVCaseIssueCommentDisplayController();


        componentController.pageController = extensionCtrl;
        extensionCtrl.currentUserWorkflowRole = CVWorkflowSettingsManager.ROLE_FINANCE;
        componentController.addIssue();
        componentController.cvcicNewIssue.Message__c = 'message';
        componentController.saveIssue();

        PageReference prResponse = extensionCtrl.approve();
        System.assert(prResponse == null);

        extensionCtrl.currentUserWorkflowRole = CVWorkflowSettingsManager.ROLE_PROGRAM;

        prResponse = extensionCtrl.approve();
        System.assert(prResponse != null);
        Test.stopTest();

        Case updatedTestCase = [SELECT Id, OwnerId, Status, Finance_Management_Workflow_Status__c, Program_Management_Workflow_Status__c, Comments__c FROM Case LIMIT 1];
        System.assertEquals(CaseManager.STATUS_ROLE_GE_ACTION_REQUIRED, updatedTestCase.Finance_Management_Workflow_Status__c);
        System.assertEquals(CaseManager.STATUS_ROLE_APPROVED, updatedTestCase.Program_Management_Workflow_Status__c);
        System.assertEquals(CaseManager.STATUS_GE_APPROVAL_PROCESS, updatedTestCase.Status);
    }

    /**
     * tests the functioning of CaseWorkflowExtensionControllerBaseTestImpl requestAdditionalInfo for both internal roles with no issues
     */
    private static testmethod void test_requestAdditionalInfo_noIssues() {
        Case testCase = (Case) (Database.query('SELECT ' + String.join(CVWorkflowManager.fieldsToLoadBase, ',') + ' FROM Case LIMIT 1')[0]);

        Test.startTest();
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(testCase);
        CaseWorkflowExtensionControllerBaseTestImpl extensionCtrl = new CaseWorkflowExtensionControllerBaseTestImpl(stdCtrl);
        CVCaseIssueCommentDisplayController componentController = new CVCaseIssueCommentDisplayController();

        componentController.pageController = extensionCtrl;
        extensionCtrl.currentUserWorkflowRole = CVWorkflowSettingsManager.ROLE_FINANCE;

        PageReference prResponse = extensionCtrl.requestAdditionalInfo();
        System.assert(prResponse == null);

        extensionCtrl.currentUserWorkflowRole = CVWorkflowSettingsManager.ROLE_PROGRAM;

        prResponse = extensionCtrl.requestAdditionalInfo();
        System.assert(prResponse == null);
        Test.stopTest();

        Case updatedTestCase = [SELECT Id, OwnerId, Status, Finance_Management_Workflow_Status__c, Program_Management_Workflow_Status__c, Comments__c FROM Case LIMIT 1];
        System.assertEquals(CaseManager.STATUS_ROLE_GE_ACTION_REQUIRED, updatedTestCase.Finance_Management_Workflow_Status__c);
        System.assertEquals(CaseManager.STATUS_ROLE_GE_ACTION_REQUIRED, updatedTestCase.Program_Management_Workflow_Status__c);
        System.assertEquals(CaseManager.STATUS_GE_APPROVAL_PROCESS, updatedTestCase.Status);
    }

    /**
     * tests the functioning of CaseWorkflowExtensionControllerBaseTestImpl requestAdditionalInfo for both internal roles with no issues
     */
    private static testmethod void test_requestAdditionalInfo_withIssues() {
        Case testCase = (Case) (Database.query('SELECT ' + String.join(CVWorkflowManager.fieldsToLoadBase, ',') + ' FROM Case LIMIT 1')[0]);

        Test.startTest();
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(testCase);
        CaseWorkflowExtensionControllerBaseTestImpl extensionCtrl = new CaseWorkflowExtensionControllerBaseTestImpl(stdCtrl);
        CVCaseIssueCommentDisplayController componentController = new CVCaseIssueCommentDisplayController();

        componentController.pageController = extensionCtrl;
        extensionCtrl.currentUserWorkflowRole = CVWorkflowSettingsManager.ROLE_FINANCE;
        componentController.addIssue();
        componentController.cvcicNewIssue.Message__c = 'message';
        componentController.saveIssue();

        PageReference prResponse = extensionCtrl.requestAdditionalInfo();
        System.assert(prResponse != null);

        extensionCtrl.currentUserWorkflowRole = CVWorkflowSettingsManager.ROLE_PROGRAM;

        prResponse = extensionCtrl.requestAdditionalInfo();
        System.assert(prResponse == null);
        Test.stopTest();

        Case updatedTestCase = [SELECT Id, OwnerId, Status, Finance_Management_Workflow_Status__c, Program_Management_Workflow_Status__c, Comments__c FROM Case LIMIT 1];
        System.assertEquals(CaseManager.STATUS_ROLE_LICENSEE_RESPONSE_NEEDED, updatedTestCase.Finance_Management_Workflow_Status__c);
        System.assertEquals(CaseManager.STATUS_ROLE_GE_ACTION_REQUIRED, updatedTestCase.Program_Management_Workflow_Status__c);
        System.assertEquals(CaseManager.STATUS_GE_APPROVAL_PROCESS, updatedTestCase.Status);
    }

    /**
     * tests the functioning of CaseWorkflowExtensionControllerBaseTestImpl reject for both internal roles
     */
    private static testmethod void test_reject_noIssues() {
        Case testCase = (Case) (Database.query('SELECT ' + String.join(CVWorkflowManager.fieldsToLoadBase, ',') + ' FROM Case LIMIT 1')[0]);

        Test.startTest();
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(testCase);
        CaseWorkflowExtensionControllerBaseTestImpl extensionCtrl = new CaseWorkflowExtensionControllerBaseTestImpl(stdCtrl);
        CVCaseIssueCommentDisplayController componentController = new CVCaseIssueCommentDisplayController();

        componentController.pageController = extensionCtrl;
        extensionCtrl.currentUserWorkflowRole = CVWorkflowSettingsManager.ROLE_FINANCE;

        PageReference prResponse = extensionCtrl.reject();
        System.assert(prResponse != null);

        extensionCtrl.currentUserWorkflowRole = CVWorkflowSettingsManager.ROLE_PROGRAM;

        prResponse = extensionCtrl.reject();
        System.assert(prResponse != null);
        Test.stopTest();

        Case updatedTestCase = [SELECT Id, OwnerId, Status, Finance_Management_Workflow_Status__c, Program_Management_Workflow_Status__c, Comments__c FROM Case LIMIT 1];
        System.assertEquals(CaseManager.STATUS_ROLE_REJECTED, updatedTestCase.Finance_Management_Workflow_Status__c);
        System.assertEquals(CaseManager.STATUS_ROLE_REJECTED, updatedTestCase.Program_Management_Workflow_Status__c);
        System.assertEquals(CaseManager.STATUS_CLOSED_REJECTED, updatedTestCase.Status);
    }

    /**
     * tests the functioning of CaseWorkflowExtensionControllerBaseTestImpl reSubmit without adding comments to issues
     */
    private static testmethod void test_reSubmit_IssuesNoComments() {
        Case testCase = (Case) (Database.query('SELECT ' + String.join(CVWorkflowManager.fieldsToLoadBase, ',') + ' FROM Case LIMIT 1')[0]);

        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(testCase);
        CaseWorkflowExtensionControllerBaseTestImpl extensionCtrl = new CaseWorkflowExtensionControllerBaseTestImpl(stdCtrl);
        CVCaseIssueCommentDisplayController componentController = new CVCaseIssueCommentDisplayController();

        componentController.pageController = extensionCtrl;
        extensionCtrl.currentUserWorkflowRole = CVWorkflowSettingsManager.ROLE_FINANCE;
        componentController.addIssue();
        componentController.cvcicNewIssue.Message__c = 'message';
        componentController.saveIssue();

        PageReference prResponse = extensionCtrl.requestAdditionalInfo();
        System.assert(prResponse != null);

        extensionCtrl.currentUserWorkflowRole = CVWorkflowSettingsManager.ROLE_PROGRAM;

        prResponse = extensionCtrl.approve();
        System.assert(prResponse != null);

        Test.startTest();
        extensionCtrl.currentUserWorkflowRole = CVWorkflowSettingsManager.ROLE_LICENSEE;
        prResponse = extensionCtrl.reSubmit();
        System.assert(prResponse == null);
        Test.stopTest();

        Case updatedTestCase = [SELECT Id, OwnerId, Status, Finance_Management_Workflow_Status__c, Program_Management_Workflow_Status__c, Comments__c FROM Case LIMIT 1];
        System.assertEquals(CaseManager.STATUS_ROLE_LICENSEE_RESPONSE_NEEDED, updatedTestCase.Finance_Management_Workflow_Status__c);
        System.assertEquals(CaseManager.STATUS_ROLE_APPROVED, updatedTestCase.Program_Management_Workflow_Status__c);
        System.assertEquals(CaseManager.STATUS_LICENSEE_RESPONSE_NEEDED, updatedTestCase.Status);
    }

    /**
     * tests the functioning of CaseWorkflowExtensionControllerBaseTestImpl reSubmit with adding comments to issues
     */
    private static testmethod void test_reSubmit_IssuesWithComments() {
        Case testCase = (Case) (Database.query('SELECT ' + String.join(CVWorkflowManager.fieldsToLoadBase, ',') + ' FROM Case LIMIT 1')[0]);

        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(testCase);
        CaseWorkflowExtensionControllerBaseTestImpl extensionCtrl = new CaseWorkflowExtensionControllerBaseTestImpl(stdCtrl);
        CVCaseIssueCommentDisplayController componentController = new CVCaseIssueCommentDisplayController();

        componentController.pageController = extensionCtrl;
        extensionCtrl.currentUserWorkflowRole = CVWorkflowSettingsManager.ROLE_FINANCE;
        componentController.addIssue();
        componentController.cvcicNewIssue.Message__c = 'message';
        componentController.saveIssue();

        PageReference prResponse = extensionCtrl.requestAdditionalInfo();
        System.assert(prResponse != null);

        extensionCtrl.currentUserWorkflowRole = CVWorkflowSettingsManager.ROLE_PROGRAM;

        prResponse = extensionCtrl.approve();
        System.assert(prResponse != null);

        Test.startTest();
        extensionCtrl.currentUserWorkflowRole = CVWorkflowSettingsManager.ROLE_LICENSEE;
        componentController.cvcicNewCommentIssueId = extensionCtrl.cvcicIssesList[0].Id;
        componentController.addComment();
        componentController.cvcicNewComment.Message__c = 'message';
        componentController.saveComment();
        prResponse = extensionCtrl.reSubmit();
        System.assert(prResponse != null);
        Test.stopTest();
        update new Case(Id = testCase.Id
                        , Status = CaseManager.STATUS_GE_APPROVAL_PROCESS );
        Case updatedTestCase = [SELECT Id, OwnerId, Status, Finance_Management_Workflow_Status__c, Program_Management_Workflow_Status__c, Comments__c FROM Case LIMIT 1];
        System.assertEquals(CaseManager.STATUS_ROLE_GE_ACTION_REQUIRED, updatedTestCase.Finance_Management_Workflow_Status__c);
        System.assertEquals(CaseManager.STATUS_ROLE_GE_ACTION_REQUIRED, updatedTestCase.Program_Management_Workflow_Status__c);
        System.assertEquals(CaseManager.STATUS_GE_APPROVAL_PROCESS, updatedTestCase.Status);
    }

}