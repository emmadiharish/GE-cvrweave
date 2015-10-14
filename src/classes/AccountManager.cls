/******************************************************************************************************************************
* Name - AccountManager
* Description
* Manager class that contains all the methods and constants for handling Account records.
* To be used as a single source of business logic and data loading methods in order to ease reuse.
* Modification Log :
* ---------------------------------------------------------------------------
* Developer Date Description
* ---------------------------------------------------------------------------
* Zoran Zunko 07/16/2015 Created.
* Zoran Zunko 08/26/2015 added getCountries.
******************************************************************************************************************************/
public with sharing class AccountManager {

//******************************************************************************************************************************
//record type constants
//******************************************************************************************************************************
    public static String RT_LICENSEE = 'Account.CV_Licensee';
//******************************************************************************************************************************

    /**
     * Loads a list of all CV Licensee accounts
     * @param  contactIds list of Ids
     * @return            a List with all CV licensee accounts queried Id, Name, [Contacts - Name, Id]
     */
    public static List<Account> getCVLicenseeAccounts() {
        System.debug(LoggingLevel.DEBUG, 'AccountManager - getCVLicenseeAccounts start');

        return [SELECT Id, Name /*, (SELECT Id, Name FROM Contacts WHERE Id IN :contactIds) */ FROM Account WHERE RecordTypeId = :Cache.RecordTypeId(RT_LICENSEE) ORDER BY Name ASC];
    }


    /**
     * Gets a select options list of all countries enabled in the org
     * @return            a List with all the countries defined in the countries picklist
     */
    public static List<SelectOption> getCountries() {

        System.debug(LoggingLevel.DEBUG, 'AccountManager - getCountries start');

        Set<String> firstCountries = CVWorkflowGeneralParametersManager.getCountries();

        System.debug(LoggingLevel.DEBUG, 'firstCountries: ' + firstCountries);

        List<SelectOption> options = new List<SelectOption>();

        for(String country : firstCountries) {
            options.add(new SelectOption(country, country));
        }

        Schema.DescribeFieldResult fieldResult = Account.BillingCountryCode.getDescribe();
        System.debug(LoggingLevel.DEBUG, 'fieldResult: ' + fieldResult);
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

        for( Schema.PicklistEntry f : ple) {
            if(!firstCountries.contains(f.getLabel())) {
                options.add(new SelectOption(f.getLabel(), f.getLabel()));
            }
        }

        System.debug(LoggingLevel.DEBUG, 'AccountManager - getCountries end');
        return options;
    }
}