/******************************************************************************************************************************
* Name - CaseNewBrandChangeControllerExt
* Description
* Controller Extension class for new Royalty Submission cases.
* Modification Log :
* ---------------------------------------------------------------------------
* Developer Date Description
* ---------------------------------------------------------------------------
* Zoran Zunko 05/26/2015 Created.
******************************************************************************************************************************/
public with sharing class CaseNewBrandChangeControllerExt extends CaseNewWFControllerExtBase {

    public override Map<String, FieldSet> getSectionFieldSetMap() {

        return new Map<String, FieldSet>{

                detailSectionTitle =>
                        cNewCase.Change_Type__c ==
                                'Other (enter short name)' ?
                                Schema.SObjectType.Case.FieldSets.New_Brand_Change_Other_Field_Set
                                : Schema.SObjectType.Case.FieldSets.New_Brand_Change_Field_Set
        };
    }

//******************************************************************************************************************************
//controller properties
//******************************************************************************************************************************

    public CaseNewBrandChangeControllerExt(ApexPages.StandardController stdController) {

        super(stdController);

        System.debug(LoggingLevel.DEBUG, 'CaseNewBrandChangeControllerExt - constructor start');
        cNewCase = CaseManager.setBrandChangeCaseFields(cNewCase, getuLicenseeUser());
        initInfoMessage = 'Please fill out Required Fields and attach ECN form and applicable documentation in order to submit request.';
        attachmentMissingMessage = 'You must attach ECN Form in order to submit request.';

        NUMBER_OF_ATTACHMENTS = 6;
        REQUIRED_NUMBER_OF_ATTACHMENTS = 1;

        init();
        System.debug(LoggingLevel.DEBUG, 'CaseNewBrandChangeControllerExt - constructor end');
    }
}