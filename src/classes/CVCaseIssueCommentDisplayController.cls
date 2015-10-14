/******************************************************************************************************************************
* Name - CVCaseIssueCommentDisplayController
* Description
* Controller class for CVCaseIssueCommentDisplay
* //TODO
* Modification Log :
* ---------------------------------------------------------------------------
* Developer Date Description
* ---------------------------------------------------------------------------
* Zoran Zunko 05/03/2015 Created.
******************************************************************************************************************************/
public with sharing class CVCaseIssueCommentDisplayController {
//*****************************************************************************************************************************
//controller properties
//******************************************************************************************************************************
    public CaseWorkflowExtensionControllerBase pageController {get; set;}

    public CV_Case_Issue_Comment__c cvcicNewIssue {get; private set;}
    public CV_Case_Issue_Comment__c cvcicNewComment {get; private set;}

    public Id cvcicNewCommentIssueId {get; set;}
    public Id cvcicMarkResolvedIssueId {get; set;}

    public Boolean displayPopUp {get; private set;}
    {
        displayPopUp = false;
    }

//******************************************************************************************************************************

    public CVCaseIssueCommentDisplayController() {

	}

    public PageReference addIssue() {
        cvcicNewIssue = CVCaseIssueCommentManager.createIssueForUserId(pageController.getCurrentUserWorkflowRole(), pageController.cLicenseeCase.Id);
        displayPopUp = true;
        return null;
    }

    public PageReference saveIssue() {
        System.debug(LoggingLevel.DEBUG, 'CVCaseIssueCommentDisplayController - saveIssue start');
        try {
            insert cvcicNewIssue;
            displayPopUp = false;
            pageController.init();
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Issue was successfully added.'));
        }
        catch(Exception ex) {
            System.debug(LoggingLevel.ERROR, ex.getMessage() + '\n' + ex.getStackTraceString());
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error while creating the issue please try again later.'));
        }
        System.debug(LoggingLevel.DEBUG, 'CVCaseIssueCommentDisplayController - saveIssue end');

        return null;
    }

    public PageReference addComment() {
        cvcicNewComment = CVCaseIssueCommentManager.createCommentForUserId(pageController.getCurrentUserWorkflowRole(), pageController.cLicenseeCase.Id);
        cvcicNewComment.Related_Issue__c = cvcicNewCommentIssueId;
        displayPopUp = true;
        return null;
    }

    public PageReference saveComment() {
        System.debug(LoggingLevel.DEBUG, 'CVCaseIssueCommentDisplayController - saveComment start');
        try {
            displayPopUp = false;
            insert cvcicNewComment;
            pageController.init();
            cvcicNewCommentIssueId = null;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Comment was successfully added.'));
        }
        catch(Exception ex) {
            System.debug(LoggingLevel.ERROR, ex.getMessage() + '\n' + ex.getStackTraceString());
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error while creating the Comment please try again later.'));
        }
        System.debug(LoggingLevel.DEBUG, 'CVCaseIssueCommentDisplayController - saveComment end');

        return null;
    }

    public PageReference cancel() {
        displayPopUp = false;
        return null;
    }

    public PageReference markedResolved() {
        System.debug(LoggingLevel.DEBUG, 'CVCaseIssueCommentDisplayController - markedResolved start');
        try {
            update CVCaseIssueCommentManager.markIssueResolved(cvcicMarkResolvedIssueId);
            displayPopUp = false;
            pageController.init();
            cvcicMarkResolvedIssueId = null;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Issue was successfully resolved.'));
        }
        catch(Exception ex) {
            System.debug(LoggingLevel.ERROR, ex.getMessage() + '\n' + ex.getStackTraceString());
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error while resolving the Issue please try again later.'));
        }
        System.debug(LoggingLevel.DEBUG, 'CVCaseIssueCommentDisplayController - markedResolved end');

        return null;
    }
}