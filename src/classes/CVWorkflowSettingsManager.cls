/******************************************************************************************************************************
* Name - CVWorkflowSettingsManager
* Description
* Manager class that contains all the methods and constants for handling CV Workflow Settings custom settings.
* To be used as a single source of business logic and data loading methods in order to ease reuse.
* Modification Log :
* ---------------------------------------------------------------------------
* Developer Date Description
* ---------------------------------------------------------------------------
* Zoran Zunko 05/06/2015 Created.
******************************************************************************************************************************/
public with sharing class CVWorkflowSettingsManager {

    public static final String ROLE_PROGRAM = 'Program';
    public static final String ROLE_FINANCE = 'Finance';
    public static final String ROLE_LICENSEE = 'Licensee';
    public static final String ROLE_BRAND = 'Brand';
    public static final String ROLE_TECH_SAFETY = 'Tech_Safety';
    public static final String ROLE_REGIONAL = 'Regional';
    public static final String ROLE_LEGAL = 'Legal';
    public static final String ROLE_NA = 'N/A';

    @testVisible private static CV_Workflow_Settings__c cvwsUserSettings;

    /**
     * get the role of the user in the Royalty Workflow. If no setting is defined for a given user returns N/A
     * @param  userId Id of the user for which setting value needs to be returned
     * @return        setting value defined for a given user id, N/A if no value is defined
     */
    public static String getRoyaltyWorkflowRoleForUser(Id userId) {

        if(!Test.isRunningTest() || cvwsUserSettings == null) cvwsUserSettings = CV_Workflow_Settings__c.getInstance(userId);

        if(cvwsUserSettings.CV_Royalty_Workflow_Role__c == null) {
            return ROLE_NA;
        }

        return cvwsUserSettings.CV_Royalty_Workflow_Role__c;
    }

    /**
     * get the role of the user in the Brand Change Workflow. If no setting is defined for a given user returns N/A
     * @param  userId Id of the user for which setting value needs to be returned
     * @return        setting value defined for a given user id, N/A if no value is defined
     */
    public static String getBrandChangeWorkflowRoleForUser(Id userId) {

        if(!Test.isRunningTest() || cvwsUserSettings == null) cvwsUserSettings = CV_Workflow_Settings__c.getInstance(userId);

        if(cvwsUserSettings.CV_Brand_Change_Workflow_Role__c == null) {
            return ROLE_NA;
        }

        return cvwsUserSettings.CV_Brand_Change_Workflow_Role__c;
    }

    /**
     * get the role of the user in the Product Change Workflow. If no setting is defined for a given user returns N/A
     * @param  userId Id of the user for which setting value needs to be returned
     * @return        setting value defined for a given user id, N/A if no value is defined
     */
    public static String getProductChangeWorkflowRoleForUser(Id userId) {

        if(!Test.isRunningTest() || cvwsUserSettings == null) cvwsUserSettings = CV_Workflow_Settings__c.getInstance(userId);

        if(cvwsUserSettings.CV_Product_Change_Workflow_Role__c == null) {
            return ROLE_NA;
        }

        return cvwsUserSettings.CV_Product_Change_Workflow_Role__c;
    }

    /**
     * get the role of the user in the Ancillary Brand Approval Workflow. If no setting is defined for a given user returns N/A
     * @param  userId Id of the user for which setting value needs to be returned
     * @return        setting value defined for a given user id, N/A if no value is defined
     */
    public static String getAncillaryBrandWorkflowRoleForUser(Id userId) {

        if(!Test.isRunningTest() || cvwsUserSettings == null) cvwsUserSettings = CV_Workflow_Settings__c.getInstance(userId);

        if(cvwsUserSettings.CV_Ancillary_Brand_Workflow_Role__c == null) {
            return ROLE_NA;
        }

        return cvwsUserSettings.CV_Ancillary_Brand_Workflow_Role__c;
    }

    /**
     * get the role of the user in the External Legal Workflow. If no setting is defined for a given user returns N/A
     * @param  userId Id of the user for which setting value needs to be returned
     * @return        setting value defined for a given user id, N/A if no value is defined
     */
    public static String getExternalLegalWorkflowRoleForUser(Id userId) {

        if(!Test.isRunningTest() || cvwsUserSettings == null) cvwsUserSettings = CV_Workflow_Settings__c.getInstance(userId);

        if(cvwsUserSettings.CV_External_Legal_Workflow_Role__c == null) {
            return ROLE_NA;
        }

        return cvwsUserSettings.CV_External_Legal_Workflow_Role__c;
    }

    /**
     * get the role of the user in the Internal Legal Workflow. If no setting is defined for a given user returns N/A
     * @param  userId Id of the user for which setting value needs to be returned
     * @return        setting value defined for a given user id, N/A
     */
    public static String getInternalLegalWorkflowRoleForUser(Id userId) {

        if(!Test.isRunningTest() || cvwsUserSettings == null) cvwsUserSettings = CV_Workflow_Settings__c.getInstance(userId);

        if(cvwsUserSettings.CV_Internal_Legal_Workflow_Role__c == null) {
            return ROLE_NA;
        }

        return cvwsUserSettings.CV_Internal_Legal_Workflow_Role__c;
    }

    /**
     * get the role of the user in the NPI Workflow. If no setting is defined for a given user returns N/A
     * @param  userId Id of the user for which setting value needs to be returned
     * @return        setting value defined for a given user id, N/A
     */
    public static String getNPIWorkflowRoleForUser(Id userId) {

        if(!Test.isRunningTest() || cvwsUserSettings == null) cvwsUserSettings = CV_Workflow_Settings__c.getInstance(userId);

        if(cvwsUserSettings.CV_NPI_Workflow_Role__c == null) {
            return ROLE_NA;
        }

        return cvwsUserSettings.CV_NPI_Workflow_Role__c;
    }

    @testVisible private static Map<String, Map<String, Id>> cVWorkflowUsersByWorkflowAndRole;
    public static Map<String, Map<String, Id>> getCVWorkflowUsersByWorkflowAndRole() {

        if(cVWorkflowUsersByWorkflowAndRole == null) {

            cVWorkflowUsersByWorkflowAndRole = new Map<String, Map<String, Id>>();

            for(String caseRecordType : CaseManager.caseRecordTypeIdSet) {

                cVWorkflowUsersByWorkflowAndRole.put(Cache.RecordTypeId(caseRecordType), new Map<String, Id> ());
            }

            List<CV_Workflow_Settings__c> workflowSettingRecords = [SELECT 
                                                                        CV_Ancillary_Brand_Workflow_Role__c
                                                                        , CV_Brand_Change_Workflow_Role__c
                                                                        , CV_External_Legal_Workflow_Role__c
                                                                        , CV_Internal_Legal_Workflow_Role__c
                                                                        , CV_Product_Change_Workflow_Role__c
                                                                        , CV_Royalty_Workflow_Role__c
                                                                        , CV_NPI_Workflow_Role__c
                                                                        , SetupOwnerId
                                                                    FROM CV_Workflow_Settings__c
                                                                    ORDER BY SetupOwner.LastName  //this way we get the alphabetical first
                                                                    ];
            //todo: double check the process once there are multiple users assigned
            for(CV_Workflow_Settings__c wfSetting : workflowSettingRecords) {

                if(String.valueOf(wfSetting.SetupOwnerId).startsWith('005')) {

                    if(!String.isBlank(wfSetting.CV_Ancillary_Brand_Workflow_Role__c) && wfSetting.CV_Ancillary_Brand_Workflow_Role__c != ROLE_NA) {
                        cVWorkflowUsersByWorkflowAndRole.get(Cache.RecordTypeId(CaseManager.RT_ANCILLARY_BRAND)).put(wfSetting.CV_Ancillary_Brand_Workflow_Role__c, wfSetting.SetupOwnerId);
                    }

                    if(!String.isBlank(wfSetting.CV_Brand_Change_Workflow_Role__c) && wfSetting.CV_Brand_Change_Workflow_Role__c != ROLE_NA) {
                        cVWorkflowUsersByWorkflowAndRole.get(Cache.RecordTypeId(CaseManager.RT_BRAND_CHANGE)).put(wfSetting.CV_Brand_Change_Workflow_Role__c, wfSetting.SetupOwnerId);
                    }

                    if(!String.isBlank(wfSetting.CV_External_Legal_Workflow_Role__c) && wfSetting.CV_External_Legal_Workflow_Role__c != ROLE_NA) {
                        cVWorkflowUsersByWorkflowAndRole.get(Cache.RecordTypeId(CaseManager.RT_EXTERNAL_LEGAL)).put(wfSetting.CV_External_Legal_Workflow_Role__c, wfSetting.SetupOwnerId);
                    }

                    if(!String.isBlank(wfSetting.CV_Internal_Legal_Workflow_Role__c) && wfSetting.CV_Internal_Legal_Workflow_Role__c != ROLE_NA) {
                        cVWorkflowUsersByWorkflowAndRole.get(Cache.RecordTypeId(CaseManager.RT_INTERNAL_LEGAL)).put(wfSetting.CV_Internal_Legal_Workflow_Role__c, wfSetting.SetupOwnerId);
                    }

                    if(!String.isBlank(wfSetting.CV_Product_Change_Workflow_Role__c) && wfSetting.CV_Product_Change_Workflow_Role__c != ROLE_NA) {
                        cVWorkflowUsersByWorkflowAndRole.get(Cache.RecordTypeId(CaseManager.RT_PRODUCT_CHANGE)).put(wfSetting.CV_Product_Change_Workflow_Role__c, wfSetting.SetupOwnerId);
                    }

                    if(!String.isBlank(wfSetting.CV_Royalty_Workflow_Role__c) && wfSetting.CV_Royalty_Workflow_Role__c != ROLE_NA) {
                        cVWorkflowUsersByWorkflowAndRole.get(Cache.RecordTypeId(CaseManager.RT_ROYALTY_SUBMISSION)).put(wfSetting.CV_Royalty_Workflow_Role__c, wfSetting.SetupOwnerId);
                    }

                    if(!String.isBlank(wfSetting.CV_NPI_Workflow_Role__c) && wfSetting.CV_NPI_Workflow_Role__c != ROLE_NA) {
                        cVWorkflowUsersByWorkflowAndRole.get(Cache.RecordTypeId(CaseManager.RT_NPI)).put(wfSetting.CV_NPI_Workflow_Role__c, wfSetting.SetupOwnerId);
                    }
                }

            }
        }
        return cVWorkflowUsersByWorkflowAndRole;
    }
}