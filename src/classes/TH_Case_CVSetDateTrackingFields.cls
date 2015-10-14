/******************************************************************************************************************************
* Name - TH_Case_CVSetDateTrackingFields
* Description
* Case trigger handler for Consumer Ventures Workflow cases which executes before Insert and Update,
* sets the role date field values for a particular case
* MUST be run after TH_Case_CVRolesManagement
* TODO
* Modification Log :
* ---------------------------------------------------------------------------
* Developer Date Description
* ---------------------------------------------------------------------------
* Zoran Zunko 08/05/2015 Created.
******************************************************************************************************************************/
public with sharing class TH_Case_CVSetDateTrackingFields implements GE_TriggerDispatch.ITriggerEntry {

    List<Case> caseNewList;
    List<Case> caseOldList;
    Map<ID, Case> caseNewMap;
    Map<ID, Case> caseOldMap;

    /**
     * Main Entry point - only called on the first trigger instance
     */
    public void mainEntry(String TriggerObject, Boolean IsBefore, Boolean IsDelete, Boolean IsAfter, Boolean IsInsert, Boolean IsUpdate, Boolean IsExecuting, List<SObject> newList, Map<ID, SObject> newMap, List<SObject> oldList, Map<ID,SObject> oldMap) {

        caseNewList = (List<Case>)newList;
        caseOldList = (List<Case>)oldList;
        caseNewMap = (Map<ID,Case>)newMap;
        caseOldMap = (Map<ID,Case>)oldMap;

        List<Case> cCVCaseList = new List<Case>();

        System.debug(LoggingLevel.DEBUG, 'caseNewList: ' + caseNewList);
        System.debug(LoggingLevel.DEBUG, 'caseOldList: ' + caseOldList);
        if(IsBefore && (IsInsert || IsUpdate)) {
            cCVCaseList = CaseManager.getCVCases(caseNewList);
        }
        System.debug(LoggingLevel.DEBUG, 'cCVCaseList: ' + cCVCaseList);
        if(IsBefore && IsInsert) {
            setRoleDateChangedFieldsNewCase(cCVCaseList);
            setStatusDateChangedFieldNewCase(cCVCaseList);
        }
        if(IsBefore && IsUpdate) {

            setRoleDateChangedFieldsUpdatedCase(cCVCaseList);
            setStatusDateChangedFieldUpdatedCase(cCVCaseList);
        }
        System.debug(caseNewList);

    }

    /**
     * Secondary entry point - called if this class was the primary trigger and causes a secondary trigger
     */
    public void inProgressEntry(String TriggerObject, Boolean IsBefore, Boolean IsDelete, Boolean IsAfter, Boolean IsInsert, Boolean IsUpdate, Boolean IsExecuting, List<SObject> newList, Map<ID, SObject> newMap, List<SObject> oldList, Map<ID,SObject> oldMap) {
        System.debug(LoggingLevel.DEBUG, 'TH_Case_CVSetDateTrackingFields - inProgressEntry start');
        System.debug(LoggingLevel.DEBUG, 'TH_Case_CVSetDateTrackingFields - inProgressEntry end');
    }

    public Map<String, String> getTriggerContext() {
        System.debug(LoggingLevel.DEBUG, 'TH_Case_CVSetDateTrackingFields - GetTriggerContext start');
        Map<String, String> response = new Map<String, String>();
        response.put('name', 'TH_Case_CVSetDateTrackingFields');
        System.debug(LoggingLevel.DEBUG, 'TH_Case_CVSetDateTrackingFields - GetTriggerContext end');
        return response;

    }

    /**
     * sets the status changed date field on new cv cases to the today date
     * @param  cCVCaseList List of CV cases
     */
    @testVisible private void setStatusDateChangedFieldNewCase(List<Case> cCVCaseList) {
        System.debug(LoggingLevel.DEBUG, 'TH_Case_CVSetDateTrackingFields - setStatusDateChangedFieldsNewCase start');

        for(Case cCVCase: cCVCaseList) {

                cCVCase.Status_Date__c = Date.today();
        }

        System.debug(LoggingLevel.DEBUG, 'TH_Case_CVSetDateTrackingFields - setStatusDateChangedFieldsNewCase end');
    }

    /**
     * sets the status changed date field on updated cv cases to the today date
     * @param  cCVCaseList List of CV cases
     */
    @testVisible private void setStatusDateChangedFieldUpdatedCase(List<Case> cCVCaseList) {
        System.debug(LoggingLevel.DEBUG, 'TH_Case_CVSetDateTrackingFields - setStatusDateChangedFieldsNewCase start');

        for(Case cCVCase: cCVCaseList) {

            if(cCVCase.Status != caseOldMap.get(cCVCase.Id).Status) {

                cCVCase.Status_Date__c = Date.today();
            }
        }

        System.debug(LoggingLevel.DEBUG, 'TH_Case_CVSetDateTrackingFields - setStatusDateChangedFieldsNewCase end');
    }

    /**
     * gets the participating roles list, and for every role status fields that participates in the workflow sets the value of the date changed field for the role
     * @param  cCVCaseList List of CV cases that have a role workflow status field changed.
     */
    @testVisible private void setRoleDateChangedFieldsNewCase(List<Case> cCVCaseList) {
        System.debug(LoggingLevel.DEBUG, 'TH_Case_CVSetDateTrackingFields - setRoleDateChangedFieldsNewCase start');

        for(Case cCVCase: cCVCaseList) {

                Set<String> roles = CVWorkflowManager.getCVCaseRoleSet(cCVCase);
                System.debug(LoggingLevel.DEBUG, 'roles: ' + roles);
                for(String role : roles) {
                    //System.debug(LoggingLevel.DEBUG, 'CVWorkflowManager.checkRoleFieldExists(role): ' + CVWorkflowManager.checkRoleFieldExists(role));
                    //System.debug(LoggingLevel.DEBUG, 'CVWorkflowManager.getStatusFieldValueForRole(role, cCVCase): ' + CVWorkflowManager.getStatusFieldValueForRole(role, cCVCase));
                    if(CVWorkflowManager.checkRoleFieldExists(role) && CVWorkflowManager.getStatusFieldValueForRole(role, cCVCase) != CVWorkflowSettingsManager.ROLE_NA) {

                        CVWorkflowManager.setStatusDateFieldValueForRole(role, cCVCase);
                        System.debug(LoggingLevel.DEBUG, 'role: ' + role);
                        System.debug(LoggingLevel.DEBUG, 'CVWorkflowSettingsManager.getCVWorkflowUsersByWorkflowAndRole().get(cCVCase.RecordTypeId): ' + CVWorkflowSettingsManager.getCVWorkflowUsersByWorkflowAndRole().get(cCVCase.RecordTypeId));

                        if(CVWorkflowSettingsManager.getCVWorkflowUsersByWorkflowAndRole().get(cCVCase.RecordTypeId) != null && CVWorkflowSettingsManager.getCVWorkflowUsersByWorkflowAndRole().get(cCVCase.RecordTypeId).get(role) != null /*&& CVWorkflowSettingsManager.getCVWorkflowUsersByWorkflowAndRole().get(cCVCase.RecordTypeId).get(role) != CVWorkflowSettingsManager.ROLE_NA*/) {

                            System.debug(LoggingLevel.DEBUG, 'CVWorkflowSettingsManager.getCVWorkflowUsersByWorkflowAndRole().get(cCVCase.RecordTypeId).get(role): ' + CVWorkflowSettingsManager.getCVWorkflowUsersByWorkflowAndRole().get(cCVCase.RecordTypeId).get(role));
                            CVWorkflowManager.setOwnerFieldValueForRole(role, cCVCase, CVWorkflowSettingsManager.getCVWorkflowUsersByWorkflowAndRole().get(cCVCase.RecordTypeId).get(role));
                        }
                        else if(!Test.isRunningTest()){

                            cCVCase.addError('Role: ' + role + ' is not CV workflow defined role. Please contact your System Adminstrator.');
                        }
                    }
                    else if(!CVWorkflowManager.checkRoleFieldExists(role)){

                        cCVCase.addError('Role: ' + role + ' is not CV workflow defined role. Please contact your System Adminstrator.');
                    }
                }
        }

        System.debug(LoggingLevel.DEBUG, 'TH_Case_CVSetDateTrackingFields - setRoleDateChangedFieldsNewCase end');
    }

    /**
     * gets the changed roles status list, and for every role status fields that participates in the workflow sets the value of the date changed field for the role
     * @param  cCVCaseList List of CV cases that have a role workflow status field changed.
     */
    @testVisible private void setRoleDateChangedFieldsUpdatedCase(List<Case> cCVCaseList) {
        System.debug(LoggingLevel.DEBUG, 'TH_Case_CVSetDateTrackingFields - setRoleDateChangedFieldsUpdatedCase start');

        for(Case cCVCase: cCVCaseList) {

                Set<String> changedRoles = getCaseChangedStatusRoles(cCVCase, CVWorkflowManager.getCVCaseRoleSet(cCVCase));
                System.debug(LoggingLevel.DEBUG, 'changedRoles: ' + changedRoles);
                for(String role : changedRoles) {

                    if(CVWorkflowManager.checkRoleFieldExists(role)) {

                        CVWorkflowManager.setStatusDateFieldValueForRole(role, cCVCase);
                    }
                    else {

                        cCVCase.addError('Role: ' + role + ' is not CV workflow defined role. Please contact your System Adminstrator.');
                    }
                }
        }

        System.debug(LoggingLevel.DEBUG, 'TH_Case_CVSetDateTrackingFields - setRoleDateChangedFieldsUpdatedCase end');
    }

    /**
     * checks whether the case role status has been updated and returns a list of case roles for which the status has been changed
     * @param  cCVCase Case to check
     * @param  caseRoles set of participating roles
     * @return             Set of CV workflow roles that have the role status value changed
     */
    @testVisible private Set<String> getCaseChangedStatusRoles(Case cCVCase, Set<String> caseRoles) {
        System.debug(LoggingLevel.DEBUG, 'TH_Case_CVSetDateTrackingFields - getCaseChangedStatusRoles start');

        Set<String> response = new Set<String>();

        for(String caseRole: caseRoles) {

            System.debug(LoggingLevel.DEBUG, 'caseRole: ' + caseRole);
            System.debug(LoggingLevel.DEBUG, 'CVWorkflowManager.getStatusFieldNameForRole(caseRole): ' + CVWorkflowManager.getStatusFieldNameForRole(caseRole));
            System.debug(LoggingLevel.DEBUG, 'caseOldMap.get(cCVCase.Id): ' + caseOldMap.get(cCVCase.Id));
            System.debug(LoggingLevel.DEBUG, 'caseOldMap.get(cCVCase.Id).get(CVWorkflowManager.getStatusFieldNameForRole(caseRole)): ' + caseOldMap.get(cCVCase.Id).get(CVWorkflowManager.getStatusFieldNameForRole(caseRole)));

            if(cCVCase.get(CVWorkflowManager.getStatusFieldNameForRole(caseRole)) == null || !cCVCase.get(CVWorkflowManager.getStatusFieldNameForRole(caseRole)).equals(caseOldMap.get(cCVCase.Id).get(CVWorkflowManager.getStatusFieldNameForRole(caseRole)))) {

                response.add(caseRole);
            }
        }

        System.debug(LoggingLevel.DEBUG, 'response: ' + response);
        System.debug(LoggingLevel.DEBUG, 'TH_Case_CVSetDateTrackingFields - getCaseChangedStatusRoles end');
        return response;
    }


}