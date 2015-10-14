/******************************************************************************************************************************
* Name - TestDataFactory
* @description
* Class used as a single point of all the test data creation
* Modification Log :
* ---------------------------------------------------------------------------
* Developer Date Description
* ---------------------------------------------------------------------------
* Zoran Zunko 05/13/2015 Created.
******************************************************************************************************************************/
@isTest public class TestDataFactory {
//******************************************************************************************************************************
//test constants
//******************************************************************************************************************************
    public static final String CV_PARTNER_COMMUNITY_PROFILE_NAME = 'CV Licensee Partner Community User';
//******************************************************************************************************************************

    /**
     * creates users for test contexts
     * @param  basename    prefix for usernames and emails
     * @param  profileName name of the profile to be used for users
     * @param  count       number of records to generate
     * @return             non-inserted list of generated User records
     */
	public static List<User> createUsers(String basename, String profileName, Integer count) {

        Profile p = [select id from profile where name=:profileName limit 1];

        List<User> results = new List<User>();
        for (Integer x = 0; x < count; x++) {
            results.add(new User(
            FirstName = basename + 'Test',
            Lastname= 'User' + String.valueOf(x),
            Alias = basename + 'Test' + String.valueOf(x),
            Email = basename + 'test.user' + String.valueOf(x) + '@test.com',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocalesidKey = 'en_US',
            Profileid = p.Id,
            Country = 'United States',
            TimezoneSidKey = 'America/Los_Angeles',
            Username= 'test.user' + String.valueOf(x) + '@test.dev'
            ));
        }
        return results;
    }

    /**
     * creates community users for test contexts
     * @param  basename    prefix for usernames and emails
     * @param  profileName name of the profile to be used for users
     * @param  cIdsList    ids of contacts for which to generate community users
     * @return             non-inserted list of generated User records
     */
    public static List<User> createCommunityUsers(String basename, String profileName, List<Id> cIdsList) {

        Profile p = [select id from profile where name=:profileName limit 1];

        List<User> results = new List<User>();
        for (Id cId : cIdsList) {
            results.add(new User(
            FirstName = basename + 'Test',
            Lastname= 'User' + cId,
            Alias = basename + ((String)cId).right(5) ,
            Email = basename + 'test.user' + cId + '@test.com',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocalesidKey = 'en_US',
            Profileid = p.Id,
            Country = 'United States',
            TimezoneSidKey = 'America/Los_Angeles',
            Username= 'test.user' + cId + '@test.dev',
            ContactId = cId
            ));
        }
        return results;
    }

    /**
     * creates Accounts for test contexts
     * @param  basename    prefix for Account names
     * @param  ownerId     Id of the owner user
     * @param  count       number of records to generate
     * @return             non-inserted list of generated Account records
     */
    public static List<Account> createAccounts(String basename, String ownerId, Integer count) {
        List<Account> results = new List<Account>();
        for (Integer x = 0; x < count; x++) {
          results.add(new Account(Name = basename + String.valueOf(x), OwnerId = ownerId));
        }
        return results;
    }

    /**
     * creates Contacts for test contexts
     * @param  basename    prefix for contact names
     * @param  ownerId     Id of the owner user
     * @param  accountId   Id of the corresponding account record
     * @param  count       number of records to generate
     * @return             non-inserted list of generated Contact records
     */
    public static List<Contact> createContacts(String basename, String ownerId, String accountId, Integer count) {
        List<Contact> results = new List<Contact>();
        for (Integer x = 0; x < count; x++) {
            results.add(new Contact(
            FirstName = basename + String.valueOf(x),
            LastName = 'Contact',
            Email = basename + '-' + accountId + '-' + String.valueOf(x) + '@test.com',
            AccountId = accountId,
            OwnerId = ownerId
            ));
        }
        return results;
    }

    /**
     * creates a single Royalty Submission Case for test contexts
     * @param  ownerId     Id of the owner partner user
     * @param  accountId   Id of the corresponding account record
     * @param  contactId   Id of the corresponding contact record
     * @return             non-inserted Royalty Submission Case record
     */
    public static Case createRoyaltySubmissionCase(String basename, String ownerId, String accountId, String contactId) {
        Case cLicenseeCase = new Case();

        cLicenseeCase.RecordTypeId = Cache.RecordTypeId(CaseManager.RT_ROYALTY_SUBMISSION);
        cLicenseeCase.ContactId = contactId;
        cLicenseeCase.AccountId = accountId;
        cLicenseeCase.Subject = basename + ' Royalty Submission';
        cLicenseeCase.Description = basename + ' Royalty Submission';
        cLicenseeCase.Type = CaseManager.TYPE_CONSUMER_VENTURES;
        cLicenseeCase.Origin = CaseManager.ORIGIN_LICENSEE_PORTAL;
        cLicenseeCase.Status = CaseManager.STATUS_GE_APPROVAL_PROCESS;
        cLicenseeCase.Royalty_Period_Start_Date__c = System.today().addMonths(-1).toStartOfMonth();
        cLicenseeCase.Royalty_Period_End_Date__c = System.today().toStartOfMonth().addDays(-1);
        cLicenseeCase.OwnerId = ownerId;

        return cLicenseeCase;
    }

    /**
     * creates a single Brand Change Approval Case for test contexts
     * @param  ownerId     Id of the owner partner user
     * @param  accountId   Id of the corresponding account record
     * @param  contactId   Id of the corresponding contact record
     * @return             non-inserted Brand Change Case record
     */
    public static Case createBrandChangeCase(String basename, String ownerId, String accountId, String contactId) {
        Case cLicenseeCase = new Case();

        cLicenseeCase.RecordTypeId = Cache.RecordTypeId(CaseManager.RT_BRAND_CHANGE);
        cLicenseeCase.ContactId = contactId;
        cLicenseeCase.AccountId = accountId;
        cLicenseeCase.Subject = basename + ' Brand Change';
        cLicenseeCase.Description = basename + ' Brand Change';
        cLicenseeCase.Type = CaseManager.TYPE_CONSUMER_VENTURES;
        cLicenseeCase.Origin = CaseManager.ORIGIN_LICENSEE_PORTAL;
        cLicenseeCase.Status = CaseManager.STATUS_GE_APPROVAL_PROCESS;
        cLicenseeCase.Change_Type__c = 'Material Change';
        cLicenseeCase.SKU_Number__c = 'Test SKU';
        cLicenseeCase.SKU_Description__c = 'Test SKU Description';


        cLicenseeCase.OwnerId = ownerId;

        return cLicenseeCase;
    }

    /**
     * creates a single Product Change Approval Case for test contexts
     * @param  ownerId     Id of the owner partner user
     * @param  accountId   Id of the corresponding account record
     * @param  contactId   Id of the corresponding contact record
     * @return             non-inserted Product Change Case record
     */
    public static Case createProductChangeCase(String basename, String ownerId, String accountId, String contactId) {
        Case cLicenseeCase = new Case();

        cLicenseeCase.RecordTypeId = Cache.RecordTypeId(CaseManager.RT_PRODUCT_CHANGE);
        cLicenseeCase.ContactId = contactId;
        cLicenseeCase.AccountId = accountId;
        cLicenseeCase.Subject = basename + ' Product Change';
        cLicenseeCase.Description = basename + ' Product Change';
        cLicenseeCase.Type = CaseManager.TYPE_CONSUMER_VENTURES;
        cLicenseeCase.Origin = CaseManager.ORIGIN_LICENSEE_PORTAL;
        cLicenseeCase.Status = CaseManager.STATUS_GE_APPROVAL_PROCESS;
        cLicenseeCase.Change_Type__c = 'Material Change';
        cLicenseeCase.SKU_Number__c = 'Test SKU';
        cLicenseeCase.SKU_Description__c = 'Test SKU Description';
        cLicenseeCase.New_SKU_Number__c = 'new SKU number';


        cLicenseeCase.OwnerId = ownerId;

        return cLicenseeCase;
    }

    /**
     * creates a single Ancillary Brand Approval Case for test contexts
     * @param  ownerId     Id of the owner partner user
     * @param  accountId   Id of the corresponding account record
     * @param  contactId   Id of the corresponding contact record
     * @return             non-inserted Ancillary Brand Change Case record
     */
    public static Case createAncillaryBrandChangeCase(String basename, String ownerId, String accountId, String contactId) {
        Case cLicenseeCase = new Case();

        cLicenseeCase.RecordTypeId = Cache.RecordTypeId(CaseManager.RT_ANCILLARY_BRAND);
        cLicenseeCase.ContactId = contactId;
        cLicenseeCase.AccountId = accountId;
        cLicenseeCase.Subject = basename + ' Ancillary Brand Approval';
        cLicenseeCase.Description = basename + ' Ancillary Brand Approval';
        cLicenseeCase.Type = CaseManager.TYPE_CONSUMER_VENTURES;
        cLicenseeCase.Origin = CaseManager.ORIGIN_LICENSEE_PORTAL;
        cLicenseeCase.Status = CaseManager.STATUS_GE_APPROVAL_PROCESS;

        cLicenseeCase.Region__c = 'Americas';
        cLicenseeCase.SKU_Number__c = 'Test SKU';
        cLicenseeCase.SKU_Description__c = 'Test SKU Description';
        cLicenseeCase.Description = 'Description';
        cLicenseeCase.CV_Agreement_No_Name__c = null; //TODO: 'Agreement_No_Name__c';
        cLicenseeCase.Change_Type_Other__c = 'Change_Type_Other__c';
        cLicenseeCase.Brand_Approval_Type__c = 'Other';
        cLicenseeCase.Date_of_Launch_Event__c = Date.today();


        cLicenseeCase.OwnerId = ownerId;

        return cLicenseeCase;
    }

    /**
     * creates a single External Legal Case for test contexts
     * @param  ownerId     Id of the owner partner user
     * @param  accountId   Id of the corresponding account record
     * @param  contactId   Id of the corresponding contact record
     * @return             non-inserted AExternal Legal Case record
     */
    public static Case createExternalLegalCase(String basename, String ownerId, String accountId, String contactId) {
        Case cLicenseeCase = new Case();

        cLicenseeCase.RecordTypeId = Cache.RecordTypeId(CaseManager.RT_EXTERNAL_LEGAL);
        cLicenseeCase.ContactId = contactId;
        cLicenseeCase.AccountId = accountId;
        cLicenseeCase.Subject = basename + ' External Legal';
        cLicenseeCase.Description = basename + ' External Legal';
        cLicenseeCase.Type = CaseManager.TYPE_CONSUMER_VENTURES;
        cLicenseeCase.Origin = CaseManager.ORIGIN_LICENSEE_PORTAL;
        cLicenseeCase.Status = CaseManager.STATUS_GE_APPROVAL_PROCESS;

        cLicenseeCase.Request_Type__c = 'Amendment';
        cLicenseeCase.Amendment_Change_Type__c = 'Other';
        cLicenseeCase.Amendment_Change_Other__c = 'other change';
        cLicenseeCase.Description = 'desc';

        cLicenseeCase.OwnerId = ownerId;

        return cLicenseeCase;
    }

    /**
     * creates a single Internal Legal Case for test contexts
     * @param  ownerId     Id of the owner user
     * @param  accountId   Id of the corresponding account record
     * @param  contactId   Id of the corresponding contact record
     * @return             non-inserted Internal Legal Case record
     */
    public static Case createInternalLegalCase(String basename, String ownerId, String accountId, String contactId) {
        Case cLicenseeCase = new Case();

        cLicenseeCase.RecordTypeId = Cache.RecordTypeId(CaseManager.RT_INTERNAL_LEGAL);
        cLicenseeCase.ContactId = contactId;
        cLicenseeCase.AccountId = accountId;
        cLicenseeCase.Subject = basename + ' Internal Legal';
        cLicenseeCase.Description = basename + ' Internal Legal';
        cLicenseeCase.Type = CaseManager.TYPE_CONSUMER_VENTURES;
        cLicenseeCase.Origin = CaseManager.ORIGIN_INTERNAL_LEGAL;
        cLicenseeCase.Status = CaseManager.STATUS_GE_APPROVAL_PROCESS;

        cLicenseeCase.Request_Type__c = 'Amendment';
        cLicenseeCase.Amendment_Change_Type__c = 'Other';
        cLicenseeCase.Amendment_Change_Other__c = 'other change';
        cLicenseeCase.Description = 'desc';

        cLicenseeCase.OwnerId = ownerId;

        return cLicenseeCase;
    }

    /**
     * creates a single NPI Case for test contexts
     * @param  ownerId     Id of the owner user
     * @param  accountId   Id of the corresponding account record
     * @param  contactId   Id of the corresponding contact record
     * @return             non-inserted Internal Legal Case record
     */
    public static Case createNPICase(String basename, String ownerId, String accountId, String contactId) {
        Case cLicenseeCase = new Case();

        cLicenseeCase.RecordTypeId = Cache.RecordTypeId(CaseManager.RT_NPI);
        cLicenseeCase.ContactId = contactId;
        cLicenseeCase.AccountId = accountId;
        cLicenseeCase.Subject = basename + ' NPI';
        cLicenseeCase.Description = basename + ' NPI';
        cLicenseeCase.Type = CaseManager.TYPE_CONSUMER_VENTURES;
        cLicenseeCase.Origin = CaseManager.ORIGIN_LICENSEE_PORTAL;
        cLicenseeCase.Status = CaseManager.STATUS_GE_APPROVAL_PROCESS;

        cLicenseeCase.CV_Factory_Name__c = 'CV_Factory_Name__c';
        cLicenseeCase.CV_Factory_Location_Country__c = 'CV_Factory_Location_Country__c';
        cLicenseeCase.CV_Agreement_No_Name__c = null;
        cLicenseeCase.Description = 'Description';
        cLicenseeCase.BOI_Number__c = 'BOI_Number__c';
        cLicenseeCase.SKU_Number__c = 'SKU_Number__c';
        cLicenseeCase.Short_Product_Description__c = 'Short_Product_Description__c';
        cLicenseeCase.Long_Product_Description__c = 'Long_Product_Description__c';
        cLicenseeCase.Product_Category__c = 'Product_Category__c';
        cLicenseeCase.CV_Product_Sub_Cat_1__c = 'CV_Product_Sub_Cat_1__c';
        cLicenseeCase.CV_Product_Sub_Cat_2__c = 'CV_Product_Sub_Cat_2__c';
        cLicenseeCase.CV_Feature_1__c = 'CV_Feature_1__c';
        cLicenseeCase.CV_Feature_2__c = 'CV_Feature_2__c';
        cLicenseeCase.CV_Feature_3__c = 'CV_Feature_3__c';
        cLicenseeCase.CV_Feature_4__c = 'CV_Feature_4__c';
        cLicenseeCase.CV_Feature_5__c = 'CV_Feature_5__c';
        cLicenseeCase.CV_Targeted_Retailers__c = 'CV_Targeted_Retailers__c';
        cLicenseeCase.CV_Estimated_Annual_Unit_Volumes__c = 'CV_Estimated_Annual_Unit_Volumes__c';
        cLicenseeCase.CV_Estimated_MSRP__c = 12;
        cLicenseeCase.CV_Retailer_GM__c = 12;
        cLicenseeCase.CV_Estimated_Average_Selling_Price__c = 12;
        cLicenseeCase.CV_FOB__c = 12;
        cLicenseeCase.CV_Landed_Cost_COGS__c = 12;
        cLicenseeCase.CV_Licensee_GM__c = 12;
        cLicenseeCase.CV_Licensee_GM_Percent__c = 12;
        cLicenseeCase.CV_T1_Review__c = Date.today();
        cLicenseeCase.CV_T2_Review__c = Date.today();
        cLicenseeCase.CV_Production__c = Date.today();
        cLicenseeCase.CV_Ship_date_to_Licensee__c = Date.today();
        cLicenseeCase.CV_Ship_date_to_Customer__c = Date.today();
        cLicenseeCase.CV_Customer_rollout_date__c = Date.today();


        cLicenseeCase.OwnerId = ownerId;

        return cLicenseeCase;
    }

    /**
     * creates Case issues for test contexts
     * @param  caseId   Id of the corresponding Case record
     * @param  count       number of records to generate
     * @return             non-inserted list of generated CV_Case_Issue_Comment__c records
     */
    public static List<CV_Case_Issue_Comment__c> createCVCaseIssues(String caseId, Integer count) {
        List<CV_Case_Issue_Comment__c> results = new List<CV_Case_Issue_Comment__c>();
        for (Integer x = 0; x < count; x++) {
            CV_Case_Issue_Comment__c cvcicNewIssue = new CV_Case_Issue_Comment__c();
            cvcicNewIssue.RecordTypeId = Cache.RecordTypeId(CVCaseIssueCommentManager.RT_ISSUE);
            cvcicNewIssue.Resolved__c = false;
            cvcicNewIssue.Type__c = CVCaseIssueCommentManager.TYPE_ISSUE;
            cvcicNewIssue.Case__c = caseId;
            cvcicNewIssue.GE_Created_By__c = CVWorkflowSettingsManager.ROLE_FINANCE;
            cvcicNewIssue.Created_By__c = CVCaseIssueCommentManager.CREATED_BY_LICENSEE;
            cvcicNewIssue.Message__c = 'message';

            results.add(cvcicNewIssue);
        }
        return results;
    }

    /**
     * creates Case issues comments for test contexts
     * @param  caseId           Id of the corresponding Case record
     * @param  relatedIssueId   Id of the corresponding related issue record
     * @param  count            number of records to generate
     * @return                  non-inserted list of generated CV_Case_Issue_Comment__c records
     */
    public static List<CV_Case_Issue_Comment__c> createCVCaseIssueComments(String caseId, String relatedIssueId, Integer count) {
        List<CV_Case_Issue_Comment__c> results = new List<CV_Case_Issue_Comment__c>();
        for (Integer x = 0; x < count; x++) {
            CV_Case_Issue_Comment__c cvcicNewIssue = new CV_Case_Issue_Comment__c();
            cvcicNewIssue.RecordTypeId = Cache.RecordTypeId(CVCaseIssueCommentManager.RT_COMMENT);
            cvcicNewIssue.Resolved__c = false;
            cvcicNewIssue.Type__c = CVCaseIssueCommentManager.TYPE_COMMENT;
            cvcicNewIssue.Case__c = caseId;
            cvcicNewIssue.GE_Created_By__c = CVWorkflowSettingsManager.ROLE_FINANCE;
            cvcicNewIssue.Created_By__c = CVCaseIssueCommentManager.CREATED_BY_GE;
            cvcicNewIssue.Message__c = 'message';
            cvcicNewIssue.Related_Issue__c = relatedIssueId;

            results.add(cvcicNewIssue);
        }
        return results;
    }

    /**
     * creates products for test contexts
     * @param  licensees        List of Licensee Accounts
     * @param  basename         product basename
     * @param  countPerLicensee number of products per licensee
     * @return                  non-inserted list of generated Product2 records
     */
    public static List<Product2> createProducts(List<Account> licensees, String basename, Integer countPerLicensee) {

        List<Product2> results = new List<Product2>();
        for (Account licensee : licensees) {

            for (Integer x = 0; x < countPerLicensee; x++) {
              results.add(
                    new Product2(
                            Name = basename + String.valueOf(x)
                            , IsActive=true
                            , Licensee__c = licensee.Id
                            , Product_Number__c = basename + String.valueOf(x)
                            , RecordTypeId = Cache.RecordTypeId(ProductManager.RT_CONSUMER_VENTURES)
                    ));
            }
        }
        return results;
    }

     /**
     * creates contracts for test contexts
     * @param  licensees        List of Licensee Accounts
     * @param  basename         contract basename
     * @param  countPerLicensee number of products per licensee
     * @return                  non-inserted list of generated Contract records
     */
    public static List<Contract> createContracts(List<Account> licensees, String basename, Integer countPerLicensee) {

        List<Contract> results = new List<Contract>();
        for (Account licensee : licensees) {

            for (Integer x = 0; x < countPerLicensee; x++) {
              results.add(
                    new Contract(
                            Name = basename + String.valueOf(x)
                            , AccountId = licensee.Id
                            , Status = 'Draft'
                            , RecordTypeId = Cache.RecordTypeId(ContractManager.RT_AGREEMENT)
                    ));
            }
        }
        return results;
    }
}