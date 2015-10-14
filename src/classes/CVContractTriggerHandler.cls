/******************************************************************************************************************************
* Name - CVContractTriggerHandler

* Description - This class does the following:
    - Trigger handler for Contract trigger.

* Modification Log :
* ---------------------------------------------------------------------------
* Developer     Date            Description
* ---------------------------------------------------------------------------
* Siva Gunda    10/13/2015      Created.
******************************************************************************************************************************/

public without sharing class CVContractTriggerHandler implements CVITrigger {
  
    //  -----------------------------
    //  PRIVATE VARIABLES
    //  -----------------------------
    private CVContractGateway      cGw;            // Reference to object containing related records collected prior to pass through each triggered Tag
    private List<CV_Royalty_Payment_Tracking__c> rpttobedeletedList = new List<CV_Royalty_Payment_Tracking__c>();
    private List<CV_Sales_Report_Tracking__c> srtobedeletedList = new List<CV_Sales_Report_Tracking__c>();
    private List<CV_Royalty_Payment_Tracking__c> rpttobeinsertedList = new List<CV_Royalty_Payment_Tracking__c>();
    private List<CV_Sales_Report_Tracking__c> srtobeinsertedList = new List<CV_Sales_Report_Tracking__c>();

    //  -----------------------------
    //  CONSTRUCTOR
    //  -----------------------------
    public CVContractTriggerHandler() {}

    // -------------------------------
    // bulkBefore: This method is called prior to execution of a BEFORE trigger. Use this to cache any data required into maps prior execution of the trigger.   
    // -------------------------------
    public void bulkBefore() {
        Map<Id, Contract> OldMap = new Map<Id, Contract>();
        if(Trigger.isUpdate || Trigger.isDelete)
        {
            for(SObject c : Trigger.OldMap.values())
                OldMap.put(c.Id, (Contract)c);
        }
        this.cGw          = new CVContractGateway(Trigger.isUpdate || Trigger.isInsert? Trigger.new : Trigger.old, OldMap);
        if (CVFlowControl.runContractTriggerHandler())
            this.cGw.initialize();
    }

    // -------------------------------
    // bulkAfter: This method is called prior to execution of an AFTER trigger. Use this to cache any data required into maps prior execution of the trigger.
    // ------------------------------- 
    public void bulkAfter() {
        Map<Id, Contract> OldMap = new Map<Id, Contract>();
        if(Trigger.isUpdate || Trigger.isDelete)
        {
            for(SObject c: Trigger.OldMap.values())
                OldMap.put(c.Id, (Contract)c);
        }
        
        this.cGw          = new CVContractGateway(Trigger.isUpdate || Trigger.isInsert? Trigger.new : Trigger.old, OldMap);
        if (CVFlowControl.runContractTriggerHandler())
            this.cGw.initialize();
    }

    // -------------------------------
    // beforeInsert: This method is called iteratively for each record to be inserted during a BEFORE trigger. Never execute any SOQL/SOSL etc in this and other iterative methods.  
    // ------------------------------- 
    public void beforeInsert(SObject sobj) {
        Contract c            = (Contract) sobj;
        sharedBefore(c,null);
    }

    // -------------------------------
    // beforeUpdate: This method is called iteratively for each record to be updated during a BEFORE trigger. Never execute any SOQL/SOSL etc in this and other iterative methods.
    // -------------------------------   
    public void beforeUpdate(SObject oldSobj, SObject sobj) {
        Contract c            = (Contract ) sobj;
        Contract  cOld        = (Contract ) oldSobj;
        sharedBefore(c, cOld);
    }

    //  --------------------------------
    //  sharedBefore
    //  --------------------------------
    private void sharedBefore(Contract c, Contract cOld) {
        CVContractWrapper cW         = new CVContractWrapper (c, cOld);
        System.debug(CVFlowControl.getLogLevel(),'\n\n***ENTERING ContractTriggerHandler ' + CVUtilityFns.triggerLabel() );    // validate has the debug statement
        cW.validate(this.cGw);
        cW.derive(this.cGw);
        System.debug(CVFlowControl.getLogLevel(),'\n\n***LEAVING AgreementTriggerHandler ' + CVUtilityFns.triggerLabel() );    // validate has the debug statement
    }


    // -------------------------------
    // beforeDelete: This method is called iteratively for each record to be deleted during a BEFORE trigger. Never execute any SOQL/SOSL etc in this and other iterative methods.
    // -------------------------------   
    public void beforeDelete(SObject sobj) {
        Contract c    = (Contract) sobj;
    }

    // -------------------------------
    // afterInsert: This method is called iteratively for each record inserted during an AFTER trigger.  The record is 'read only' by this point.
    // -------------------------------
    public void afterInsert(SObject sobj) {
        Contract   c       = (Contract) sobj;
        CVContractWrapper   cW      = new CVContractWrapper(c, null);
        this.rpttobeinsertedList = cW.addtorpttobeinsertedList(this.cGW, this.rpttobeinsertedList);
        this.srtobeinsertedList = cW.addtosrtobeinsertedList(this.cGW, this.srtobeinsertedList);
    }

    // -------------------------------
    // afterUpdate: This method is called iteratively for each record updated during an AFTER trigger. The record is 'read only' by this point. 
    // -------------------------------
    public void afterUpdate(SObject oldSobj, SObject sobj){
        Contract   c             = (Contract) sobj;
        Contract  cOld           = (Contract ) oldSobj;
        CVContractWrapper cW     = new CVContractWrapper(c, cOld);
        this.rpttobedeletedList  = cW.addtorpttobedeletedList(this.cGW, this.rpttobedeletedList);
        this.srtobedeletedList   = cW.addtosrtobedeletedList(this.cGW, this.srtobedeletedList);
        this.rpttobeinsertedList = cW.addtorpttobeinsertedList(this.cGW, this.rpttobeinsertedList);
        this.srtobeinsertedList  = cW.addtosrtobeinsertedList(this.cGW, this.srtobeinsertedList);
    }

    // -------------------------------
    // afterDelete: This method is called iteratively for each record deleted during an AFTER trigger.  The record is 'read only' by this point.
    // -------------------------------
    public void afterDelete(SObject sobj) {
        Contract   c       = (Contract) sobj;
    }

    // -------------------------------
    // afterUndelete: This method is called iteratively for each record deleted during an AFTER trigger.  The record is 'read only' by this point.
    // -------------------------------
    public void afterUndelete(SObject sobj) {
        Contract   c       = (Contract) sobj;
    }


    // -------------------------------
    // andFinally: This method is called once all records have been processed by the trigger. Use this method to accomplish any final operations such as creation or updates of other records.
    // -------------------------------   
    public void andFinally() {
        // disable for now because we want the trigger to run once again after schedules are created.
        // CVFlowControl.setRunContractTriggerHandler(false);        // turn off triggers on Contract
        
        System.debug('Deleting royalty payments count: '+this.rpttobedeletedList.size());
        // delete Royalty payment trackings.
        if(!rpttobedeletedList.isEmpty())
            delete this.rpttobedeletedList;

        System.debug('Deleting sales report count: '+this.srtobedeletedList.size());
        // delete Sales Report trackings.
        if(!srtobedeletedList.isEmpty())
            delete this.srtobedeletedList;

        System.debug('Inserting royalty payments count: '+this.rpttobeinsertedList.size());
        // create Royalty payment trackings.
        if(!rpttobeinsertedList.isEmpty())
            insert this.rpttobeinsertedList;

        System.debug('Inserting sales report count: '+this.srtobeinsertedList.size());
        // create Sales Report trackings.
        if(!srtobeinsertedList.isEmpty())
            insert this.srtobeinsertedList;
        
        CVFlowControl.resetAll();
    }

}