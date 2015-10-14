/******************************************************************************************************************************
* Name - CVWorkflowConfigurationManager
* Description
* Manager class that contains all the methods and constants for handling CV Workflow Configuration custom settings.
* To be used as a single source of business logic and data loading methods in order to ease reuse.
* Modification Log :
* ---------------------------------------------------------------------------
* Developer Date Description
* ---------------------------------------------------------------------------
* Zoran Zunko 06/09/2015 Created.
******************************************************************************************************************************/
public with sharing class CVWorkflowConfigurationManager {

    @testVisible private static Map<String, CVWorkflowConfiguration__c> cvwcWorkflowConfiguration;

    public static Map<String, CVWorkflowConfiguration__c> getCvwcWorkflowConfiguration() {
        if(cvwcWorkflowConfiguration == null) {
            cvwcWorkflowConfiguration = CVWorkflowConfiguration__c.getAll();
        }
        return cvwcWorkflowConfiguration;
    }

    //todo: add configuration for number of attachments

    public static List<String> getAvailableRolesForWorkflow(String workflowName) {
        if(getCvwcWorkflowConfiguration().get(workflowName) != null) {
            return cvwcWorkflowConfiguration.get(workflowName).Allowed_Roles__c.replace(' ', '').replace('\n', '').replace('\r', '').replace('\t', '').split(',');
        }
        return new List<String>();
    }

    public static List<String> getMandatoryRolesForWorkflow(String workflowName) {
        if(getCvwcWorkflowConfiguration().get(workflowName) != null) {
            return cvwcWorkflowConfiguration.get(workflowName).Mandatory_Roles__c.replace(' ', '').replace('\n', '').replace('\r', '').replace('\t', '').split(',');
        }
        return new List<String>();
    }
}