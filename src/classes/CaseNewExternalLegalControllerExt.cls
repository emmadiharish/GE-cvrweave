/******************************************************************************************************************************
* Name - CaseNewExternalLegalControllerExt
* Description
* Controller Extension class for new External Legal cases.
* Modification Log :
* ---------------------------------------------------------------------------
* Developer Date Description
* ---------------------------------------------------------------------------
* Zoran Zunko 07/01/2015 Created.
******************************************************************************************************************************/
public with sharing class CaseNewExternalLegalControllerExt extends CaseNewWFControllerExtBase {

//******************************************************************************************************************************
//controller properties
//******************************************************************************************************************************
    
    public override Map<String, FieldSet> getSectionFieldSetMap() {

        if (String.isBlank(cNewCase.Request_Type__c)) {

            return new Map<String, FieldSet>{

                    detailSectionTitle => Schema.SObjectType.Case.FieldSets.New_External_Legal_Field_Set
            };
        }
        else if (cNewCase.Request_Type__c == 'Other') {

            return new Map<String, FieldSet>{

                    detailSectionTitle => Schema.SObjectType.Case.FieldSets.New_External_Legal_Other_Field_Set
            };
        }
        else if (cNewCase.Request_Type__c == 'Amendment' && !String.isBlank(cNewCase.Amendment_Change_Type__c) && cNewCase.Amendment_Change_Type__c.contains('Other')) {

            return new Map<String, FieldSet>{

                    detailSectionTitle => Schema.SObjectType.Case.FieldSets.New_External_Legal_Amendment_Other
            };
        }
        else if (cNewCase.Request_Type__c == 'Amendment') {

            return new Map<String, FieldSet>{

                    detailSectionTitle => Schema.SObjectType.Case.FieldSets.New_External_Legal_Amendment_Field_Set
            };
        }
        else {

            return new Map<String, FieldSet>{

                    detailSectionTitle => Schema.SObjectType.Case.FieldSets.New_External_Legal_Field_Set
            };
        }
    }

//******************************************************************************************************************************

    public CaseNewExternalLegalControllerExt(ApexPages.StandardController stdController) {

        super(stdController);

        System.debug(LoggingLevel.DEBUG, 'CaseNewExternalLegalControllerExt - constructor start');

        cNewCase = CaseManager.setExternalLegalCaseFields(cNewCase, getuLicenseeUser());
        initInfoMessage = 'You must attach Agreement or Amendment Form in order to submit request.';
        attachmentMissingMessage = 'You must attach ECN Form in order to submit request.';

        NUMBER_OF_ATTACHMENTS = 6;
        REQUIRED_NUMBER_OF_ATTACHMENTS = 1;

        init();
        System.debug(LoggingLevel.DEBUG, 'CaseNewExternalLegalControllerExt - constructor end');
    }

    /**
     * initializes the controller
     */
    public override void init() {

        System.debug(LoggingLevel.DEBUG, 'CaseNewExternalLegalControllerExt - init start');
        try {

            initAttachments();
            initAgreement();
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, initInfoMessage));
        }
        catch (Exception ex) {
            System.debug(LoggingLevel.ERROR, ex.getMessage() + '\n' + ex.getStackTraceString());
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'There was an error while loading the page please try again later.'));
        }
        System.debug(LoggingLevel.DEBUG, 'CaseNewExternalLegalControllerExt - init end');
    }
}