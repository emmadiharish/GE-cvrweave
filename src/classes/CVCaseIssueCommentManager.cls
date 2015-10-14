/******************************************************************************************************************************
* Name - CVCaseIssueCommentManager
* Description
* Manager class that contains all the methods and constants for handling CV Case Issue/Comment records.
* To be used as a single source of business logic and data loading methods in order to ease reuse.
* Modification Log :
* ---------------------------------------------------------------------------
* Developer Date Description
* ---------------------------------------------------------------------------
* Zoran Zunko 05/03/2015 Created.
******************************************************************************************************************************/
public with sharing class CVCaseIssueCommentManager {

//******************************************************************************************************************************
//record type constants
//******************************************************************************************************************************
    public static String RT_ISSUE = 'CV_Case_Issue_Comment__c.Issue';
    public static String RT_COMMENT = 'CV_Case_Issue_Comment__c.Comment';
//******************************************************************************************************************************

//******************************************************************************************************************************
//type constants
//******************************************************************************************************************************
    public static String TYPE_ISSUE = 'Issue';
    public static String TYPE_COMMENT = 'Comment';
//******************************************************************************************************************************

//******************************************************************************************************************************
//Created By constatnts
//******************************************************************************************************************************
    public static String CREATED_BY_GE = 'GE';
    public static String CREATED_BY_LICENSEE = 'Licensee';
//******************************************************************************************************************************

    /**
     * loads all Issues with their comments for a given case id. All results are sorted from newer to older
     * @param  cCaseId id of the case to load the issues for
     * @return         a List of Issues with all the fields queried (contains Comments inner list)
     */
    public static List<CV_Case_Issue_Comment__c> getIssuesForCaseId(Id cCaseId) {
        return [SELECT
                    Case__c
                    , Created_By__c
                    , GE_Created_By__c
                    , Message__c
                    , Related_Issue__c
                    , Resolved__c
                    , Type__c
                    , Name
                    , CreatedDate
                    , New_Samples_Required__c
                    , (SELECT Case__c
                        , Created_By__c
                        , GE_Created_By__c
                        , Message__c
                        , Related_Issue__c
                        , Resolved__c
                        , Type__c
                        , Name
                        , CreatedDate
                      FROM Comments__r
                      ORDER BY Name ASC)
                FROM CV_Case_Issue_Comment__c
                WHERE Case__c = :cCaseId
                    AND RecordTypeId = :Cache.RecordTypeId(RT_ISSUE)
                ORDER BY Name ASC];
    }

    /**
     * creates a new CV_Case_Issue_Comment__c record of issue type, without Message field set.
     * @param  currentUserWorkflowRole GE CV Workflow role of the user creating the issue
     * @return                         a new not inserted CV_Case_Issue_Comment__c record of issue type
     */
    public static CV_Case_Issue_Comment__c createIssueForUserId(String currentUserWorkflowRole, Id cLicenseeCaseId) {

        CV_Case_Issue_Comment__c cvcicNewIssue = new CV_Case_Issue_Comment__c();
        cvcicNewIssue.RecordTypeId = Cache.RecordTypeId(RT_ISSUE);
        cvcicNewIssue.Resolved__c = false;
        cvcicNewIssue.Type__c = TYPE_ISSUE;
        cvcicNewIssue.Case__c = cLicenseeCaseId;
        cvcicNewIssue.GE_Created_By__c = currentUserWorkflowRole;
        cvcicNewIssue.Created_By__c = currentUserWorkflowRole == CVWorkflowSettingsManager.ROLE_LICENSEE ? CREATED_BY_LICENSEE : CREATED_BY_GE;

        return cvcicNewIssue;
    }

    /**
     * creates a new CV_Case_Issue_Comment__c record of comment type, without Message field set.
     * @param  currentUserWorkflowRole GE CV Workflow role of the user creating the comment
     * @return                         a new not inserted CV_Case_Issue_Comment__c record of comment type
     */
    public static CV_Case_Issue_Comment__c createCommentForUserId(String currentUserWorkflowRole, Id cLicenseeCaseId) {

        CV_Case_Issue_Comment__c cvcicNewIssue = new CV_Case_Issue_Comment__c();
        cvcicNewIssue.RecordTypeId = Cache.RecordTypeId(RT_COMMENT);
        cvcicNewIssue.Resolved__c = false;
        cvcicNewIssue.Case__c = cLicenseeCaseId;
        cvcicNewIssue.Type__c = TYPE_COMMENT;
        cvcicNewIssue.GE_Created_By__c = currentUserWorkflowRole;//currentUserWorkflowRole == CVWorkflowSettingsManager.ROLE_LICENSEE ? '' : currentUserWorkflowRole;
        cvcicNewIssue.Created_By__c = currentUserWorkflowRole == CVWorkflowSettingsManager.ROLE_LICENSEE ? CREATED_BY_LICENSEE : CREATED_BY_GE;

        return cvcicNewIssue;
    }

    /**
     * resolves an issue based on the issue id, does not update the record
     * @param  cvcicIssueToResolveId id of the issue to resolve
     * @return                       new instance of CV_Case_Issue_Comment__c record with id set to cvcicIssueToResolveId and Resolved set to true
     */
    public static CV_Case_Issue_Comment__c markIssueResolved(Id cvcicIssueToResolveId) {
        return new CV_Case_Issue_Comment__c(
                                                Id = cvcicIssueToResolveId
                                                , Resolved__c = true
                                                );
    }

}