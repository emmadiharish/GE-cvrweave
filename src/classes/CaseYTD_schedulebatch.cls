public class CaseYTD_schedulebatch {
    private static void resetFinancials() {
        try {
            Case[] cases =             
                [SELECT id, CV_Total_Royalty_Processed__c 
                 FROM Case
                 WHERE CV_Total_Royalty_Processed__c  <> NULL];                 
                               
                for(Case cas : cases) {
                    System.debug('Case.Id: ' + cas.Id);
                    System.debug('Total: ' + cas.CV_Total_Royalty_Processed__c );
                    
                    if(null != cas && null != cas.Id) {
                        cas.CV_Total_Royalty_Processed__c  = NULL;
                    }
                }
            update cases;
        } catch(Exception e) {
            System.debug('An unexpected error has occurred: ' + e.getMessage());
        }
    }
    
    public static void updateFinancials() {
        try {
            resetFinancials();
            
            AggregateResult[] totalResults =             
                    [SELECT Royalty_Submission_Case__c cas, SUM(Item_Sales_Total__c) total
                    FROM CV_Royalty_Data__c 
                    WHERE IsDeleted = FALSE AND Period_End_Date__c <> NULL
                    GROUP BY Royalty_Submission_Case__c
                    ORDER BY Royalty_Submission_Case__c];            
            Case[] caseTotals = new Case[]{};
                
                for(AggregateResult ar : totalResults) {
                    System.debug('cas: ' + ar.get('cas'));
                    System.debug('total: ' + ar.get('total'));
                    if(null != ar.get('cas')) {
                        Case cas = new Case();
                        cas.id = (ID) ar.get('cas');
                        cas.CV_Total_Royalty_Processed__c  = (Decimal) ar.get('total');                        
                        caseTotals.add(cas);
                    }
                }
            update caseTotals;
        } catch(Exception e) {
            System.debug('An unexpected error has occurred: ' + e.getMessage());
        }
    }
}