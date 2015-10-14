public class CVProductCategoryYTD_schedulebatch {
    public static void updateFinancials() {
        resetFinancials();
        updateFinancialsFromProduct();
        updateFinancialsFromChildren();
        updateFinancialsFromChildren();
    }
    
    public static void resetFinancials() {
        try {
            CV_Product_Category__c [] productCategories =             
                [SELECT id, CV_Year_To_Date__c, CV_Previous_Year_To_Date__c, CV_Inception_To_Date__c
                 FROM CV_Product_Category__c 
                 WHERE CV_Year_To_Date__c <> NULL OR CV_Previous_Year_To_Date__c <> NULL OR CV_Inception_To_Date__c <> NULL];                 
                               
                for(CV_Product_Category__c prodcat : productCategories) {
                    System.debug('Prod.Id: ' + prodcat.Id);
                    System.debug('YTD: ' + prodcat.CV_Year_To_Date__c);
                    System.debug('PYTD: ' + prodcat.CV_Previous_Year_To_Date__c);
                    System.debug('ITD: ' + prodcat.CV_Inception_To_Date__c);
                    
                    if(null != prodcat && null != prodcat.Id) {
                        prodcat.CV_Year_To_Date__c = NULL;
                        prodcat.CV_Previous_Year_To_Date__c = NULL;
                        prodcat.CV_Inception_To_Date__c = NULL;
                    }
                }
            update productCategories;
        } catch(Exception e) {
            System.debug('An unexpected error has occurred: ' + e.getMessage());
        }
    }
    

    public static void updateFinancialsFromProduct() {
        try {
            AggregateResult[] ytdResults =             
                [SELECT CV_Product_Category__c cat, SUM(CV_Year_To_Date__c) YTD, SUM(CV_Previous_Year_To_Date__c) PYTD, SUM(CV_Inception_To_Date__c) ITD 
                 FROM Product2 
                 WHERE IsDeleted = FALSE
                 GROUP BY CV_Product_Category__c ];
            
            CV_Product_Category__c[] ytdCategories = new CV_Product_Category__c[]{};
                
                for(AggregateResult ar : ytdResults) {
                    System.debug('Cat: ' + ar.get('cat'));
                    System.debug('YTD: ' + ar.get('YTD'));
                    System.debug('PYTD: ' + ar.get('PYTD'));
                    System.debug('ITD: ' + ar.get('ITD'));
                    if(null != ar.get('cat')) {
                        CV_Product_Category__c cat = new CV_Product_Category__c();
                        cat.id = (ID) ar.get('cat');
                        cat.CV_Year_To_Date__c = (Decimal) ar.get('YTD');
                        cat.CV_Previous_Year_To_Date__c = (Decimal) ar.get('PYTD');
                        cat.CV_Inception_To_Date__c = (Decimal) ar.get('ITD');
                        
                        ytdCategories.add(cat);
                    }
                }
            update ytdCategories;
        } catch(Exception e) {
            System.debug('An unexpected error has occurred: ' + e.getMessage());
        }
    }
    
        public static void updateFinancialsFromChildren() {
        try {
            AggregateResult[] ytdResults =             
                [SELECT Parent_Category__c cat, SUM(CV_Year_To_Date__c) YTD, SUM(CV_Previous_Year_To_Date__c) PYTD, SUM(CV_Inception_To_Date__c) ITD 
                 FROM CV_Product_Category__c 
                 WHERE IsDeleted = FALSE AND (CV_Year_To_Date__c <> NULL OR CV_Previous_Year_To_Date__c <> NULL)
                 GROUP BY Parent_Category__c];
            
            CV_Product_Category__c[] ytdCategories = new CV_Product_Category__c[]{};
                
                for(AggregateResult ar : ytdResults) {
                    System.debug('Cat: ' + ar.get('cat'));
                    System.debug('YTD: ' + ar.get('YTD'));
                    System.debug('PYTD: ' + ar.get('PYTD'));
                    System.debug('ITD: ' + ar.get('ITD'));
                    if(null != ar.get('cat')) {
                        CV_Product_Category__c cat = new CV_Product_Category__c();
                        cat.id = (ID) ar.get('cat');
                        cat.CV_Year_To_Date__c = (Decimal) ar.get('YTD');
                        cat.CV_Previous_Year_To_Date__c = (Decimal) ar.get('PYTD');
                        cat.CV_Inception_To_Date__c = (Decimal) ar.get('ITD');
                        
                        ytdCategories.add(cat);
                    }
                }
            update ytdCategories;
        } catch(Exception e) {
            System.debug('An unexpected error has occurred: ' + e.getMessage());
        }
    }
}