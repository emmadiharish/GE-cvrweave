/******************************************************************************************************************************
* Name - TH_Case_StartExternalLegal
* Description
* Case trigger handler for Consumer Ventures Workflow cases
* TODO
* Modification Log :
* ---------------------------------------------------------------------------
* Developer Date Description
* ---------------------------------------------------------------------------
* Zoran Zunko 06/10/2015 Created.
******************************************************************************************************************************/
public with sharing class TH_Case_StartExternalLegal implements GE_TriggerDispatch.ITriggerEntry {

    List<Case> caseNewList;
    List<Case> caseOldList;
    Map<ID, Case> caseNewMap;
    Map<ID, Case> caseOldMap;
    Set<String> externalLegalCaseTriggers;

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
        if(IsAfter && IsUpdate) {
            externalLegalCaseTriggers = CVInternalLegalParametersManager.getExternalLegalKickoffSet(UserInfo.getUserId());
            cCVCaseList = CaseManager.getCVInternalLegalCases(caseNewList);
            createExternalLegalCases(cCVCaseList);
        }
    }

    /**
     * Secondary entry point - called if this class was the primary trigger and causes a secondary trigger
     */
    public void inProgressEntry(String TriggerObject, Boolean IsBefore, Boolean IsDelete, Boolean IsAfter, Boolean IsInsert, Boolean IsUpdate, Boolean IsExecuting, List<SObject> newList, Map<ID, SObject> newMap, List<SObject> oldList, Map<ID,SObject> oldMap) {
        System.debug(LoggingLevel.DEBUG, 'TH_Case_StartExternalLegal - inProgressEntry start');
        System.debug(LoggingLevel.DEBUG, 'TH_Case_StartExternalLegal - inProgressEntry end');
    }

    public Map<String, String> getTriggerContext() {
        System.debug(LoggingLevel.DEBUG, 'TH_Case_StartExternalLegal - GetTriggerContext start');
        Map<String, String> response = new Map<String, String>();
        response.put('name', 'TH_Case_StartExternalLegal');
        System.debug(LoggingLevel.DEBUG, 'TH_Case_StartExternalLegal - GetTriggerContext end');
        return response;

    }

    private void createExternalLegalCases(List<Case> internalApprovedCases) {

        //TODO: set owners?

        List<Case> externalLegalCases = new List<Case> ();
        Set<Id> licenseeIdSet = new Set<Id> ();
        for(Case cInternalLegalCase : internalApprovedCases) {
            licenseeIdSet.add(cInternalLegalCase.AccountId);
        }

        Map<Id, User> licenseeContactUserMap = new Map<Id, User> ();
        for(User uLicenseeUser : CommunityUserManager.getCommunityUsersForLicenseeIds(new List<Id> (licenseeIdSet))) {
            licenseeContactUserMap.put(uLicenseeUser.ContactId, uLicenseeUser);
        }

        for(Case cInternalLegal : internalApprovedCases) {

            if(externalLegalCaseTriggers.contains(cInternalLegal.Request_Type__c)) {

                if(licenseeContactUserMap.get(cInternalLegal.ContactId) != null) {

                    externalLegalCases.add(CaseManager.setExternalLegalCaseFields(cInternalLegal, licenseeContactUserMap.get(cInternalLegal.ContactId).Id));
                }
                else {

                    cInternalLegal.addError('Licensee Contact assigned to the case is not an active Community user, please set the Contact to an active Licensee Contact');
                }
            }
        }

        insert externalLegalCases;
    }

}