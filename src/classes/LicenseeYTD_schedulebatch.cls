public class LicenseeYTD_schedulebatch {
    private static void resetFinancials() {
        try {
            Account[] accounts =             
                [SELECT id, CV_Year_To_Date__c, CV_Previous_Year_To_Date__c, CV_Inception_To_Date__c
                 FROM Account
                 WHERE CV_Year_To_Date__c <> NULL OR CV_Previous_Year_To_Date__c <> NULL OR CV_Inception_To_Date__c <> NULL];                 
                               
                for(Account acc : accounts) {
                    System.debug('Acc.Id: ' + acc.Id);
                    System.debug('YTD: ' + acc.CV_Year_To_Date__c);
                    System.debug('PYTD: ' + acc.CV_Previous_Year_To_Date__c);
                    System.debug('ITD: ' + acc.CV_Inception_To_Date__c);
                    
                    if(null != acc && null != acc.Id) {
                        acc.CV_Year_To_Date__c = NULL;
                        acc.CV_Previous_Year_To_Date__c = NULL;
                        acc.CV_Inception_To_Date__c = NULL;
                    }
                }
            update accounts;
        } catch(Exception e) {
            System.debug('An unexpected error has occurred: ' + e.getMessage());
        }
    }
    
    public static void updateFinancials() {
        try {
            resetFinancials();
            
            AggregateResult[] ytdResults =             
                [SELECT AccountId acc, SUM(CV_Year_To_Date__c) YTD, SUM(CV_Previous_Year_To_Date__c) PYTD, SUM(CV_Inception_To_Date__c) ITD 
                 FROM Contract 
                 WHERE IsDeleted = FALSE
                 GROUP BY AccountId];
            
            Account[] ytdAccounts = new Account[]{};
                
                for(AggregateResult ar : ytdResults) {
                    System.debug('Acc: ' + ar.get('acc'));
                    System.debug('YTD: ' + ar.get('YTD'));
                    System.debug('PYTD: ' + ar.get('PYTD'));
                    System.debug('ITD: ' + ar.get('ITD'));
                    if(null != ar.get('acc')) {
                        Account acc = new Account();
                        acc.id = (ID) ar.get('acc');
                        acc.CV_Year_To_Date__c = (Decimal) ar.get('YTD');
                        acc.CV_Previous_Year_To_Date__c = (Decimal) ar.get('PYTD');
                        acc.CV_Inception_To_Date__c = (Decimal) ar.get('ITD');
                        
                        ytdAccounts.add(acc);
                    }
                }
            update ytdAccounts;
        } catch(Exception e) {
            System.debug('An unexpected error has occurred: ' + e.getMessage());
        }
    }
}