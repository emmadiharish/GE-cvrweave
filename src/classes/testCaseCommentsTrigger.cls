@isTest
private class testCaseCommentsTrigger {

    static testMethod void TestCaseCommentsTriggerHandler(){

        List<User> usr = [Select Id from User where IsActive=True limit 1];

        Case c = new Case();
        c.Subject = 'TestCase_for_Coverage';
        c.OwnerId = usr[0].Id;
        insert c;

        CaseComment cc = new CaseComment();
        cc.ParentId = c.Id;
        cc.CommentBody = 'TestCaseComment_for_Coverage';
        insert cc;
                
        for(CaseComment cc2:[SELECT IsPublished FROM CaseComment 
            WHERE CommentBody = 'TestCase_for_Coverage']) {
                    System.assert(cc2.IsPublished=true);
            }
        
        delete cc;   
        delete c;

   }
 
}