/******************************************************************************************************************************
* Name - DueDateRuleManager
* Description
* 	- Manager class that contains all the methods and constants for handling Due Date Rule records.
*  	- To be used as a single source of business logic and data loading methods in order to ease reuse.
* Modification Log :
* ---------------------------------------------------------------------------
* Developer Date Description
* ---------------------------------------------------------------------------
* Siva Gunda 10/15/2015 Created.
******************************************************************************************************************************/
public with sharing class DueDateRuleManager {
	
    //******************************************************************************************************************************
    //period constants
    //******************************************************************************************************************************
        public static final String DDR_PERIOD_MONTH_END     =   'Month end';
        public static final String DDR_PERIOD_QUARTER_END   =   'Quarter end';
        public static final String DDR_PERIOD_QUARTER_START =   'Quarter start';
    //******************************************************************************************************************************
    //
	/**
     * loads a map of due date rules with custom due dates for given due date rule Id's.
     * @param  licenseeIds Ids of the licensees to load the Agreements for
     * @return Map of Due Date Rule Id to Due Date Rule with custom dates.
     */
    public static Map<Id, CV_Due_Date_Rule__c> getDueDateRulewCustomDatesMapbyId(Set<Id> ddrIdSet){
        System.debug(LoggingLevel.DEBUG, 'DueDateRuleManager - getDueDateRulewCustomDatesMapbyId start');

        // CVCustomDueDates__r query should be ordered by Period_End_Date__c else order of schedule creation will change.
        Map<Id, CV_Due_Date_Rule__c> result =  new Map<ID, CV_Due_Date_Rule__c>([select Id, isStandard__c, Days__c, Period__c,
									                                                    (Select Period_Start_Date__c, Period_End_Date__c, Due_Date__c 
									                                                        From CVCustomDueDates__r
									                                                            Order by Period_End_Date__c)
									                                                        From CV_Due_Date_Rule__c 
									                                                            Where Id IN :ddrIdSet]);
        
        System.debug(LoggingLevel.DEBUG, 'DueDateRuleManager - getDueDateRulewCustomDatesMapbyId end result is: '+ result);
        return result;
    }

	/**
     * Helper method to generate Scheules based on due date rule.
     *     if rule is standard then
     *         - due date will be based on days and period.
     *         - if period is monthly then schedules should be created monthly.
     *         - else if period is quarterly then schedules should be created quarterly.
     *     else
     *         - use comma separated  custom dates.
     * @param  ddr: due date rule associated to contract, c: contract, objectType: schedule type to be populated.
     * @return List<sObject> which is a list of schedules on contract 
     */
    public static List<sObject> getSchedulesbasedonDuedateRule(CV_Due_Date_Rule__c ddr, Contract c, Schema.sObjectType objectType){
        
        // add -1 days to calculations because salesforce addDays method is weird.
        System.debug(LoggingLevel.DEBUG, 'DueDateRuleManager - getSchedulesbasedonDuedateRule start');

        List<sObject> result = new List<sObject>();

        Date cStartDate = c.Startdate;
        Date cEndDate = c.EndDate;

        if(cStartDate == null
            || ddr == null)
            return result;

        // if endDate is null then consider it as startDate+10 years.                
        if(cEndDate == null)
            cEndDate = cStartDate.addYears(10);

        if(ddr.isStandard__c){
            String daysstr = ddr.Days__c;
            String period = ddr.Period__c;

            if(String.isNotBlank(daysstr)
                && String.isNotBlank(period))
            {
                Integer daysint = Integer.valueOf(daysstr.substringBefore(' '));
                if(DDR_PERIOD_MONTH_END.equalsIgnoreCase(period)){
                    Date periodStartDate = cStartDate; 
                    while(periodStartDate < cEndDate){
                        // Period End Date should be end of the month.
                        Date periodEndDate = periodStartDate.addMonths(1).toStartofMonth().addDays(-1);
                        periodEndDate = periodEndDate > cEndDate ? cEndDate : periodEndDate;

                        Date dueDate = periodEndDate.addDays(daysint-1);

                        sObject obj = objectType.newSObject();
                        obj.put('Contract__c', c.Id);
                        obj.put('StartDate__c', periodStartDate);
                        obj.put('EndDate__c', periodEndDate);
                        obj.put('DueDate__c', dueDate);

                        // startdate will always be previous endDate + 1.
                        periodStartDate = periodEndDate.addDays(1);

                        result.add(obj);
                    }
                }
                else{// if quarterly.
                    Date periodStartDate = cStartDate; 
                    while(periodStartDate < cEndDate){
                        // Period End Date should be end of the month.
                        Date periodEndDate = CVYearQuarterUtils.getProgramQuarterEndDate(periodStartDate);
                        periodEndDate = periodEndDate > cEndDate ? cEndDate : periodEndDate;

                        Date dueDate = null;
                        
                        if(DDR_PERIOD_QUARTER_START.equalsIgnoreCase(period)){
                            dueDate = CVYearQuarterUtils.getProgramQuarterStartDate(periodEndDate).addDays(daysint-1);
                        }
                        else if(DDR_PERIOD_QUARTER_END.equalsIgnoreCase(period)){
                            dueDate = CVYearQuarterUtils.getProgramQuarterEndDate(periodEndDate).addDays(daysint-1);
                        }
                        
                        sObject obj = objectType.newSObject();
                        obj.put('Contract__c', c.Id);
                        obj.put('StartDate__c', periodStartDate);
                        obj.put('EndDate__c', periodEndDate);
                        obj.put('DueDate__c', dueDate);

                        // startdate will always be previous endDate + 1.
                        periodStartDate = periodEndDate.addDays(1);

                        result.add(obj);
                    }
                }
            }
        }
        else{
            if(!ddr.CVCustomDueDates__r.isEmpty())
            {
                // results are ordered by Period_End_Date__c so no need to sort again.
                for(CV_Custom_Due_Date__c cdd : ddr.CVCustomDueDates__r)
                {
                    sObject obj = objectType.newSObject();
                    obj.put('Contract__c', c.Id);
                    obj.put('StartDate__c', cdd.Period_Start_Date__c);
                    obj.put('EndDate__c', cdd.Period_End_Date__c);
                    obj.put('DueDate__c', cdd.Due_Date__c);

                    result.add(obj);
                }
            }
        }
        System.debug(LoggingLevel.DEBUG, 'DueDateRuleManager - getSchedulesbasedonDuedateRule end result is: '+result);
        return result;
    }
}