/******************************************************************************************************************************
* Name - CaseCVWorkflowGatekeeperExtController
* Description
* Controller Extension class for new CVWoekflowGatekeeper page.
* Modification Log :
* ---------------------------------------------------------------------------
* Developer Date Description
* ---------------------------------------------------------------------------
* Zoran Zunko 06/09/2015 Created.
******************************************************************************************************************************/
public with sharing class CaseCVWorkflowGatekeeperExtController {

    public class CVWorkflowRoleWrapper {
        public Boolean participating {get; set;}
        public Boolean readonly {get; private set;}
        public String wfRole {get; private set;}

        public CVWorkflowRoleWrapper(String wfRole, Boolean readonly) {
            this(wfRole, false, readonly);
        }

        public CVWorkflowRoleWrapper(String wfRole, Boolean participating, Boolean readonly) {
            this.wfRole = wfRole;
            this.participating = participating;
            this.readonly = readonly;
        }
    }
//******************************************************************************************************************************
//controller properties
//******************************************************************************************************************************
    @testVisible private List<String> fieldsToLoad {
        get {
            return CVWorkflowManager.fieldsToLoadBase;
        }
    }

    @testVisible private Case cWfCase;

    @testVisible private Set<String> currentRoles;

    @testVisible public List<CVWorkflowRoleWrapper> cvwrwRoleList {get; private set;}

    public Boolean getIsSaveEnabled() {
        return (CaseManager.getGatekeepingAllowedStatuses().contains(cWfCase.Status));
    }
//******************************************************************************************************************************

    public CaseCVWorkflowGatekeeperExtController(ApexPages.StandardController stdController) {

        System.debug(LoggingLevel.DEBUG, 'CaseCVWorkflowGatekeeperExtController - constructor start');
        if(!Test.isRunningTest()) {
            stdController.addFields(fieldsToLoad);
        }
        cWfCase = (Case) stdController.getRecord();
        cvwrwRoleList = new List<CVWorkflowRoleWrapper>();
        System.debug(LoggingLevel.DEBUG, stdController.getRecord());

        System.debug(LoggingLevel.DEBUG, 'CaseCVWorkflowGatekeeperExtController - constructor end');
    }

    /**
     * initializes the controller
     */
    public PageReference init() {
        System.debug(LoggingLevel.DEBUG, 'CaseCVWorkflowGatekeeperExtController - init start');
        try {
            if(cWfCase.Participating_Roles__c == null) {
                cWfCase.Participating_Roles__c = String.join(CVWorkflowConfigurationManager.getMandatoryRolesForWorkflow(cWfCase.RecordType.DeveloperName), ',');
                update cWfCase;
            }
            currentRoles = new Set<String> (cWfCase.Participating_Roles__c.split(','));
            System.debug(LoggingLevel.DEBUG, 'currentRoles: ' + currentRoles );
            System.debug(LoggingLevel.DEBUG, 'cvwrwRoleList: ' + cvwrwRoleList );
            cvwrwRoleList.clear();

            if(getIsSaveEnabled()) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Please select roles to add to the process and press Save.'));
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please note that once a role has been selected and saved it can\'t be removed from the workflow.'));
                for(String availableRole : CVWorkflowConfigurationManager.getAvailableRolesForWorkflow(cWfCase.RecordType.DeveloperName)) {
                    if(currentRoles.contains(availableRole)) {
                        cvwrwRoleList.add(new CVWorkflowRoleWrapper(availableRole, true, true));
                    }
                    else {
                        cvwrwRoleList.add(new CVWorkflowRoleWrapper(availableRole, false));
                    }
                }
            }
            else{
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'New Roles can only be added if the Status is ' + CaseManager.STATUS_SUBMITTED_FOR_REVIEW + ' or ' + CaseManager.STATUS_RE_SUBMITTED_FOR_REVIEW + '.'));
                for(String availableRole : CVWorkflowConfigurationManager.getAvailableRolesForWorkflow(cWfCase.RecordType.DeveloperName)) {
                    if(currentRoles.contains(availableRole)) {
                        cvwrwRoleList.add(new CVWorkflowRoleWrapper(availableRole, true, true));
                    }
                    else {
                        cvwrwRoleList.add(new CVWorkflowRoleWrapper(availableRole, true));
                    }
                }
            }
            System.debug(LoggingLevel.DEBUG, 'cvwrwRoleList: ' + cvwrwRoleList );
        }
        catch(Exception ex) {
            System.debug(LoggingLevel.ERROR, ex.getMessage() + '\n' + ex.getStackTraceString());
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error while loading the page please try again later.'));
        }
        System.debug(LoggingLevel.DEBUG, 'CaseCVWorkflowGatekeeperExtController - init end');
        return null;
    }

    /**
     * Saves current pick of roles for workflow
     * @return null PageReference if there was an error, or case detail page if successfull.
     */
    public PageReference save() {
        System.debug(LoggingLevel.DEBUG, 'CaseCVWorkflowGatekeeperExtController - save start');
        PageReference prResponse = null;
        Savepoint sp = Database.setSavepoint();
        try {
            Set<String> newCurrentRoles = new Set<String>();
            for(CVWorkflowRoleWrapper cvwrwRole : cvwrwRoleList) {
                if(cvwrwRole.participating) {
                    newCurrentRoles.add(cvwrwRole.wfRole);
                }
            }
            System.debug(LoggingLevel.DEBUG, 'newCurrentRoles: ' + newCurrentRoles );
            if(!currentRoles.containsAll(newCurrentRoles)) {
                cWfCase.Participating_Roles__c = String.join(new List<String>(newCurrentRoles), ',');
            }
            if(cWfCase.RecordTypeId == Cache.RecordTypeId(CaseManager.RT_NPI)) {

                if(cWfCase.Status == CaseManager.STATUS_SUBMITTED_FOR_REVIEW) {

                    cWfCase.Status = CaseManager.STATUS_GE_APPROVAL_PROCESS;
                }
                else if(cWfCase.Status == CaseManager.STATUS_RE_SUBMITTED_FOR_REVIEW) {

                    cWfCase.Status = CaseManager.STATUS_GE_APPROVAL_PROCESS;
                }
                else if(cWfCase.Status == CaseManager.STATUS_T1_RESUBMITTED) {

                    cWfCase.Status = CaseManager.STATUS_T1_GE_APPROVAL_PROCESS;
                }
                else if(cWfCase.Status == CaseManager.STATUS_T2_RESUBMITTED) {

                    cWfCase.Status = CaseManager.STATUS_T2_GE_APPROVAL_PROCESS;
                }
                else if(cWfCase.Status == CaseManager.STATUS_T0_CLOSED_APPROVED) {

                    cWfCase.Status = CaseManager.STATUS_T1_SAMPLES_NOT_SHIPPED;
                }
                else if(cWfCase.Status == CaseManager.STATUS_T1_SAMPLES_SHIPPED) {

                    cWfCase.Status = CaseManager.STATUS_T1_GE_APPROVAL_PROCESS;
                }
                else if(cWfCase.Status == CaseManager.STATUS_T2_SAMPLES_SHIPPED) {

                    cWfCase.Status = CaseManager.STATUS_T2_GE_APPROVAL_PROCESS;
                }
                else if(cWfCase.Status == CaseManager.STATUS_T1_SCHEDULING_REVIEW) {

                    cWfCase.Status = CaseManager.STATUS_T1_REVIEW_SCHEDULED;
                }
                else if(cWfCase.Status == CaseManager.STATUS_T1_REVIEW_SCHEDULED) {

                    cWfCase.Status = CaseManager.STATUS_T1_REVIEW_CONDUCTED;
                }
                else if(cWfCase.Status == CaseManager.STATUS_T1_REVIEW_CONDUCTED) {

                    cWfCase.Status = CaseManager.STATUS_T2_SAMPLES_NOT_SHIPPED;
                }
                else if(cWfCase.Status == CaseManager.STATUS_T2_SCHEDULING_REVIEW) {

                    cWfCase.Status = CaseManager.STATUS_T2_REVIEW_SCHEDULED;
                }
                else if(cWfCase.Status == CaseManager.STATUS_T2_REVIEW_SCHEDULED) {

                    cWfCase.Status = CaseManager.STATUS_T2_REVIEW_CONDUCTED;
                }
                else if(cWfCase.Status == CaseManager.STATUS_T2_REVIEW_CONDUCTED) {

                    cWfCase.Status = CaseManager.STATUS_T2_CLOSED_APPROVED;
                }
            }
            else if(cWfCase.RecordTypeId == Cache.RecordTypeId(CaseManager.RT_PRODUCT_CHANGE)) {

                if(cWfCase.Status == CaseManager.STATUS_SUBMITTED_FOR_REVIEW) {

                    cWfCase.Status = CaseManager.STATUS_SAMPLES_NOT_SHIPPED;
                }
                else if(cWfCase.Status == CaseManager.STATUS_SAMPLES_SHIPPED) {

                    cWfCase.Status = CaseManager.STATUS_GE_APPROVAL_PROCESS;
                }
                else if(cWfCase.Status == CaseManager.STATUS_RE_SUBMITTED_FOR_REVIEW) {

                    cWfCase.Status = CaseManager.STATUS_GE_APPROVAL_PROCESS;
                }
            }
            else {

                cWfCase.Status = CaseManager.STATUS_GE_APPROVAL_PROCESS;
            }
            update cWfCase;
            prResponse = new PageReference('/'+cWfCase.Id);
        }
        catch(Exception ex) {
            System.debug(LoggingLevel.ERROR, ex.getMessage() + '\n' + ex.getStackTraceString());
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error while adding the roles to the case. Please try again later.'));
            Database.rollback(sp);
        }
        System.debug(LoggingLevel.DEBUG, 'CaseCVWorkflowGatekeeperExtController - save end');
        return prResponse;
    }

    public PageReference cancel() {
        System.debug(LoggingLevel.DEBUG, 'CaseCVWorkflowGatekeeperExtController - cancel start');
        PageReference prResponse  = new PageReference('/'+cWfCase.Id);
        System.debug(LoggingLevel.DEBUG, 'CaseCVWorkflowGatekeeperExtController - cancel end');
        return prResponse;
    }
}