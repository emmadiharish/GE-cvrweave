/******************************************************************************************************************************
* Name - CVFlowControl

* Description - This class does the following:
    - Control the trigger execution flow.

* Modification Log :
* ---------------------------------------------------------------------------
* Developer Date Description
* ---------------------------------------------------------------------------
* Siva Gunda 10/13/2015 Created.
******************************************************************************************************************************/

public class CVFlowControl {
    //---------------------------Application Automation Trigger Control--------------------------
    private static boolean runContractTriggerHandler = true;
    
    //Return the run trigger boolean   
    public static boolean runContractTriggerHandler()  {return runContractTriggerHandler ;}
    
    //  For Governor limits debugging
    public static    Long  CURRENT_TIME_MS                          = 0;
    private static LoggingLevel  logLevel                           = LoggingLevel.INFO;
    
    //  Dynamically set logging Level to avoid setup noise in long logs
    public static LoggingLevel getLogLevel()             {return logLevel;}
    public static void  setLogLevel(LoggingLevel lvl)    {logLevel =  lvl; System.debug(LoggingLevel.INFO,'>>>>>>>>>>Debug level set to ' + lvl + ' <<<<<<<<<<<');}
    
    //Set the run Trigger boolean
    public static void resetAll() {
        setRunContractTriggerHandler(true);
    }
    
    public static void setRunContractTriggerHandler(boolean value){
        if(value == true)      runContractTriggerHandler = true;
        else                   runContractTriggerHandler = false; 
    }
}