/******************************************************************************************************************************
* Name - CaseWorkflowExtensionControllerBase
* Description
* Base class for all Case workflow controllers
* //TODO
* Modification Log :
* ---------------------------------------------------------------------------
* Developer Date Description
* ---------------------------------------------------------------------------
* Zoran Zunko 05/03/2015 Created.
******************************************************************************************************************************/
public with sharing abstract class CaseWorkflowExtensionControllerBase {

//******************************************************************************************************************************
//controller properties
//******************************************************************************************************************************
    public Case cLicenseeCase {get; protected set;}

    public List<CV_Case_Issue_Comment__c> cvcicIssesList {get; protected set;}
    {
        cvcicIssesList = new List<CV_Case_Issue_Comment__c>();
    }

    public CaseWorkflowExtensionControllerBase thisInstance{
        get {
            return this;
        }
    }

    public String roleLicensee {
        get {
            return CVWorkflowSettingsManager.ROLE_LICENSEE;
        }
    }

    public String roleProgram {
        get {
            return CVWorkflowSettingsManager.ROLE_PROGRAM;
        }
    }

    public String roleFinance {
        get {
            return CVWorkflowSettingsManager.ROLE_FINANCE;
        }
    }

    public virtual Boolean getIsLicensee() {

        return getCurrentUserWorkflowRole() == CVWorkflowSettingsManager.ROLE_LICENSEE;
    }

    public Boolean getLicenseeButtonsVisible() {
        return
            (getCurrentUserWorkflowRole() == roleLicensee)
            &&
            ((cLicenseeCase.Status == CaseManager.STATUS_LICENSEE_RESPONSE_NEEDED)
             || (cLicenseeCase.Status == CaseManager.STATUS_T1_LICENSEE_FEEDBACK_REQUIRED)
             || (cLicenseeCase.Status == CaseManager.STATUS_T2_LICENSEE_FEEDBACK_REQUIRED)
             )
            &&
            areAllIssuesResponded();
    }

    public Boolean gecvButtonsVisible {
        get {
            return
                getCurrentUserWorkflowRole() != CVWorkflowSettingsManager.ROLE_NA
                && ((getCurrentUserWorkflowRole() != roleLicensee)
                && ((cLicenseeCase.Status == CaseManager.STATUS_GE_APPROVAL_PROCESS)
                    || (cLicenseeCase.Status == CaseManager.STATUS_T1_GE_APPROVAL_PROCESS)
                    || (cLicenseeCase.Status == CaseManager.STATUS_T2_GE_APPROVAL_PROCESS)
                    )
                && (CVWorkflowManager.getStatusFieldValueForRole(
                        getCurrentUserWorkflowRole(), cLicenseeCase) == CaseManager.STATUS_ROLE_GE_ACTION_REQUIRED)
            );
        }
    }

    public String sCVRejectionReason {get; set;}

    @testVisible protected List<String> fieldsToLoad {
        get {
            return CVWorkflowManager.fieldsToLoadBase;
        }
    }

    public virtual Boolean getAllowsReShippingOfSamples() {

        return false;
    }

//******************************************************************************************************************************

    public CaseWorkflowExtensionControllerBase() {

    }

    public CaseWorkflowExtensionControllerBase(ApexPages.StandardController stdController) {

        if(!Test.isRunningTest()) stdController.addFields(fieldsToLoad);

        System.debug(LoggingLevel.DEBUG, 'CaseWorkflowExtensionControllerBase - constructor start');

        cLicenseeCase = (Case) stdController.getRecord();
        System.debug(LoggingLevel.DEBUG, stdController.getRecord());
        System.debug(LoggingLevel.DEBUG, 'CaseWorkflowExtensionControllerBase - constructor end');
    }

    /**
     * initializes the controller
     */
    public virtual void init() {
        System.debug(LoggingLevel.DEBUG, 'CaseWorkflowExtensionControllerBase - init start');
        try {
            cvcicIssesList = CVCaseIssueCommentManager.getIssuesForCaseId(cLicenseeCase.Id);
        }
        catch(Exception ex) {
            System.debug(LoggingLevel.ERROR, ex.getMessage() + '\n' + ex.getStackTraceString());
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error while loading the page please try again later.'));
        }
        System.debug(LoggingLevel.DEBUG, 'CaseWorkflowExtensionControllerBase - init end');
    }

//******************************************************************************************************************************
// Utility methods used by all workflow controllers extending this controller
//******************************************************************************************************************************
    /**
     * Checks if all the issues raised by the current user workflow role are resolved
     * @return true is they are false otherwise.
     */
    @testVisible protected Boolean areRoleCaseIssuesResolved() {
        System.debug(LoggingLevel.DEBUG, 'CaseWorkflowExtensionControllerBase - areRoleCaseIssuesResolved start');
        System.debug(LoggingLevel.DEBUG, 'cvcicIssesList: ' + cvcicIssesList);
        for(CV_Case_Issue_Comment__c cvcicIssue : cvcicIssesList) {
            if(cvcicIssue.GE_Created_By__c == getCurrentUserWorkflowRole() && !cvcicIssue.Resolved__c) {
                return false;
            }
        }
        System.debug(LoggingLevel.DEBUG, 'CaseWorkflowExtensionControllerBase - areRoleCaseIssuesResolved end');
        return true;
    }

    /**
     * Checks if Licensee user has responded to all the issues raised by GE CV users
     * @return true is it has false otherwise.
     */
    public Boolean areAllIssuesResponded() {
        for(CV_Case_Issue_Comment__c cvcicIssue : cvcicIssesList) {
            if(!cvcicIssue.Resolved__c) {
                if(
                   (cvcicIssue.Comments__r.size() == 0)
                   || cvcicIssue.Comments__r[cvcicIssue.Comments__r.size() -1 ].Created_By__c != roleLicensee) {
                    return false;
                }
            }
        }
        return true;
    }

    /**
     * Checks if at least one of the Issues raised by the current user workflow role is still unresolved
     * @return true if at least on of the isses in no resolved false otherwise
     */
    public Boolean doesRoleCaseIssueExist() {
        for(CV_Case_Issue_Comment__c cvcicIssue : cvcicIssesList) {
            if(cvcicIssue.GE_Created_By__c == getCurrentUserWorkflowRole() && !cvcicIssue.Resolved__c) {
                return true;
            }
        }
        return false;
    }

    @testVisible protected String currentUserWorkflowRole;
    public abstract String getCurrentUserWorkflowRole();
//******************************************************************************************************************************

//******************************************************************************************************************************
// Virtual methods for case actions
//******************************************************************************************************************************
/**
     * virtual method sets the current role workflow status to rejected and closes the add rejection comment popup
     * @return case dettail page if no exception gets thrown, null otherwise
     */
    public virtual PageReference reject() {
        System.debug(LoggingLevel.DEBUG, 'CaseWorkflowExtensionControllerBase - reject start');
        PageReference prResponse = null;
        try {
            cLicenseeCase.put(
                              CVWorkflowManager.getStatusFieldNameForRole(
                                 getCurrentUserWorkflowRole())
                              , CaseManager.STATUS_ROLE_REJECTED);
            cLicenseeCase.Comments__c = String.isBlank(cLicenseeCase.Comments__c) ? sCVRejectionReason : cLicenseeCase.Comments__c + '\n------Rejection Comment-------\n' + sCVRejectionReason;

            update cLicenseeCase;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Case was rejected.'));
            prResponse = new PageReference('/'+cLicenseeCase.Id);
        }
        catch(Exception ex) {
            System.debug(LoggingLevel.ERROR, ex.getMessage() + '\n' + ex.getStackTraceString());
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error while rejecting Royalty Submission, please try again later.'));
        }
        init();
        System.debug(LoggingLevel.DEBUG, 'CaseWorkflowExtensionControllerBase - reject end');
        return prResponse;
    }

    /**
     * virtual method sets the current role workflow status to CaseManager.STATUS_ROLE_LICENSEE_RESPONSE_NEEDED
     * @return case dettail page if no exception gets thrown, null otherwise
     */
    public virtual PageReference requestAdditionalInfo() {
        PageReference prResponse = null;
        System.debug(LoggingLevel.DEBUG, 'CaseWorkflowExtensionControllerBase - requestAdditionalInfo start');
        try {
            if(doesRoleCaseIssueExist()) {
                cLicenseeCase.put(
                                  CVWorkflowManager.getStatusFieldNameForRole(
                                     getCurrentUserWorkflowRole())
                                  , CaseManager.STATUS_ROLE_LICENSEE_RESPONSE_NEEDED);

                update cLicenseeCase;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Additional information requested.'));
                prResponse = new PageReference('/'+cLicenseeCase.Id);
            }
            else {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'No unresolved isseus exist. Please create at least one issue before requesting additional information.'));
            }
        }
        catch(Exception ex) {
            System.debug(LoggingLevel.ERROR, ex.getMessage() + '\n' + ex.getStackTraceString());
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error while requesting additinal information, please try again later.'));
        }

        init();
        System.debug(LoggingLevel.DEBUG, 'CaseWorkflowExtensionControllerBase - requestAdditionalInfo end');
        return prResponse;
    }

    /**
     * virtual method marks the case as apprived by the current role.
     * If ay unresolved issues exist for the current role Case can't be approved.
     * @return null if there was an error or case details view if wen ok.
     */
    public virtual PageReference approve() {
        System.debug(LoggingLevel.DEBUG, 'CaseWorkflowExtensionControllerBase - approve start');
        PageReference prResponse = null;
        try {
            if(areRoleCaseIssuesResolved()) {
                cLicenseeCase.put(
                                  CVWorkflowManager.getStatusFieldNameForRole(
                                     getCurrentUserWorkflowRole())
                                  , CaseManager.STATUS_ROLE_APPROVED);

                update cLicenseeCase;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Case was successfuly approved.'));
                prResponse = new PageReference('/'+cLicenseeCase.Id);
            }
            else {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'One or more issues are pending resolution. Please resolve all the issues before approving the Royalty Submission.'));
            }
        }
        catch(Exception ex) {
            System.debug(LoggingLevel.ERROR, ex.getMessage() + '\n' + ex.getStackTraceString());
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error while approving Royalty Submission, please try again later.'));
        }
        System.debug(LoggingLevel.DEBUG, 'CaseWorkflowExtensionControllerBase - approve end');

        return prResponse;
    }

    /**
     * virtual method sets the current case status to resubmitted
     * @return case dettail page if no exception gets thrown, null otherwise
     */
    public virtual PageReference reSubmit() {
        System.debug(LoggingLevel.DEBUG, 'CaseWorkflowExtensionControllerBase - reSubmit start');
        PageReference prResponse = null;
        try {
            if(areAllIssuesResponded()){
                cLicenseeCase.Status = CaseManager.STATUS_RE_SUBMITTED_FOR_REVIEW;

                update cLicenseeCase;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Case was successfuly resubmitted.'));
                prResponse = new PageReference('/'+cLicenseeCase.Id);
            } else {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'One or more Issues are pending your comment. Please respond to all the issues and then re-submit.'));
            }
        }
        catch(Exception ex) {
            System.debug(LoggingLevel.ERROR, ex.getMessage() + '\n' + ex.getStackTraceString());
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error while resubmitting Royalty Submission, please try again later.'));
        }
        init();
        System.debug(LoggingLevel.DEBUG, 'CaseWorkflowExtensionControllerBase - reSubmit end');
        return prResponse;
    }
//******************************************************************************************************************************
}