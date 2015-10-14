/******************************************************************************************************************************
* Name - CaseNewRoyaltySubmissionControllerExt
* Description
* Controller Extension class for new Royalty Submission cases.
* Modification Log :
* ---------------------------------------------------------------------------
* Developer Date Description
* ---------------------------------------------------------------------------
* Zoran Zunko 05/03/2015 Created.
* Zoran Zunko 10/07/2015 Refactored to extend the base class
******************************************************************************************************************************/
public with sharing class CaseNewRoyaltySubmissionControllerExt extends CaseNewWFControllerExtBase {


//******************************************************************************************************************************
//controller properties
//******************************************************************************************************************************
    public override Map<String, FieldSet> getSectionFieldSetMap() {

        return new Map<String, FieldSet> { detailSectionTitle => Schema.SObjectType.Case.FieldSets.New_Royalty_Submission_Field_Set};
    }
//******************************************************************************************************************************

    public CaseNewRoyaltySubmissionControllerExt(ApexPages.StandardController stdController) {

        super(stdController);

        System.debug(LoggingLevel.DEBUG, 'CaseNewRoyaltySubmissionControllerExt - constructor start');

        cNewCase = CaseManager.setRoyaltySubmissionCaseFields(cNewCase, getuLicenseeUser());
        initInfoMessage = 'Please fill out Required Fields and attach at least one file in order to be able to submit Royalty information.';
        attachmentMissingMessage = initInfoMessage;

        NUMBER_OF_ATTACHMENTS = 3;
        REQUIRED_NUMBER_OF_ATTACHMENTS = 1;

        init();

        System.debug(LoggingLevel.DEBUG, 'CaseNewRoyaltySubmissionControllerExt - constructor end');
    }

    /**
     * initializes the controller
     */
    public override void init() {
        System.debug(LoggingLevel.DEBUG, 'CaseNewRoyaltySubmissionControllerExt - init start');
        try {

            initAttachments();
            initAgreement();
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, initInfoMessage));
        }
        catch(Exception ex) {
            System.debug(LoggingLevel.ERROR, ex.getMessage() + '\n' + ex.getStackTraceString());
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error while loading the page please try again later.'));
        }
        System.debug(LoggingLevel.DEBUG, 'CaseNewRoyaltySubmissionControllerExt - init end');
    }
}