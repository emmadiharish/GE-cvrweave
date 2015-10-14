/******************************************************************************************************************************
* Name - CVWorkflowManager
* Description
* Manager class that contains all the methods and constants for handling CV Workflow logic.
* To be used as a single source of business logic methods and constants in order to ease reuse.
* Modification Log :
* ---------------------------------------------------------------------------
* Developer Date Description
* ---------------------------------------------------------------------------
* Zoran Zunko 05/06/2015 Created.
******************************************************************************************************************************/
public with sharing class CVWorkflowManager {

//******************************************************************************************************************************
//field constants
//******************************************************************************************************************************
    public static final String CV_ROLE_STATUS_FIELD_FORMAT = '{0}_Management_Workflow_Status__c';
    public static final String CV_ROLE_STATUS_DATE_FIELD_FORMAT = '{0}_MGT_Workflow_Status_Date__c';
    public static final String CV_ROLE_OWNER_FIELD_FORMAT = '{0}_MGT_Workflow_Owner__c';

    public static final List<String> fieldsToLoadBase = new List<String>{'Participating_Roles__c', 'RecordType.Name', 'RecordType.DeveloperName', 'Status', 'Finance_Management_Workflow_Status__c', 'Program_Management_Workflow_Status__c', 'Brand_Management_Workflow_Status__c', 'Tech_Safety_Management_Workflow_Status__c', 'Legal_Management_Workflow_Status__c', 'PR_Management_Workflow_Status__c', 'Comments__c'};

    /**
     * gets status field name related to the current user workflow role
     * @param  workflowRole workflow role for the current user
     * @return              API field name based on the CV_ROLE_STATUS_FIELD_FORMAT value
     */
    public static String getStatusFieldNameForRole(String workflowRole) {
        return String.format(CV_ROLE_STATUS_FIELD_FORMAT, new List<String>{workflowRole});
    }

    /**
     * gets status date field name related to the current user workflow role
     * @param  workflowRole workflow role for the current user
     * @return              API field name based on the CV_ROLE_STATUS_DATE_FIELD_FORMAT value
     */
    public static String getStatusDateFieldNameForRole(String workflowRole) {
        return String.format(CV_ROLE_STATUS_DATE_FIELD_FORMAT, new List<String>{workflowRole});
    }

    /**
     * gets owner field name related to the current user workflow role
     * @param  workflowRole workflow role for the current user
     * @return              API field name based on the CV_ROLE_OWNER_FIELD_FORMAT value
     */
    public static String getOwnerFieldNameForRole(String workflowRole) {
        return String.format(CV_ROLE_OWNER_FIELD_FORMAT, new List<String>{workflowRole});
    }

    /**
     * gets case status field value related to the current user workflow role
     * @param  workflowRole workflow role for the current user
     * @param  cLicenseeCase case to retrieve the field from.
     * @return              role status field value
     */
    public static String getStatusFieldValueForRole(String workflowRole, Case cLicenseeCase) {
        System.debug(LoggingLevel.DEBUG, 'CVWorkflowManager - getStatusFieldValueForRole start');
        System.debug(LoggingLevel.DEBUG, 'workflowRole: ' + workflowRole);
        System.debug(LoggingLevel.DEBUG, 'cLicenseeCase: ' + cLicenseeCase);
        System.debug(LoggingLevel.DEBUG, 'roleStatus: ' + cLicenseeCase.get(getStatusFieldNameForRole(workflowRole)));
        System.debug(LoggingLevel.DEBUG, 'CVWorkflowManager - getStatusFieldValueForRole end');

        return (String) cLicenseeCase.get(getStatusFieldNameForRole(workflowRole));
    }

    public static void setStatusFieldValueForRole(String workflowRole, Case cLicenseeCase, String roleStatus) {
        System.debug(LoggingLevel.DEBUG, 'CVWorkflowManager - setStatusFieldValueForRole start');
        System.debug(LoggingLevel.DEBUG, 'workflowRole: ' + workflowRole);
        System.debug(LoggingLevel.DEBUG, 'cLicenseeCase: ' + cLicenseeCase);
        System.debug(LoggingLevel.DEBUG, 'roleStatus: ' + roleStatus);
        cLicenseeCase.put(getStatusFieldNameForRole(workflowRole), roleStatus);
        System.debug(LoggingLevel.DEBUG, 'CVWorkflowManager - setStatusFieldValueForRole end');
    }

    public static void setStatusDateFieldValueForRole(String workflowRole, Case cLicenseeCase) {
        System.debug(LoggingLevel.DEBUG, 'CVWorkflowManager - setStatusDateFieldValueForRole start');
        System.debug(LoggingLevel.DEBUG, 'workflowRole: ' + workflowRole);
        System.debug(LoggingLevel.DEBUG, 'cLicenseeCase: ' + cLicenseeCase);
        cLicenseeCase.put(getStatusDateFieldNameForRole(workflowRole), Date.today());
        System.debug(LoggingLevel.DEBUG, 'CVWorkflowManager - setStatusDateFieldValueForRole end');
    }

    public static void setOwnerFieldValueForRole(String workflowRole, Case cLicenseeCase, Id userId) {
        System.debug(LoggingLevel.DEBUG, 'CVWorkflowManager - setOwnerFieldValueForRole start');
        System.debug(LoggingLevel.DEBUG, 'workflowRole: ' + workflowRole);
        System.debug(LoggingLevel.DEBUG, 'cLicenseeCase: ' + cLicenseeCase);
        cLicenseeCase.put(getOwnerFieldNameForRole(workflowRole), userId);
        System.debug(LoggingLevel.DEBUG, 'CVWorkflowManager - setOwnerFieldValueForRole end');
    }

    public static Set<String> getCVCaseRoleSet(Case cvCase) {
        if(cvCase.Participating_Roles__c  != null ) {
            return new Set<String>(cvCase.Participating_Roles__c.split(','));
        }
        return new Set<String>();
    }

    public static Boolean checkRoleFieldExists(String workflowRole) {
        System.debug(LoggingLevel.DEBUG, 'CVWorkflowManager - checkRoleFieldExists start');
        System.debug(LoggingLevel.DEBUG, 'getStatusFieldNameForRole(workflowRole): ' + Schema.SObjectType.Case.fields.getMap().get(getStatusFieldNameForRole(workflowRole)));
        System.debug(LoggingLevel.DEBUG, 'CVWorkflowManager - checkRoleFieldExists end');
        return (Schema.SObjectType.Case.fields.getMap().get(getStatusFieldNameForRole(workflowRole)) != null 
                && Schema.SObjectType.Case.fields.getMap().get(getStatusDateFieldNameForRole(workflowRole)) != null);
    }

    public static Boolean checkWorkflowRoleStatusDifferent(Case cOldLicenseeCase, Case cNewLicenseeCase) {
        System.debug(LoggingLevel.DEBUG, 'CVWorkflowManager - checkWorkflowRoleStatusDifferent start');
        System.debug(LoggingLevel.DEBUG, 'no roles change: ' + cOldLicenseeCase.Participating_Roles__c == cNewLicenseeCase.Participating_Roles__c);

        if((cOldLicenseeCase.Participating_Roles__c == cNewLicenseeCase.Participating_Roles__c) && (cOldLicenseeCase.Status == cNewLicenseeCase.Status)) {
            for(String wfRole : getCVCaseRoleSet(cNewLicenseeCase)) {
                System.debug(LoggingLevel.DEBUG, 'new role status: ' + getStatusFieldValueForRole(wfRole, cNewLicenseeCase));
                System.debug(LoggingLevel.DEBUG, 'old role status: ' + getStatusFieldValueForRole(wfRole, cOldLicenseeCase));
                if((getStatusFieldValueForRole(wfRole, cNewLicenseeCase) != CaseManager.STATUS_ROLE_GE_ACTION_REQUIRED) &&  (getStatusFieldValueForRole(wfRole, cNewLicenseeCase) != getStatusFieldValueForRole(wfRole, cOldLicenseeCase)) ) {
                    return true;
                }
            }
        }
        System.debug(LoggingLevel.DEBUG, 'CVWorkflowManager - checkWorkflowRoleStatusDifferent end');
        return false;
    }

}