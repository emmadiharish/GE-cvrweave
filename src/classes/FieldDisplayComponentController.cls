/**
* @author Zoran Zunko
* @date 10/12/15
*
* @group 
* @group-content ../../ApexDocContent/
*
* @description 
*/

public with sharing class FieldDisplayComponentController {

    private Set<String> exclusionFields = new Set<String>{
            'CV_Agreement_No_Name__c'
            , 'Product_Category__c'
            , 'CV_Product_Sub_Cat_1__c'
            , 'CV_Product_Sub_Cat_2__c'
            , 'SKU_Number__c'
            , 'Change_Type__c'
            , 'CV_Product_Categories__c'
            , 'SKU_Number__c'
            , 'Brand_Approval_Type__c'
            , 'Amendment_Change_Type__c'
            , 'Request_Type__c'
            , 'AccountId'
            , 'ContactId'
            , 'CV_Targeted_Retailers__c'
            , 'CV_Factory_Location_Country__c'};

    public CaseNewWFControllerExtBase pageController {get; set;}

    public String fieldForDisplay {get; set;}


    public Case cNewCase {

        get { return pageController.cNewCase; }
    }

    public Boolean displayRegular {

        get{

            return !exclusionFields.contains(fieldForDisplay);
        }
    }

}