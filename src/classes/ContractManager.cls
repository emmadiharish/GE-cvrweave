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