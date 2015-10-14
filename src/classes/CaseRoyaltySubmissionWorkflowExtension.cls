/******************************************************************************************************************************
* Name - CaseRoyaltySubmissionWorkflowExtension
* Description
* Controller Extension class for Royalty Submission workflow
* - does not fit the naming convention due to 40 char name limit
* Modification Log :
* ---------------------------------------------------------------------------
* Developer Date Description
* ---------------------------------------------------------------------------
* Zoran Zunko 05/03/2015 Created.
* Zoran Zunko 07/21/2015 deleted commented methods.
******************************************************************************************************************************/
public with sharing class CaseRoyaltySubmissionWorkflowExtension extends CaseWorkflowExtensionControllerBase {
//TODO: check if one user can have multiple roles in one process
//******************************************************************************************************************************
//base property method overrides
//******************************************************************************************************************************
    public override String getCurrentUserWorkflowRole() {
        if(this.currentUserWorkflowRole == null) {
            this.currentUserWorkflowRole = CVWorkflowSettingsManager.getRoyaltyWorkflowRoleForUser(UserInfo.getUserId());
        }
        return this.currentUserWorkflowRole;
    }
//******************************************************************************************************************************

    public CaseRoyaltySubmissionWorkflowExtension(ApexPages.StandardController stdController) {

        super(stdController);

        System.debug(LoggingLevel.DEBUG, 'CaseRoyaltySubmissionWorkflowExtension - constructor start');
        init();
        System.debug(LoggingLevel.DEBUG, 'CaseRoyaltySubmissionWorkflowExtension - constructor end');
    }

    /**
     * initializes the controller and adds the messages to the running user if no action is required
     */
    public override void init() {
        super.init();

        System.debug(LoggingLevel.DEBUG, 'CaseRoyaltySubmissionWorkflowExtension - init start');
        try {
            if(roleLicensee != getCurrentUserWorkflowRole() && !gecvButtonsVisible) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'No action is required from your side at this time.'));
            } else if(roleLicensee == getCurrentUserWorkflowRole() && !getLicenseeButtonsVisible() && areAllIssuesResponded()) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'No action is required from your side at this time.'));
            }
            if (roleLicensee == getCurrentUserWorkflowRole() && !areAllIssuesResponded()) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'One or more Issues are pending your comment. Please respond to all the issues and then re-submit.'));
            }

        }
        catch(Exception ex) {
            System.debug(LoggingLevel.ERROR, ex.getMessage() + '\n' + ex.getStackTraceString());
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error while loading the page please try again later.'));
        }
        System.debug(LoggingLevel.DEBUG, 'CaseRoyaltySubmissionWorkflowExtension - init end');
    }
}