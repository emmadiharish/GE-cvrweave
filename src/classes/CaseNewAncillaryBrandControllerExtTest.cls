/******************************************************************************************************************************
* Name - CaseNewAncillaryBrandControllerExtTest
* @description
* Class contains all unit tests for CaseNewAncillaryBrandControllerExt
* Modification Log :
* ---------------------------------------------------------------------------
* Developer Date Description
* ---------------------------------------------------------------------------
* Zoran Zunko 06/28/2015 Created.
******************************************************************************************************************************/
@isTest public class CaseNewAncillaryBrandControllerExtTest {

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

        List<Contact> contacts = TestDataFactory.createContacts('testCon', UserInfo.getUserId(), accounts[0].Id, 1);
        insert contacts;

        List<Contract> contracts = TestDataFactory.createContracts(accounts, 'testCont', 1);
        insert contracts;

        List<User> users = TestDataFactory.createCommunityUsers('cp', TestDataFactory.CV_PARTNER_COMMUNITY_PROFILE_NAME, new List<Id> {contacts[0].Id});
        insert users;

        for(Product2 prod : products) {

            prod.Contract__c = contracts[0].Id;
        }
        update products;
    }

    /**
     * tests the functioning of CaseNewAncillaryBrandControllerExt constructor
     */
    private static testmethod void test_pageLoad() {

        User cvPartnerUser = [SELECT Id FROM User WHERE Profile.Name = :TestDataFactory.CV_PARTNER_COMMUNITY_PROFILE_NAME AND UserName LIKE '%@test.dev' LIMIT 1];
        Case testCase = new Case();
        PageReference prTestPage = Page.CaseNewAncillaryBrandApproval;
        Test.setCurrentPage(prTestPage);

        Test.startTest();
        System.runAs(cvPartnerUser) {
            ApexPages.StandardController stdCtrl = new ApexPages.StandardController(testCase);
            CaseNewAncillaryBrandControllerExt extensionCtrl = new CaseNewAncillaryBrandControllerExt(stdCtrl);

            System.assertEquals(6, extensionCtrl.NUMBER_OF_ATTACHMENTS);
            System.assertEquals(extensionCtrl.NUMBER_OF_ATTACHMENTS, extensionCtrl.attCaseAttachmentsListDisp.size());
            System.assertEquals(1, ApexPages.getMessages().size());
        }
        Test.stopTest();
    }

    /**
     * tests the functioning of CaseNewAncillaryBrandControllerExt properties
     */
     private static testmethod void test_properties() {

        User cvPartnerUser = [SELECT Id, ContactId, Contact.AccountId  FROM User WHERE Profile.Name = :TestDataFactory.CV_PARTNER_COMMUNITY_PROFILE_NAME AND UserName LIKE '%@test.dev' LIMIT 1];
        Case testCase = new Case();
        PageReference prTestPage = Page.CaseNewAncillaryBrandApproval;
        Test.setCurrentPage(prTestPage);

        Test.startTest();
        System.runAs(cvPartnerUser) {

            ApexPages.StandardController stdCtrl = new ApexPages.StandardController(testCase);
            CaseNewAncillaryBrandControllerExt extensionCtrl = new CaseNewAncillaryBrandControllerExt(stdCtrl);
            System.assertEquals(cvPartnerUser.Id, extensionCtrl.uLicenseeUser.Id);
            System.assertEquals(10, extensionCtrl.pLicenseeSKUProductsMap.size());
            System.assert(!String.isBlank(extensionCtrl.getSLicenseeSKUListString()));
            System.assert(extensionCtrl.getCategories() != null);
        }

        Test.stopTest();
    }

    /**
     * tests the functioning of CaseNewAncillaryBrandControllerExt save method wihtout any attachments
     */
    private static testmethod void test_save_noFile() {

        User cvPartnerUser = [SELECT Id FROM User WHERE Profile.Name = :TestDataFactory.CV_PARTNER_COMMUNITY_PROFILE_NAME AND UserName LIKE '%@test.dev' LIMIT 1];
        Case testCase = new Case();
        PageReference prTestPage = Page.CaseNewAncillaryBrandApproval;
        Test.setCurrentPage(prTestPage);

        Test.startTest();
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(testCase);
        CaseNewAncillaryBrandControllerExt extensionCtrl = new CaseNewAncillaryBrandControllerExt(stdCtrl);
        extensionCtrl.uLicenseeUser = CommunityUserManager.getContactDetailsForCommunityUser(cvPartnerUser.Id);
        PageReference prResponse = extensionCtrl.save();
        Test.stopTest();

        System.assert(null == prResponse);
    }

    /**
     * tests the functioning of CaseNewAncillaryBrandControllerExt save method with one attachment
     */
    private static testmethod void test_save_fileAttached() {

        User cvPartnerUser = [SELECT Id FROM User WHERE Profile.Name = :TestDataFactory.CV_PARTNER_COMMUNITY_PROFILE_NAME AND UserName LIKE '%@test.dev' LIMIT 1];
        Case testCase = new Case();
        PageReference prTestPage = Page.CaseNewAncillaryBrandApproval;
        Test.setCurrentPage(prTestPage);
        ApexPages.StandardController stdCtrl;
        CaseNewAncillaryBrandControllerExt extensionCtrl;

        PageReference prResponse;
        Test.startTest();
        System.runAs(cvPartnerUser) {

            stdCtrl = new ApexPages.StandardController(testCase);
            extensionCtrl = new CaseNewAncillaryBrandControllerExt(stdCtrl);
            extensionCtrl.attCaseAttachmentsListDisp[0].Body = Blob.valueOf('file');
            extensionCtrl.attCaseAttachmentsListDisp[0].Name = 'file.txt';
            extensionCtrl.cNewCase.Region__c = 'Americas';
            extensionCtrl.cNewCase.CV_Agreement_No_Name__c = extensionCtrl.getLicenseeContracts()[0].getValue(); //todo
            extensionCtrl.cNewCase.SKU_Number__c = 'Test SKU';
            extensionCtrl.cNewCase.SKU_Description__c = 'Test SKU Description';
            extensionCtrl.cNewCase.Brand_Approval_Type__c = 'Other';
            extensionCtrl.cNewCase.Description = 'Description';
            extensionCtrl.cNewCase.Change_Type_Other__c = 'Change_Type_Other__c';
            extensionCtrl.cNewCase.CV_Product_Categories__c = 'cat';
            extensionCtrl.cNewCase.Date_of_Launch_Event__c = Date.today();

            prResponse = extensionCtrl.save();
        }


        Test.stopTest();

        Case newCase = [SELECT Id, OwnerId FROM Case LIMIT 1];
        System.assert(prResponse != null);
        System.assert(prResponse.getUrl().contains(extensionCtrl.cNewCase.Id));
        System.assertEquals(extensionCtrl.cNewCase.Id, newCase.Id);
    }

    /**
     * tests the functioning of CaseNewAncillaryBrandControllerExt properties
     */
     private static testmethod void test_sku_selection() {

        User cvPartnerUser = [SELECT Id, ContactId, Contact.AccountId  FROM User WHERE Profile.Name = :TestDataFactory.CV_PARTNER_COMMUNITY_PROFILE_NAME AND UserName LIKE '%@test.dev' LIMIT 1];
        Case testCase = new Case();
        PageReference prTestPage = Page.CaseNewAncillaryBrandApproval;
        Test.setCurrentPage(prTestPage);

        Test.startTest();
        System.runAs(cvPartnerUser) {

            ApexPages.StandardController stdCtrl = new ApexPages.StandardController(testCase);
            CaseNewAncillaryBrandControllerExt extensionCtrl = new CaseNewAncillaryBrandControllerExt(stdCtrl);

            extensionCtrl.selectSKU();
            System.assert(extensionCtrl.displayPopUp);

            String skuValue = (new List<String> (extensionCtrl.pLicenseeSKUProductsMap.keySet()))[0];
            extensionCtrl.skuSearchValue = skuValue;
            extensionCtrl.assignSKU();
            System.assertEquals(extensionCtrl.cNewCase.SKU_Description__c, extensionCtrl.pLicenseeSKUProductsMap.get(skuValue).Name);
            System.assertEquals(extensionCtrl.cNewCase.SKU_Number__c, extensionCtrl.pLicenseeSKUProductsMap.get(skuValue).Product_Number__c);
            System.assertEquals(extensionCtrl.cNewCase.CV_Product__c, extensionCtrl.pLicenseeSKUProductsMap.get(skuValue).Id);
        }

        Test.stopTest();
    }

    /**
     * tests the functioning of CaseNewAncillaryBrandControllerExt properties
     */
     private static testmethod void test_sku_selection_cancel() {

        User cvPartnerUser = [SELECT Id, ContactId, Contact.AccountId  FROM User WHERE Profile.Name = :TestDataFactory.CV_PARTNER_COMMUNITY_PROFILE_NAME AND UserName LIKE '%@test.dev' LIMIT 1];
        Case testCase = new Case();
        PageReference prTestPage = Page.CaseNewAncillaryBrandApproval;
        Test.setCurrentPage(prTestPage);

        Test.startTest();
        System.runAs(cvPartnerUser) {

            ApexPages.StandardController stdCtrl = new ApexPages.StandardController(testCase);
            CaseNewAncillaryBrandControllerExt extensionCtrl = new CaseNewAncillaryBrandControllerExt(stdCtrl);

            extensionCtrl.selectSKU();
            System.assert(extensionCtrl.displayPopUp);

            String skuValue = (new List<String> (extensionCtrl.pLicenseeSKUProductsMap.keySet()))[0];
            extensionCtrl.skuSearchValue = skuValue;
            extensionCtrl.selectSKUCancel();
            System.assert(!extensionCtrl.displayPopUp);
        }

        Test.stopTest();
    }
}