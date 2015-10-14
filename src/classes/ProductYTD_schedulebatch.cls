public class ProductYTD_schedulebatch implements Database.Batchable<sObject>, Database.Stateful {
    
    public Database.querylocator start(Database.BatchableContext bc) {
        resetFinancials();

        String query = 'SELECT ID FROM Product2';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<sObject> scope) { 

        ProductYTD_schedulebatch.updateYTD(scope);
        ProductYTD_schedulebatch.updatePreviousYTD(scope);
        ProductYTD_schedulebatch.updateInceptionYTD(scope);
    }

    public void finish(Database.BatchableContext bc) {

    }

/*
    public static void updateFinancials() {
    	resetFinancials();
        ProductYTD_schedulebatch.updateYTD();
		ProductYTD_schedulebatch.updatePreviousYTD();
		ProductYTD_schedulebatch.updateInceptionYTD();
    }
  */
    
    public static void resetFinancials() {
        try {
            Product2[] products =             
                [SELECT id, CV_Year_To_Date__c, CV_Previous_Year_To_Date__c, CV_Current_Year__c, CV_Inception_To_Date__c
                 FROM Product2
                 WHERE CV_Year_To_Date__c <> NULL OR CV_Current_Year__c <> NULL OR CV_Previous_Year_To_Date__c <> NULL OR CV_Inception_To_Date__c <> NULL];                 
                               
                for(Product2 prod : products) {
                    System.debug('Prod.Id: ' + prod.Id);
                    System.debug('Current Year: ' + prod.CV_Current_Year__c);
                    System.debug('YTD: ' + prod.CV_Year_To_Date__c);
                    System.debug('PYTD: ' + prod.CV_Previous_Year_To_Date__c);
                    System.debug('ITD: ' + prod.CV_Inception_To_Date__c);
                    
                    if(null != prod && null != prod.Id) {
                        prod.CV_Current_Year__c = NULL;
                        prod.CV_Year_To_Date__c = NULL;
                        prod.CV_Previous_Year_To_Date__c = NULL;
                        prod.CV_Inception_To_Date__c = NULL;
                    }
                }
            update products;
        } catch(Exception e) {
            System.debug('An unexpected error has occurred: ' + e.getMessage());
        }
    }
    
    public static void updateInceptionYTD(List<Product2> products) {
        try {
                AggregateResult[] ytdResults =             
                    [SELECT Licensed_Product__c prod, SUM(Item_Sales_Total__c) IYTD
                    FROM CV_Royalty_Data__c 
                    WHERE IsDeleted = FALSE AND Period_End_Date__c <> NULL AND Licensed_Product__c in :products
                    GROUP BY Licensed_Product__c
                    ORDER BY Licensed_Product__c];
                 
                Product2[] ytdProducts = new Product2[]{};
                    
                for(AggregateResult ar : ytdResults) {
                    System.debug('Prod: ' + ar.get('prod'));
                    System.debug('IYTD: ' + ar.get('IYTD'));
                    if(null != ar.get('prod')) {
                        Product2 prod = new Product2();
                        prod.id = (ID) ar.get('prod');
                        prod.CV_Inception_To_Date__c = (Decimal) ar.get('IYTD');
                        ytdProducts.add(prod);
                    }
                }
                update ytdProducts;
            } catch(Exception e) {
                System.debug('An unexpected error has occurred: ' + e.getMessage());
            }
    }
    
    public static void updateYTD(List<Product2> products) {
        try {
                AggregateResult[] ytdResults =             
                    [SELECT Licensed_Product__c prod, CALENDAR_YEAR(Period_End_Date__c) Year,SUM(Item_Sales_Total__c) YTD
                    FROM CV_Royalty_Data__c 
                    WHERE IsDeleted = FALSE AND Period_End_Date__c = THIS_YEAR AND Licensed_Product__c in :products
                    GROUP BY Licensed_Product__c, CALENDAR_YEAR(Period_End_Date__c)
                    ORDER BY Licensed_Product__c, CALENDAR_YEAR(Period_End_Date__c)];
                 
                Product2[] ytdProducts = new Product2[]{};
                    
                for(AggregateResult ar : ytdResults) {
                    System.debug('Prod: ' + ar.get('prod'));
                    System.debug('Year: ' + ar.get('year'));
                    System.debug('YTD: ' + ar.get('ytd'));
                    if(null != ar.get('prod')) {
                        Product2 prod = new Product2();
                        prod.id = (ID) ar.get('prod');
                        prod.CV_Year_To_Date__c = (Decimal) ar.get('YTD');
                        prod.CV_Current_Year__c = (Integer) ar.get('Year');
                        ytdProducts.add(prod);
                    }
                }
                update ytdProducts;
            } catch(Exception e) {
                System.debug('An unexpected error has occurred: ' + e.getMessage());
            }
    }
    
    public static void updatePreviousYTD(List<Product2> products) {
        try {
            AggregateResult[] ytdResults =             
                [SELECT Licensed_Product__c prod, CALENDAR_YEAR(Period_End_Date__c) Year,SUM(Item_Sales_Total__c) PYTD
                 FROM CV_Royalty_Data__c 
                 WHERE IsDeleted = FALSE AND Period_End_Date__c = LAST_YEAR AND Licensed_Product__c in :products
                 GROUP BY Licensed_Product__c, CALENDAR_YEAR(Period_End_Date__c)
                 ORDER BY Licensed_Product__c, CALENDAR_YEAR(Period_End_Date__c)];
            
            Product2[] ytdProducts = new Product2[]{};
                
                for(AggregateResult ar : ytdResults) {
                    System.debug('Prod: ' + ar.get('prod'));
                    System.debug('Year: ' + ar.get('year'));
                    System.debug('PYTD: ' + ar.get('pytd'));
                    if(null != ar.get('prod')) {
                        Product2 prod = new Product2();
                        prod.id = (ID) ar.get('prod');
                        prod.CV_Previous_Year_To_Date__c = (Decimal) ar.get('PYTD');
                        
                        ytdProducts.add(prod);
                    }
                }
            update ytdProducts;
        } catch(Exception e) {
            System.debug('An unexpected error has occurred: ' + e.getMessage());
        }
    }

}