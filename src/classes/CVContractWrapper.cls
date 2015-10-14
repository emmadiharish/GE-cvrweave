/******************************************************************************************************************************
* Name - CVContractWrapper

* Description - This class does the following:
    - Wraps the Contract object so we can have methods on it.

* Modification Log :
* ---------------------------------------------------------------------------
* Developer     Date            Description
* ---------------------------------------------------------------------------
* Siva Gunda    10/13/2015      Created.
******************************************************************************************************************************/

public without sharing class CVContractWrapper{
    //  ------------------------------------------------
    //  Properties
    //  ------------------------------------------------
    public  Contract           c;
    private Contract           cOld;
    private Boolean            isValid    = true;          // passed validation checks?


    //  -------------------------------------------
    //  Constructor
    //  -------------------------------------------
    public CVContractWrapper(Contract  a) {
        this.c     = c;
        this.cOld  = null;
    }

    public CVContractWrapper(Contract c, Contract cOld) {
        this.c     = c;
        this.cOld  = cOld;
    }
    
    //  ---------------------------------------------------------------------
    //  debug 
    //  ---------------------------------------------------------------------
    public String debug() {
        return   '  Name  : ' + this.c.Name;
    }
    
    //  -------------------------------------------
    //  derive:      Field derivations
    //  -------------------------------------------
    public void derive(CVContractGateway cGW) {
        System.debug(CVFlowControl.getLogLevel(),'ENTERING derive ' + debug());
        if (!this.isValid) {}
        else {
            // Derivation 2 : populate Next Royalty Payment on Contract based in isReceived__c flag.
            //                Assumption : Royalty payments will be received in order.
            if(this.c.Calculate_Next_Royalty_Payment__c == true
                && cGW.cIdToCWRelRecsMap.containsKey(this.c.Id))
            {
                for(CV_Royalty_Payment_Tracking__c rpt : cGW.cIdToCWRelRecsMap.get(this.c.Id).CVRoyaltyPaymentTracking__r){
                    if(rpt.isReceived__c == false)
                    {   
                        this.c.Next_Royalty_Payment__c = rpt.Id;
                        break;
                    }
                }
                // make the flag false once next royalty payment is populated.
                this.c.Calculate_Next_Royalty_Payment__c = false;
            }

            // Derivation 2 : populate Next Sales Report on Contract based in isReceived__c flag.
            //                Assumption : sales reports will be received in order.
            if(this.c.Calculate_Next_Sales_Report__c == true
                && cGW.cIdToCWRelRecsMap.containsKey(this.c.Id))
            {
                for(CV_Sales_Report_Tracking__c srt : cGW.cIdToCWRelRecsMap.get(this.c.Id).CVSalesReportTracking__r){
                    if(srt.isReceived__c == false)
                    {   
                        this.c.Next_Sales_Report__c = srt.Id;
                        break;
                    }
                }
                // make the flag false once next sales report is populated.
                this.c.Calculate_Next_Sales_Report__c = false;
            }
        }
        System.debug(CVFlowControl.getLogLevel(),'LEAVING derive ' + debug());
    }

    //  -------------------------------------------
    //  validate:    Does Validations undoable by Force.com Validation Rules; sets instance Vbl isValid
    //  -------------------------------------------
    public void validate(CVContractGateway cGW) {
        if (!validationsEnabled()) {}
        else {
            //if (!validateDuplicateName(aGw)) this.isValid = false;
        }
            System.debug(CVFlowControl.getLogLevel(),'LEAVING validate, isValid=' + this.isValid);
    } 

    //  -----------------------------------------
    //  validationsEnabled
    //  -----------------------------------------
    private Boolean validationsEnabled() {
        return CVFlowControl.runContractTriggerHandler();
    }

    //  -----------------------------------------
    //  addtorpttobedeletedList : delete Royalty payment schedules when startdate, enddate, royalty payment rule is changed on contract.
    //  -----------------------------------------
    public List<CV_Royalty_Payment_Tracking__c> addtorpttobedeletedList(CVContractGateway cGW, List<CV_Royalty_Payment_Tracking__c> rpttobedeletedListtodate){
        System.debug('***ENTERING addtorpttobedeletedList ' + debug());
        
        List<CV_Royalty_Payment_Tracking__c> res = rpttobedeletedListtodate;
        if((this.c.StartDate != this.cOld.StartDate
                || this.c.EndDate != this.cOld.EndDate
                || this.c.Royalty_Payment_Due_Date_Rule__c != this.cOld.Royalty_Payment_Due_Date_Rule__c)
            && cGW.cIdToCWRelRecsMap.containsKey(this.c.Id))
        {
            res.addAll(cGW.cIdToCWRelRecsMap.get(this.c.Id).CVRoyaltyPaymentTracking__r);
        }
        
        System.debug('***LEAVING addtorpttobedeletedList ' + debug());
        return res;
    }

    //  -----------------------------------------
    //  addtosrtobedeletedList : delete Sales report schedules when startdate, enddate, sales report rule is changed on contract.
    //  -----------------------------------------
    public List<CV_Sales_Report_Tracking__c> addtosrtobedeletedList(CVContractGateway cGW, List<CV_Sales_Report_Tracking__c> srtobedeletedListtodate){
        System.debug('***ENTERING addtosrtobedeletedList ' + debug());
        
        List<CV_Sales_Report_Tracking__c> res = srtobedeletedListtodate;
        if((this.c.StartDate != this.cOld.StartDate
                || this.c.EndDate != this.cOld.EndDate
                || this.c.Sales_Report_Due_Date_Rule__c != this.cOld.Sales_Report_Due_Date_Rule__c)
            && cGW.cIdToCWRelRecsMap.containsKey(this.c.Id))
        {    
            res.addAll(cGW.cIdToCWRelRecsMap.get(this.c.Id).CVSalesReportTracking__r);
        }
        
        System.debug('***LEAVING addtosrtobedeletedList ' + debug());
        return res;
    }

    //  -----------------------------------------
    //  addtorpttobeinsertedList : create Royalty payment schedules when new contract is created updated(startDate, endDate or royalty payment rule).
    //  -----------------------------------------
    public List<CV_Royalty_Payment_Tracking__c> addtorpttobeinsertedList(CVContractGateway cGw, List<CV_Royalty_Payment_Tracking__c> rpttobeinsertedListtodate){
        System.debug('***ENTERING addtorpttobeinsertedList ' + debug());
        
        List<CV_Royalty_Payment_Tracking__c> res = rpttobeinsertedListtodate;
        // use "cOld == null" to differenciate insert and update.
        if((this.cOld == null
                || this.c.StartDate != this.cOld.StartDate
                || this.c.EndDate != this.cOld.EndDate
                || this.c.Royalty_Payment_Due_Date_Rule__c != this.cOld.Royalty_Payment_Due_Date_Rule__c)
            && String.isNotBlank(this.c.Royalty_Payment_Due_Date_Rule__c)
            && cGW.ddrIdtoddrMap.containsKey(this.c.Royalty_Payment_Due_Date_Rule__c))
        {
            Date startDate = this.c.StartDate;
            Date endDate = this.c.EndDate;
            CV_Due_Date_Rule__c ddr = cGW.ddrIdtoddrMap.get(this.c.Royalty_Payment_Due_Date_Rule__c);

            if(startDate == null)
                startDate = Date.today();
            // if endDate is null then consider it as startDate+10 years.                
            if(endDate == null)
                endDate = startDate.addYears(10);

            Date periodStartDate = startDate; 
            while(periodStartDate < endDate){
                // Period End Date should be end of the month.
                Date periodEndDate = periodStartDate.addMonths(1).toStartofMonth().addDays(-1);
                CV_Royalty_Payment_Tracking__c rpt = new CV_Royalty_Payment_Tracking__c();
                rpt.Contract__c = this.c.Id;
                rpt.StartDate__c = periodStartDate;
                rpt.EndDate__c = periodEndDate;
                rpt.DueDate__c = calculateDuedate(ddr, periodEndDate);

                // bring the date to start of the month.
                periodStartDate = periodEndDate.addDays(1);

                res.add(rpt);
            }
        }
        
        System.debug('***LEAVING addtorpttobeinsertedList ' + debug());
        return res;
    }

    //  -----------------------------------------
    //  addtosrtobeinsertedList : create Royalty payment schedules when new contract is created or updated(startDate, endDate or sales report rule).
    //  -----------------------------------------
    public List<CV_Sales_Report_Tracking__c> addtosrtobeinsertedList(CVContractGateway cGW, List<CV_Sales_Report_Tracking__c> srtobeinsertedListtodate){
        System.debug('***ENTERING addtosrtobeinsertedList ' + debug());
        
        List<CV_Sales_Report_Tracking__c> res = srtobeinsertedListtodate;
        // use "cOld == null" to differenciate insert and update.
        if((this.cOld == null
                || this.c.StartDate != this.cOld.StartDate
                || this.c.EndDate != this.cOld.EndDate
                || this.c.Sales_Report_Due_Date_Rule__c != this.cOld.Sales_Report_Due_Date_Rule__c)
            && String.isNotBlank(this.c.Sales_Report_Due_Date_Rule__c)
            && cGW.ddrIdtoddrMap.containsKey(this.c.Sales_Report_Due_Date_Rule__c))
        {
            Date startDate = this.c.StartDate;
            Date endDate = this.c.EndDate;
            CV_Due_Date_Rule__c ddr = cGW.ddrIdtoddrMap.get(this.c.Sales_Report_Due_Date_Rule__c);

            if(startDate == null)
                startDate = Date.today();
            // if endDate is null then consider it as startDate+10 years.                
            if(endDate == null)
                endDate = startDate.addYears(10);

            Date periodStartDate = startDate; 
            while(periodStartDate < endDate){
                // Period End Date should be end of the month.
                Date periodEndDate = periodStartDate.addMonths(1).toStartofMonth().addDays(-1);
                CV_Sales_Report_Tracking__c rpt = new CV_Sales_Report_Tracking__c();
                rpt.Contract__c = this.c.Id;
                rpt.StartDate__c = periodStartDate;
                rpt.EndDate__c = periodEndDate;
                rpt.DueDate__c = calculateDuedate(ddr, periodEndDate);

                // bring the date to start of the month.
                periodStartDate = periodEndDate.addDays(1);

                res.add(rpt);
            }
        }
        
        System.debug('***LEAVING addtosrtobeinsertedList ' + debug());
        return res;
    }

    // Helper method to calculate the due date for the given period based on due date rule.
    private static Date calculateDuedate(CV_Due_Date_Rule__c ddr, Date periodDate){
        /* if rule is standard then
            - due date will be based on days and period.
           else
            - use comma separated  custom dates.
        */
        // add -1 days to calculations because salesforce addDays method is weird.
        Date res = null;    
        if(ddr.isStandard__c){
            String daysstr = ddr.Days__c;
            String period = ddr.Period__c;
            if(String.isNotBlank(daysstr)
                && String.isNotBlank(period))
            {
                Integer daysint = Integer.valueOf(daysstr.substringBefore(' '));
                if(CVCONSTANTS.DDR_PERIOD_MONTH_END.equalsIgnoreCase(period)){
                    res = periodDate.addDays(daysint-1);
                }
                else if(CVCONSTANTS.DDR_PERIOD_QUARTER_START.equalsIgnoreCase(period)){
                    res = CVYearQuarterUtils.getProgramQuarterStartDate(periodDate).addDays(daysint-1);
                }
                else if(CVCONSTANTS.DDR_PERIOD_QUARTER_END.equalsIgnoreCase(period)){
                    res = CVYearQuarterUtils.getProgramQuarterEndDate(periodDate).addDays(daysint-1);
                }
            }
        }
        else{
            if(String.isNotBlank(ddr.Custom_Due_Dates__c)){
                List<String> customDatesList = ddr.Custom_Due_Dates__c.split(',');    
                customDatesList.sort();// ascending sort the list of due dates so we can can find next due date based on periodDate.
                
                Integer periodDateMonth = periodDate.month();
                // return the date next to periodDate in customDatesList
                for(String ddate : customDatesList)
                {
                    Integer ddateMonth = Integer.valueOf(ddate.substringBefore('/'));
                    if(ddateMonth > periodDateMonth)
                    {
                        // placeholder date.
                        String nextduedate = '2099-01-01';
                        if(ddate.countMatches('/') == 2){
                            nextduedate = ddate.substringBefore('/')+'-'+ddate.substringBetween('/')+'-'+ddate.substringAfterLast('/');
                        }else if(ddate.countMatches('/') == 1){
                            nextduedate = String.valueOf(periodDate.year())+'-'+ddate.substringBefore('/')+'-'+ddate.substringAfter('/');
                        }
                        res = date.valueOf(nextduedate);
                        break;
                    }
                }
            }
        }
        return res;
    }
}