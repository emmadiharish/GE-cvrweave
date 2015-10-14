/******************************************************************************************************************************
* Name - CaseNewNPIControllerExtTest
* @description
* Class contains all unit tests for CaseNewNPIControllerExt
* Modification Log :
* ---------------------------------------------------------------------------
* Developer Date Description
* ---------------------------------------------------------------------------
* Zoran Zunko 08/26/2015 Created.
******************************************************************************************************************************/
@isTest public class CaseNewNPIControllerExtTest {

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
     * tests the functioning of CaseNewNPIControllerExt constructor
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
        PageReference prTestPage = Page.CaseNewNPI;
        Test.setCurrentPage(prTestPage);

        Test.startTest();
        System.runAs(cvPartnerUser) {
            ApexPages.StandardController stdCtrl = new ApexPages.StandardController(testCase);
            CaseNewNPIControllerExt extensionCtrl = new CaseNewNPIControllerExt(stdCtrl);
            System.assertEquals(6, extensionCtrl.NUMBER_OF_ATTACHMENTS);
            System.assertEquals(extensionCtrl.NUMBER_OF_ATTACHMENTS, extensionCtrl.attCaseAttachmentsListDisp.size());
            System.assertEquals(1, ApexPages.getMessages().size());
        }
        Test.stopTest();
    }

    /**
     * tests the functioning of CaseNewNPIControllerExt properties
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
        PageReference prTestPage = Page.CaseNewNPI;
        Test.setCurrentPage(prTestPage);

        Test.startTest();

        System.runAs(cvPartnerUser) {
            ApexPages.StandardController stdCtrl = new ApexPages.StandardController(testCase);
            CaseNewNPIControllerExt extensionCtrl = new CaseNewNPIControllerExt(stdCtrl);
            System.assert(200 < extensionCtrl.getCountries().size());
            System.assertEquals(1, extensionCtrl.getLicenseeContracts().size());
        }

        Test.stopTest();
    }

    /**
     * tests the functioning of CaseNewNPIControllerExt save method wihtout any attachments
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
        PageReference prTestPage = Page.CaseNewNPI;
        Test.setCurrentPage(prTestPage);
        PageReference prResponse;

        Test.startTest();
        System.runAs(cvPartnerUser) {

            ApexPages.StandardController stdCtrl = new ApexPages.StandardController(testCase);
            CaseNewNPIControllerExt extensionCtrl = new CaseNewNPIControllerExt(stdCtrl);

            extensionCtrl.cNewCase.CV_Agreement_No_Name__c = extensionCtrl.getLicenseeContracts()[0].getValue();
            extensionCtrl.cNewCase.Description = 'desc';
            extensionCtrl.cNewCase.CV_Factory_Name__c = 'desc';
            extensionCtrl.cNewCase.CV_Factory_Location_Country__c = 'desc';
            extensionCtrl.cNewCase.BOI_Number__c = 'desc';
            extensionCtrl.cNewCase.SKU_Number__c = 'desc';
            extensionCtrl.cNewCase.Short_Product_Description__c = 'desc';
            extensionCtrl.cNewCase.Long_Product_Description__c = 'test';
            extensionCtrl.cNewCase.Product_Category__c = 'test';
            extensionCtrl.cNewCase.CV_Product_Sub_Cat_1__c = 'test';
            extensionCtrl.cNewCase.CV_Product_Sub_Cat_2__c = 'test';
            extensionCtrl.cNewCase.CV_Feature_1__c = 'test';
            extensionCtrl.cNewCase.CV_Feature_2__c = 'test';
            extensionCtrl.cNewCase.CV_Feature_3__c = 'test';
            extensionCtrl.cNewCase.CV_Feature_4__c = 'test';
            extensionCtrl.cNewCase.CV_Feature_5__c = 'test';
            extensionCtrl.cNewCase.CV_Targeted_Retailers__c = 'test';
            extensionCtrl.cNewCase.CV_Estimated_Annual_Unit_Volumes__c = 'test';
            extensionCtrl.cNewCase.CV_Estimated_MSRP__c = 12;
            extensionCtrl.cNewCase.CV_Retailer_GM__c = 12;
            extensionCtrl.cNewCase.CV_Estimated_Average_Selling_Price__c = 12;
            extensionCtrl.cNewCase.CV_FOB__c = 12;
            extensionCtrl.cNewCase.CV_Landed_Cost_COGS__c = 12;
            extensionCtrl.cNewCase.CV_Licensee_GM__c = 12;
            extensionCtrl.cNewCase.CV_Licensee_GM_Percent__c = 12;
            extensionCtrl.cNewCase.CV_T1_Review__c = Date.today();
            extensionCtrl.cNewCase.CV_T2_Review__c = Date.today();
            extensionCtrl.cNewCase.CV_Production__c = Date.today();
            extensionCtrl.cNewCase.CV_Ship_date_to_Licensee__c = Date.today();
            extensionCtrl.cNewCase.CV_Ship_date_to_Customer__c = Date.today();
            extensionCtrl.cNewCase.CV_Customer_rollout_date__c = Date.today();

            //just in case we test with one attachment
            extensionCtrl.attCaseAttachmentsListDisp[0].Body = Blob.valueOf('file');
            extensionCtrl.attCaseAttachmentsListDisp[0].Name = 'file.txt';

            prResponse = extensionCtrl.save();
        }
        Test.stopTest();

        System.assert(null == prResponse);
    }

    /**
     * tests the functioning of CaseNewNPIControllerExt save method with two attachments
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
        PageReference prTestPage = Page.CaseNewNPI;
        Test.setCurrentPage(prTestPage);
        ApexPages.StandardController stdCtrl;
        CaseNewNPIControllerExt extensionCtrl;

        PageReference prResponse;
        Test.startTest();

        System.runAs(cvPartnerUser) {

            stdCtrl = new ApexPages.StandardController(testCase);
            extensionCtrl = new CaseNewNPIControllerExt(stdCtrl);
            extensionCtrl.attCaseAttachmentsListDisp[0].Body = Blob.valueOf('file');
            extensionCtrl.attCaseAttachmentsListDisp[0].Name = 'file.txt';
            extensionCtrl.attCaseAttachmentsListDisp[1].Body = Blob.valueOf('file');
            extensionCtrl.attCaseAttachmentsListDisp[1].Name = 'file.txt';

            extensionCtrl.cNewCase.CV_Agreement_No_Name__c = extensionCtrl.getLicenseeContracts()[0].getValue();
            extensionCtrl.cNewCase.Description = 'desc';
            extensionCtrl.cNewCase.CV_Factory_Name__c = 'desc';
            extensionCtrl.cNewCase.CV_Factory_Location_Country__c = 'desc';
            extensionCtrl.cNewCase.BOI_Number__c = 'desc';
            extensionCtrl.cNewCase.SKU_Number__c = 'desc';
            extensionCtrl.cNewCase.Short_Product_Description__c = 'desc';
            extensionCtrl.cNewCase.Long_Product_Description__c = 'test';
            extensionCtrl.cNewCase.Product_Category__c = 'test';
            extensionCtrl.cNewCase.CV_Product_Sub_Cat_1__c = 'test';
            extensionCtrl.cNewCase.CV_Product_Sub_Cat_2__c = 'test';
            extensionCtrl.cNewCase.CV_Feature_1__c = 'test';
            extensionCtrl.cNewCase.CV_Feature_2__c = 'test';
            extensionCtrl.cNewCase.CV_Feature_3__c = 'test';
            extensionCtrl.cNewCase.CV_Feature_4__c = 'test';
            extensionCtrl.cNewCase.CV_Feature_5__c = 'test';
            extensionCtrl.cNewCase.CV_Targeted_Retailers__c = 'test';
            extensionCtrl.cNewCase.CV_Estimated_Annual_Unit_Volumes__c = 'test';
            extensionCtrl.cNewCase.CV_Estimated_MSRP__c = 12;
            extensionCtrl.cNewCase.CV_Retailer_GM__c = 12;
            extensionCtrl.cNewCase.CV_Estimated_Average_Selling_Price__c = 12;
            extensionCtrl.cNewCase.CV_FOB__c = 12;
            extensionCtrl.cNewCase.CV_Landed_Cost_COGS__c = 12;
            extensionCtrl.cNewCase.CV_Licensee_GM__c = 12;
            extensionCtrl.cNewCase.CV_Licensee_GM_Percent__c = 12;
            extensionCtrl.cNewCase.CV_T1_Review__c = Date.today();
            extensionCtrl.cNewCase.CV_T2_Review__c = Date.today();
            extensionCtrl.cNewCase.CV_Production__c = Date.today();
            extensionCtrl.cNewCase.CV_Ship_date_to_Licensee__c = Date.today();
            extensionCtrl.cNewCase.CV_Ship_date_to_Customer__c = Date.today();
            extensionCtrl.cNewCase.CV_Customer_rollout_date__c = Date.today();

            prResponse = extensionCtrl.save();
        }

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