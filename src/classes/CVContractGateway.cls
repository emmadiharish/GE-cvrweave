/******************************************************************************************************************************
* Name - CVContractGateway

* Description - This class does the following:
    - used to query and store objects required for execution of Contract trigger.

* Modification Log :
* ---------------------------------------------------------------------------
* Developer     Date            Description
* ---------------------------------------------------------------------------
* Siva Gunda    10/13/2015      Created.
******************************************************************************************************************************/

public without sharing class CVContractGateway{

    private List<Contract> cList; // Contracts in trigger list
    private Map<Id, Contract> cIdtocOldMap;
    
    public Map<Id, Contract> cIdToCWRelRecsMap  = new Map<Id, Contract>();
    public Map<Id, CV_Due_Date_Rule__c> ddrIdtoddrMap = new Map<Id, CV_Due_Date_Rule__c>();

    //  --------------------------------------------
    //  CONSTRUCTOR
    //  --------------------------------------------
    public CVContractGateway(List<Contract> cList, Map<Id, Contract> cIdtocOldMap) {
        this.cList            = cList;
        this.cIdtocOldMap     = cIdtocOldMap;
    }

    //  --------------------------------------------
    //  initialize
    //  --------------------------------------------
    public void initialize() {
        System.debug(CVFlowControl.getLogLevel(),'ENTERING CVContractGateway.initialize');
        if (Trigger.isExecuting && Trigger.isBefore)
        {
            if(Trigger.isUpdate)
            {
                this.cIdToCWRelRecsMap = buildcIdToCWRelRecsMap();   
            }
        }
        else if(Trigger.isExecuting && Trigger.isAfter)
        {
            if(Trigger.isUpdate)
            {
                this.cIdToCWRelRecsMap = buildcIdToCWRelRecsMap();
                this.ddrIdtoddrMap = buildddrIdtoddrMap();
            }
            else if(Trigger.isInsert)
            {
                this.ddrIdtoddrMap = buildddrIdtoddrMap();
            }
        }
        System.debug(CVFlowControl.getLogLevel(),'LEAVINGCVContractGateway.initialize');
    }

    //  -------------------------------------------
    //  buildcIdToCWRelRecsMap:  Map of contract Id to Contract w/ CV_Royalty_Payment_Tracking__c, CV_Sales_Report_Tracking__c and other as needed related records
    //  -------------------------------------------
    private Map<Id, Contract> buildcIdToCWRelRecsMap(){
        System.debug(CVFlowControl.getLogLevel(),'ENTERING buildcIdToCWRelRecsMap');
        Set<Id>         cIdSet       = new Set<Id> ();
        Map<Id, Contract>  res = new Map<ID, Contract> ();
        for (Contract c : this.cList)
        {
            if(Trigger.isAfter)
            {
                Contract cOld = this.cIdtocOldMap.get(c.Id);
                if(c.RecordTypeId == CVMetaUtils.getRecordTypeId(Contract.sObjectType, CVCONSTANTS.C_RT_AGREEMENT)
                    && (c.StartDate != cOld.StartDate
                        || c.EndDate != cOld.EndDate
                        || c.Royalty_Payment_Due_Date_Rule__c != cOld.Royalty_Payment_Due_Date_Rule__c
                        || c.Sales_Report_Due_Date_Rule__c != cOld.Sales_Report_Due_Date_Rule__c))
                    cIdSet.add(c.id);
            }
            else
                cIdSet.add(c.id);
        }
        if(!cIdSet.isEmpty())
        {
            res          = new Map<Id, Contract> ([select Id, Name,   
                                                        (Select Id, isReceived__c, ActualDate__c 
                                                                From CVRoyaltyPaymentTracking__r
                                                                    Order by EndDate__c),
                                                        (Select Id, isReceived__c, ActualDate__c
                                                                From CVSalesReportTracking__r
                                                                    Order by EndDate__c)
                                                                    From Contract where id IN :cIdSet]  );
        }
        System.debug(CVFlowControl.getLogLevel(),'LEAVING buildcIdToCWRelRecsMap res keyset is: '+res.keySet());
        return res;
    }

    //  -------------------------------------------
    //  buildddrIdtoddrMap:  Map of Due Date Rule Id to Due Date Rule.
    //  -------------------------------------------
    private Map<Id, CV_Due_Date_Rule__c> buildddrIdtoddrMap(){
        System.debug(CVFlowControl.getLogLevel(),'ENTERING buildddrIdtoddrMap');

        Set<Id>                       ddrIdSet      = new Set<Id> ();
        Map<Id, CV_Due_Date_Rule__c>  res           = new Map<ID, CV_Due_Date_Rule__c> ();
        
        
        // use cIdtocOldMap.isEmpty() to differentiate between insert and update.
        // query only when Royalty_Payment_Due_Date_Rule__c, Sales_Report_Due_Date_Rule__c are not null. 
        // query when startDate, endDate or due date rules are changed so be aware while accessing.
        for (Contract c : this.cList) 
        {
            if(c.RecordTypeId == CVMetaUtils.getRecordTypeId(Contract.sObjectType, CVCONSTANTS.C_RT_AGREEMENT))
            {    
                Contract cOld = this.cIdtocOldMap.get(c.Id);
                if(cOld == null
                    ||( c.StartDate != cOld.StartDate
                        || c.EndDate != cOld.EndDate
                        || c.Royalty_Payment_Due_Date_Rule__c != cOld.Royalty_Payment_Due_Date_Rule__c
                        || c.Sales_Report_Due_Date_Rule__c != cOld.Sales_Report_Due_Date_Rule__c))
                {
                    if(c.Royalty_Payment_Due_Date_Rule__c != null)
                        ddrIdSet.add(c.Royalty_Payment_Due_Date_Rule__c);
                    if(c.Sales_Report_Due_Date_Rule__c != null)
                        ddrIdSet.add(c.Sales_Report_Due_Date_Rule__c);
                }
            }
        }

        if(!ddrIdSet.isEmpty())
        {
            // CVCustomDueDates__r query should be ordered by Period_End_Date__c else order of schedule creation will change.
            res =  new Map<ID, CV_Due_Date_Rule__c>([select Id, isStandard__c, Days__c, Period__c,
                                                        (Select Period_Start_Date__c, Period_End_Date__c, Due_Date__c 
                                                            From CVCustomDueDates__r
                                                                Order by Period_End_Date__c)
                                                            From CV_Due_Date_Rule__c 
                                                                Where Id IN :ddrIdSet]);
        }

        System.debug(CVFlowControl.getLogLevel(),'LEAVING buildddrIdtoddrMap res keyset is: '+res.keySet());
        return res;
    }
}