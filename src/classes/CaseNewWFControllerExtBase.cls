/******************************************************************************************************************************
* Name - CaseNewWFControllerExtBase
* Description
* Base class for all new controllers
* Modification Log :
* ---------------------------------------------------------------------------
* Developer Date Description
* ---------------------------------------------------------------------------
* Zoran Zunko 07/10/2015 Created.
******************************************************************************************************************************/
public with sharing abstract class CaseNewWFControllerExtBase {

    @TestVisible protected Integer NUMBER_OF_ATTACHMENTS;
    @TestVisible protected Integer REQUIRED_NUMBER_OF_ATTACHMENTS;

    public List<Attachment> attCaseAttachmentsListDisp { get; protected set; }

    public abstract Map<String, FieldSet> getSectionFieldSetMap();
    public virtual List<Schema.FieldSetMember> getInputFieldSetMembers() {

        List<Schema.FieldSetMember> response = new List<Schema.FieldSetMember>();
        for (FieldSet fs : getSectionFieldSetMap().values()) {

            response.addAll(fs.getFields());
        }
        return response;
    }

//******************************************************************************************************************************
//controller properties
//******************************************************************************************************************************

    /*******************************************************************************************************************
    * Section Titles part
    *******************************************************************************************************************/
    public String detailSectionTitle {

        get {
            return 'Case Details';
        }
    }

    public String productDetailSectionTitle {

        get {
            return 'Product Details';
        }
    }

    public String factoryDetailSectionTitle {

        get {
            return 'Factory Details';
        }
    }

    public String retailDetailSectionTitle {

        get {
            return 'Retail Details';
        }
    }

    public String targetDatesSectionTitle {

        get {
            return 'Target Dates';
        }
    }
    /*******************************************************************************************************************
    * Section Titles part END
    *******************************************************************************************************************/

    /*******************************************************************************************************************
    * Internal Handling part
    *******************************************************************************************************************/
    @testVisible private List<SelectOption> licenseeAccounts;
    public List<SelectOption> getLicenseeAccounts() {

        if(licenseeAccounts == null) {
            licenseeAccounts = loadLicenseeAccounts();
        }

        return licenseeAccounts;
    }

    public List<SelectOption> getLicenseeContacts() {

        List<SelectOption> response = new List<SelectOption>();

        if(cNewCase.AccountId != null) {
            for(User uLicenseeCommunityUser : CommunityUserManager.getCommunityUsersForLicenseeId(cNewCase.AccountId)) {

                response.add(new SelectOption(uLicenseeCommunityUser.ContactId, uLicenseeCommunityUser.Contact.Name));
            }
        }

        return response;
    }

    @testVisible protected Map<Id, Account> licenseeAccountsMap;

    @testVisible protected List<SelectOption> loadLicenseeAccounts() {

        List<SelectOption> response = new List<SelectOption>();

        List<Account> accts = AccountManager.getCVLicenseeAccounts();

        for(Account aLicenseeAccount : accts) {

            response.add(new SelectOption(aLicenseeAccount.Id, aLicenseeAccount.Name));
        }

        licenseeAccountsMap = new Map<Id, Account> (accts);

        return response;
    }
    /*******************************************************************************************************************
    * Internal Handling part END
    *******************************************************************************************************************/

    /*******************************************************************************************************************
    * Categories Handling part
    *******************************************************************************************************************/

    /**
    * retrieves the list os categfories for the selected Agreement
    * */
    public virtual List<SelectOption> getCategories() {

        List<SelectOption> response = new List<SelectOption>();
        for (CV_Product_Category__c cvPc : CVProductCategoryManager.getCVProductCategoriesForContractId(cNewCase.CV_Agreement_No_Name__c)) {
            response.add(new SelectOption(cvPc.Composite_Key__c, cvPc.Composite_Key__c));
        }
        return response;
    }

    /*******************************************************************************************************************
    * Categories Handling part end
    *******************************************************************************************************************/

    /*******************************************************************************************************************
    * Contracts Handling part
    *******************************************************************************************************************/

    /**
    * used for loading the Agrement / Contracts for a Licensee
    * */
    @testVisible public List<SelectOption> loadLicenseeContracts() {

        List<SelectOption> response = new List<SelectOption>();

        for (Contract cLicenseeContract : ContractManager.getAgreementsForLicenseeId(getuLicenseeUser().Contact.AccountId)) {

            response.add(new SelectOption(cLicenseeContract.Id, cLicenseeContract.AIF__c + ' ' + cLicenseeContract.Name));
        }

        return response;
    }

    @testVisible private List<SelectOption> licenseeContracts;
    public virtual List<SelectOption> getLicenseeContracts() {

        if (licenseeContracts == null) {
            licenseeContracts = loadLicenseeContracts();
        }

        return licenseeContracts;
    }

    public Boolean singleAgreement {

        get {
            return licenseeContracts.size() <= 1;
        }
    }

    public String singleAgreementName {

        get {

            if (licenseeContracts.size() == 1) {

                return licenseeContracts[0].getLabel();
            }

            return '';
        }
    }
    /*******************************************************************************************************************
    * Contracts Handling part END
    *******************************************************************************************************************/

    /*******************************************************************************************************************
    * SKU Handling part
    *******************************************************************************************************************/
    @testVisible public Map<String, Product2> pLicenseeSKUProductsMap { get; private set; }

    protected String sLicenseeSKUListString;
    /**
    * genereate the String containing all the licensee products for a given contract
    * */
    public String getSLicenseeSKUListString() {

        if (String.isBlank(sLicenseeSKUListString) || pLicenseeSKUProductsMap.size() == 0) {

            List<String> sLicenseeSKUList = new List<String>();
            sLicenseeSKUList.addAll(pLicenseeSKUProductsMap.keySet());
            sLicenseeSKUListString = String.join(sLicenseeSKUList, ',');
        }
        return sLicenseeSKUListString;
    }

    public PageReference resetProducts() {

        pLicenseeSKUProductsMap.clear();

        return null;
    }

    public Boolean displayPopUp { get; private set; }


    public String skuSearchValue { get; set; }
    /*******************************************************************************************************************
    * SKU Handling part END
    *******************************************************************************************************************/

    /*******************************************************************************************************************
    * Countries Handling part
    *******************************************************************************************************************/

    @testVisible private List<SelectOption> countries;
    public List<SelectOption> getCountries() {

        if (countries == null) {
            countries = AccountManager.getCountries();
        }

        return countries;
    }

    /*******************************************************************************************************************
    * Countries Handling part END
    *******************************************************************************************************************/


    protected String initInfoMessage { get; set; }
    protected String attachmentMissingMessage { get; set; }




    public CaseNewWFControllerExtBase thisInstance {
        get {
            return this;
        }
    }

    public Case cNewCase { get; protected set; }

    @testVisible private User uLicenseeUser;
    public virtual User getuLicenseeUser() {
        if (uLicenseeUser == null) {
            uLicenseeUser = CommunityUserManager.getContactDetailsForCommunityUser(UserInfo.getUserId());
        }
        return uLicenseeUser;

    }

//******************************************************************************************************************************
    public CaseNewWFControllerExtBase(ApexPages.StandardController stdController) {

        System.debug(LoggingLevel.DEBUG, 'CaseNewWFControllerExtBase - constructor start');

        cNewCase = (Case) stdController.getRecord();
        attCaseAttachmentsListDisp = new List<Attachment>();

        initInfoMessage = '';
        attachmentMissingMessage = '';
        displayPopUp = false;

        System.debug(LoggingLevel.DEBUG, 'cNewCase: ' + cNewCase);

        pLicenseeSKUProductsMap = new Map<String, Product2>();
        System.debug(LoggingLevel.DEBUG, 'CaseNewWFControllerExtBase - constructor end');
    }

//******************************************************************************************************************************
//initialization methods
//******************************************************************************************************************************
    /**
     * initializes the controller
     */
    protected virtual void init() {
        System.debug(LoggingLevel.DEBUG, 'CaseNewWFControllerExtBase - init start');
        try {

            initAttachments();
            initAgreement();
            initProducts();

            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, initInfoMessage));

        }
        catch (Exception ex) {

            System.debug(LoggingLevel.ERROR, ex.getMessage() + '\n' + ex.getStackTraceString());
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'There was an error while loading the page please try again later.'));
        }
        System.debug(LoggingLevel.DEBUG, 'CaseNewWFControllerExtBase - init end');
    }

    protected virtual void initAttachments() {

        System.debug(LoggingLevel.DEBUG, 'CaseNewWFControllerExtBase - initAttachments start');
        try {

            attCaseAttachmentsListDisp.clear();
            for (Integer i = 0; i < NUMBER_OF_ATTACHMENTS; i++) {

                attCaseAttachmentsListDisp.add(new Attachment());
            }
        }
        catch (Exception ex) {
            System.debug(LoggingLevel.ERROR, ex.getMessage() + '\n' + ex.getStackTraceString());
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'There was an error while initializing attachments. Please try again later.'));
        }

        System.debug(LoggingLevel.DEBUG, 'CaseNewWFControllerExtBase - initAttachments end');
    }

    protected virtual void initAgreement() {

        System.debug(LoggingLevel.DEBUG, 'CaseNewWFControllerExtBase - initAgreement start');
        try {

            cNewCase.CV_Agreement_No_Name__c = getLicenseeContracts()[0].getValue();
            System.debug(LoggingLevel.DEBUG, 'cNewCase.CV_Agreement_No_Name__c : ' + cNewCase.CV_Agreement_No_Name__c);
        }
        catch (Exception ex) {
            System.debug(LoggingLevel.ERROR, ex.getMessage() + '\n' + ex.getStackTraceString());
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'There was an error while assigning your agreement. Please try again later.'));
        }

        System.debug(LoggingLevel.DEBUG, 'CaseNewWFControllerExtBase - initAgreement end');
    }

    protected virtual void initProducts() {

        System.debug(LoggingLevel.DEBUG, 'CaseNewWFControllerExtBase - initProducts start');
        try {

            List<Product2> pLicenseeProductsList = ProductManager.getProductsForLicenseeContract(cNewCase.CV_Agreement_No_Name__c);
            pLicenseeSKUProductsMap.clear();

            for (Product2 pLicenseeProduct : pLicenseeProductsList) {
                pLicenseeSKUProductsMap.put(pLicenseeProduct.Product_Number__c + ' -- ' + pLicenseeProduct.Name.replace(',', '.'), pLicenseeProduct);
            }

            System.debug(LoggingLevel.DEBUG, 'pLicenseeSKUProductsMap: ' + pLicenseeSKUProductsMap);
            System.debug(LoggingLevel.DEBUG, 'pLicenseeProductsList: ' + pLicenseeProductsList);
        }
        catch (Exception ex) {
            System.debug(LoggingLevel.ERROR, ex.getMessage() + '\n' + ex.getStackTraceString());
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'There was an error while loading the your products. Please try again later.'));
        }

        System.debug(LoggingLevel.DEBUG, 'CaseNewWFControllerExtBase - initProducts end');
    }

    public void initCategoryOptions() {

        System.debug(LoggingLevel.DEBUG, 'CaseNewWFControllerExtBase - initCategoryOptions start');
        try {

            Map<String, Map<String, Set<String>>> categoriesMap = new Map<String, Map<String, Set<String>>>();

            for (CV_Product_Category__c cvpcCategory : CVProductCategoryManager.getCVProductCategories()) {

                if (categoriesMap.get(cvpcCategory.Category__c) == null) {

                    categoriesMap.put(cvpcCategory.Category__c, new Map<String, Set<String>>());
                }

                if (categoriesMap.get(cvpcCategory.Category__c).get(cvpcCategory.Sub_Cat_1__c) == null) {

                    categoriesMap.get(cvpcCategory.Category__c).put(cvpcCategory.Sub_Cat_1__c, new Set<String>());
                }

                categoriesMap.get(cvpcCategory.Category__c).get(cvpcCategory.Sub_Cat_1__c).add(cvpcCategory.Sub_Cat_2__c);

            }

            categoriesOptions = new List<SelectOption>();
            categoriesSubCat1Map = new Map<String, List<SelectOption>>();
            subCat1SubCat2Map = new Map<String, List<SelectOption>>();

            for (String category : categoriesMap.keySet()) {

                System.debug(LoggingLevel.DEBUG, 'category: ' + category);

                categoriesOptions.add(new SelectOption(category, category));
                categoriesSubCat1Map.put(category, new List<SelectOption>());

                if (categoriesMap.get(category) != null) {

                    for (String subCat1 : categoriesMap.get(category).keySet()) {

                        System.debug(LoggingLevel.DEBUG, 'subCat1: ' + subCat1);
                        System.debug(LoggingLevel.DEBUG, 'categoriesSubCat1Map.get(category): ' + categoriesSubCat1Map.get(category));

                        if (String.isBlank(subCat1)) continue;

                        categoriesSubCat1Map.get(category).add(new SelectOption(subCat1, subCat1));
                        subCat1SubCat2Map.put(subCat1, new List<SelectOption>());

                        for (String subCat2 : categoriesMap.get(category).get(subCat1)) {

                            if (String.isBlank(subCat2)) continue;

                            subCat1SubCat2Map.get(subCat1).add(new SelectOption(subCat2, subCat2));
                        }
                    }
                }
            }
        }
        catch (Exception ex) {
            System.debug(LoggingLevel.ERROR, ex.getMessage() + '\n' + ex.getStackTraceString());
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'There was an error while loading the Agreement categories. Please try again later.'));
        }

        System.debug(LoggingLevel.DEBUG, 'CaseNewWFControllerExtBase - initCategoryOptions end');
    }
//******************************************************************************************************************************
//initialization methods END
//******************************************************************************************************************************

//******************************************************************************************************************************
//SKU assignment methods
//******************************************************************************************************************************
    public PageReference assignSKU() {

        System.debug(LoggingLevel.DEBUG, 'CaseNewWFControllerExtBase - assignSKU start');
        System.debug(LoggingLevel.DEBUG, 'cNewCase.SKU_Number__c: ' + skuSearchValue);
        try {

            if (pLicenseeSKUProductsMap.get(skuSearchValue) != null) {

                cNewCase.SKU_Description__c = pLicenseeSKUProductsMap.get(skuSearchValue).Name;
                cNewCase.SKU_Number__c = pLicenseeSKUProductsMap.get(skuSearchValue).Product_Number__c;
                cNewCase.CV_Product__c = pLicenseeSKUProductsMap.get(skuSearchValue).Id;
            }

            System.debug(LoggingLevel.DEBUG, 'cNewCase.SKU_Description__c: ' + cNewCase.SKU_Description__c);
            System.debug(LoggingLevel.DEBUG, 'cNewCase.SKU_Number__c: ' + cNewCase.SKU_Number__c);
            System.debug(LoggingLevel.DEBUG, 'cNewCase.CV_Product__c: ' + cNewCase.CV_Product__c);
        }
        catch (Exception ex) {

            System.debug(LoggingLevel.ERROR, ex.getMessage() + '\n' + ex.getStackTraceString());
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'There was an error while assigning SKU, please try again later.'));
        }

        displayPopUp = false;
        skuSearchValue = '';

        System.debug(LoggingLevel.DEBUG, 'CaseNewWFControllerExtBase - assignSKU end');

        return null;
    }

    public PageReference selectSKU() {

        System.debug(LoggingLevel.DEBUG, 'CaseNewWFControllerExtBase - selectSKU start');
        try {

            displayPopUp = true;
        }
        catch (Exception ex) {

            System.debug(LoggingLevel.ERROR, ex.getMessage() + '\n' + ex.getStackTraceString());
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'There was an error while loading the page please try again later.'));
        }
        System.debug(LoggingLevel.DEBUG, 'CaseNewWFControllerExtBase - selectSKU end');

        return null;
    }

    public PageReference selectSKUCancel() {

        System.debug(LoggingLevel.DEBUG, 'CaseNewWFControllerExtBase - selectSKUCancel start');

        displayPopUp = false;

        System.debug(LoggingLevel.DEBUG, 'CaseNewWFControllerExtBase - selectSKUCancel end');

        return null;
    }
//******************************************************************************************************************************
//SKU assignment methods END
//******************************************************************************************************************************

//******************************************************************************************************************************
//Save methods
//******************************************************************************************************************************
    /**
     * Saves and Submits current case with attachments, if database error occurs entire transaction is aborted.
     * If there is not a single file attached it message is displayed to user to attach at leas one file
     * @return null PageReference if there was an error, or case detail page if successfull.
     */
    public PageReference save() {

        System.debug(LoggingLevel.DEBUG, 'CaseNewWFControllerExtBase - save start');
        PageReference prResponse = null;
        Savepoint sp = Database.setSavepoint();
        try {

            System.debug(LoggingLevel.DEBUG, 'CaseNewWFControllerExtBase - save in try');
            List<Attachment> attListIns = new List<Attachment>();
            System.debug(LoggingLevel.DEBUG, 'CaseNewWFControllerExtBase - before for');
            for (Attachment attNew : attCaseAttachmentsListDisp) {

                if (attNew.Body != null) {

                    attListIns.add(attNew);
                }
            }
            System.debug(LoggingLevel.DEBUG, 'CaseNewWFControllerExtBase - after for');
            //check if any attachments
            Boolean requiredMissing = false;

            System.debug(LoggingLevel.DEBUG, 'REQUIRED_NUMBER_OF_ATTACHMENTS: ' + required_number_of_attachments);

            if (attListIns.size() >= required_number_of_attachments) {

                System.debug(LoggingLevel.DEBUG, 'CaseNewWFControllerExtBase - in if');

                for (Schema.FieldSetMember fsm : getInputFieldSetMembers()) {

                    System.debug(LoggingLevel.DEBUG, 'CaseNewWFControllerExtBase - before second for');

                    System.debug(LoggingLevel.DEBUG, 'fsm.getRequired(): ' + fsm.getRequired());
                    System.debug(LoggingLevel.DEBUG, 'cNewCase.get(fsm.getFieldPath()): ' + cNewCase.get(fsm.getFieldPath()));

                    if (!checkMandatoryField(fsm)) {

                        System.debug(LoggingLevel.ERROR, fsm.getLabel() + ' is required');
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, fsm.getLabel() + ' is required'));
                        requiredMissing = true;
                    }
                }

                if (requiredMissing) return null;

                cNewCase.Status = CaseManager.STATUS_SUBMITTED_FOR_REVIEW;

                insert cNewCase;

                for (Attachment attIns : attListIns) {
                    attIns.parentId = cNewCase.Id;
                }

                insert attListIns;
                prResponse = new PageReference('/' + cNewCase.Id);
            }
            else {

                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, attachmentMissingMessage));
            }
        }
        catch (Exception ex) {

            System.debug(LoggingLevel.ERROR, ex.getMessage() + '\n' + ex.getStackTraceString());
            System.debug(LoggingLevel.ERROR, ex.getLineNumber());
            System.debug(LoggingLevel.ERROR, ex.getTypeName());
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'There was an error while submitting the case. Please try again later.'));
            Database.rollback(sp);
        }

        System.debug(LoggingLevel.DEBUG, 'CaseNewWFControllerExtBase - save end');
        return prResponse;
    }

    protected virtual Boolean checkMandatoryField(Schema.FieldSetMember fsm) {

        System.debug(LoggingLevel.DEBUG, 'CaseNewWFControllerExtBase - checkField start');

        System.debug(LoggingLevel.DEBUG, 'fsm.getRequired(): ' + fsm.getRequired());
        System.debug(LoggingLevel.DEBUG, 'cNewCase.get(fsm.getFieldPath()): ' + cNewCase.get(fsm.getFieldPath()));

        System.debug(LoggingLevel.DEBUG, 'CaseNewWFControllerExtBase - checkField end');

        return !( fsm.getRequired() && cNewCase.get(fsm.getFieldPath()) == null );
    }
//******************************************************************************************************************************
//Save methods END
//******************************************************************************************************************************

//******************************************************************************************************************************
//Category Handling methods and properties
//******************************************************************************************************************************
    public List<SelectOption> categoriesOptions { get; protected set; }

    public PageReference categorySelected() {

        if (categoriesSubCat1Map.get(cNewCase.Product_Category__c) != null && categoriesSubCat1Map.get(cNewCase.Product_Category__c).size() > 0) {

            cNewCase.CV_Product_Sub_Cat_1__c = categoriesSubCat1Map.get(cNewCase.Product_Category__c)[0].getValue();
            if (subCat1SubCat2Map.get(cNewCase.CV_Product_Sub_Cat_1__c) != null && subCat1SubCat2Map.get(cNewCase.CV_Product_Sub_Cat_1__c).size() > 0) {

                cNewCase.CV_Product_Sub_Cat_2__c = subCat1SubCat2Map.get(cNewCase.CV_Product_Sub_Cat_1__c)[0].getValue();
            }
            else {

                cNewCase.CV_Product_Sub_Cat_2__c = null;
            }
        }
        else {

            cNewCase.CV_Product_Sub_Cat_1__c = null;
        }

        return null;
    }

    @testVisible protected Map<String, List<SelectOption>> categoriesSubCat1Map { get; set; }
    @testVisible protected Map<String, List<SelectOption>> subCat1SubCat2Map { get; set; }

    public List<SelectOption> subCat1Options {

        get {

            if (categoriesSubCat1Map.get(cNewCase.Product_Category__c) != null) {

                return categoriesSubCat1Map.get(cNewCase.Product_Category__c);
            }

            return new List<SelectOption>();
        }
    }

    public List<SelectOption> subCat2Options {

        get {

            if (subCat1SubCat2Map.get(cNewCase.CV_Product_Sub_Cat_1__c) != null) {

                return subCat1SubCat2Map.get(cNewCase.CV_Product_Sub_Cat_1__c);
            }

            return new List<SelectOption>();
        }
    }
//******************************************************************************************************************************
//Category Handling methods and properties END
//******************************************************************************************************************************
}