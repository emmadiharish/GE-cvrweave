/******************************************************************************************************************************
* Name - CVWorkflowGeneralParametersManager
* Description
* Manager class that contains all the methods and constants for handling CV Workflow Geenral Settings custom settings.
* To be used as a single source of business logic and data loading methods in order to ease reuse.
* Modification Log :
* ---------------------------------------------------------------------------
* Developer Date Description
* ---------------------------------------------------------------------------
* Zoran Zunko 08/26/2015 Created.
******************************************************************************************************************************/
public with sharing class CVWorkflowGeneralParametersManager {

    @testVisible private static CV_Workflow_General_Parameters__c cvwgpGlobalSettings;

    /**
     * get the countries in Set<String> format
     * @return        list of countries as defined in the countries custom setting
     */
    public static Set<String> getCountries() {

        if(!Test.isRunningTest() || cvwgpGlobalSettings == null) cvwgpGlobalSettings = CV_Workflow_General_Parameters__c.getOrgDefaults();

        if(cvwgpGlobalSettings.CV_Countries__c == null) {
            return new Set<String>();
        }

        Set<String> response = new Set<String>();

        for(String country :cvwgpGlobalSettings.CV_Countries__c.replace('\n', '').replace('\r', '').replace('\t', '').split(',')) {

            response.add(country.trim());
        }

        return response;
    }
}