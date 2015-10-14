/******************************************************************************************************************************
* Name - CaseManager
* Description
* Manager class that contains all the methods and constants for handling Case records.
* To be used as a single source of business logic and data loading methods in order to ease reuse.
* Modification Log :
* ---------------------------------------------------------------------------
* Developer Date Description
* ---------------------------------------------------------------------------
* Zoran Zunko 05/03/2015 Created.
* Zoran Zunko 08/05/2015 Status field constants adjustment.
* Zoran Zunko 08/25/2015 setNPICaseFields added
******************************************************************************************************************************/
public with sharing class CaseManager {

//******************************************************************************************************************************
//record type constants
//******************************************************************************************************************************
    public static String RT_ROYALTY_SUBMISSION = 'Case.CV_Royalty_Submission';
    public static String RT_PRODUCT_CHANGE = 'Case.CV_Product_Change';
    public static String RT_BRAND_CHANGE = 'Case.CV_Brand_Change';
    public static String RT_ANCILLARY_BRAND = 'Case.CV_Ancilary_Brand';
    public static String RT_EXTERNAL_LEGAL = 'Case.CV_External_Legal';
    public static String RT_INTERNAL_LEGAL = 'Case.CV_Internal_Legal';
    public static String RT_NPI = 'Case.CV_New_Product';

    public static Set<String> caseRecordTypeIdSet = new Set<String>{
                                                        RT_ROYALTY_SUBMISSION
                                                        , RT_PRODUCT_CHANGE
                                                        , RT_BRAND_CHANGE
                                                        , RT_ANCILLARY_BRAND
                                                        , RT_EXTERNAL_LEGAL
                                                        , RT_INTERNAL_LEGAL
                                                        , RT_NPI
                                                        };
//******************************************************************************************************************************

//******************************************************************************************************************************
//type constants
//******************************************************************************************************************************
    public static String TYPE_CONSUMER_VENTURES = 'Consumer Ventures';
//******************************************************************************************************************************

//******************************************************************************************************************************
//origin constants
//******************************************************************************************************************************
    public static String ORIGIN_LICENSEE_PORTAL = 'Licensee Portal';
    public static String ORIGIN_INTERNAL_LEGAL = 'Internal Legal Case';
//******************************************************************************************************************************

//******************************************************************************************************************************
//Product Change Type constants
//******************************************************************************************************************************
    public static String PRODUCT_CHANGE_TYPE_BRAND = 'Brand Change';
    public static String PRODUCT_CHANGE_TYPE_PRODUCT = 'Product Change';
//******************************************************************************************************************************

//******************************************************************************************************************************
//Request type constants
//******************************************************************************************************************************
    public static String REQUEST_TYPE_AMENDMENT = 'Amendment';
    
//******************************************************************************************************************************

//******************************************************************************************************************************
//Status constatnts
//******************************************************************************************************************************
    public static final String STATUS_NEW = 'Created';
    public static final String STATUS_SUBMITTED_FOR_REVIEW = 'Submitted';
    public static final String STATUS_RE_SUBMITTED_FOR_REVIEW = 'Resubmitted';
    public static final String STATUS_GE_APPROVAL_PROCESS = 'GE Approval Process';
    public static final String STATUS_CLOSED_APPROVED = 'Closed - Approved';
    public static final String STATUS_CLOSED_REJECTED = 'Closed - Rejected';
    public static final String STATUS_LICENSEE_RESPONSE_NEEDED = 'Licensee Feedback Required';
    public static final String STATUS_SAMPLES_NOT_SHIPPED = 'Samples Not Shipped';
    public static final String STATUS_SAMPLES_SHIPPED = 'Samples Shipped';
    public static final String STATUS_SAMPLES_RECEIVED_BY_GE = 'Samples Received by GE';
    public static final String STATUS_T1_SAMPLES_SHIPPED = 'T1 Samples Shipped';
    public static final String STATUS_T1_SAMPLES_RECEIVED_BY_GE = 'T1 Samples Received by GE';
    public static final String STATUS_T1_GE_APPROVAL_PROCESS = 'T1 GE Approval Process';
    public static final String STATUS_T1_LICENSEE_FEEDBACK_REQUIRED = 'T1 Licensee Feedback Required';
    public static final String STATUS_T1_RESUBMITTED = 'T1 Resubmitted';
    public static final String STATUS_T1_CLOSED_REJECTED = 'T1 Closed - Rejected';
    public static final String STATUS_T1_SCHEDULING_REVIEW = 'T1 Scheduling Review';
    public static final String STATUS_T1_REVIEW_SCHEDULED = 'T1 Review Scheduled';
    public static final String STATUS_T1_REVIEW_CONDUCTED = 'T1 Review Conducted';
    public static final String STATUS_T2_SAMPLES_SHIPPED = 'T2 Samples Shipped';
    public static final String STATUS_T2_SAMPLES_RECEIVED_BY_GE = 'T2 Samples Received by GE';
    public static final String STATUS_T2_GE_APPROVAL_PROCESS = 'T2 GE Approval Process';
    public static final String STATUS_T2_LICENSEE_FEEDBACK_REQUIRED = 'T2 Licensee Feedback Required';
    public static final String STATUS_T2_RESUBMITTED = 'T2 Resubmitted';
    public static final String STATUS_T2_CLOSED_REJECTED = 'T2 Closed - Rejected';
    public static final String STATUS_T2_SCHEDULING_REVIEW = 'T2 Scheduling Review';
    public static final String STATUS_T2_REVIEW_SCHEDULED = 'T2 Review Scheduled';
    public static final String STATUS_T2_REVIEW_CONDUCTED = 'T2 Review Conducted';
    public static final String STATUS_T2_CLOSED_APPROVED = 'T2 Closed - Approved';

    //TODO CHECK WITH SCOTT AND PAT
    //******************************************************************************************************************************
    public static final String STATUS_T0_GE_APPROVAL_PROCESS = 'T0 GE Approval Process';
    public static final String STATUS_T0_LICENSEE_FEEDBACK_REQUIRED = 'T0 Licensee Feedback Required';
    public static final String STATUS_T0_RESUBMITTED = 'T0 Resubmitted';
    public static final String STATUS_T0_SUBMITTED = 'T0 Submitted';
    public static final String STATUS_T0_CLOSED_REJECTED = 'T0 Closed - Rejected';
    public static final String STATUS_T0_CLOSED_APPROVED = 'T0 Closed - Approved';
    public static final String STATUS_T1_SAMPLES_NOT_SHIPPED = 'T1 Samples Not Shipped';
    public static final String STATUS_T2_SAMPLES_NOT_SHIPPED = 'T2 Samples Not Shipped';

    //******************************************************************************************************************************

    @testVisible private static Set<String> gatekeepingAllowedStatuses;
    public static Set<String> getGatekeepingAllowedStatuses() {

        if(gatekeepingAllowedStatuses == null) {

            gatekeepingAllowedStatuses = new Set<String> {
                    STATUS_SUBMITTED_FOR_REVIEW
                    , STATUS_RE_SUBMITTED_FOR_REVIEW
                    , STATUS_T0_SUBMITTED
                    , STATUS_T0_RESUBMITTED
                    //, STATUS_T1_SUBMITTED
                    , STATUS_T1_RESUBMITTED
                    //, STATUS_T2_SUBMITTED
                    , STATUS_T2_RESUBMITTED
                    , STATUS_T0_CLOSED_APPROVED
                    , STATUS_SAMPLES_SHIPPED
                    , STATUS_T1_SAMPLES_SHIPPED
                    , STATUS_T2_SAMPLES_SHIPPED
                    , STATUS_T1_SCHEDULING_REVIEW
                    , STATUS_T1_REVIEW_SCHEDULED
                    , STATUS_T1_REVIEW_CONDUCTED
                    , STATUS_T2_SCHEDULING_REVIEW
                    , STATUS_T2_REVIEW_SCHEDULED
                    , STATUS_T2_REVIEW_CONDUCTED
                };
        }

        return gatekeepingAllowedStatuses;
    }

    @testVisible private static Set<String> geRoleStatusResetStatuses;
    public static Set<String> getGeRoleStatusResetStatuses() {

        if(geRoleStatusResetStatuses == null) {

            geRoleStatusResetStatuses = new Set<String> {
                    STATUS_GE_APPROVAL_PROCESS
                    , STATUS_T0_GE_APPROVAL_PROCESS
                    , STATUS_T1_GE_APPROVAL_PROCESS
                    , STATUS_T2_GE_APPROVAL_PROCESS
                };
        }

        return geRoleStatusResetStatuses;
    }

//******************************************************************************************************************************

//******************************************************************************************************************************
//CV Role status constatnts
//******************************************************************************************************************************
    public static String STATUS_ROLE_GE_ACTION_REQUIRED = 'GE Action Required';
    public static String STATUS_ROLE_LICENSEE_RESPONSE_NEEDED = 'Licensee Response Needed';
    public static String STATUS_ROLE_APPROVED = 'Approved';
    public static String STATUS_ROLE_REJECTED = 'Rejected';
//******************************************************************************************************************************

    /**
     * Creates a Map of Consumer Ventures cases by iterating through a map of Updated/Inserted cases and 
     * checking whether Case.Type == Consumer Ventures
     * @param  caseNewMap Trigger.newMap
     * @return            a new Map<Id, Case> with all Consumer Ventures Cases
     */
    public static List<Case> getCVCases(List<Case> caseList) {
        System.debug(LoggingLevel.DEBUG, 'CaseManager - getCVCases start');
        System.debug(LoggingLevel.DEBUG, 'caseList: ' + caseList);
        List<Case> cCVCasesList = new List<Case>();

        for(Case cCVCase : caseList) {
            if(cCVCase.Type == CaseManager.TYPE_CONSUMER_VENTURES) {
                cCVCasesList.add(cCVCase);
            }
        }
        System.debug(LoggingLevel.DEBUG, 'cCVCasesList: ' + cCVCasesList);
        System.debug(LoggingLevel.DEBUG, 'CaseManager - getCVCases end');

        return cCVCasesList;
    }

    /**
     * Creates a List of Consumer Ventures Approved Internal cases by iterating through a map of Updated/Inserted cases and 
     * checking whether Case.RecordType is Internal Legal
     * @param  caseList Trigger.new
     * @return            a new List<Case> with all Consumer Ventures Cases Internal Legal Approved
     */
    public static List<Case> getCVInternalLegalCases(List<Case> caseList) {
        System.debug(LoggingLevel.DEBUG, 'CaseManager - getCVInternalLegalCases start');
        System.debug(LoggingLevel.DEBUG, 'caseList: ' + caseList);
        List<Case> cCVCasesList = new List<Case>();

        for(Case cCVCase : caseList) {
            if(cCVCase.RecordTypeId == Cache.RecordTypeId(RT_INTERNAL_LEGAL) && cCVCase.Status == STATUS_CLOSED_APPROVED) {
                cCVCasesList.add(cCVCase);
            }
        }
        System.debug(LoggingLevel.DEBUG, 'cCVCasesList: ' + cCVCasesList);
        System.debug(LoggingLevel.DEBUG, 'CaseManager - getCVInternalLegalCases end');

        return cCVCasesList;
    }

    /**
     * Queries Case record type parameters and returns the results in a map
     * @param  caseIds Ids of Case records that need to be queried
     * @return         Map<Id, Case> with following fields queried Id, RecordTypeId, RecordType.Name, RecordType.DeveloperName
     */
    public static Map<Id, Case> getCasesWithRecordTypeForCaseIds(List<Id> caseIds) {
        System.debug(LoggingLevel.DEBUG, 'CaseManager - getCasesWithRecordTypeForCaseIds start');
        System.debug(LoggingLevel.DEBUG, 'caseIds: ' + caseIds);
        Map<Id, Case> response =
            new Map<Id, Case>(
                          [SELECT Id
                                  , RecordTypeId
                                  , RecordType.Name
                                  , RecordType.DeveloperName
                           FROM Case
                           WHERE Id IN :caseIds]
                    );
        System.debug(LoggingLevel.DEBUG, 'response: ' + response);
        System.debug(LoggingLevel.DEBUG, 'CaseManager - getCasesWithRecordTypeForCaseIds end');
        return response;
    }

    private static Map<Id, RecordType> caseRecordTypeIdMapForCaseIds;
    public static Map<Id, RecordType> getCaseRecordTypeIdMapForCaseIds(List<Case> cvCases) {
        System.debug(LoggingLevel.DEBUG, 'CaseManager - getCaseRecordTypeIdMapForCaseIds start');
        System.debug(LoggingLevel.DEBUG, 'caseRecordTypeIdMapForCaseIds: ' + caseRecordTypeIdMapForCaseIds);
        if(caseRecordTypeIdMapForCaseIds == null) {
            System.debug(LoggingLevel.DEBUG, 'cases: ' + cvCases);
            Set<Id> recordTypeIds = new Set<Id>();
            for(Case cCVCase : cvCases) {
                recordTypeIds.add(cCVCase.RecordTypeId);
            }
            caseRecordTypeIdMapForCaseIds =new Map<Id, RecordType>(
                                                          [SELECT Id
                                                                  , Name
                                                                  , DeveloperName
                                                           FROM RecordType
                                                           WHERE Id IN :recordTypeIds]
                        );
            System.debug(LoggingLevel.DEBUG, 'caseRecordTypeIdMapForCaseIds: ' + caseRecordTypeIdMapForCaseIds);
        }
        System.debug(LoggingLevel.DEBUG, 'CaseManager - getCaseRecordTypeIdMapForCaseIds end');
        return caseRecordTypeIdMapForCaseIds;
    }

    /**
     * Sets the fields required for Royalty Submission Case based on licensee data
     * @param  cRoyaltySubmissionCase case record to set the fields
     * @param  uLicensee              Licensee user creating the Case
     * @return                        the Royalty Submission Case with fields set.
     */
    public static Case setRoyaltySubmissionCaseFields(Case cRoyaltySubmissionCase, User uLicensee) {
        cRoyaltySubmissionCase.RecordTypeId = Cache.RecordTypeId(RT_ROYALTY_SUBMISSION);
        cRoyaltySubmissionCase.ContactId = uLicensee.ContactId;
        cRoyaltySubmissionCase.AccountId = uLicensee.Contact.Account.Id;
        cRoyaltySubmissionCase.Subject = uLicensee.Contact.Account.Name + ' Royalty Submission';
        cRoyaltySubmissionCase.Description = uLicensee.Contact.Account.Name + ' Royalty Submission';
        cRoyaltySubmissionCase.Type = TYPE_CONSUMER_VENTURES;
        cRoyaltySubmissionCase.Origin = ORIGIN_LICENSEE_PORTAL;
        cRoyaltySubmissionCase.Status = STATUS_SUBMITTED_FOR_REVIEW;

        return cRoyaltySubmissionCase;
    }

    /**
     * Sets the fields required for Product Change Case based on licensee data
     * @param  cProductChange         case record to set the fields
     * @param  uLicensee              Licensee user creating the Case
     * @return                        Product Change Case with fields set.
     */
    public static Case setProductChangeCaseFields(Case cProductChange, User uLicensee) {
        cProductChange.RecordTypeId = Cache.RecordTypeId(RT_PRODUCT_CHANGE);
        cProductChange.ContactId = uLicensee.ContactId;
        cProductChange.AccountId = uLicensee.Contact.Account.Id;
        cProductChange.Subject = uLicensee.Contact.Account.Name + ' Product Change';
        cProductChange.Type = TYPE_CONSUMER_VENTURES;
        cProductChange.Origin = ORIGIN_LICENSEE_PORTAL;
        cProductChange.Status = STATUS_SUBMITTED_FOR_REVIEW;
        cProductChange.Product_Change_Type__c = PRODUCT_CHANGE_TYPE_PRODUCT;

        return cProductChange;
    }

    /**
     * Sets the fields required for Brand Change Case based on licensee data
     * @param  cBrandChange           case record to set the fields
     * @param  uLicensee              Licensee user creating the Case
     * @return                        Brand Change Case with fields set.
     */
    public static Case setBrandChangeCaseFields(Case cBrandChange, User uLicensee) {
        cBrandChange.RecordTypeId = Cache.RecordTypeId(RT_BRAND_CHANGE);
        cBrandChange.ContactId = uLicensee.ContactId;
        cBrandChange.AccountId = uLicensee.Contact.Account.Id;
        cBrandChange.Subject = uLicensee.Contact.Account.Name + ' Brand Change';
        cBrandChange.Type = TYPE_CONSUMER_VENTURES;
        cBrandChange.Origin = ORIGIN_LICENSEE_PORTAL;
        cBrandChange.Status = STATUS_SUBMITTED_FOR_REVIEW;
        cBrandChange.Product_Change_Type__c = PRODUCT_CHANGE_TYPE_BRAND;

        return cBrandChange;
    }

    /**
     * Sets the fields required for Ancillary Brand Approval Case based on licensee data
     * @param  cAncillaryBrand           case record to set the fields
     * @param  uLicensee              Licensee user creating the Case
     * @return                        Ancillary Brand Case with fields set.
     */
    public static Case setAncillaryBrandCaseFields(Case cAncillaryBrand, User uLicensee) {
        cAncillaryBrand.RecordTypeId = Cache.RecordTypeId(RT_ANCILLARY_BRAND);
        cAncillaryBrand.ContactId = uLicensee.ContactId;
        cAncillaryBrand.AccountId = uLicensee.Contact.Account.Id;
        cAncillaryBrand.Subject = uLicensee.Contact.Account.Name + ' Ancillary Brand Approval';
        cAncillaryBrand.Type = TYPE_CONSUMER_VENTURES;
        cAncillaryBrand.Origin = ORIGIN_LICENSEE_PORTAL;
        cAncillaryBrand.Status = STATUS_SUBMITTED_FOR_REVIEW;

        return cAncillaryBrand;
    }

    /**
     * Sets the fields required for External Legal Case based on licensee data
     * @param  cExternalLegal           case record to set the fields
     * @param  uLicensee              Licensee user creating the Case
     * @return                        External Legal Case with fields set.
     */
    public static Case setExternalLegalCaseFields(Case cExternalLegal, User uLicensee) {
        cExternalLegal.RecordTypeId = Cache.RecordTypeId(RT_EXTERNAL_LEGAL);
        cExternalLegal.ContactId = uLicensee.ContactId;
        cExternalLegal.AccountId = uLicensee.Contact.Account.Id;
        cExternalLegal.Subject = uLicensee.Contact.Account.Name + ' External Legal';
        cExternalLegal.Type = TYPE_CONSUMER_VENTURES;
        cExternalLegal.Origin = ORIGIN_LICENSEE_PORTAL;
        cExternalLegal.Status = STATUS_SUBMITTED_FOR_REVIEW;

        return cExternalLegal;
    }

    /**
     * Sets the fields required for External Legal Case based on licensee data
     * @param  cExternalLegal           case record to set the fields
     * @param  uLicenseeId              Licensee userid for ownership of the Case
     * @return                        External Legal Case with fields set.
     */
    public static Case setExternalLegalCaseFields(Case cInternalLegal, Id uLicenseeId) {
        Case cExternalLegal = new Case();
        cExternalLegal.RecordTypeId = Cache.RecordTypeId(RT_EXTERNAL_LEGAL);
        cExternalLegal.ContactId = cInternalLegal.ContactId;
        cExternalLegal.AccountId = cInternalLegal.AccountId;
        cExternalLegal.Request_Type__c = cInternalLegal.Request_Type__c;
        cExternalLegal.CV_Agreement_No_Name__c = cInternalLegal.CV_Agreement_No_Name__c;
        cExternalLegal.Amendment_Change_Type__c = cInternalLegal.Amendment_Change_Type__c;
        cExternalLegal.Description = cInternalLegal.Description;
        cExternalLegal.Amendment_Change_Other__c = cInternalLegal.Amendment_Change_Other__c;
        cExternalLegal.Participating_Roles__c = cInternalLegal.Participating_Roles__c;
        cExternalLegal.Subject = cInternalLegal.Subject.replace(' Internal Legal', ' External Legal');
        cExternalLegal.Type = TYPE_CONSUMER_VENTURES;
        cExternalLegal.Origin = ORIGIN_INTERNAL_LEGAL;
        cExternalLegal.Status = STATUS_SUBMITTED_FOR_REVIEW;
        cExternalLegal.ParentId = cInternalLegal.Id;
        cExternalLegal.OwnerId = uLicenseeId;

        return cExternalLegal;
    }

    /**
     * Sets the fields required for Internal Legal Case based on licensee data
     * @param  cInternalLegal           case record to set the fields
     * @param  uLicensee              Licensee user creating the Case
     * @return                        Internal Legal Case with fields set.
     */
    public static Case setInternalLegalCaseFields(Case cInternalLegal, Account aLicenseeAccount) {
        cInternalLegal.RecordTypeId = Cache.RecordTypeId(RT_INTERNAL_LEGAL);
        //cInternalLegal.ContactId = uLicensee.ContactId;
        cInternalLegal.AccountId = aLicenseeAccount.Id;
        cInternalLegal.Subject = aLicenseeAccount.Name + ' Internal Legal';
        cInternalLegal.Type = TYPE_CONSUMER_VENTURES;
        cInternalLegal.Origin = ORIGIN_INTERNAL_LEGAL;
        cInternalLegal.Status = STATUS_SUBMITTED_FOR_REVIEW;

        return cInternalLegal;
    }

    /**
     * Sets the fields required for NPI Case based on licensee data
     * @param  cInternalLegal           case record to set the fields
     * @param  uLicensee              Licensee user creating the Case
     * @return                        Internal Legal Case with fields set.
     */
    public static Case setNPICaseFields(Case cNPI, User uLicensee) {
        cNPI.RecordTypeId = Cache.RecordTypeId(RT_NPI);
        cNPI.ContactId = uLicensee.ContactId;
        cNPI.AccountId = uLicensee.Contact.Account.Id;
        cNPI.Subject = uLicensee.Contact.Account.Name + ' NPI';
        cNPI.Type = TYPE_CONSUMER_VENTURES;
        cNPI.Status = STATUS_SUBMITTED_FOR_REVIEW;
        cNPI.Origin = ORIGIN_LICENSEE_PORTAL;

        return cNPI;
    }
}