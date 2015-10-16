/******************************************************************************************************************************
* Name - GE_TriggerDispatch
* Description
* trigger dispatch class
* Modification Log :
* ---------------------------------------------------------------------------
* Developer Date Description
* ---------------------------------------------------------------------------
* Zoran Zunko 06/09/2015 Created.
* Siva Gunda 10/15/2015 - Added Contract trigger handlers.
******************************************************************************************************************************/
public with sharing class GE_TriggerDispatch {

    // Holds a reference to the currently executing trigger
    public static ITriggerEntry activefunction = null;

    // Code control of no triggers
    public static Boolean noTriggers = FALSE;


    public interface ITriggerEntry {
        void mainEntry(String TriggerObject, Boolean IsBefore, Boolean IsDelete, Boolean IsAfter, Boolean IsInsert, Boolean IsUpdate, Boolean IsExecuting, List<SObject> newList, Map<ID, SObject> newMap, List<SObject> oldList, Map<ID,SObject> oldMap);
        void inProgressEntry(String TriggerObject, Boolean IsBefore, Boolean IsDelete, Boolean IsAfter, Boolean IsInsert, Boolean IsUpdate, Boolean IsExecuting, List<SObject> newList, Map<ID, SObject> newMap, List<SObject> oldList, Map<ID,SObject> oldMap);
        Map<String, String> getTriggerContext();
    }

    public static void entry(String TriggerObject, Boolean IsBefore, Boolean IsDelete, Boolean IsAfter, Boolean IsInsert, Boolean IsUpdate, Boolean IsExecuting, List<SObject> newList, Map<ID, SObject> newMap, List<SObject> oldList, Map<ID,SObject> oldMap) {
        System.debug(LoggingLevel.DEBUG, 'GE_TriggerDispatch - entry start');
        System.debug(LoggingLevel.DEBUG, 'activefunction: ' + activefunction);
        System.debug(LoggingLevel.DEBUG, 'noTriggers: ' + noTriggers);
        // Check if triggers have been disabled by another class
        if (!noTriggers) {
            /* Check if triggers are disabled for this user
            NoTriggers__c noUserTriggers = NoTriggers__c.getInstance(UserInfo.getUserId());
            if (noUserTriggers.Flag__c) {
                return;
            }*/

            debugContext(TriggerObject, IsBefore, IsDelete, IsAfter, IsInsert, IsUpdate);

            // If we were called as the result of an already executing trigger, pass control to the InProgressEntry method of that
            // trigger and let it decide what to do.
            if (activefunction != null) {
                activefunction.InProgressEntry(TriggerObject, IsBefore, IsDelete, IsAfter, IsInsert, IsUpdate, IsExecuting, newList, newMap, oldList, oldMap);
                return;
            }

            if (TriggerObject == 'Case') {
                activefunction = new TH_Case_CVRolesManagement();
                activefunction.MainEntry(TriggerObject, IsBefore, IsDelete, IsAfter, IsInsert, IsUpdate, IsExecuting, newList, newMap, oldList, oldMap);
                activefunction = new TH_Case_CVSetDateTrackingFields();
                activefunction.MainEntry(TriggerObject, IsBefore, IsDelete, IsAfter, IsInsert, IsUpdate, IsExecuting, newList, newMap, oldList, oldMap);
                activefunction = null;
            }else if (TriggerObject == 'Contract') {
                activefunction = new TH_Contract_CVManageSchedules();
                activefunction.MainEntry(TriggerObject, IsBefore, IsDelete, IsAfter, IsInsert, IsUpdate, IsExecuting, newList, newMap, oldList, oldMap);
                activefunction = null;
            }else if(TriggerObject == 'Object API'){
                // Otherwise call the triggers we want to execute
            }
        }
        System.debug(LoggingLevel.DEBUG, 'GE_TriggerDispatch - entry end');
    }

    /**
     * Debug the context for the trigger call
     *
     * Helps us to know which triggers are forwarded by what
     */
    public static void debugContext(String TriggerObject, Boolean IsBefore, Boolean IsDelete, Boolean IsAfter, Boolean IsInsert, Boolean IsUpdate) {

        // Get some context string variables for debugging
        String beforeAfter = IsBefore ? 'BEFORE' : 'AFTER';
        String dmlOperation;
        if (IsUpdate) {
            dmlOperation = 'UPDATE';
        }
        else if (IsInsert) {
            dmlOperation = 'INSERT';
        }
        else if (IsDelete) {
            dmlOperation = 'DELETE';
        }

        if (activefunction != null) {
            System.debug('*** TRIGGER: ' + beforeAfter + ' ' + dmlOperation + ' trigger on ' + TriggerObject + ' caused by ' + activeFunction.GetTriggerContext().get('name'));
            return;
        }
        else {
            System.debug('*** TRIGGER: ' + beforeAfter + ' ' + dmlOperation + ' trigger on ' + TriggerObject);
        }

    }

}