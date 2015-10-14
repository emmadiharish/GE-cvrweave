/******************************************************************************************************************************
* Name - CommunityUserManagerTest
* @description
* Class contains all unit tests for CommunityUserManagerTest
* Modification Log :
* ---------------------------------------------------------------------------
* Developer Date Description
* ---------------------------------------------------------------------------
* Zoran Zunko 05/13/2015 Created.
******************************************************************************************************************************/
@isTest public class CommunityUserManagerTest {

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
     * tests the functioning of getContactDetailsForCommunityUser() method user exists case
     */
    private static testmethod void test_getContactDetailsForCommunityUser_exists() {
        List<User> cvPartnerUsers = [SELECT Id FROM User WHERE Profile.Name = :TestDataFactory.CV_PARTNER_COMMUNITY_PROFILE_NAME AND UserName LIKE '%@test.dev'];

        System.assert(cvPartnerUsers.size() == 1);


        Test.startTest();
        User cvPartnerUser = CommunityUserManager.getContactDetailsForCommunityUser(cvPartnerUsers[0].Id);
        Test.stopTest();

        System.assert(cvPartnerUser != null);
        System.assertEquals(cvPartnerUsers[0].Id, cvPartnerUser.Id);
    }
    /**
     * tests the functioning of getContactDetailsForCommunityUser() method user does not exist case
     */
    private static testmethod void test_getContactDetailsForCommunityUser_invalidUser() {
        Test.startTest();
        User cvPartnerUser = CommunityUserManager.getContactDetailsForCommunityUser(null);
        Test.stopTest();

        System.assert(cvPartnerUser == null);
    }

     /**
     * tests the functioning of getContactDetailsForCommunityUser() method user does not exist case
     */
    private static testmethod void test_getCommunityUsersForLicenseeId() {
        Account licenseeAccount = [SELECT Id FROM Account LIMIT 1];


        System.assertEquals(1, CommunityUserManager.getCommunityUsersForLicenseeId(licenseeAccount.Id).size());
    }
}