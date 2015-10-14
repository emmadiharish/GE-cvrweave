/**
* @author Zoran Zunko
* @date 10/1/15
*
* @group 
* @group-content ../../ApexDocContent/
*
* @description 
*/

public with sharing class CaseNewProductFromNPICtrlExt {

    Product2 pNewProduct;
    public Case cProductCase { get; set; }

    @testVisible private List<String> caseFieldStrings = new List<String>{
            'AccountId'
            , 'Account.Name'
            , 'Status'
            , 'Short_Product_Description__c'
            , 'SKU_Number__c'
            , 'CV_Agreement_No_Name__c'
            , 'CV_Feature_1__c'
            , 'CV_Feature_2__c'
            , 'CV_Feature_3__c'
            , 'CV_Feature_4__c'
            , 'CV_Feature_5__c'
            , 'CV_Landed_Cost_COGS__c'
            , 'CV_Estimated_MSRP__c'
            , 'BOI_Number__c'
            , 'CV_Licensee_GM_Percent__c'
            , 'CV_Licensee_GM__c'
            , 'CV_Customer_rollout_date__c'
            , 'Product_Category__c'
            , 'CV_Product_Sub_Cat_1__c'
            , 'CV_Product_Sub_Cat_2__c'
    };
    

    public CaseNewProductFromNPICtrlExt(ApexPages.StandardController stdController) {

        System.debug(LoggingLevel.DEBUG, 'CaseNewProductFromNPICtrlExt - constructor start');
        stdController.addFields(caseFieldStrings);
        cProductCase = (Case) stdController.getRecord();
        System.debug(LoggingLevel.DEBUG, stdController.getRecord());

        System.debug(LoggingLevel.DEBUG, 'CaseNewProductFromNPICtrlExt - constructor end');
    }
    
    /**
     * initializes the controller and adds the messages to the running user if no action is required
     */
    public PageReference createProduct() {

        System.debug(LoggingLevel.DEBUG, 'CaseNewProductFromNPICtrlExt - createProduct start');
        try {
            if (cProductCase.Status != CaseManager.STATUS_T2_CLOSED_APPROVED) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Products can be created only from approved NPI Cases'));
                return null;
            }

            pNewProduct = ProductManager.createProductFromCase(cProductCase);
            pNewProduct.CV_Product_Category__r = new CV_Product_Category__c(Composite_Key__c = cProductCase.Product_Category__c + '-' + cProductCase.CV_Product_Sub_Cat_1__c + '-' + cProductCase.CV_Product_Sub_Cat_2__c);
            insert pNewProduct;
            ApexPages.StandardController productStandardController = new ApexPages.StandardController(pNewProduct);

            PageReference p = productStandardController.edit();
            p.getParameters().put('retUrl', '/' + pNewProduct.Id);
            return p;

        }
        catch (Exception ex) {
            System.debug(LoggingLevel.ERROR, ex.getMessage() + '\n' + ex.getStackTraceString());
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'There was an error while creating the product, please try again later.'));
        }
        System.debug(LoggingLevel.DEBUG, 'CaseNewProductFromNPICtrlExt - createProduct end');
        return null;
    }

    public PageReference back() {

        return new PageReference('/' + cProductCase.Id);
    }
}