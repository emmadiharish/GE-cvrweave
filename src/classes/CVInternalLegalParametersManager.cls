/******************************************************************************************************************************
* Name - CVInternalLegalParametersManager
* Description
* Manager class that contains all the methods and constants for handling CV Workflow Settings custom settings.
* To be used as a single source of business logic and data loading methods in order to ease reuse.
* Modification Log :
* ---------------------------------------------------------------------------
* Developer Date Description
* ---------------------------------------------------------------------------
* Zoran Zunko 07/20/2015 Created.
******************************************************************************************************************************/
public with sharing class CVInternalLegalParametersManager {

    @testVisible private static CV_Internal_Legal_Parameters__c cvInternalLegalParameters;
    /**
     * reurns the CV Internal Legal Parameters values as a Set
     * @param  userId the user context
     * @return        Set<String> with values split by ','
     */
    public static Set<String> getExternalLegalKickoffSet(Id userId) {
        if(!Test.isRunningTest()) cvInternalLegalParameters = CV_Internal_Legal_Parameters__c.getInstance(userId);

        if(cvInternalLegalParameters.External_Legal_Kickoff_Condition__c == null) {
            return new Set<String> ();
        }

        return new Set<String>(cvInternalLegalParameters.External_Legal_Kickoff_Condition__c.replace('\n', '').replace('\r', '').replace('\t', '').split(','));
    }
}