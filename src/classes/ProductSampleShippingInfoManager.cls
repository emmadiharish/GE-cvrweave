/******************************************************************************************************************************
* Name - ProductSampleShippingInfoManager
* Description
* Manager class that contains all the methods and constants for handling Product Sample Shipping Info records.
* To be used as a single source of business logic and data loading methods in order to ease reuse.
* Modification Log :
* ---------------------------------------------------------------------------
* Developer Date Description
* ---------------------------------------------------------------------------
* Zoran Zunko 05/03/2015 Created.
* Zoran Zunko 09/03/2015 Added Shipping_Info_Case_Status__c handling code
******************************************************************************************************************************/
public with sharing class ProductSampleShippingInfoManager {
    /**
     * loads all Shipping Infos with their comments for a given case id.
     * @param  cCaseId id of the case to load the Shipping Infos for
     * @return         a shipping infos with all the fields queried, together with related confirmations
     */
    public static List<Product_Sample_Shipping_Info__c> getShippingInfosForCaseId(Id cCaseId) {
        return [SELECT
                    Case__c
                    , Number_Of_Packages__c
                    , Estimated_Delivery_Date__c
                    , Ship_Date__c
                    , Shipper__c
                    , Shipper_Tracking_No__c
                    , Shipping_Type__c
                    , Shipping_Info_Case_Status__c
                    , Confirmed__c
                    , (SELECT
                        Reception_Confirmed__c
                        ,Role__c
                        FROM Confirmations__r)
                FROM Product_Sample_Shipping_Info__c
                WHERE Case__c = :cCaseId
                ORDER BY Name ASC];
    }

    /**
     * loads all Shipping Infos with their comments for a given case id and case status.
     * @param  cCaseId id of the case to load the Shipping Infos for
     * @return         a shipping infos with all the fields queried, together with related confirmations
     */
    public static List<Product_Sample_Shipping_Info__c> getShippingInfosForCaseIdAndCaseStatus(Id cCaseId, String caseStatusInfo) {
        return [SELECT
                    Case__c
                    , Number_Of_Packages__c
                    , Estimated_Delivery_Date__c
                    , Ship_Date__c
                    , Shipper__c
                    , Shipper_Tracking_No__c
                    , Shipping_Type__c
                    , Shipping_Info_Case_Status__c
                    , Confirmed__c
                    , (SELECT
                        Reception_Confirmed__c
                        ,Role__c
                        FROM Confirmations__r)
                FROM Product_Sample_Shipping_Info__c
                WHERE Case__c = :cCaseId
                    AND Shipping_Info_Case_Status__c = :caseStatusInfo
                ORDER BY Name ASC];
    }

    /**
     * loads Shipping Infos with their comments for a given id.
     * @param  shippingInfoId id of the Shipping Info record
     * @return         a shipping info with all the fields queried, together with related confirmations
     */
    public static Product_Sample_Shipping_Info__c getShippingInfoId(Id shippingInfoId) {
        return [SELECT
                    Case__c
                    , Number_Of_Packages__c
                    , Estimated_Delivery_Date__c
                    , Ship_Date__c
                    , Shipper__c
                    , Shipper_Tracking_No__c
                    , Shipping_Type__c
                    , Shipping_Info_Case_Status__c
                    , Confirmed__c
                    , (SELECT
                        Reception_Confirmed__c
                        ,Role__c
                        FROM Confirmations__r)
                FROM Product_Sample_Shipping_Info__c
                WHERE Id = :shippingInfoId
                ORDER BY Name ASC LIMIT 1];
    }

    /**
     * creates a new Product_Sample_Shipping_Info__c record with a Case lookup set to cLicenseeCaseId.
     * @param  cLicenseeCaseId         a case for which shipping info needs to be created for.
     * @return                         new Product_Sample_Shipping_Info__c instance
     */
    public static Product_Sample_Shipping_Info__c createShipmentInforForCaseId(Id cLicenseeCaseId) {

        Product_Sample_Shipping_Info__c shippingInfo = new Product_Sample_Shipping_Info__c();
        shippingInfo.Case__c = cLicenseeCaseId;

        return shippingInfo;
    }

    public static List<Product_Sample_Ship_Info_Confirmation__c> createShipmentConfirmations(Id shippingInfoId, List<String> wfRoles) {
        List<Product_Sample_Ship_Info_Confirmation__c> response = new List<Product_Sample_Ship_Info_Confirmation__c>();

        for (String wfRole : wfRoles) {
            response.add(new Product_Sample_Ship_Info_Confirmation__c(
                                Product_Sample_Shipping_Info__c = shippingInfoId
                                , Reception_Confirmed__c = false
                                , Role__c = wfRole
                            )
                         );
        }
        return response;
    }
}