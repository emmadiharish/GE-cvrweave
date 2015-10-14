/******************************************************************************************************************************
* Name - CommunityUserManager
* Description
* Manager class that contains all the methods and constants for handling Community User records.
* To be used as a single source of business logic and data loading methods in order to ease reuse.
* Modification Log :
* ---------------------------------------------------------------------------
* Developer Date Description
* ---------------------------------------------------------------------------
* Zoran Zunko 05/03/2015 Created.
******************************************************************************************************************************/
public with sharing class CommunityUserManager {

    /**
     * queries account and contact details for a given Community user id
     * @param  userId Community user id
     * @return        User record with: Contact.Name, Contact.Id, Contact.Account.Id, Contact.Account.Name
     *                Or null if no user is found.
     */
    public static User getContactDetailsForCommunityUser(Id userId) {
        List<User> uResList = getContactDetailsForCommunityUsers(new List<Id> {userId});

        if(uResList.size() != 0) {
            return uResList[0];
        } else {
            return null;
        }
    }

    /**
     * queries account and contact details for a given list of Community user ids
     * @param  userIds List of community user ids
     * @return         List<User> with: Contact.Name, Contact.Id, Contact.Account.Id, Contact.Account.Name
     */
    public static List<User> getContactDetailsForCommunityUsers(List<Id> userIds) {
        return [SELECT ContactId, Contact.Name, Contact.AccountId, Contact.Account.Name FROM User WHERE Id IN :userIds];
    }

    /**
     * method returns a list of community users for a given licensee
     * @param  licenseeId an Id of a licensee account
     * @return            List of active users for given licensee
     */
    public static List<User> getCommunityUsersForLicenseeId(Id licenseeId) {

        return getCommunityUsersForLicenseeIds(new List<Id> {licenseeId});
    }

    /**
     * method returns a list of community users for a given list of licensees
     * @param  licenseeIds a List<Id> of licensee accounts
     * @return            List of active users for given licensees
     */
    public static List<User> getCommunityUsersForLicenseeIds(List<Id> licenseeIds) {

        return [SELECT Id, ContactId, Contact.Name FROM User WHERE Contact.AccountId IN :licenseeIds AND IsActive = true];
    }
}