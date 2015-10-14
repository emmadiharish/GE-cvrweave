/**
* @author Zoran Zunko
* @date 10/1/15
*
* @group 
* @group-content ../../ApexDocContent/
*
* @description 
*/

public with sharing class CaseNewAmmendmentCtrlExt {

    Contract cNewContract;
    public Case cLegalCase { get; set; }

    @testVisible private List<String> caseFieldStrings = new List<String>{
            'AccountId'
            , 'Account.Name'
            , 'Status'
            , 'Request_Type__c'
            , 'CV_Agreement_No_Name__r.Agreement_Type__c'
            , 'CV_Agreement_No_Name__c'
            , 'CV_Agreement_No_Name__r.Name'
            , 'CV_Agreement_No_Name__r.AIF__c'
            , 'CV_Agreement_No_Name__r.GE_Business_Unit__c'
    };


    public CaseNewAmmendmentCtrlExt(ApexPages.StandardController stdController) {

        System.debug(LoggingLevel.DEBUG, 'CaseNewAmmendmentCtrlExt - constructor start');
        stdController.addFields(caseFieldStrings);
        cLegalCase = (Case) stdController.getRecord();
        System.debug(LoggingLevel.DEBUG, stdController.getRecord());

        System.debug(LoggingLevel.DEBUG, 'CaseNewAmmendmentCtrlExt - constructor end');
    }
    
    /**
     * initializes the controller and adds the messages to the running user if no action is required
     */
    public PageReference createAmendment() {

        System.debug(LoggingLevel.DEBUG, 'CaseNewAmmendmentCtrlExt - createAmmendment start');
        try {
            if (cLegalCase.Status != CaseManager.STATUS_CLOSED_APPROVED) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Ammendments can be created only from approved Legal Cases'));
                return null;
            }
            else if (cLegalCase.Request_Type__c != CaseManager.REQUEST_TYPE_AMENDMENT) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Ammendments can be created only from approved Legal Cases of Amendment type'));
                return null;
            }

            cNewContract = ContractManager.createContractFromCase(cLegalCase);
            insert cNewContract;
            ApexPages.StandardController productStandardController = new ApexPages.StandardController(cNewContract);

            PageReference p = productStandardController.edit();
            p.getParameters().put('retUrl', '/' + cNewContract.Id);
            return p;

        }
        catch (Exception ex) {
            System.debug(LoggingLevel.ERROR, ex.getMessage() + '\n' + ex.getStackTraceString());
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'There was an error while creating the ammendment, please try again later.'));
        }
        System.debug(LoggingLevel.DEBUG, 'CaseNewAmmendmentCtrlExt - createAmmendment end');
        return null;
    }

    public PageReference back() {

        return new PageReference('/' + cLegalCase.Id);

    }
}