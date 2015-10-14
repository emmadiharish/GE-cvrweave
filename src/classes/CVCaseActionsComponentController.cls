/******************************************************************************************************************************
* Name - CVCaseActionsComponentController
* Description
* Controller class for CVCaseActionsComponent
* //TODO
* Modification Log :
* ---------------------------------------------------------------------------
* Developer Date Description
* ---------------------------------------------------------------------------
* Zoran Zunko 05/25/2015 Created.
******************************************************************************************************************************/
public with sharing class CVCaseActionsComponentController {
//*****************************************************************************************************************************
//controller properties
//******************************************************************************************************************************
    public CaseWorkflowExtensionControllerBase pageController {get; set;}

    public Boolean displayPopUp {get; private set;}
    {
        displayPopUp = false;
    }

//******************************************************************************************************************************

    public CVCaseActionsComponentController() {

    }

    /**
     * method starts the rejection of the case by displaying the rejection comment entry popup
     * @return null
     */
    public PageReference rejectStart() {
        System.debug(LoggingLevel.DEBUG, 'CVCaseActionsComponentController - rejectStart start');
        pageController.sCVRejectionReason = '';
        displayPopUp = true;
        System.debug(LoggingLevel.DEBUG, 'CVCaseActionsComponentController - rejectStart end');
        return null;
    }

    /**
     * method cancels the rejection of the case and closes the rejection comment entry popup
     * @return null
     */
    public PageReference rejectCancel() {
        System.debug(LoggingLevel.DEBUG, 'CVCaseActionsComponentController - rejectCancel start');
        displayPopUp = false;
        System.debug(LoggingLevel.DEBUG, 'CVCaseActionsComponentController - rejectCancel end');
        return null;
    }

    /**
     * method sets the popup display to false and calls pageController.reject()
     * @return null
     */
    public PageReference reject() {
        System.debug(LoggingLevel.DEBUG, 'CVCaseActionsComponentController - reject start');
        displayPopUp = false;
        System.debug(LoggingLevel.DEBUG, 'CVCaseActionsComponentController - reject end');
        return pageController.reject();
    }
}