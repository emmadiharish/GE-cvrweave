/******************************************************************************************************************************
* Name - CaseNewNPIControllerExt
* Description
* Controller Extension class for NPI cases.
* Modification Log :
* ---------------------------------------------------------------------------
* Developer Date Description
* ---------------------------------------------------------------------------
* Zoran Zunko 08/25/2015 Created.
******************************************************************************************************************************/
public with sharing class CaseNewNPIControllerExt extends CaseNewWFControllerExtBase {

//******************************************************************************************************************************
//controller properties
//******************************************************************************************************************************
    public override Map<String, FieldSet> getSectionFieldSetMap() {

        Map<String, FieldSet> sectionFieldSetMap = new Map<String, FieldSet>{

                detailSectionTitle => Schema.SObjectType.Case.FieldSets.New_NPI_General_Field_Set
                , productDetailSectionTitle => Schema.SObjectType.Case.FieldSets.New_NPI_Product_Details_Field_Set
                , factoryDetailSectionTitle => Schema.SObjectType.Case.FieldSets.New_NPI_Factory_Details_Field_Set
                , targetDatesSectionTitle => Schema.SObjectType.Case.FieldSets.New_NPI_Target_Dates_Field_Set
        };

        if (String.isBlank(cNewCase.CV_Targeted_Retailers__c) || !cNewCase.CV_Targeted_Retailers__c.contains('Other (please specify)')) {

            sectionFieldSetMap.put(retailDetailSectionTitle,Schema.SObjectType.Case.FieldSets.New_NPI_Retail_Details_Field_Set);
        }
        else {

            sectionFieldSetMap.put(retailDetailSectionTitle,Schema.SObjectType.Case.FieldSets.New_NPI_Retail_Details_Other_Field_Set);
        }

        return sectionFieldSetMap;
    }

    public List<String> sectionOrderList;
    public List<String> getSectionOrderList() {

        if(sectionOrderList == null) {

            sectionOrderList =
                    new List<String> {
                            detailSectionTitle
                            , productDetailSectionTitle
                            , factoryDetailSectionTitle
                            , retailDetailSectionTitle
                            , targetDatesSectionTitle
            };
        }

        return sectionOrderList;
    }

//******************************************************************************************************************************

    public CaseNewNPIControllerExt(ApexPages.StandardController stdController) {

        super(stdController);

        System.debug(LoggingLevel.DEBUG, 'CaseNewNPIControllerExt - constructor start');

        getLicenseeAccounts();
        cNewCase = CaseManager.setNPICaseFields(cNewCase, getuLicenseeUser());
        initInfoMessage = 'You must attach both Design Packet and BOI (Basis Of Interest) Documents in order to submit the case.';
        attachmentMissingMessage = 'You must attach both Design Packet and BOI (Basis Of Interest) Documents in order to submit the case.';

        NUMBER_OF_ATTACHMENTS = 6;
        REQUIRED_NUMBER_OF_ATTACHMENTS = 2;

        init();
        System.debug(LoggingLevel.DEBUG, 'CaseNewNPIControllerExt - constructor end');
        System.debug(LoggingLevel.DEBUG, 'CaseNewNPIControllerExt - constructor start');
    }

    /**
     * initializes the controller
     */
    public override void init() {

        System.debug(LoggingLevel.DEBUG, 'CaseNewNPIControllerExt - init start');
        try {
            
            initCategoryOptions();
            initAttachments();
            initAgreement();
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, initInfoMessage));
        }
        catch (Exception ex) {
            System.debug(LoggingLevel.ERROR, ex.getMessage() + '\n' + ex.getStackTraceString());
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'There was an error while loading the page please try again later.'));
        }
        System.debug(LoggingLevel.DEBUG, 'CaseNewNPIControllerExt - init end');
    }
}