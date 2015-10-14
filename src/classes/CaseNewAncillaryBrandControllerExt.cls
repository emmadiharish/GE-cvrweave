/******************************************************************************************************************************
* Name - CaseNewAncillaryBrandControllerExt
* Description
* Controller Extension class for new Ancillary Brand Approval cases.
* Modification Log :
* ---------------------------------------------------------------------------
* Developer Date Description
* ---------------------------------------------------------------------------
* Zoran Zunko 06/17/2015 Created.
******************************************************************************************************************************/
public with sharing class CaseNewAncillaryBrandControllerExt extends CaseNewWFControllerExtBase{

//******************************************************************************************************************************
//controller properties
//******************************************************************************************************************************

    public override Map<String, FieldSet> getSectionFieldSetMap() {

        return new Map<String, FieldSet>{

                detailSectionTitle =>
                        cNewCase.Brand_Approval_Type__c ==
                                'Other' ?
                                Schema.SObjectType.Case.FieldSets.New_Ancillary_Brand_Other_Field_Set
                                : Schema.SObjectType.Case.FieldSets.New_Ancillary_Brand_Field_Set
        };
    }

//******************************************************************************************************************************

    public CaseNewAncillaryBrandControllerExt(ApexPages.StandardController stdController) {

        super(stdController);

        System.debug(LoggingLevel.DEBUG, 'CaseNewAncillaryBrandControllerExt - constructor start');
        cNewCase = CaseManager.setBrandChangeCaseFields(cNewCase, getuLicenseeUser());
        initInfoMessage = 'Please fill out Required Fields and applicable documentation in order to submit request.';
        attachmentMissingMessage = 'You must attach Brand Approval Request Form in order to submit request.';

        NUMBER_OF_ATTACHMENTS = 6;
        REQUIRED_NUMBER_OF_ATTACHMENTS = 1;

        init();
        System.debug(LoggingLevel.DEBUG, 'CaseNewAncillaryBrandControllerExt - constructor end');
    }
    
}