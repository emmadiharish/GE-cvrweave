/******************************************************************************************************************************
* Name - CVUtilityFns

* Description - This class does the following:
    - common Utility methods must be static.

* Modification Log :
* ---------------------------------------------------------------------------
* Developer Date Description
* ---------------------------------------------------------------------------
* Siva Gunda 10/13/2015 Created.
******************************************************************************************************************************/

public with sharing class CVUtilityFns {
    //  printGovernorLimits            : Print in debuglog the current governor limits (scriptstatements, queries, exec time)
    //  triggerLabel                   : Returns a convenient display label for debugging of current Trigger context
    
    //  ----------------------------------------
    //  PUBLIC UTILITYFNS METHODS
    //  ----------------------------------------
    //  -----------------------------------------------
    //  triggerLabel: optimized for script statement minimization
    //  -----------------------------------------------
    public static String triggerLabel() {
        if (Trigger.isExecuting) {
        if (Trigger.isUpdate) return (Trigger.isBefore ? 'before' : 'after') + 'Update()';
        if (Trigger.isInsert) return (Trigger.isBefore ? 'before' : 'after') + 'Insert()';
        if (Trigger.isDelete) return (Trigger.isBefore ? 'before' : 'after') + 'Delete()';
        if (Trigger.isBefore) return 'unknown trigger state';
        else          return 'afterUndelete';
        }
        return '';
    }
    
    //  --------------------------------------------------------
    //  printGovernorLimits          : Print in debuglog the current governor limits (scriptstatements, queries, exec time)
    //  --------------------------------------------------------
    public static void printGovernorLimits(String executionPoint) {
        Long    prevCurrentTimeMs   = CVFlowControl.CURRENT_TIME_MS;
        Long    CurrentTimeMs       = System.currentTimeMillis();
        System.debug(LoggingLevel.INFO,'\n\n================GOVERNOR LIMITS=======================' +
                    '\n   at execution point: '+ executionPoint + 
                    '\n   ' + Limits.getCpuTime() + ' out of limit:' + Limits.getLimitCpuTime() +
                    '\n   ' + Limits.getQueries() + ' out of limit:' + Limits.getLimitQueries() +
                    '\n   ' + (CurrentTimeMs - prevCurrentTimeMs)/1000.0 + ' ss.mmm since last Governor Limits display ' +
                    '\n=========================================================' +
                    '\n\n');
        CVFlowControl.CURRENT_TIME_MS = CurrentTimeMs;            
                    
    }

}