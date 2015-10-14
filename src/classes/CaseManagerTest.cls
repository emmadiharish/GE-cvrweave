/******************************************************************************************************************************
* Name - CaseManagerTest
* @description
* Class contains all unit tests for CaseManager
* Modification Log :
* ---------------------------------------------------------------------------
* Developer Date Description
* ---------------------------------------------------------------------------
* Zoran Zunko 05/13/2015 Created.
******************************************************************************************************************************/
@isTest public class CaseManagerTest {

    /**
     * Class wide entry point for creation of test data.
     */
    @testSetup static void dataSetup() {

        List<Account> accounts = TestDataFactory.createAccounts('testAcc', UserInfo.getUserId(), 1);
        insert accounts;

        List<Contact> contacts = TestDataFactory.createContacts('testCon', UserInfo.getUserId(), accounts[0].Id, 1);
        insert contacts;

        List<User> users = TestDataFactory.createCommunityUsers('cp', TestDataFactory.CV_PARTNER_COMMUNITY_PROFILE_NAME, new List<Id> {contacts[0].Id});
        insert users;
    }

    /**
     * tests the functioning of getCVCases() method
     */
    private static testmethod void test_getCVCases() {
        User cvPartnerUser = [SELECT Id FROM User WHERE Profile.Name = :TestDataFactory.CV_PARTNER_COMMUNITY_PROFILE_NAME AND UserName LIKE '%@test.dev' LIMIT 1];
        Account licenseeAccount = [SELECT Id FROM Account LIMIT 1];
        Contact licenseeContact = [SELECT Id FROM Contact LIMIT 1];

        List<Case> cvCases = new List<Case> ();
        GE_TriggerDispatch.noTriggers = true;
        Test.startTest();
        for(Integer i = 0; i < 10; i++) {
            cvCases.add(TestDataFactory.createAncillaryBrandChangeCase('AB Case', cvPartnerUser.Id, licenseeAccount.Id, licenseeContact.Id));
        }
        Case nonCVCase = TestDataFactory.createAncillaryBrandChangeCase('AB Case', cvPartnerUser.Id, licenseeAccount.Id, licenseeContact.Id);
        nonCVCase.Type = 'non-cv';
        cvCases.add(nonCVCase);
        insert cvCases;
        Test.stopTest();
        GE_TriggerDispatch.noTriggers = false;

        System.assertEquals(cvCases.size() - 1, CaseManager.getCVCases(cvCases).size());
    }

    /**
     * tests the functioning of getCasesWithRecordTypeForCaseIds() method
     */
    private static testmethod void test_getCasesWithRecordTypeForCaseIds() {
        User cvPartnerUser = [SELECT Id FROM User WHERE Profile.Name = :TestDataFactory.CV_PARTNER_COMMUNITY_PROFILE_NAME AND UserName LIKE '%@test.dev' LIMIT 1];
        Account licenseeAccount = [SELECT Id FROM Account LIMIT 1];
        Contact licenseeContact = [SELECT Id FROM Contact LIMIT 1];

        List<Case> cvCases = new List<Case> ();
        GE_TriggerDispatch.noTriggers = true;
        Test.startTest();
        for(Integer i = 0; i < 10; i++) {
            cvCases.add(TestDataFactory.createAncillaryBrandChangeCase('AB Case', cvPartnerUser.Id, licenseeAccount.Id, licenseeContact.Id));
        }
        insert cvCases;
        Test.stopTest();
        GE_TriggerDispatch.noTriggers = false;
        List<Id> cvCaseIds = new List<Id>();
        for(Case cvCase : cvCases){

            cvCaseIds.add(cvCase.Id);
        }
        Map<Id, Case> cvCasesWithRecordTypes = CaseManager.getCasesWithRecordTypeForCaseIds(cvCaseIds);

        for(Case cvCase : cvCasesWithRecordTypes.values()) {

            System.assertEquals(Cache.RecordTypeId(CaseManager.RT_ANCILLARY_BRAND), cvCase.RecordTypeId);
            System.assertEquals(CaseManager.RT_ANCILLARY_BRAND.split('\\.')[1], cvCase.RecordType.DeveloperName);
            System.assert(cvCase.RecordType.Name != null);
        }
    }

    /**
     * tests the functioning of getCaseRecordTypeIdMapForCaseIds() method
     */
    private static testmethod void test_getCaseRecordTypeIdMapForCaseIds() {
        User cvPartnerUser = [SELECT Id FROM User WHERE Profile.Name = :TestDataFactory.CV_PARTNER_COMMUNITY_PROFILE_NAME AND UserName LIKE '%@test.dev' LIMIT 1];
        Account licenseeAccount = [SELECT Id FROM Account LIMIT 1];
        Contact licenseeContact = [SELECT Id FROM Contact LIMIT 1];

        List<Case> cvCases = new List<Case> ();
        GE_TriggerDispatch.noTriggers = true;
        Test.startTest();
        for(Integer i = 0; i < 10; i++) {
            cvCases.add(TestDataFactory.createAncillaryBrandChangeCase('AB Case', cvPartnerUser.Id, licenseeAccount.Id, licenseeContact.Id));
        }
        insert cvCases;
        Test.stopTest();
        GE_TriggerDispatch.noTriggers = false;

        Map<Id, RecordType> cvCaseRecordTypes = CaseManager.getCaseRecordTypeIdMapForCaseIds(cvCases);

        for(RecordType cvCaseRecordType : cvCaseRecordTypes.values()) {

            System.assertEquals(Cache.RecordTypeId(CaseManager.RT_ANCILLARY_BRAND), cvCaseRecordType.Id);
            System.assertEquals(CaseManager.RT_ANCILLARY_BRAND.split('\\.')[1], cvCaseRecordType.DeveloperName);
        }
    }

    /**
     * tests the functioning of getCVInternalLegalCases() method
     */
    private static testmethod void test_getCVInternalLegalCases() {
        User cvPartnerUser = [SELECT Id FROM User WHERE Profile.Name = :TestDataFactory.CV_PARTNER_COMMUNITY_PROFILE_NAME AND UserName LIKE '%@test.dev' LIMIT 1];
        Account licenseeAccount = [SELECT Id FROM Account LIMIT 1];
        Contact licenseeContact = [SELECT Id FROM Contact LIMIT 1];

        List<Case> cvCases = new List<Case> ();
        GE_TriggerDispatch.noTriggers = true;
        Test.startTest();
        for(Integer i = 0; i < 10; i++) {
            cvCases.add(TestDataFactory.createAncillaryBrandChangeCase('AB Case', cvPartnerUser.Id, licenseeAccount.Id, licenseeContact.Id));
        }
        Case internalLegalCase = TestDataFactory.createInternalLegalCase('IL Case', cvPartnerUser.Id, licenseeAccount.Id, licenseeContact.Id);
        internalLegalCase.Status = CaseManager.STATUS_CLOSED_APPROVED;
        cvCases.add(internalLegalCase);
        insert cvCases;
        Test.stopTest();
        GE_TriggerDispatch.noTriggers = false;

        System.assertEquals(1, CaseManager.getCVInternalLegalCases(cvCases).size());
    }

    /**
     * tests the functioning of setRoyaltySubmissionCaseFields() method
     */
    private static testmethod void test_setRoyaltySubmissionCaseFields() {
        List<User> cvPartnerUsers = [SELECT Id FROM User WHERE Profile.Name = :TestDataFactory.CV_PARTNER_COMMUNITY_PROFILE_NAME AND UserName LIKE '%@test.dev'];

        System.assert(cvPartnerUsers.size() == 1);

        User cvPartnerUser = CommunityUserManager.getContactDetailsForCommunityUser(cvPartnerUsers[0].Id);

        Case testCase = new Case();

        Test.startTest();
        testCase = CaseManager.setRoyaltySubmissionCaseFields(testCase, cvPartnerUser);
        Test.stopTest();

        System.assertEquals(testCase.RecordTypeId, (Id)Cache.RecordTypeId(CaseManager.RT_ROYALTY_SUBMISSION));
        System.assertEquals(testCase.ContactId, cvPartnerUser.ContactId);
        System.assertEquals(testCase.AccountId, cvPartnerUser.Contact.Account.Id);
        System.assertEquals(testCase.Subject, cvPartnerUser.Contact.Account.Name + ' Royalty Submission');
        System.assertEquals(testCase.Description, cvPartnerUser.Contact.Account.Name + ' Royalty Submission');
        System.assertEquals(testCase.Type, CaseManager.TYPE_CONSUMER_VENTURES);
        System.assertEquals(testCase.Origin, CaseManager.ORIGIN_LICENSEE_PORTAL);
        System.assertEquals(testCase.Status, CaseManager.STATUS_SUBMITTED_FOR_REVIEW);
    }

    /**
     * tests the functioning of setProductChangeCaseFields() method
     */
    private static testmethod void test_setProductChangeCaseFields() {
        List<User> cvPartnerUsers = [SELECT Id FROM User WHERE Profile.Name = :TestDataFactory.CV_PARTNER_COMMUNITY_PROFILE_NAME AND UserName LIKE '%@test.dev'];

        System.assert(cvPartnerUsers.size() == 1);

        User cvPartnerUser = CommunityUserManager.getContactDetailsForCommunityUser(cvPartnerUsers[0].Id);

        Case testCase = new Case();

        Test.startTest();
        testCase = CaseManager.setProductChangeCaseFields(testCase, cvPartnerUser);
        Test.stopTest();

        System.assertEquals(testCase.RecordTypeId, (Id)Cache.RecordTypeId(CaseManager.RT_PRODUCT_CHANGE));
        System.assertEquals(testCase.ContactId, cvPartnerUser.ContactId);
        System.assertEquals(testCase.AccountId, cvPartnerUser.Contact.Account.Id);
        System.assertEquals(testCase.Subject, cvPartnerUser.Contact.Account.Name + ' Product Change');
        System.assertEquals(testCase.Type, CaseManager.TYPE_CONSUMER_VENTURES);
        System.assertEquals(testCase.Origin, CaseManager.ORIGIN_LICENSEE_PORTAL);
        System.assertEquals(testCase.Status, CaseManager.STATUS_SUBMITTED_FOR_REVIEW);
        System.assertEquals(testCase.Product_Change_Type__c, CaseManager.PRODUCT_CHANGE_TYPE_PRODUCT);
    }

    /**
     * tests the functioning of setBrandChangeCaseFields() method
     */
    private static testmethod void test_setBrandChangeCaseFields() {
        List<User> cvPartnerUsers = [SELECT Id FROM User WHERE Profile.Name = :TestDataFactory.CV_PARTNER_COMMUNITY_PROFILE_NAME AND UserName LIKE '%@test.dev'];

        System.assert(cvPartnerUsers.size() == 1);

        User cvPartnerUser = CommunityUserManager.getContactDetailsForCommunityUser(cvPartnerUsers[0].Id);

        Case testCase = new Case();

        Test.startTest();
        testCase = CaseManager.setBrandChangeCaseFields(testCase, cvPartnerUser);
        Test.stopTest();

        System.assertEquals(testCase.RecordTypeId, (Id)Cache.RecordTypeId(CaseManager.RT_BRAND_CHANGE));
        System.assertEquals(testCase.ContactId, cvPartnerUser.ContactId);
        System.assertEquals(testCase.AccountId, cvPartnerUser.Contact.Account.Id);
        System.assertEquals(testCase.Subject, cvPartnerUser.Contact.Account.Name + ' Brand Change');
        System.assertEquals(testCase.Type, CaseManager.TYPE_CONSUMER_VENTURES);
        System.assertEquals(testCase.Origin, CaseManager.ORIGIN_LICENSEE_PORTAL);
        System.assertEquals(testCase.Status, CaseManager.STATUS_SUBMITTED_FOR_REVIEW);
        System.assertEquals(testCase.Product_Change_Type__c, CaseManager.PRODUCT_CHANGE_TYPE_BRAND);
    }

    /**
     * tests the functioning of setProductChangeCaseFields() method
     */
    private static testmethod void test_setAncillaryBrandCaseFields() {
        List<User> cvPartnerUsers = [SELECT Id FROM User WHERE Profile.Name = :TestDataFactory.CV_PARTNER_COMMUNITY_PROFILE_NAME AND UserName LIKE '%@test.dev'];

        System.assert(cvPartnerUsers.size() == 1);

        User cvPartnerUser = CommunityUserManager.getContactDetailsForCommunityUser(cvPartnerUsers[0].Id);

        Case testCase = new Case();

        Test.startTest();
        testCase = CaseManager.setAncillaryBrandCaseFields(testCase, cvPartnerUser);
        Test.stopTest();

        System.assertEquals(testCase.RecordTypeId, (Id)Cache.RecordTypeId(CaseManager.RT_ANCILLARY_BRAND));
        System.assertEquals(testCase.ContactId, cvPartnerUser.ContactId);
        System.assertEquals(testCase.AccountId, cvPartnerUser.Contact.Account.Id);
        System.assertEquals(testCase.Subject, cvPartnerUser.Contact.Account.Name + ' Ancillary Brand Approval');
        System.assertEquals(testCase.Type, CaseManager.TYPE_CONSUMER_VENTURES);
        System.assertEquals(testCase.Origin, CaseManager.ORIGIN_LICENSEE_PORTAL);
        System.assertEquals(testCase.Status, CaseManager.STATUS_SUBMITTED_FOR_REVIEW);
    }

    /**
     * tests the functioning of setExternalLegalCaseFields() method
     */
    private static testmethod void test_setExternalLegalCaseFields() {
        List<User> cvPartnerUsers = [SELECT Id FROM User WHERE Profile.Name = :TestDataFactory.CV_PARTNER_COMMUNITY_PROFILE_NAME AND UserName LIKE '%@test.dev'];

        System.assert(cvPartnerUsers.size() == 1);

        User cvPartnerUser = CommunityUserManager.getContactDetailsForCommunityUser(cvPartnerUsers[0].Id);

        Case testCase = new Case();

        Test.startTest();
        testCase = CaseManager.setExternalLegalCaseFields(testCase, cvPartnerUser);
        Test.stopTest();

        System.assertEquals(testCase.RecordTypeId, (Id)Cache.RecordTypeId(CaseManager.RT_EXTERNAL_LEGAL));
        System.assertEquals(testCase.ContactId, cvPartnerUser.ContactId);
        System.assertEquals(testCase.AccountId, cvPartnerUser.Contact.Account.Id);
        System.assertEquals(testCase.Subject, cvPartnerUser.Contact.Account.Name + ' External Legal');
        System.assertEquals(testCase.Type, CaseManager.TYPE_CONSUMER_VENTURES);
        System.assertEquals(testCase.Origin, CaseManager.ORIGIN_LICENSEE_PORTAL);
        System.assertEquals(testCase.Status, CaseManager.STATUS_SUBMITTED_FOR_REVIEW);
    }

    /**
     * tests the functioning of setExternalLegalCaseFields from internal case method
     */
    private static testmethod void test_setExternalLegalCaseFieldsFromInternalLegal() {
        User cvPartnerUser = [SELECT Id, ContactId FROM User WHERE Profile.Name = :TestDataFactory.CV_PARTNER_COMMUNITY_PROFILE_NAME AND UserName LIKE '%@test.dev' LIMIT 1];
        Account licenseeAccount = [SELECT Id FROM Account LIMIT 1];
        Contact licenseeContact = [SELECT Id FROM Contact LIMIT 1];

        GE_TriggerDispatch.noTriggers = true;
        Test.startTest();
        Case internalLegalCase = TestDataFactory.createInternalLegalCase('IL Case', cvPartnerUser.Id, licenseeAccount.Id, licenseeContact.Id);
        internalLegalCase.Status = CaseManager.STATUS_CLOSED_APPROVED;
        insert internalLegalCase;
        Test.stopTest();
        GE_TriggerDispatch.noTriggers = false;

        Case testCase = new Case();

        testCase = CaseManager.setExternalLegalCaseFields(internalLegalCase, cvPartnerUser.Id);

        System.assertEquals((Id)Cache.RecordTypeId(CaseManager.RT_EXTERNAL_LEGAL), testCase.RecordTypeId);
        System.assertEquals(internalLegalCase.ContactId, testCase.ContactId);
        System.assertEquals(internalLegalCase.AccountId, testCase.AccountId);
        System.assertEquals(internalLegalCase.Request_Type__c, testCase.Request_Type__c);
        System.assertEquals(internalLegalCase.CV_Agreement_No_Name__c, testCase.CV_Agreement_No_Name__c);
        System.assertEquals(internalLegalCase.Amendment_Change_Type__c, testCase.Amendment_Change_Type__c);
        System.assertEquals(internalLegalCase.Description, testCase.Description);
        System.assertEquals(internalLegalCase.Amendment_Change_Other__c, testCase.Amendment_Change_Other__c);
        System.assertEquals(internalLegalCase.Subject.replace(' Internal Legal', ' External Legal'), testCase.Subject);
        System.assertEquals(internalLegalCase.Type, testCase.Type);
        System.assertEquals(internalLegalCase.Origin, testCase.Origin);
        System.assertEquals(CaseManager.STATUS_SUBMITTED_FOR_REVIEW, testCase.Status);
        System.assertEquals(internalLegalCase.Id, testCase.ParentId);
        System.assertEquals(cvPartnerUser.Id, testCase.OwnerId);
    }


    /**
     * tests the functioning of setProductChangeCaseFields() method
     */
    private static testmethod void test_setInternalLegalCaseFields() {
        Account licenseeAccount = [SELECT Name, Id FROM Account LIMIT 1];

        Case testCase = new Case();

        Test.startTest();
        testCase = CaseManager.setInternalLegalCaseFields(testCase, licenseeAccount);
        Test.stopTest();

        System.assertEquals(testCase.RecordTypeId, (Id)Cache.RecordTypeId(CaseManager.RT_INTERNAL_LEGAL));
        System.assertEquals(testCase.AccountId, licenseeAccount.Id);
        System.assertEquals(testCase.Subject, licenseeAccount.Name + ' Internal Legal');
        System.assertEquals(testCase.Type, CaseManager.TYPE_CONSUMER_VENTURES);
        System.assertEquals(testCase.Origin, CaseManager.ORIGIN_INTERNAL_LEGAL);
        System.assertEquals(testCase.Status, CaseManager.STATUS_SUBMITTED_FOR_REVIEW);
    }
}