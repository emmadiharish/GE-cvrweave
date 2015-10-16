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
public with sharing class TH_Contract_CVManageSchedules {
	List<Contract> contractNewList;
    List<Contract> contractOldList;
    Map<ID, Contract> contractNewMap;
    Map<ID, Contract> contractOldMap;

    /**
     * Main Entry point - only called on the first trigger instance
     */
    public void mainEntry(String TriggerObject, Boolean IsBefore, Boolean IsDelete, Boolean IsAfter, Boolean IsInsert, Boolean IsUpdate, Boolean IsExecuting, List<SObject> newList, Map<ID, SObject> newMap, List<SObject> oldList, Map<ID,SObject> oldMap) {

        contractNewList = (List<Contract>)newList;
        contractNewList = (List<Contract>)oldList;
        contractNewMap = (Map<ID,Contract>)newMap;
        contractOldMap = (Map<ID,Contract>)oldMap;

        List<Contract> cAgreementContractList = new List<Contract>();
        Map<Id, Contract> agreementsMap = new Map<Id, Contract>();
        Map<Id, CV_Due_Date_Rule__c> ddrIdtoddrMap = new Map<Id, CV_Due_Date_Rule__c>();

        System.debug(LoggingLevel.DEBUG, 'contractNewList: ' + contractNewList);
        System.debug(LoggingLevel.DEBUG, 'agreementsMap: ' + agreementsMap);
        System.debug(LoggingLevel.DEBUG, 'ddrIdtoddrMap: ' + ddrIdtoddrMap);

        if(IsBefore && (IsInsert || IsUpdate)) {
            cAgreementContractList = ContractManager.getAgreements(contractNewList);
            Set<Id> agreementIdSet = new Set<Id>();
            for(Contract c : cAgreementContractList){
                agreementIdSet.add(c.Id);
            }
            
            agreementsMap = ContractManager.getContractswRelListsbycId(agreementIdSet);
        }

        if(IsAfter && (IsInsert || IsUpdate))
        {
            cAgreementContractList = ContractManager.getAgreements(contractNewList);
            Set<Id> ddrIdSet = getChangedDueDateRuleIds(cAgreementContractList);

            ddrIdtoddrMap = DueDateRuleManager.getDueDateRulewCustomDatesMapbyId(ddrIdSet);
        }

        System.debug(LoggingLevel.DEBUG, 'contractNewList: ' + contractNewList);
        System.debug(LoggingLevel.DEBUG, 'agreementsMap: ' + agreementsMap);
        System.debug(LoggingLevel.DEBUG, 'ddrIdtoddrMap: ' + ddrIdtoddrMap);

        if(IsBefore && IsInsert) {
            
        }
        if(IsBefore && (IsInsert || IsUpdate)) {
            setNextRoyaltyPayment(cAgreementContractList, agreementsMap);
            setNextSalesReport(cAgreementContractList, agreementsMap);
        }
        if(IsBefore && IsUpdate) {
            
        }

        if(IsAfter && (IsUpdate || IsInsert))
        {
            createRevenuePaymentSchedules(cAgreementContractList, ddrIdtoddrMap);
            createSalesReportSchedules(cAgreementContractList, ddrIdtoddrMap);
        }
        System.debug(contractNewList);

    }

    /**
     * Secondary entry point - called if this class was the primary trigger and causes a secondary trigger
     */
    public void inProgressEntry(String TriggerObject, Boolean IsBefore, Boolean IsDelete, Boolean IsAfter, Boolean IsInsert, Boolean IsUpdate, Boolean IsExecuting, List<SObject> newList, Map<ID, SObject> newMap, List<SObject> oldList, Map<ID,SObject> oldMap) {
        System.debug(LoggingLevel.DEBUG, 'TH_Contract_CVManageSchedules - inProgressEntry start');
        System.debug(LoggingLevel.DEBUG, 'TH_Contract_CVManageSchedules - inProgressEntry end');
    }

    public Map<String, String> getTriggerContext() {
        System.debug(LoggingLevel.DEBUG, 'TH_Contract_CVManageSchedules - GetTriggerContext start');
        Map<String, String> response = new Map<String, String>();
        response.put('name', 'TH_Contract_CVManageSchedules');
        System.debug(LoggingLevel.DEBUG, 'TH_Contract_CVManageSchedules - GetTriggerContext end');
        return response;

    }

    private void setNextRoyaltyPayment(List<Contract> cAgreementContractList, Map<Id, Contract> agreementsMap){
        // Derivation 2 : populate Next Royalty Payment on Contract based in isReceived__c flag.
        //                Assumption : Royalty payments will be received in order.
        
        System.debug(LoggingLevel.DEBUG, 'TH_Contract_CVManageSchedules - setNextRoyaltyPayment start');
        for(Contract c : cAgreementContractList)
        {
            if(c.Calculate_Next_Royalty_Payment__c == true
                && agreementsMap.containsKey(c.Id))
            {
                CV_Sales_Report_Tracking__c nextdueRPT = RoyaltyPaymentManager.getnextdueRoyaltyPayment(agreementsMap.get(c.Id).CVRoyaltyPaymentTracking__r);
                c.Next_Sales_Report__c = nextdueRPT!= null ? nextdueRPT.Id : null;
                
                // make the flag false once next royalty payment is populated.
                c.Calculate_Next_Royalty_Payment__c = false;
            }
        }
        System.debug(LoggingLevel.DEBUG, 'TH_Contract_CVManageSchedules - setNextRoyaltyPayment end');
    }

    private void setNextSalesReport(List<Contract> cAgreementContractList, Map<Id, Contract> agreementsMap){
        // Derivation 2 : populate Next Sales Report on Contract based in isReceived__c flag.
        //                Assumption : sales reports will be received in order.
        
        System.debug(LoggingLevel.DEBUG, 'TH_Contract_CVManageSchedules - setNextSalesReport start');
        for(Contract c : cAgreementContractList)
        {
            if(c.Calculate_Next_Sales_Report__c == true
                && agreementsMap.containsKey(c.Id))
            {
                CV_Sales_Report_Tracking__c nextdueSRT = SalesReportManager.getnextdueSalesReport(agreementsMap.get(c.Id).CVSalesReportTracking__r);
                c.Next_Sales_Report__c = nextdueSRT!= null ? nextdueSRT.Id : null;

                // make the flag false once next sales report is populated.
                c.Calculate_Next_Sales_Report__c = false;
            }
        }
        System.debug(LoggingLevel.DEBUG, 'TH_Contract_CVManageSchedules - setNextSalesReport end');
    }

    //  -----------------------------------------
    //  deleterptsOnContractUpdate : delete Royalty payment schedules when startdate, enddate, royalty payment rule is changed on contract.
    //  -----------------------------------------
    private void deleterptsOnContractUpdate(List<Contract> cAgreementContractList, Map<Id, Contract> agreementsMap){
        System.debug(LoggingLevel.DEBUG, 'TH_Contract_CVManageSchedules - deleterptsOnContractUpdate start');
        
        List<CV_Royalty_Payment_Tracking__c> rpttobedeletedList = new List<CV_Royalty_Payment_Tracking__c>();
        for(Contract c : cAgreementContractList){
            Contract cOld = contractOldMap.get(c.Id);
            if(ContractManager.isequalsRoyalPaymentSchedule(c, cOld)
                && agreementsMap.containsKey(c.Id))
            {
                rpttobedeletedList.addAll(agreementsMap.get(c.Id).CVRoyaltyPaymentTracking__r);
            }
        }
        if(!rpttobedeletedList.isEmpty())    
            delete rpttobedeletedList;
        
        System.debug(LoggingLevel.DEBUG, 'TH_Contract_CVManageSchedules - deleterptsOnContractUpdate end');
    }

    //  -----------------------------------------
    //  deletesrtsOnContractUpdate : delete Sales report schedules when startdate, enddate, sales report rule is changed on contract.
    //  -----------------------------------------
    private void deletesrtsOnContractUpdate(List<Contract> cAgreementContractList, Map<Id, Contract> agreementsMap){
        System.debug(LoggingLevel.DEBUG, 'TH_Contract_CVManageSchedules - deletesrtsOnContractUpdate start');
        
        List<CV_Sales_Report_Tracking__c> srtobedeletedList = new List<CV_Sales_Report_Tracking__c>();
        for(Contract c : cAgreementContractList){
            Contract cOld = contractOldMap.get(c.Id);
            if(ContractManager.isequalsSalesReportSchedule(c, cOld)
                && agreementsMap.containsKey(c.Id)
            {    
                srtobedeletedList.addAll(agreementsMap.get(c.Id).CVSalesReportTracking__r);
            }
        }

        if(!srtobedeletedList.isEmpty())
            delete srtobedeletedList;
        
        System.debug(LoggingLevel.DEBUG, 'TH_Contract_CVManageSchedules - deletesrtsOnContractUpdate end');
    }

    //  -----------------------------------------
    //  createRevenuePaymentSchedules : create Royalty payment schedules when new contract is created updated(startDate, endDate or royalty payment rule).
    //  -----------------------------------------
    private void createRevenuePaymentSchedules(List<Contract> cAgreementContractList, Map<Id, CV_Due_Date_Rule__c> ddrIdtoddrMap){
        System.debug(LoggingLevel.DEBUG, 'TH_Contract_CVManageSchedules - createRevenuePaymentSchedules start');
        
        List<CV_Royalty_Payment_Tracking__c> rpttobeinsertedList = new List<CV_Royalty_Payment_Tracking__c>();
        // use "cOld == null" to differenciate insert and update.
        for(Contract c : cAgreementContractList)
        {
            Contract cOld = contractOldMap.get(c.Id);
            if((cOld == null
                  || ContractManager.isequalsRoyalPaymentSchedule(c, cOld)
                &&  c.Royalty_Payment_Due_Date_Rule__c != null
                && ddrIdtoddrMap.containsKey(c.Royalty_Payment_Due_Date_Rule__c))
            {
                CV_Due_Date_Rule__c ddr = ddrIdtoddrMap.get(c.Royalty_Payment_Due_Date_Rule__c);
                rpttobeinsertedList.addAll((List<CV_Royalty_Payment_Tracking__c>)DueDateRuleManager.getSchedulesbasedonDuedateRule(ddr, c, CV_Royalty_Payment_Tracking__c.sObjectType));
            }
        }   
        if(!rpttobeinsertedList.isEmpty())
            insert rpttobeinsertedList;
        
        System.debug(LoggingLevel.DEBUG, 'TH_Contract_CVManageSchedules - createRevenuePaymentSchedules end');
    }

    //  -----------------------------------------
    //  createSalesReportSchedules : create Sales Report schedules when new contract is created or updated(startDate, endDate or sales report rule).
    //  -----------------------------------------
    private void createSalesReportSchedules(List<Contract> cAgreementContractList, Map<Id, CV_Due_Date_Rule__c> ddrIdtoddrMap){
        System.debug(LoggingLevel.DEBUG, 'TH_Contract_CVManageSchedules - createSalesReportSchedules start');
        
        List<CV_Sales_Report_Tracking__c> srtobeinsertedList = new List<CV_Sales_Report_Tracking__c>();
        // use "cOld == null" to differenciate insert and update.
        for(Contract c : cAgreementContractList)
        {
            Contract cOld = contractOldMap.get(c.Id);
            if((cOld == null
                    || ContractManager.isequalsSalesReportSchedule(c, cOld)
                && c.Sales_Report_Due_Date_Rule__c != null
                && ddrIdtoddrMap.containsKey(c.Sales_Report_Due_Date_Rule__c))
            {
                CV_Due_Date_Rule__c ddr = ddrIdtoddrMap.get(c.Sales_Report_Due_Date_Rule__c);
                for(sObject obj : DueDateRuleManager.getSchedulesbasedonDuedateRule(ddr, c, CV_Sales_Report_Tracking__c.sObjectType))
                    srtobeinsertedList.add((CV_Sales_Report_Tracking__c)obj);
            }
        }   
        if(!srtobeinsertedList.isEmpty())    
            insert srtobeinsertedList;

        System.debug(LoggingLevel.DEBUG, 'TH_Contract_CVManageSchedules - createSalesReportSchedules end');
    }

    /**
     * prepare set of due date Ids if Contract period or due date rules are changed.
     * @param  cList List of contracts to check.
     * @return Set of Due date rule Id's.
     */
    private Set<Id> getChangedDueDateRuleIds(List<Contract> cList){
        for (Contract c : cList) 
        {
            Contract cOld = contractOldMap.get(c.Id);
            if((cOld == null
                || ContractManager.isequalsRoyalPaymentSchedule(c, cOld))
                && c.Royalty_Payment_Due_Date_Rule__c != null)
            {
                ddrIdSet.add(c.Royalty_Payment_Due_Date_Rule__c);
            }

            if((cOld == null
                || ContractManager.isequalsSalesReportSchedule(c, cOld))
                && c.Sales_Report_Due_Date_Rule__c != null)
            {
                ddrIdSet.add(c.Sales_Report_Due_Date_Rule__c);
            }
        }
    }
}