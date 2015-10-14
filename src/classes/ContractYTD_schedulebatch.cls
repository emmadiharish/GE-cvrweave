public class ContractYTD_schedulebatch {
    private static void resetFinancials() {
        try {
            Contract[] contracts =             
                [SELECT id, CV_Year_To_Date__c, CV_Previous_Year_To_Date__c, CV_Inception_To_Date__c
                 FROM Contract
                 WHERE CV_Year_To_Date__c <> NULL OR CV_Previous_Year_To_Date__c <> NULL OR CV_Inception_To_Date__c <> NULL];                 
                               
                for(Contract con : contracts) {
                    System.debug('Prod.Id: ' + con.Id);
                    System.debug('YTD: ' + con.CV_Year_To_Date__c);
                    System.debug('PYTD: ' + con.CV_Previous_Year_To_Date__c);
                    System.debug('ITD: ' + con.CV_Inception_To_Date__c);
                    
                    if(null != con && null != con.Id) {
                        con.CV_Year_To_Date__c = NULL;
                        con.CV_Previous_Year_To_Date__c = NULL;
                        con.CV_Inception_To_Date__c = NULL;
                    }
                }
            update contracts;
        } catch(Exception e) {
            System.debug('An unexpected error has occurred: ' + e.getMessage());
        }
    }
    
    public static void updateFinancials() {
        try {
            resetFinancials();
            
            AggregateResult[] ytdResults =             
                [SELECT Contract__c con, SUM(CV_Year_To_Date__c) YTD, SUM(CV_Previous_Year_To_Date__c) PYTD, SUM(CV_Inception_To_Date__c) ITD 
                 FROM Product2 
                 WHERE IsDeleted = FALSE
                 GROUP BY Contract__c];
            
            Contract[] ytdContracts = new Contract[]{};
                
                for(AggregateResult ar : ytdResults) {
                    System.debug('Con: ' + ar.get('con'));
                    System.debug('YTD: ' + ar.get('YTD'));
                    System.debug('PYTD: ' + ar.get('PYTD'));
                    System.debug('ITD: ' + ar.get('ITD'));
                    if(null != ar.get('con')) {
                        Contract con = new Contract();
                        con.id = (ID) ar.get('con');
                        con.CV_Year_To_Date__c = (Decimal) ar.get('YTD');
                        con.CV_Previous_Year_To_Date__c = (Decimal) ar.get('PYTD');
                        con.CV_Inception_To_Date__c = (Decimal) ar.get('ITD');
                        
                        ytdContracts.add(con);
                    }
                }
            update ytdContracts;
        } catch(Exception e) {
            System.debug('An unexpected error has occurred: ' + e.getMessage());
        }
    }
}