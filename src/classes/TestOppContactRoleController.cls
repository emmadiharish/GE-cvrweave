@isTest(SeeAllData=true)
public class TestOppContactRoleController {
    
    static testMethod void testGetoppContactRoleInt()
    {
        Account account = new Account(Name='New Account');
        RecordType intRecordType = [SELECT Id,Name FROM RecordType WHERE Name = 'CCOE Internal Customer'];
        account.RecordTypeId = intRecordType.Id;
        insert account;
        Opportunity opp = new Opportunity(Name='New Test');
        opp.AccountId = account.Id;
        opp.Internal_Customer__c = account.Id;
        opp.CloseDate = date.parse('12/31/2014');
        opp.StageName = 'Prospect';
        insert opp;
        System.debug('Opp Id' + opp.Id);
        Contact con = new Contact(FirstName='first',LastName='last');
        con.AccountId = account.Id;
        insert con;
        Contact newcon = [SELECT Id, FirstName, AccountId, Account_Type__c from Contact where Id =: con.Id];
        System.debug('CONTACT ACC Record Type ' + newcon.Account_Type__c);
        System.debug('CONTACT ACC Id ' + newcon.AccountId);
        //con.Account_Type__c = 'CCOE Internal Customer';
        
        OpportunityContactRole oppConRole = new OpportunityContactRole();
        oppConRole.Role = 'Evaluator';
        oppConRole.ContactId = con.Id;
        oppConRole.OpportunityId = opp.Id;
        oppConRole.IsPrimary = false;
        insert oppConRole;
        PageReference pageRef = Page.Opportunity_Contact_Roles;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', opp.Id);
        OppContactRoleController controller = new OppContactRoleController(new ApexPages.StandardController(opp));
        //controller.id = opp.Id;
        List<OpportunityContactRoleWrapper> oppContactRoles = controller.getOppContactRoleInt();
        
    }
    
    static testMethod void testGetoppContactRoleExt()
    {
        Opportunity opp = new Opportunity();
        OppContactRoleController controller = new OppContactRoleController(new ApexPages.StandardController(opp));
        List<OpportunityContactRoleWrapper> oppContactRoles = controller.getOppContactRoleExt();
        
    }    
    
    static testMethod void testNewContactRole()
    {
    	Opportunity opp = new Opportunity();
    	OppContactRoleController controller = new OppContactRoleController(new ApexPages.StandardController(opp));
		PageReference pageRef = controller.newContactRole();
        
    }
    
    static testMethod void testDeleteContactRole()
    {
        Account account = new Account(Name='New Account');
        RecordType intRecordType = [SELECT Id,Name FROM RecordType WHERE Name = 'CCOE Internal Customer'];
        account.RecordTypeId = intRecordType.Id;
        insert account;
        Opportunity opp = new Opportunity(Name='New Test');
        opp.AccountId = account.Id;
        opp.Internal_Customer__c = account.Id;
        opp.CloseDate = date.parse('12/31/2014');
        opp.StageName = 'Prospect';
        insert opp;
        Contact con = new Contact(FirstName='first',LastName='last');
        insert con;
        OpportunityContactRole oppConRole = new OpportunityContactRole();
        oppConRole.Role = 'Evaluator';
        oppConRole.ContactId = con.Id;
        oppConRole.OpportunityId = opp.Id;
        oppConRole.IsPrimary = false;
        insert oppConRole;
    	OppContactRoleController controller = new OppContactRoleController(new ApexPages.StandardController(opp));
		controller.delContactRole = oppConRole.Id;
        PageReference pageRef = controller.deleteContactRole();
        
    }
}