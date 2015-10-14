@isTest(seeAllData=true)
public class TestOpportunityContactRoleWrapper {

    static testMethod void testAllFields()
    {
        OpportunityContactRoleWrapper oppWrapper = new OpportunityContactRoleWrapper();
        oppWrapper.setContactId('contactId');
        oppWrapper.setAccountType('CCOE Internal Customer');
        oppWrapper.setEmail('email');
        oppWrapper.setFirstName('firstName');
        oppWrapper.setLastName('lastName');
        oppWrapper.setName('name');
        oppWrapper.setPhone('phone');
        oppWrapper.setRole('role');
        oppWrapper.setRoleId('roleId');
        oppWrapper.setOppId('oppId');
        oppWrapper.setPrimary(true);
        oppWrapper.getName();
    }
}