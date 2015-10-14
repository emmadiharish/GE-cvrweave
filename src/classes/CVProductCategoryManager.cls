/******************************************************************************************************************************
* Name - CVProductCategoryManager
* Description
* Manager class that contains all the methods and constants for handling CV Product Category records.
* To be used as a single source of business logic and data loading methods in order to ease reuse.
* Modification Log :
* ---------------------------------------------------------------------------
* Developer Date Description
* ---------------------------------------------------------------------------
* Zoran Zunko 06/17/2015 Created.
******************************************************************************************************************************/
public with sharing class CVProductCategoryManager {

    /**
     * loads all CV Product Categories and sort them by CompoiteKey
     * @return         a List of Categories that exist n the system
     */
    public static List<CV_Product_Category__c> getCVProductCategories() {
        return [SELECT
                    Category__c
                    , Sub_Cat_1__c
                    , Sub_Cat_2__c
                    , Name
                    , Composite_Key__c
                FROM CV_Product_Category__c
                ORDER BY Composite_Key__c ASC];
    }

    /**
     * loads all CV Product Categories for a given Contract and sort them by CompositeKey
     * @return         a List of Categories that exist for products under a contract
     */
    public static List<CV_Product_Category__c> getCVProductCategoriesForContractId(Id contractId) {
        return (List<CV_Product_Category__c>) Database.query('SELECT Composite_Key__c FROM CV_Product_Category__c WHERE Id IN (SELECT CV_Product_Category__c FROM Product2 WHERE CV_Product_Category__c != null AND Contract__c = :contractId) ORDER BY Composite_Key__c ASC');
    }
}