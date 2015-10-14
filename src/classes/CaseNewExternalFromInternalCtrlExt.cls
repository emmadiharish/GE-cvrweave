/******************************************************************************************************************************
* Name - CaseNewExternalFromInternalCtrlExt
* @description
* Controller Extension for creation of new External Legal from the Internal Legal Case
* Modification Log :
* ---------------------------------------------------------------------------
* Developer Date Description
* ---------------------------------------------------------------------------
* Zoran Zunko 07/24/2015 Created.
******************************************************************************************************************************/
public with sharing class CaseNewExternalFromInternalCtrlExt {

//******************************************************************************************************************************
//controller properties
//******************************************************************************************************************************

    @testVisible public Case cInternalLegal {get; private set;}

    @testVisible List<String> caseFields = new List<String> {'ContactId'
                                                             , 'AccountId'
                                                             , 'Request_Type__c'
                                                             , 'CV_Agreement_No_Name__c'
                                                             , 'Amendment_Change_Type__c'
                                                             , 'Description'
                                                             , 'Amendment_Change_Other__c'
                                                             , 'Subject'
                                                             , 'Status'
                                                             , 'Id'
                                                             , 'Participating_Roles__c'
                                                         };
//******************************************************************************************************************************
	public CaseNewExternalFromInternalCtrlExt(ApexPages.StandardController stdController) {

        System.debug(LoggingLevel.DEBUG, 'CaseNewExternalFromInternalCtrlExt - constructor start');
        if(!Test.isRunningTest()) stdController.addFields(caseFields);
        cInternalLegal = (Case)stdController.getRecord();

        System.debug(LoggingLevel.DEBUG, 'CaseNewInternalLegalControllerExt - constructor end');
	}

    /**
     * checks if the Internal Legal Case is closed
     * checks if the Internal Legal Case is valid for start of External Legal Case
     * @return Detail page for created new External Legal case or displayes error message
     */
    public PageReference createExternalLegalCase() {

        System.debug(LoggingLevel.DEBUG, 'CaseNewExternalFromInternalCtrlExt - createExternalLegalCase start');
        try {

            if(cInternalLegal.Status != CaseManager.STATUS_CLOSED_APPROVED) {

                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'New External Legal can be started only from Approved Internal Legal Workflow.'));
                return null;
            }
            Set<String> externalLegalCaseTriggers = CVInternalLegalParametersManager.getExternalLegalKickoffSet(UserInfo.getUserId());
            if(!externalLegalCaseTriggers.contains(cInternalLegal.Request_Type__c)) {

                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Internal Legal Request Type: ' +  cInternalLegal.Request_Type__c + ' New External Legal can be started only from the follwoing Request Type values: ' + String.join(new List<String> (externalLegalCaseTriggers), ', ')));
                return null;
            }
            else {

                Map<Id, User> licenseeContactUserMap = new Map<Id, User> ();
                for(User uLicenseeUser : CommunityUserManager.getCommunityUsersForLicenseeId(cInternalLegal.AccountId)) {
                    licenseeContactUserMap.put(uLicenseeUser.ContactId, uLicenseeUser);
                }
                if(licenseeContactUserMap.get(cInternalLegal.ContactId) != null) {

                    Case cExternalLegal = CaseManager.setExternalLegalCaseFields(cInternalLegal, licenseeContactUserMap.get(cInternalLegal.ContactId).Id);
                    insert cExternalLegal;

                    return new PageReference('/' + cExternalLegal.Id);
                }
                else {

                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Licensee Contact assigned to the case is not an active Community user, please set the Contact to an active Licensee Contact and try again.'));
                    return null;
                }
            }
        }
        catch(Exception ex) {

            System.debug(LoggingLevel.ERROR, ex.getMessage() + '\n' + ex.getStackTraceString());
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error while loading the page please try again later.'));
        }
        System.debug(LoggingLevel.DEBUG, 'CaseNewExternalFromInternalCtrlExt - createExternalLegalCase end');
        return null;
    }
}