/******************************************************************************************************************************
* Name - CaseCVWorkflowGatekeeperExtCtrlTest
* @description
* Class contains all unit tests for CaseCVWorkflowGatekeeperExtController
* Modification Log :
* ---------------------------------------------------------------------------
* Developer Date Description
* ---------------------------------------------------------------------------
* Zoran Zunko 06/28/2015 Created.
******************************************************************************************************************************/
@isTest public class CaseCVWorkflowGatekeeperExtCtrlTest {

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
     * tests the functioning of CaseCVWorkflowGatekeeperExtController constructor and initialization
     */
    private static testmethod void test_pageLoad() {

        Case testCase = (Case) (Database.query('SELECT ' + String.join(CVWorkflowManager.fieldsToLoadBase, ',') + ' FROM Case LIMIT 1')[0]);

        Test.startTest();
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(testCase);
        CaseCVWorkflowGatekeeperExtController extensionCtrl = new CaseCVWorkflowGatekeeperExtController(stdCtrl);

        extensionCtrl.init();
        Test.stopTest();

        System.assertEquals(4, extensionCtrl.cvwrwRoleList.size());
    }

    /**
     * tests the functioning of CaseCVWorkflowGatekeeperExtController constructor and initialization when status is not valid for gatekeeping
     */
    private static testmethod void test_pageLoad_otherStatus() {

        Case testCase = (Case) (Database.query('SELECT ' + String.join(CVWorkflowManager.fieldsToLoadBase, ',') + ' FROM Case LIMIT 1')[0]);
        testCase.Status = CaseManager.STATUS_SAMPLES_SHIPPED;
        update testCase;

        Test.startTest();
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(testCase);
        CaseCVWorkflowGatekeeperExtController extensionCtrl = new CaseCVWorkflowGatekeeperExtController(stdCtrl);

        extensionCtrl.init();
        Test.stopTest();

        System.assertEquals(4, extensionCtrl.cvwrwRoleList.size());
    }

    /**
     * tests the functioning of CaseCVWorkflowGatekeeperExtController save method
     */
    private static testmethod void test_save() {

        Case testCase = (Case) (Database.query('SELECT ' + String.join(CVWorkflowManager.fieldsToLoadBase, ',') + ' FROM Case LIMIT 1')[0]);

        Test.startTest();
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(testCase);
        CaseCVWorkflowGatekeeperExtController extensionCtrl = new CaseCVWorkflowGatekeeperExtController(stdCtrl);

        extensionCtrl.init();
        for(CaseCVWorkflowGatekeeperExtController.CVWorkflowRoleWrapper cvwfrw : extensionCtrl.cvwrwRoleList) {

            cvwfrw.participating = true;
        }

        System.assert(extensionCtrl.save() != null);
        Test.stopTest();

        testCase = [SELECT Participating_Roles__c FROM Case WHERE Id = :testCase.Id];
        System.assertEquals(4, testCase.Participating_Roles__c.split(',').size());
    }

     /**
     * tests the functioning of CaseCVWorkflowGatekeeperExtController other methods
     */
    private static testmethod void test_other() {

        Case testCase = (Case) (Database.query('SELECT ' + String.join(CVWorkflowManager.fieldsToLoadBase, ',') + ' FROM Case LIMIT 1')[0]);

        Test.startTest();
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(testCase);
        CaseCVWorkflowGatekeeperExtController extensionCtrl = new CaseCVWorkflowGatekeeperExtController(stdCtrl);

        extensionCtrl.init();

        System.assert(extensionCtrl.fieldsToLoad != null);

        System.assert(extensionCtrl.cancel() != null);
        Test.stopTest();
    }
}