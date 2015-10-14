/******************************************************************************************************************************
* Name - CaseProductChangeWorkflowCtrlExtTest
* @description
* Class contains all unit tests for CaseProductChangeWorkflowCtrlExt
* Modification Log :
* ---------------------------------------------------------------------------
* Developer Date Description
* ---------------------------------------------------------------------------
* Zoran Zunko 06/23/2015 Created.
******************************************************************************************************************************/
@isTest public class CaseProductChangeWorkflowCtrlExtTest {

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

        Case testCase = TestDataFactory.createProductChangeCase('PC Case', users[0].Id, accounts[0].Id, contacts[0].Id);
        insert testCase;
    }

    /**
     * tests the functioning of CaseProductChangeWorkflowCtrlExtTest constructor
     */
    private static testmethod void test_pageLoad() {
        Case testCase = (Case) (Database.query('SELECT ' + String.join(CVWorkflowManager.fieldsToLoadBase, ',') + ' FROM Case LIMIT 1')[0]);

        Test.startTest();
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(testCase);
        CaseProductChangeWorkflowCtrlExt extensionCtrl = new CaseProductChangeWorkflowCtrlExt(stdCtrl);
        CVCaseIssueCommentDisplayController componentController = new CVCaseIssueCommentDisplayController();
        componentController.pageController = extensionCtrl;
        Test.stopTest();

        System.assertEquals(testCase, extensionCtrl.cLicenseeCase);
    }

    /**
     * tests the functioning of CaseProductChangeWorkflowCtrlExtTest addShippingInfoLicensee
     */
    private static testmethod void test_addShippingInfoLicensee() {
        Case testCase = (Case) (Database.query('SELECT ' + String.join(CVWorkflowManager.fieldsToLoadBase, ',') + ' FROM Case LIMIT 1')[0]);

        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(testCase);
        CaseProductChangeWorkflowCtrlExt extensionCtrl = new CaseProductChangeWorkflowCtrlExt(stdCtrl);
        CVCaseIssueCommentDisplayController componentController = new CVCaseIssueCommentDisplayController();
        componentController.pageController = extensionCtrl;
        extensionCtrl.currentUserWorkflowRole = CVWorkflowSettingsManager.ROLE_LICENSEE;

        Test.startTest();
        extensionCtrl.addShippingInfoLicensee();
        System.assert(extensionCtrl.showShippingPopoupLicensee);
        System.assert(extensionCtrl.shippingInfoLicensee != null);

        extensionCtrl.shippingInfoLicensee.Number_Of_Packages__c = 3;
        extensionCtrl.shippingInfoLicensee.Estimated_Delivery_Date__c = Date.today();
        extensionCtrl.shippingInfoLicensee.Ship_Date__c = Date.today();
        extensionCtrl.shippingInfoLicensee.Shipper__c = 'Shipper';
        extensionCtrl.shippingInfoLicensee.Shipper_Tracking_No__c = 'Shipper_Tracking_No__c';
        extensionCtrl.shippingInfoLicensee.Shipping_Type__c = 'Shipping_Type__c';

        extensionCtrl.saveShippingInfoLicensee();
        System.assert(!extensionCtrl.showShippingPopoupLicensee);

        Test.stopTest();
        System.assertEquals(CaseManager.STATUS_SAMPLES_SHIPPED, extensionCtrl.cLicenseeCase.Status);

    }

    /**
     * tests the functioning of CaseProductChangeWorkflowCtrlExtTest confirmShippingInfoWfRole
     */
    private static testmethod void test_confirmShippingInfoWfRole() {
        Case testCase = (Case) (Database.query('SELECT ' + String.join(CVWorkflowManager.fieldsToLoadBase, ',') + ' FROM Case LIMIT 1')[0]);

        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(testCase);
        CaseProductChangeWorkflowCtrlExt extensionCtrl = new CaseProductChangeWorkflowCtrlExt(stdCtrl);
        CVCaseIssueCommentDisplayController componentController = new CVCaseIssueCommentDisplayController();
        componentController.pageController = extensionCtrl;
        extensionCtrl.currentUserWorkflowRole = CVWorkflowSettingsManager.ROLE_LICENSEE;

        extensionCtrl.addShippingInfoLicensee();
        extensionCtrl.shippingInfoLicensee.Number_Of_Packages__c = 3;
        extensionCtrl.shippingInfoLicensee.Estimated_Delivery_Date__c = Date.today();
        extensionCtrl.shippingInfoLicensee.Ship_Date__c = Date.today();
        extensionCtrl.shippingInfoLicensee.Shipper__c = 'Shipper';
        extensionCtrl.shippingInfoLicensee.Shipper_Tracking_No__c = 'Shipper_Tracking_No__c';
        extensionCtrl.shippingInfoLicensee.Shipping_Type__c = 'Shipping_Type__c';
        extensionCtrl.saveShippingInfoLicensee();

        testCase.Status = CaseManager.STATUS_GE_APPROVAL_PROCESS;
        update testCase;

        Test.startTest();
        extensionCtrl.currentUserWorkflowRole = CVWorkflowSettingsManager.ROLE_PROGRAM;
        extensionCtrl.init();

        System.assert(extensionCtrl.getShowShippingPopoupWfRole());
        System.assert(extensionCtrl.productSampleShipInfoConfirmationCurrentRole != null);
        System.assert(!extensionCtrl.productSampleShipInfoConfirmationCurrentRole.Reception_Confirmed__c);
        extensionCtrl.confirmShippingInfoWfRole();

        System.assert(!extensionCtrl.getShowShippingPopoupWfRole());
        System.assert(extensionCtrl.productSampleShipInfoConfirmationCurrentRole.Reception_Confirmed__c);
        Test.stopTest();
    }

    /**
     * tests the functioning of CaseProductChangeWorkflowCtrlExtTest confirmShippingInfoWfRole
     */
    private static testmethod void test_other() {
        Case testCase = (Case) (Database.query('SELECT ' + String.join(CVWorkflowManager.fieldsToLoadBase, ',') + ' FROM Case LIMIT 1')[0]);

        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(testCase);
        CaseProductChangeWorkflowCtrlExt extensionCtrl = new CaseProductChangeWorkflowCtrlExt(stdCtrl);
        CVCaseIssueCommentDisplayController componentController = new CVCaseIssueCommentDisplayController();
        componentController.pageController = extensionCtrl;
        extensionCtrl.currentUserWorkflowRole = CVWorkflowSettingsManager.ROLE_LICENSEE;

        Test.startTest();
        extensionCtrl.addShippingInfoLicensee();
        extensionCtrl.cancelShippingInfoLicensee();
        System.assert(!extensionCtrl.showShippingPopoupLicensee);
        extensionCtrl.currentUserWorkflowRole = CVWorkflowSettingsManager.ROLE_PROGRAM;
        extensionCtrl.init();
        System.assert(extensionCtrl.cancelShippingInfoWfRole() != null);

        Test.stopTest();
    }
}