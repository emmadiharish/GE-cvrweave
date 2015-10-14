/******************************************************************************************************************************
* Name - CaseInternalLegalWorkflowCtrlExtTest
* @description
* Class contains all unit tests for CaseInternalLegalWorkflowCtrlExt
* Modification Log :
* ---------------------------------------------------------------------------
* Developer Date Description
* ---------------------------------------------------------------------------
* Zoran Zunko 07/22/2015 Created.
******************************************************************************************************************************/
@isTest public class CaseInternalLegalWorkflowCtrlExtTest {

    /**
     * Class wide entry point for creation of test data.
     */
    @testSetup static void dataSetup() {

        List<sObject> workflowConfiguration = Test.loadData(CVWorkflowConfiguration__c.sObjectType, 'TestData_CV_Wokrflow_Configuration');

        List<Account> accounts = TestDataFactory.createAccounts('testAcc', UserInfo.getUserId(), 1);
        insert accounts;

        List<Contact> contacts = TestDataFactory.createContacts('testCon', UserInfo.getUserId(), accounts[0].Id, 1);
        insert contacts;

        Case testCase = TestDataFactory.createInternalLegalCase('IL Case', UserInfo.getUserId(), accounts[0].Id, contacts[0].Id);
        insert testCase;
    }

    /**
     * tests the functioning of CaseInternalLegalWorkflowCtrlExt constructor
     */
    private static testmethod void test_pageLoad() {
        Case testCase = [SELECT Id, OwnerId, Status, Comments__c FROM Case LIMIT 1];

        Test.startTest();
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(testCase);
        CaseInternalLegalWorkflowCtrlExt extensionCtrl = new CaseInternalLegalWorkflowCtrlExt(stdCtrl);
        CVCaseIssueCommentDisplayController componentController = new CVCaseIssueCommentDisplayController();
        componentController.pageController = extensionCtrl;
        Test.stopTest();

        System.assertEquals(testCase, extensionCtrl.cLicenseeCase);
    }
}