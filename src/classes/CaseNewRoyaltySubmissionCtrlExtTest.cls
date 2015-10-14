/******************************************************************************************************************************
* Name - CaseNewRoyaltySubmissionCtrlExtTest
* @description
* Class contains all unit tests for CaseNewRoyaltySubmissionControllerExt
* Modification Log :
* ---------------------------------------------------------------------------
* Developer Date Description
* ---------------------------------------------------------------------------
* Zoran Zunko 05/14/2015 Created.
******************************************************************************************************************************/
@isTest public class CaseNewRoyaltySubmissionCtrlExtTest {

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

        List<Contract> contracts = TestDataFactory.createContracts(accounts, 'testCont', 1);
        insert contracts;

        List<Product2> products = TestDataFactory.createProducts(accounts, 'Prod', 10);

        for(Product2 prod : products) {

            prod.Contract__c = contracts[0].Id;
        }
        insert products;
    }

    /**
     * tests the functioning of CaseNewRoyaltySubmissionControllerExt constructor
     */
    private static testmethod void test_pageLoad() {

        User cvPartnerUser = [SELECT Id FROM User WHERE Profile.Name = :TestDataFactory.CV_PARTNER_COMMUNITY_PROFILE_NAME AND UserName LIKE '%@test.dev' LIMIT 1];
        Case testCase = new Case();
        PageReference prTestPage = Page.CaseNewRoyaltySubmission;
        Test.setCurrentPage(prTestPage);

        Test.startTest();
        System.runAs(cvPartnerUser) {

            ApexPages.StandardController stdCtrl = new ApexPages.StandardController(testCase);
            CaseNewRoyaltySubmissionControllerExt extensionCtrl = new CaseNewRoyaltySubmissionControllerExt(stdCtrl);

            System.assertEquals(extensionCtrl.NUMBER_OF_ATTACHMENTS, extensionCtrl.attCaseAttachmentsListDisp.size());
            System.assertEquals(3, extensionCtrl.NUMBER_OF_ATTACHMENTS);
            System.assertEquals(1, ApexPages.getMessages().size());
        }

        Test.stopTest();
    }

    /**
     * tests the functioning of CaseNewRoyaltySubmissionControllerExt proeprties
     */
    private static testmethod void test_properties() {
        Case testCase = new Case();
        PageReference prTestPage = Page.CaseNewRoyaltySubmission;
        Test.setCurrentPage(prTestPage);

        Test.startTest();
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(testCase);
        CaseNewRoyaltySubmissionControllerExt extensionCtrl = new CaseNewRoyaltySubmissionControllerExt(stdCtrl);
        User uTestUser = extensionCtrl.getuLicenseeUser();
        Test.stopTest();

        System.assertEquals(UserInfo.getUserId(), uTestUser.Id);
    }

    /**
     * tests the functioning of CaseNewRoyaltySubmissionControllerExt save method wihtout any attachments
     */
    private static testmethod void test_save_noFile() {
        User cvPartnerUser = [SELECT Id FROM User WHERE Profile.Name = :TestDataFactory.CV_PARTNER_COMMUNITY_PROFILE_NAME AND UserName LIKE '%@test.dev' LIMIT 1];
        Case testCase = new Case();
        PageReference prTestPage = Page.CaseNewRoyaltySubmission;
        Test.setCurrentPage(prTestPage);

        Test.startTest();
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(testCase);
        CaseNewRoyaltySubmissionControllerExt extensionCtrl = new CaseNewRoyaltySubmissionControllerExt(stdCtrl);
        extensionCtrl.uLicenseeUser = CommunityUserManager.getContactDetailsForCommunityUser(cvPartnerUser.Id);
        PageReference prResponse = extensionCtrl.save();
        Test.stopTest();

        System.assert(null == prResponse);
    }

    /**
     * tests the functioning of CaseNewRoyaltySubmissionControllerExt save method with one attachment
     */
    private static testmethod void test_save_fileAttached() {
        User cvPartnerUser = [SELECT Id FROM User WHERE Profile.Name = :TestDataFactory.CV_PARTNER_COMMUNITY_PROFILE_NAME AND UserName LIKE '%@test.dev' LIMIT 1];
        Case testCase = new Case();
        PageReference prTestPage = Page.CaseNewRoyaltySubmission;
        Test.setCurrentPage(prTestPage);

        CaseNewRoyaltySubmissionControllerExt extensionCtrl;
        PageReference prResponse;

        Test.startTest();
        System.runAs(cvPartnerUser) {

            ApexPages.StandardController stdCtrl = new ApexPages.StandardController(testCase);
            extensionCtrl = new CaseNewRoyaltySubmissionControllerExt(stdCtrl);
            extensionCtrl.uLicenseeUser = CommunityUserManager.getContactDetailsForCommunityUser(cvPartnerUser.Id);
            extensionCtrl.attCaseAttachmentsListDisp[0].Body = Blob.valueOf('file');
            extensionCtrl.attCaseAttachmentsListDisp[0].Name = 'file.txt';
            extensionCtrl.cNewCase.Royalty_Period_Start_Date__c = System.today().addMonths(-1).toStartOfMonth();
            extensionCtrl.cNewCase.Royalty_Period_End_Date__c = System.today().toStartOfMonth().addDays(-1);
            prResponse = extensionCtrl.save();
            System.assert(prResponse != null);
        }

        Test.stopTest();

        Case newCase = [SELECT Id, Royalty_Period_Start_Date__c, Royalty_Period_End_Date__c, OwnerId FROM Case LIMIT 1];

        System.assert(prResponse.getUrl().contains(extensionCtrl.cNewCase.Id));
        System.assertEquals(extensionCtrl.cNewCase.Id, newCase.Id);
        System.assertEquals(extensionCtrl.cNewCase.Royalty_Period_Start_Date__c, newCase.Royalty_Period_Start_Date__c);
        System.assertEquals(extensionCtrl.cNewCase.Royalty_Period_End_Date__c, newCase.Royalty_Period_End_Date__c);
    }
}