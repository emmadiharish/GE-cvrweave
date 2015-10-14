public class OppContactRoleController {
    OpportunityContactRole opportunityContactRole;
    private List<OpportunityContactRole> oppContactRole;
    private List<OpportunityContactRole> oppContactRoleInt;
    private List<OpportunityContactRole> oppContactRoleExt;
    List<OpportunityContactRoleWrapper> relContacts;
    private Opportunity opportunity;
    private Id Id;
    public string delContactRole {get; set;}
    public OppContactRoleController(ApexPages.StandardController opp) {
        id = ApexPages.currentPage().getParameters().get('id');
    }
    
    public List<OpportunityContactRoleWrapper> getoppContactRoleInt()
    {
            return getOppContactRole('CCOE Internal Customer');
    }
    
    public List<OpportunityContactRoleWrapper> getoppContactRoleExt()
    {
            return getOppContactRole('CCOE End Customer');
    }    
    
    public List<OpportunityContactRoleWrapper> getOppContactRole(String accountRecordType)
    {
        List<OpportunityContactRole> oppContactRoleIds = [SELECT contactId, Id, Role, IsPrimary FROM OpportunityContactRole WHERE OpportunityId =: id];
        List<OpportunityContactRoleWrapper> relContacts = null;//new List<OpportunityContactRoleWrapper>();
        for (OpportunityContactRole oppCrs : oppContactRoleIds)
        {
            Contact contact = [SELECT Id,Name,Account.Name, Account_Type__c, Email, Phone FROM Contact WHERE ID =: oppCrs.contactId];
            if (contact.Account_Type__c == accountRecordType)
            {
                OpportunityContactRoleWrapper oppContactRole = new OpportunityContactRoleWrapper();
                oppContactRole.setOppId(id);
                oppContactRole.setContactId(oppCrs.contactId+'');
                oppContactRole.setName(contact.Name);
                oppContactRole.setEmail(contact.Email);
                oppContactRole.setPhone(contact.Phone);
                oppContactRole.setAccountType(contact.Account_Type__c);
                oppContactRole.setRoleId(oppCrs.Id);
                oppContactRole.setRole(oppCrs.Role);
                oppContactRole.setPrimary(oppCrs.IsPrimary);
                if (relContacts == null)
                {
                    relContacts = new List<OpportunityContactRoleWrapper>();
                }
                relContacts.add(oppContactRole);
            }
        }
        return relContacts;
    }
    
    public PageReference newContactRole()
    {
        PageReference newContactRole = new PageReference('/p/opp/ContactRoleEditUi/e?oppid='+id+'&retURL=/apex/Opportunity_Contact_Roles?id='+id+'&sfdc.override=1');
        newContactRole.setRedirect(true);
        return newContactRole;
    }
    
    public PageReference deleteContactRole()
    {
        OpportunityContactRole oppContactRole = new OpportunityContactRole(ID=delContactRole);
        delete oppContactRole;
        PageReference pageRef = new PageReference('/apex/Opportunity_Contact_Roles?id='+id+'&sfdc.override=1');
        pageRef.setRedirect(true);
        return pageRef;
        
    
    }
}