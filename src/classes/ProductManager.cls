/******************************************************************************************************************************
* Name - ProductManager
* Description
* Manager class that contains all the methods and constants for handling Product records.
* To be used as a single source of business logic and data loading methods in order to ease reuse.
* Modification Log :
* ---------------------------------------------------------------------------
* Developer Date Description
* ---------------------------------------------------------------------------
* Zoran Zunko 05/28/2015 Created.
******************************************************************************************************************************/
public with sharing class ProductManager {

//******************************************************************************************************************************
//record type constants
//******************************************************************************************************************************
    public static String RT_CONSUMER_VENTURES = 'Product2.Consumer_Ventures';
    public static String RT_CCOE_PRODUCT = 'Product2.CCOE_Product';
//******************************************************************************************************************************

//******************************************************************************************************************************
//type constants
//******************************************************************************************************************************
//******************************************************************************************************************************

    /**
     * loads all Products with their SKU numbers for a given Licensee(Contact) id. All results are sorted.
     * @param  cCaseId id of the case to load the issues for
     * @return         a List of Issues with all the fields queried (contains Comments inner list)
     */
    public static List<Product2> getProductsForLicensee(Id cLincenseeId) {
        return [SELECT
                    Name
                    , Product_Number__c
                    , Description
                FROM Product2
                WHERE Licensee__c = :cLincenseeId
                    AND RecordTypeId = :Cache.RecordTypeId(RT_CONSUMER_VENTURES)
                ORDER BY Product_Number__c ASC];
    }

    /**
     * loads all Products with their SKU numbers for a given Licensee(Contact) id. All results are sorted.
     * @param  cCaseId id of the case to load the issues for
     * @return         a List of Issues with all the fields queried (contains Comments inner list)
     */
    public static List<Product2> getProductsForLicenseeContract(Id cLicenseeContractId) {
        return [SELECT
                    Name
                    , Product_Number__c
                    , Sub_Cat_1__c
                    , Sub_Cat_2__c
                    , Category__c
                    , Description
                FROM Product2
                WHERE Contract__c = :cLicenseeContractId
                    AND RecordTypeId = :Cache.RecordTypeId(RT_CONSUMER_VENTURES)
                ORDER BY Product_Number__c ASC];
    }


    public static Product2 createProductFromCase(Case cProductCase ) {

        Product2 response = new Product2(
                Name = 'Test'
                , Licensee__c = cProductCase.AccountId
                , Contract__c = cProductCase.CV_Agreement_No_Name__c
                , Description = cProductCase.Short_Product_Description__c
                , Product_Number__c = cProductCase.SKU_Number__c
                , RecordTypeId = Cache.RecordTypeId(RT_CONSUMER_VENTURES)
                , Key_Features_Function_1__c = cProductCase.CV_Feature_1__c
                , Key_Features_Function_2__c = cProductCase.CV_Feature_2__c
                , Key_Features_Function_3__c = cProductCase.CV_Feature_3__c
                , Key_Features_Function_4__c = cProductCase.CV_Feature_4__c
                , Key_Features_Function_5__c = cProductCase.CV_Feature_5__c
                , Landed_Cost_COGS__c = cProductCase.CV_Landed_Cost_COGS__c
                , MSRP__c = cProductCase.CV_Estimated_MSRP__c
                , BOI__c = cProductCase.BOI_Number__c
                , Licensee_GMp__c = cProductCase.CV_Licensee_GM_Percent__c
                , Licensee_GM__c = cProductCase.CV_Licensee_GM__c
                , Planned_Launch__c = cProductCase.CV_Customer_rollout_date__c
                , Status__c= 'Draft'
        );

        return response;
    }

}