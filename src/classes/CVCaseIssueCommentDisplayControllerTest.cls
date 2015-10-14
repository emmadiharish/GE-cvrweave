/******************************************************************************************************************************
* Name - CVCaseIssueCommentDisplayControllerTest
* @description
* Class contains all unit tests for CVCaseIssueCommentDisplayController
* Modification Log :
* ---------------------------------------------------------------------------
* Developer Date Description
* ---------------------------------------------------------------------------
* Zoran Zunko 05/14/2015 Created.
******************************************************************************************************************************/
@isTest public class CVCaseIssueCommentDisplayControllerTest {

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
* tests the functioning of CVCaseIssueCommentDisplayController constructor
*/
private static testmethod void test_pageLoad() {
Case testCase = [SELECT Id, OwnerId, Status, Finance_Management_Workflow_Status__c, Program_Management_Workflow_Status__c, Comments__c FROM Case LIMIT 1];

Test.startTest();
ApexPages.StandardController stdCtrl = new ApexPages.StandardController(testCase);
CaseWorkflowExtensionControllerBaseTest.CaseWorkflowExtensionControllerBaseTestImpl extensionCtrl =
new CaseWorkflowExtensionControllerBaseTest.CaseWorkflowExtensionControllerBaseTestImpl(stdCtrl);
CVCaseIssueCommentDisplayController componentController = new CVCaseIssueCommentDisplayController();

componentController.pageController = extensionCtrl;
Test.stopTest();

System.assert(!componentController.displayPopUp);
System.assertEquals(0, componentController.pageController.cvcicIssesList.size());
}

/**
* tests the functioning of CVCaseIssueCommentDisplayController adding new issue
*/
private static testmethod void test_addIssue_saveIssue() {
Case testCase = [SELECT Id, OwnerId, Status, Finance_Management_Workflow_Status__c, Program_Management_Workflow_Status__c, Comments__c FROM Case LIMIT 1];


Test.startTest();
ApexPages.StandardController stdCtrl = new ApexPages.StandardController(testCase);
CaseWorkflowExtensionControllerBaseTest.CaseWorkflowExtensionControllerBaseTestImpl extensionCtrl =
new CaseWorkflowExtensionControllerBaseTest.CaseWorkflowExtensionControllerBaseTestImpl(stdCtrl);
CVCaseIssueCommentDisplayController componentController = new CVCaseIssueCommentDisplayController();

componentController.pageController = extensionCtrl;
extensionCtrl.currentUserWorkflowRole = CVWorkflowSettingsManager.ROLE_FINANCE;
componentController.addIssue();
componentController.cvcicNewIssue.Message__c = 'message';
componentController.saveIssue();

Test.stopTest();

System.assertEquals(1, componentController.pageController.cvcicIssesList.size());
}

/**
* tests the functioning of CVCaseIssueCommentDisplayController adding new comment
*/
private static testmethod void test_addComment_saveComment() {
Case testCase = [SELECT Id, OwnerId, Status, Finance_Management_Workflow_Status__c, Program_Management_Workflow_Status__c, Comments__c FROM Case LIMIT 1];

Test.startTest();
ApexPages.StandardController stdCtrl = new ApexPages.StandardController(testCase);
CaseWorkflowExtensionControllerBaseTest.CaseWorkflowExtensionControllerBaseTestImpl extensionCtrl =
new CaseWorkflowExtensionControllerBaseTest.CaseWorkflowExtensionControllerBaseTestImpl(stdCtrl);
CVCaseIssueCommentDisplayController componentController = new CVCaseIssueCommentDisplayController();

componentController.pageController = extensionCtrl;
extensionCtrl.currentUserWorkflowRole = CVWorkflowSettingsManager.ROLE_FINANCE;
componentController.addIssue();
componentController.cvcicNewIssue.Message__c = 'message';
componentController.saveIssue();

componentController.cvcicNewCommentIssueId = componentController.pageController.cvcicIssesList[0].Id;
componentController.addComment();
componentController.cvcicNewComment.Message__c = 'message';
componentController.saveComment();

Test.stopTest();

System.assertEquals(1, componentController.pageController.cvcicIssesList[0].Comments__r.size());
}

/**
* tests the functioning of CVCaseIssueCommentDisplayController markedResolved method
*/
private static testmethod void test_markedResolved() {
Case testCase = [SELECT Id, OwnerId, Status, Finance_Management_Workflow_Status__c, Program_Management_Workflow_Status__c, Comments__c FROM Case LIMIT 1];

Test.startTest();
ApexPages.StandardController stdCtrl = new ApexPages.StandardController(testCase);
CaseWorkflowExtensionControllerBaseTest.CaseWorkflowExtensionControllerBaseTestImpl extensionCtrl =
new CaseWorkflowExtensionControllerBaseTest.CaseWorkflowExtensionControllerBaseTestImpl(stdCtrl);
CVCaseIssueCommentDisplayController componentController = new CVCaseIssueCommentDisplayController();

componentController.pageController = extensionCtrl;
extensionCtrl.currentUserWorkflowRole = CVWorkflowSettingsManager.ROLE_FINANCE;
componentController.addIssue();
componentController.cvcicNewIssue.Message__c = 'message';
componentController.saveIssue();

componentController.cvcicMarkResolvedIssueId = componentController.pageController.cvcicIssesList[0].Id;
componentController.markedResolved();

Test.stopTest();

System.assert(componentController.pageController.cvcicIssesList[0].Resolved__c);
}

/**
* tests the functioning of CVCaseIssueCommentDisplayController markedResolved method
*/
private static testmethod void test_cancel() {
Case testCase = [SELECT Id, OwnerId, Status, Finance_Management_Workflow_Status__c, Program_Management_Workflow_Status__c, Comments__c FROM Case LIMIT 1];

Test.startTest();
ApexPages.StandardController stdCtrl = new ApexPages.StandardController(testCase);
CaseWorkflowExtensionControllerBaseTest.CaseWorkflowExtensionControllerBaseTestImpl extensionCtrl =
new CaseWorkflowExtensionControllerBaseTest.CaseWorkflowExtensionControllerBaseTestImpl(stdCtrl);
CVCaseIssueCommentDisplayController componentController = new CVCaseIssueCommentDisplayController();

componentController.pageController = extensionCtrl;
componentController.addIssue();
System.assert(componentController.displayPopUp);

componentController.cancel();

Test.stopTest();

System.assert(!componentController.displayPopUp);
}
}