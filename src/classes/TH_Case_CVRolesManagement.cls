/******************************************************************************************************************************
* Name - TH_Case_CVRolesManagement
* Description
* Case trigger handler for Consumer Ventures Workflow cases
* TODO
* Modification Log :
* ---------------------------------------------------------------------------
* Developer Date Description
* ---------------------------------------------------------------------------
* Zoran Zunko 06/10/2015 Created.
******************************************************************************************************************************/
public with sharing class TH_Case_CVRolesManagement implements GE_TriggerDispatch.ITriggerEntry {

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
        if(IsBefore && (IsInsert || IsUpdate)) {
            cCVCaseList = CaseManager.getCVCases(caseNewList);
        }
        System.debug(LoggingLevel.DEBUG, 'cCVCaseList: ' + cCVCaseList);
        if(IsBefore && IsInsert) {
            setMandatoryRoles(cCVCaseList);
        }
        if(IsBefore && (IsInsert || IsUpdate)) {
            setCVRoleStatuses(cCVCaseList);
        }
        if(IsBefore && IsUpdate) {
            setNewCVRoleStatuses(cCVCaseList);
            calculateCVWorkflowStatus(cCVCaseList);
        }
        System.debug(caseNewList);

    }

    /**
     * Secondary entry point - called if this class was the primary trigger and causes a secondary trigger
     */
    public void inProgressEntry(String TriggerObject, Boolean IsBefore, Boolean IsDelete, Boolean IsAfter, Boolean IsInsert, Boolean IsUpdate, Boolean IsExecuting, List<SObject> newList, Map<ID, SObject> newMap, List<SObject> oldList, Map<ID,SObject> oldMap) {
        System.debug(LoggingLevel.DEBUG, 'TH_Case_CVRolesManagement - inProgressEntry start');
        System.debug(LoggingLevel.DEBUG, 'TH_Case_CVRolesManagement - inProgressEntry end');
    }

    public Map<String, String> getTriggerContext() {
        System.debug(LoggingLevel.DEBUG, 'TH_Case_CVRolesManagement - GetTriggerContext start');
        Map<String, String> response = new Map<String, String>();
        response.put('name', 'TH_Case_CVRolesManagement');
        System.debug(LoggingLevel.DEBUG, 'TH_Case_CVRolesManagement - GetTriggerContext end');
        return response;

    }

    @testVisible private void setMandatoryRoles(List<Case> cCVCaseList) {
        System.debug(LoggingLevel.DEBUG, 'TH_Case_CVRolesManagement - setMandatoryRoles start');

        Map<Id, RecordType> cCVCaseRecordTypesMap = CaseManager.getCaseRecordTypeIdMapForCaseIds(cCVCaseList);

        for(Case cCVCase: cCVCaseList) {
            List<String> caseMandatoryRoles = CVWorkflowConfigurationManager.getMandatoryRolesForWorkflow(cCVCaseRecordTypesMap.get(cCVCase.RecordTypeId).DeveloperName);
            if(caseMandatoryRoles == null || caseMandatoryRoles.size() == 0) {
                cCVCase.addError(cCVCaseRecordTypesMap.get(cCVCase.RecordTypeId).Name + ' workflow has not been properly configured. Please contact Consumer Ventures administrator.');
            }
            else if(String.isBlank(cCVCase.Participating_Roles__c)){
                cCVCase.Participating_Roles__c = String.join(caseMandatoryRoles, ',');
            }
        }

        System.debug(LoggingLevel.DEBUG, 'TH_Case_CVRolesManagement - setMandatoryRoles end');
    }

    @testVisible private void setCVRoleStatuses(List<Case> cCVCaseList) {
        System.debug(LoggingLevel.DEBUG, 'TH_Case_CVRolesManagement - setCVRoleStatuses start');

        for(Case cCVCase: cCVCaseList) {
            //check if the status has been changed to submitted or re-submitted insert treated as status change
            System.debug(LoggingLevel.DEBUG, 'cCVCase.Status: ' + cCVCase.Status);
            System.debug(LoggingLevel.DEBUG, 'caseOldMap: ' + caseOldMap);
            if(
                (
                    CaseManager.getGeRoleStatusResetStatuses().contains(cCVCase.Status)
                )
                &&
                (
                    (caseOldMap == null)
                    || (cCVCase.Status != caseOldMap.get(cCVCase.Id).Status)
                )
              ) {
                for(String cvWFRole : CVWorkflowManager.getCVCaseRoleSet(cCVCase)) {
                    CVWorkflowManager.setStatusFieldValueForRole(cvWFRole, cCVCase, CaseManager.STATUS_ROLE_GE_ACTION_REQUIRED);
                }
            }
        }

        System.debug(LoggingLevel.DEBUG, 'TH_Case_CVRolesManagement - setCVRoleStatuses end');
    }

    @testVisible private void setNewCVRoleStatuses(List<Case> cCVCaseList) {
        /*System.debug(LoggingLevel.DEBUG, 'TH_Case_CVRolesManagement - setNewCVRoleStatuses start');

        for(Case cCVCase: cCVCaseList) {
            //check if the status has been changed to submitted or re-submitted insert treated as status change
            System.debug(LoggingLevel.DEBUG, 'cCVCase.Status: ' + cCVCase.Status);
            System.debug(LoggingLevel.DEBUG, 'caseOldMap: ' + caseOldMap);
            //check if case roles have been added
            if(cCVCase.Participating_Roles__c != caseOldMap.get(cCVCase.Id).Participating_Roles__c) {
                Set<String> oldRoles = CVWorkflowManager.getCVCaseRoleSet(caseOldMap.get(cCVCase.Id));
                Set<String> newRoles = CVWorkflowManager.getCVCaseRoleSet(cCVCase);
                System.debug(LoggingLevel.DEBUG, 'oldRoles: ' + oldRoles);
                System.debug(LoggingLevel.DEBUG, 'newRoles: ' + newRoles);
                for(String newRole : newRoles) {
                    if(!oldRoles.contains(newRole)) {
                        if(CVWorkflowManager.checkRoleFieldExists(newRole)) {
                            CVWorkflowManager.setStatusFieldValueForRole(newRole, cCVCase, CaseManager.STATUS_ROLE_GE_ACTION_REQUIRED);
                        }
                        else if(!Test.isRunningTest()){
                            cCVCase.addError('Role: ' + newRole + ' is not CV workflow defined role. Please contact your System Adminsitrator.');
                        }
                    }
                }
            }
        }

        System.debug(LoggingLevel.DEBUG, 'TH_Case_CVRolesManagement - setNewCVRoleStatuses end');*/
    }

    @testVisible private void calculateCVWorkflowStatus(List<Case> cCVCaseList) {
        System.debug(LoggingLevel.DEBUG, 'TH_Case_CVRolesManagement - calculateCVWorkflowStatus start');

        for(Case cCVCase: cCVCaseList) {
            if(CVWorkflowManager.checkWorkflowRoleStatusDifferent(caseOldMap.get(cCVCase.Id), cCVCase)) {
                Set<String> wfRoles = CVWorkflowManager.getCVCaseRoleSet(cCVCase);
                Set<String> wfRoleStatuses = new Set<String>();
                System.debug(LoggingLevel.DEBUG, 'wfRoles: ' + wfRoles);
                for(String wfRole : wfRoles) {
                    wfRoleStatuses.add(CVWorkflowManager.getStatusFieldValueForRole(wfRole, cCVCase));
                }
                System.debug(LoggingLevel.DEBUG, 'wfRoleStatuses: ' + wfRoleStatuses);
                if(wfRoleStatuses.contains(CaseManager.STATUS_ROLE_GE_ACTION_REQUIRED)) {
                    continue;
                }
                if(cCVCase.RecordTypeId == Cache.RecordTypeId(CaseManager.RT_NPI)) {

                    if(cCVCase.Status == CaseManager.STATUS_GE_APPROVAL_PROCESS) {

                        if(wfRoleStatuses.contains(CaseManager.STATUS_ROLE_REJECTED)) {
                            cCVCase.Status = CaseManager.STATUS_CLOSED_REJECTED;
                        }
                        else if(wfRoleStatuses.contains(CaseManager.STATUS_ROLE_LICENSEE_RESPONSE_NEEDED)) {
                            cCVCase.Status = CaseManager.STATUS_LICENSEE_RESPONSE_NEEDED;
                        }
                        else {
                            cCVCase.Status = CaseManager.STATUS_T0_CLOSED_APPROVED;
                        }
                    }
                    else if(cCVCase.Status == CaseManager.STATUS_T1_GE_APPROVAL_PROCESS) {

                        if(wfRoleStatuses.contains(CaseManager.STATUS_ROLE_REJECTED)) {
                            cCVCase.Status = CaseManager.STATUS_T1_CLOSED_REJECTED;
                        }
                        else if(wfRoleStatuses.contains(CaseManager.STATUS_ROLE_LICENSEE_RESPONSE_NEEDED)) {
                            cCVCase.Status = CaseManager.STATUS_T1_LICENSEE_FEEDBACK_REQUIRED;
                        }
                        else {

                            cCVCase.Status = CaseManager.STATUS_T1_SCHEDULING_REVIEW;
                        }
                    }
                    else if(cCVCase.Status == CaseManager.STATUS_T2_GE_APPROVAL_PROCESS) {

                        if(wfRoleStatuses.contains(CaseManager.STATUS_ROLE_REJECTED)) {
                            cCVCase.Status = CaseManager.STATUS_T2_CLOSED_REJECTED;
                        }
                        else if(wfRoleStatuses.contains(CaseManager.STATUS_ROLE_LICENSEE_RESPONSE_NEEDED)) {
                            cCVCase.Status = CaseManager.STATUS_T2_LICENSEE_FEEDBACK_REQUIRED;
                        }
                        else {

                            cCVCase.Status = CaseManager.STATUS_T2_SCHEDULING_REVIEW;
                        }
                    }

                }
                else {

                    if(wfRoleStatuses.contains(CaseManager.STATUS_ROLE_REJECTED)) {
                        cCVCase.Status = CaseManager.STATUS_CLOSED_REJECTED;
                    }
                    else if(wfRoleStatuses.contains(CaseManager.STATUS_ROLE_LICENSEE_RESPONSE_NEEDED)) {
                        cCVCase.Status = CaseManager.STATUS_LICENSEE_RESPONSE_NEEDED;
                    }
                    else {
                        cCVCase.Status = CaseManager.STATUS_CLOSED_APPROVED;
                    }
                }
            }
            System.debug(LoggingLevel.DEBUG, 'cCVCase.Status: ' + cCVCase.Status);
        }

        System.debug(LoggingLevel.DEBUG, 'TH_Case_CVRolesManagement - calculateCVWorkflowStatus end');
    }
}