@isTest(seeAllData=true)
public class TestSetDefaultOpportunityValues {

    static testMethod void testDefaultValueTrigger()
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
        
        delete opp;
        
    }
    
        static testMethod void testDefaultValueTrigger2()
    {
        Account account = new Account(Name='New Account');
        RecordType intRecordType = [SELECT Id,Name FROM RecordType WHERE Name = 'CCOE Internal Customer'];
        account.RecordTypeId = intRecordType.Id;
        insert account;
        Opportunity opp = new Opportunity(Name='New Test');
        opp.AccountId = account.Id;
        opp.Internal_Customer__c = null;
        opp.CloseDate = date.parse('12/31/2014');
        opp.StageName = 'Prospect';
        insert opp;
        
        delete opp;
        
    }
}