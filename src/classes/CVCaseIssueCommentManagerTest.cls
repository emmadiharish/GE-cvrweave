/******************************************************************************************************************************
* Name - CVCaseIssueCommentManagerTest
* @description
* Class contains all unit tests for CVCaseIssueCommentManager
* Modification Log :
* ---------------------------------------------------------------------------
* Developer Date Description
* ---------------------------------------------------------------------------
* Zoran Zunko 05/13/2015 Created.
******************************************************************************************************************************/
@isTest public class CVCaseIssueCommentManagerTest {

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

        List<CV_Case_Issue_Comment__c> issues = TestDataFactory.createCVCaseIssues(testCase.Id, 3);
        insert issues;

        List<CV_Case_Issue_Comment__c> issueComments = new List<CV_Case_Issue_Comment__c>();
        for(CV_Case_Issue_Comment__c cvcic : issues) {
            issueComments.addAll(TestDataFactory.createCVCaseIssueComments(testCase.Id, cvcic.Id, 3));
        }
        insert issueComments;
    }

    /**
     * tests the functioning of createIssueForUserId() method
     */
    private static testmethod void test_createIssueForUserId_nonlicensee() {
        Case testCase = [SELECT Id, OwnerId FROM Case LIMIT 1];

        Test.startTest();
        CV_Case_Issue_Comment__c cvciTestIssue = CVCaseIssueCommentManager.createIssueForUserId(CVWorkflowSettingsManager.ROLE_FINANCE, testCase.Id);
        Test.stopTest();

        System.assertEquals(cvciTestIssue.RecordTypeId, Cache.RecordTypeId(CVCaseIssueCommentManager.RT_ISSUE));
        System.assertEquals(cvciTestIssue.Resolved__c, false);
        System.assertEquals(cvciTestIssue.Type__c, CVCaseIssueCommentManager.TYPE_ISSUE);
        System.assertEquals(cvciTestIssue.Case__c, testCase.Id);
        System.assertEquals(cvciTestIssue.GE_Created_By__c, CVWorkflowSettingsManager.ROLE_FINANCE);
        System.assertEquals(cvciTestIssue.Created_By__c, CVCaseIssueCommentManager.CREATED_BY_GE);
    }

    /**
     * tests the functioning of createIssueForUserId() method
     */
    private static testmethod void test_createIssueForUserId_licensee() {
        Case testCase = [SELECT Id, OwnerId FROM Case LIMIT 1];

        Test.startTest();
        CV_Case_Issue_Comment__c cvciTestIssue = CVCaseIssueCommentManager.createIssueForUserId(CVWorkflowSettingsManager.ROLE_LICENSEE, testCase.Id);
        Test.stopTest();

        System.assertEquals(cvciTestIssue.RecordTypeId, Cache.RecordTypeId(CVCaseIssueCommentManager.RT_ISSUE));
        System.assertEquals(cvciTestIssue.Resolved__c, false);
        System.assertEquals(cvciTestIssue.Type__c, CVCaseIssueCommentManager.TYPE_ISSUE);
        System.assertEquals(cvciTestIssue.Case__c, testCase.Id);
        System.assertEquals(cvciTestIssue.GE_Created_By__c, CVWorkflowSettingsManager.ROLE_LICENSEE);
        System.assertEquals(cvciTestIssue.Created_By__c, CVCaseIssueCommentManager.CREATED_BY_LICENSEE);
    }

    /**
     * tests the functioning of createIssueForUserId() method
     */
    private static testmethod void test_createCommentForUserId_nonicensee() {
        Case testCase = [SELECT Id, OwnerId FROM Case LIMIT 1];

        Test.startTest();
        CV_Case_Issue_Comment__c cvciTestIssue = CVCaseIssueCommentManager.createCommentForUserId(CVWorkflowSettingsManager.ROLE_FINANCE, testCase.Id);
        Test.stopTest();

        System.assertEquals(cvciTestIssue.RecordTypeId, Cache.RecordTypeId(CVCaseIssueCommentManager.RT_COMMENT));
        System.assertEquals(cvciTestIssue.Resolved__c, false);
        System.assertEquals(cvciTestIssue.Type__c, CVCaseIssueCommentManager.TYPE_COMMENT);
        System.assertEquals(cvciTestIssue.Case__c, testCase.Id);
        System.assertEquals(cvciTestIssue.GE_Created_By__c, CVWorkflowSettingsManager.ROLE_FINANCE);
        System.assertEquals(cvciTestIssue.Created_By__c, CVCaseIssueCommentManager.CREATED_BY_GE);
    }

    /**
     * tests the functioning of createIssueForUserId() method
     */
    private static testmethod void test_createCommentForUserId_licensee() {
        Case testCase = [SELECT Id, OwnerId FROM Case LIMIT 1];

        Test.startTest();
        CV_Case_Issue_Comment__c cvciTestIssue = CVCaseIssueCommentManager.createCommentForUserId(CVWorkflowSettingsManager.ROLE_LICENSEE, testCase.Id);
        Test.stopTest();

        System.assertEquals(cvciTestIssue.RecordTypeId, Cache.RecordTypeId(CVCaseIssueCommentManager.RT_COMMENT));
        System.assertEquals(cvciTestIssue.Resolved__c, false);
        System.assertEquals(cvciTestIssue.Type__c, CVCaseIssueCommentManager.TYPE_COMMENT);
        System.assertEquals(cvciTestIssue.Case__c, testCase.Id);
        System.assertEquals(cvciTestIssue.GE_Created_By__c, CVWorkflowSettingsManager.ROLE_LICENSEE);
        System.assertEquals(cvciTestIssue.Created_By__c, CVCaseIssueCommentManager.CREATED_BY_LICENSEE);
    }

    /**
     * tests the functioning of getIssuesForCaseId() method
     */
    private static testmethod void test_getIssuesForCaseId() {
        Case testCase = [SELECT Id, OwnerId FROM Case LIMIT 1];

        Test.startTest();
        List<CV_Case_Issue_Comment__c> cvciTestIssues = CVCaseIssueCommentManager.getIssuesForCaseId(testCase.Id);
        Test.stopTest();

        System.assertEquals(3, cvciTestIssues.size());
        for(CV_Case_Issue_Comment__c cvciTestIssue : cvciTestIssues) {
            System.assert(3 == cvciTestIssue.Comments__r.size());
        }
    }

    /**
     * tests the functioning of markIssueResolved() method
     */
    private static testmethod void test_markIssueResolved() {
        CV_Case_Issue_Comment__c cvciTestIssue = [SELECT Id FROM CV_Case_Issue_Comment__c WHERE Type__c = :CVCaseIssueCommentManager.TYPE_ISSUE LIMIT 1];

        Test.startTest();
        CV_Case_Issue_Comment__c cvciTestIssueResolved = CVCaseIssueCommentManager.markIssueResolved(cvciTestIssue.Id);
        Test.stopTest();

        System.assertEquals(cvciTestIssue.Id, cvciTestIssueResolved.Id);
        System.assert(cvciTestIssueResolved.Resolved__c);
    }
}