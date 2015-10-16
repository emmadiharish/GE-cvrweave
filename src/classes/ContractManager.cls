/******************************************************************************************************************************
* Name - ContractManager
* Description
* Manager class that contains all the methods and constants for handling Contract records.
* To be used as a single source of business logic and data loading methods in order to ease reuse.
* Modification Log :
* ---------------------------------------------------------------------------
* Developer Date Description
* ---------------------------------------------------------------------------
* Zoran Zunko 07/07/2015 Created.
* Siva Gunda 10/15/2015 - Added getContractswRelListsbycId, isContractPeriodSame, isequalsRoyalPaymentSchedule, isequalsSalesReportSchedule.
******************************************************************************************************************************/
public without sharing class ContractManager {

//******************************************************************************************************************************
//record type constants
//******************************************************************************************************************************
    public static String RT_AGREEMENT = 'Contract.Agreement';
    public static String RT_AMENDMENT = 'Contract.Amendment';
//******************************************************************************************************************************

    /**
     * loads a list of agreements for a licensee
     * @param  licenseeId Id of the licensee to load the Agreements for
     * @return            List<Contract> with AIF__c, Name fields
     */
    public static List<Contract> getAgreementsForLicenseeId(Id licenseeId) {

        System.debug(LoggingLevel.DEBUG, 'ContractManager - getAgreementsForLicenseeId start');
        System.debug(LoggingLevel.DEBUG, 'licenseeId: ' + licenseeId);

        return getAgreementsForLicenseeIds(new List<Id>{
                licenseeId
        });

    }

    /**
     * loads a list of agreements for licensees
     * @param  licenseeIds Ids of the licensees to load the Agreements for
     * @return            List<Contract> with AIF__c, Name fields
     */
    public static List<Contract> getAgreementsForLicenseeIds(List<Id> licenseeIds) {

        System.debug(LoggingLevel.DEBUG, 'ContractManager - getAgreementsForLicenseeIds start');
        System.debug(LoggingLevel.DEBUG, 'licenseeIds: ' + licenseeIds);
        Id agreementId = Cache.RecordTypeId(RT_AGREEMENT);
        List<Contract> response = (List<Contract>) Database.Query('SELECT AIF__c, Name FROM Contract WHERE AccountId IN :licenseeIds AND RecordTypeId = :agreementId');
        System.debug(LoggingLevel.DEBUG, 'response: ' + response);
        System.debug(LoggingLevel.DEBUG, 'ContractManager - getAgreementsForLicenseeIds end');

        return response;
    }

    /**
     * loads a map of Contracts with related list for a given contractIds.
     * @param  Id of the Contract to load the Contracts for
     * @return            List<Contract> with Related lists CVRoyaltyPaymentTracking__r, CVSalesReportTracking__r ordered by EndDate__c. 
     */
    public static Map<Id, Contract> getContractswRelListsbycId(Set<Id> contractIds) {

        System.debug(LoggingLevel.DEBUG, 'ContractManager - getContractswRelListsbycId start');
        System.debug(LoggingLevel.DEBUG, 'contractIds: ' + contractIds);
        Id agreementId = Cache.RecordTypeId(RT_AGREEMENT);
        Map<Id, Contract> response = new Map<Id, Contract>([SELECT Id, Name, (Select Id, isReceived__c, ActualDate__c 
                                                                                    From CVRoyaltyPaymentTracking__r
                                                                                        Order by EndDate__c),
                                                                              (Select Id, isReceived__c, ActualDate__c
                                                                                    From CVSalesReportTracking__r
                                                                                        Order by EndDate__c) 
                                                                FROM Contract WHERE Id IN :contractIds]);
        System.debug(LoggingLevel.DEBUG, 'response: ' + response);
        System.debug(LoggingLevel.DEBUG, 'ContractManager - getContractswRelListsbycId end');
        return response;
    }

    /**
     * returns true or false based on contract term is natches or not.
     * @param  c is the new version of contract and secondContract is contract to compare against.
     * @return returns true or false based on contract term(startDate or endDate) is changed or not.
     */
    public static Boolean isContractPeriodSame(Contract c, Contract secondContract) {

        System.debug(LoggingLevel.DEBUG, 'ContractManager - isContractPeriodChanged start');
        if(c == null
            || secondContract == null)
            return false;

        if(c.StartDate == secondContract.StartDate
            && c.EndDate == secondContract.EndDate)
            return true;
        System.debug(LoggingLevel.DEBUG, 'ContractManager - isContractPeriodChanged end');
        return false;
    }

    /**
     * returns true or false based on contract term or royal payment due date rule changed or not.
     * @param  c is the new version of contract and secondContract is contract to compare against.
     * @return returns true or false based on contract term(startDate or endDate) is changed or not.
     */
    public static Boolean isequalsRoyalPaymentSchedule(Contract c, Contract secondContract) {

        System.debug(LoggingLevel.DEBUG, 'ContractManager - isequalsRoyalPaymentSchedule start');
        if(isContractPeriodSame(c, secondContract)
            && c.Royalty_Payment_Due_Date_Rule__c == secondContract.Royalty_Payment_Due_Date_Rule__c)
            return true;
        System.debug(LoggingLevel.DEBUG, 'ContractManager - isequalsRoyalPaymentSchedule end');
        return false;
    }

    /**
     * returns true or false based on contract term or sales report due date rule changed or not.
     * @param  c is the new version of contract and secondContract is contract to compare against.
     * @return returns true or false based on contract term(startDate or endDate) is changed or not.
     */
    public static Boolean isequalsSalesReportSchedule(Contract c, Contract secondContract) {

        System.debug(LoggingLevel.DEBUG, 'ContractManager - isequalsSalesReportSchedule start');
        if(isContractPeriodSame(c, secondContract)
            && c.Sales_Report_Due_Date_Rule__c == secondContract.Sales_Report_Due_Date_Rule__c)
            return true;
        System.debug(LoggingLevel.DEBUG, 'ContractManager - isequalsSalesReportSchedule end');
        return false;
    }

    /**
     * Creates a List of Contracts by iterating through a map of Updated/Inserted contracts and 
     * checking whether Contract.RecordType == Agreement
     * @param  cList Trigger.new
     * @return  a List<Contract> where recordtype is Agreement.
     */
    public static List<Contract> getAgreements(List<Contract> cList) {
        System.debug(LoggingLevel.DEBUG, 'ContractManager - getAgreements start');
        System.debug(LoggingLevel.DEBUG, 'cList: ' + cList);
        Id agreementId = Cache.RecordTypeId(RT_AGREEMENT);
        List<Contract> cAgreementsList = new List<Contract>();
        for(Contract c : cList) {
            if(c.RecordTypeId == agreementId){
                cAgreementsList.add(c);
            }
        }
        System.debug(LoggingLevel.DEBUG, 'cAgreementsList: ' + cAgreementsList);
        System.debug(LoggingLevel.DEBUG, 'ContractManager - getAgreements end');

        return cAgreementsList;
    }

    public static Contract createContractFromCase(Case cLegalCase) {

        Contract response = new Contract(
                Name = cLegalCase.CV_Agreement_No_Name__r.Name + ' Amendment'
        , AccountId = cLegalCase.AccountId
        , RecordTypeId = Cache.RecordTypeId(RT_AMENDMENT)
        , Agreement_Type__c = cLegalCase.CV_Agreement_No_Name__r.Agreement_Type__c
        , Referenced_Agreement__c = cLegalCase.CV_Agreement_No_Name__c
        , Status = 'Draft'
        , AIF__c = cLegalCase.CV_Agreement_No_Name__r.AIF__c
        , GE_Business_Unit__c = cLegalCase.CV_Agreement_No_Name__r.GE_Business_Unit__c
        );

        return response;
    }
}