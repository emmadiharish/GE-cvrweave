@isTest
private class testCaseTrigger {

    static testMethod void TestCaseTriggerHandler(){
   
        List<User> usr = [Select Id from User where IsActive=True limit 1];

        Case c = new Case();
        c.Subject = 'TestCase_for_Coverage';
        c.OwnerId = usr[0].Id;
        insert c;
        
                
        for(Case c2:[SELECT OwnerId, Requestor__c FROM Case 
            WHERE Subject = 'TestCase_for_Coverage']) {
                    System.assertEquals(c2.Requestor__c,c2.OwnerId);
            }
           
        delete c;

   }
 
}