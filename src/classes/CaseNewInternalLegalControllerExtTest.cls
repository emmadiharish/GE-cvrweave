/******************************************************************************************************************************
* Name - CaseNewInternalLegalControllerExtTest
* @description
* Class contains all unit tests for CaseNewInternalLegalControllerExt
* Modification Log :
* ---------------------------------------------------------------------------
* Developer Date Description
* ---------------------------------------------------------------------------
* Zoran Zunko 07/22/2015 Created.
******************************************************************************************************************************/
@isTest public class CaseNewInternalLegalControllerExtTest {

    /**
     * Class wide entry point for creation of test data.
     */
    @testSetup static void dataSetup() {

        List<sObject> workflowConfiguration = Test.loadData(CVWorkflowConfiguration__c.sObjectType, 'TestData_CV_Wokrflow_Configuration');
        List<sObject> categoryData = Test.loadData(CV_Product_Category__c.sObjectType, 'TestData_CV_Categories');

        List<Account> accounts = TestDataFactory.createAccounts('testAcc', UserInfo.getUserId(), 1);
        insert accounts;

        List<Product2> products = TestDataFactory.createProducts(accounts, 'Prod', 10);
        insert products;

        List<Contract> contracts = TestDataFactory.createContracts(accounts, 'testCont', 1);
        insert contracts;

        List<Contact> contacts = TestDataFactory.createContacts('testCon', UserInfo.getUserId(), accounts[0].Id, 1);
        insert contacts;

        List<User> users = TestDataFactory.createCommunityUsers('cp', TestDataFactory.CV_PARTNER_COMMUNITY_PROFILE_NAME, new List<Id>{
                contacts[0].Id
        });
        insert users;
    }

    /**
     * tests the functioning of CaseNewInternalLegalControllerExt constructor
     */
    private static testmethod void test_pageLoad() {


        User cvPartnerUser =
        [
                SELECT Id, ContactId, Contact.AccountId
                FROM User
                WHERE Profile.Name = :TestDataFactory.CV_PARTNER_COMMUNITY_PROFILE_NAME
                        AND UserName LIKE '%@test.dev'
                LIMIT 1
        ];
        Case testCase = new Case();
        PageReference prTestPage = Page.CaseNewInternalLegal;
        Test.setCurrentPage(prTestPage);

        Test.startTest();
        System.runAs(cvPartnerUser) {
            ApexPages.StandardController stdCtrl = new ApexPages.StandardController(testCase);
            CaseNewInternalLegalControllerExt extensionCtrl = new CaseNewInternalLegalControllerExt(stdCtrl);

            System.assertEquals(6, extensionCtrl.NUMBER_OF_ATTACHMENTS);
            System.assertEquals(extensionCtrl.NUMBER_OF_ATTACHMENTS, extensionCtrl.attCaseAttachmentsListDisp.size());
            System.assertEquals(1, ApexPages.getMessages().size());
        }
        Test.stopTest();
    }

    /**
     * tests the functioning of CaseNewInternalLegalControllerExt properties
     */
    private static testmethod void test_properties() {

        User cvPartnerUser =
        [
                SELECT Id, ContactId, Contact.AccountId
                FROM User
                WHERE Profile.Name = :TestDataFactory.CV_PARTNER_COMMUNITY_PROFILE_NAME
                        AND UserName LIKE '%@test.dev'
                LIMIT 1
        ];
        Case testCase = new Case();
        PageReference prTestPage = Page.CaseNewInternalLegal;
        Test.setCurrentPage(prTestPage);

        Test.startTest();

        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(testCase);
        CaseNewInternalLegalControllerExt extensionCtrl = new CaseNewInternalLegalControllerExt(stdCtrl);
        System.assertEquals(1, extensionCtrl.getLicenseeAccounts().size());
        extensionCtrl.cNewCase.AccountId = extensionCtrl.getLicenseeAccounts()[0].getValue();
        System.assertEquals(1, extensionCtrl.getLicenseeContacts().size());
        System.assertEquals(1, extensionCtrl.getLicenseeContracts().size());

        Test.stopTest();
    }

    /**
     * tests the functioning of CaseNewInternalLegalControllerExt save method wihtout any attachments
     */
    private static testmethod void test_save_noFile() {

        User cvPartnerUser =
        [
                SELECT Id
                FROM User
                WHERE Profile.Name = :TestDataFactory.CV_PARTNER_COMMUNITY_PROFILE_NAME
                        AND UserName LIKE '%@test.dev'
                LIMIT 1
        ];
        Case testCase = new Case();
        PageReference prTestPage = Page.CaseNewInternalLegal;
        Test.setCurrentPage(prTestPage);

        Test.startTest();
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(testCase);
        CaseNewInternalLegalControllerExt extensionCtrl = new CaseNewInternalLegalControllerExt(stdCtrl);
        PageReference prResponse = extensionCtrl.save();
        Test.stopTest();

        System.assert(null == prResponse);
    }

    /**
     * tests the functioning of CaseNewInternalLegalControllerExt save method with one attachment
     */
    private static testmethod void test_save_fileAttached() {

        User cvPartnerUser =
        [
                SELECT Id
                FROM User
                WHERE Profile.Name = :TestDataFactory.CV_PARTNER_COMMUNITY_PROFILE_NAME
                        AND UserName LIKE '%@test.dev'
                LIMIT 1
        ];
        Case testCase = new Case();
        PageReference prTestPage = Page.CaseNewInternalLegal;
        Test.setCurrentPage(prTestPage);
        ApexPages.StandardController stdCtrl;
        CaseNewInternalLegalControllerExt extensionCtrl;

        PageReference prResponse;
        Test.startTest();

        stdCtrl = new ApexPages.StandardController(testCase);
        extensionCtrl = new CaseNewInternalLegalControllerExt(stdCtrl);
        extensionCtrl.attCaseAttachmentsListDisp[0].Body = Blob.valueOf('file');
        extensionCtrl.attCaseAttachmentsListDisp[0].Name = 'file.txt';

        extensionCtrl.cNewCase.AccountId = extensionCtrl.getLicenseeAccounts()[0].getValue();
        extensionCtrl.cNewCase.ContactId = extensionCtrl.getLicenseeContacts()[0].getValue();
        extensionCtrl.cNewCase.CV_Agreement_No_Name__c = extensionCtrl.getLicenseeContracts()[0].getValue();
        extensionCtrl.cNewCase.Request_Type__c = 'Amendment';
        extensionCtrl.cNewCase.Amendment_Change_Type__c = 'Other';
        extensionCtrl.cNewCase.Amendment_Change_Other__c = 'other change';
        extensionCtrl.cNewCase.Description = 'desc';

        prResponse = extensionCtrl.save();

        Test.stopTest();

        Case newCase =
        [
                SELECT Id, OwnerId
                FROM Case
                LIMIT 1
        ];
        System.assert(prResponse != null);
        System.assert(prResponse.getUrl().contains(extensionCtrl.cNewCase.Id));
        System.assertEquals(extensionCtrl.cNewCase.Id, newCase.Id);
    }
}