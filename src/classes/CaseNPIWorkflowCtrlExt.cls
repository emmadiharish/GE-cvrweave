/******************************************************************************************************************************
* Name - CaseNPIWorkflowCtrlExt
* Description
* Controller Extension class for NPI workflow
* Modification Log :
* ---------------------------------------------------------------------------
* Developer Date Description
* ---------------------------------------------------------------------------
* Zoran Zunko 09/02/2015 Created.
******************************************************************************************************************************/
public with sharing class CaseNPIWorkflowCtrlExt extends CaseWorkflowExtensionControllerBase {
//TODO: check if one user can have multiple roles in one process
//******************************************************************************************************************************
//base property method overrides
//******************************************************************************************************************************
    public override String getCurrentUserWorkflowRole() {
        if(this.currentUserWorkflowRole == null) {
            this.currentUserWorkflowRole = CVWorkflowSettingsManager.getNPIWorkflowRoleForUser(UserInfo.getUserId());
        }
        return this.currentUserWorkflowRole;
    }

    public override Boolean getAllowsReShippingOfSamples() {

        return cLicenseeCase.Status == CaseManager.STATUS_T2_GE_APPROVAL_PROCESS;
    }

//******************************************************************************************************************************
//******************************************************************************************************************************
//controller properties
//******************************************************************************************************************************
    public Boolean shippingButtonsVisible {
        get {
            return
                (getCurrentUserWorkflowRole() == roleLicensee)
                && ((cLicenseeCase.Status == CaseManager.STATUS_T1_SAMPLES_NOT_SHIPPED)
                    || (cLicenseeCase.Status == CaseManager.STATUS_T2_SAMPLES_NOT_SHIPPED));
        }
    }
//******************************************************************************************************************************

    public CaseNPIWorkflowCtrlExt(ApexPages.StandardController stdController) {

        super(stdController);

        System.debug(LoggingLevel.DEBUG, 'CaseNPIWorkflowCtrlExt - constructor start');
        init();
        System.debug(LoggingLevel.DEBUG, 'CaseNPIWorkflowCtrlExt - constructor end');
    }

    /**
     * initializes the controller and adds the messages to the running user if no action is required
     */
    public override void init() {
        super.init();

        System.debug(LoggingLevel.DEBUG, 'CaseNPIWorkflowCtrlExt - init start');
        try {
            if(roleLicensee != getCurrentUserWorkflowRole() && !gecvButtonsVisible) {

                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'No action is required from your side at this time.'));
                return;
            }
            else if(roleLicensee == getCurrentUserWorkflowRole() && !getLicenseeButtonsVisible() && areAllIssuesResponded() && !shippingButtonsVisible) {

                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'No action is required from your side at this time.'));
            }
            else if(roleLicensee == getCurrentUserWorkflowRole() && shippingButtonsVisible) {

                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Please add shipping information'));
            }

            if (roleLicensee == getCurrentUserWorkflowRole() && !areAllIssuesResponded()) {

                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'One or more Issues are pending your comment. Please respond to all the issues and then re-submit.'));
            }

            System.debug('currentUserWorkflowRole:' + currentUserWorkflowRole);

            if(roleLicensee != getCurrentUserWorkflowRole()) {

                List<Product_Sample_Shipping_Info__c> shippingInfos = ProductSampleShippingInfoManager.getShippingInfosForCaseIdAndCaseStatus(cLicenseeCase.Id, cLicenseeCase.Status);

                for(Product_Sample_Shipping_Info__c shippingInfo : shippingInfos) {

                    if(!shippingInfo.Confirmed__c) {

                        shippingInfoWfRole = shippingInfo;

                        for(Product_Sample_Ship_Info_Confirmation__c pssic : shippingInfoWfRole.Confirmations__r) {

                            if(pssic.Role__c == currentUserWorkflowRole) {

                                productSampleShipInfoConfirmationCurrentRole = pssic;
                                System.debug('shippingInfoWfRole' + shippingInfoWfRole);
                                break;
                            }
                        }

                        break;
                    }
                }
            }

        }
        catch(Exception ex) {
            System.debug(LoggingLevel.ERROR, ex.getMessage() + '\n' + ex.getStackTraceString());
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error while loading the page please try again later.'));
        }
        System.debug(LoggingLevel.DEBUG, 'CaseNPIWorkflowCtrlExt - init end');
    }

//******************************************************************************************************************************
//Method overrides
//******************************************************************************************************************************
    /**
     * override method sets the current case status depending on the current NPI status
     * @return case dettail page if no exception gets thrown, null otherwise
     */
    public override PageReference reSubmit() {

        System.debug(LoggingLevel.DEBUG, 'CaseNPIWorkflowCtrlExt - reSubmit start');
        PageReference prResponse = null;

        try {

            if(areAllIssuesResponded()) {

                if( cLicenseeCase.Status == CaseManager.STATUS_LICENSEE_RESPONSE_NEEDED) {

                    cLicenseeCase.Status = CaseManager.STATUS_RE_SUBMITTED_FOR_REVIEW;
                }
                else if( cLicenseeCase.Status == CaseManager.STATUS_T1_LICENSEE_FEEDBACK_REQUIRED) {

                    cLicenseeCase.Status = CaseManager.STATUS_T1_RESUBMITTED;
                }
                else if( cLicenseeCase.Status == CaseManager.STATUS_T2_LICENSEE_FEEDBACK_REQUIRED) {

                    if(areNewSamplesRequired()) {

                        cLicenseeCase.Status = CaseManager.STATUS_T2_SAMPLES_NOT_SHIPPED;
                    }
                    else {

                        cLicenseeCase.Status = CaseManager.STATUS_T2_RESUBMITTED;
                    }
                }

                update cLicenseeCase;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Case was successfuly resubmitted.'));
                prResponse = new PageReference('/'+cLicenseeCase.Id);
            }
            else {

                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'One or more Issues are pending your comment. Please respond to all the issues and then re-submit.'));
            }
        }
        catch(Exception ex) {

            System.debug(LoggingLevel.ERROR, ex.getMessage() + '\n' + ex.getStackTraceString());
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error while resubmitting Royalty Submission, please try again later.'));
        }
        init();
        System.debug(LoggingLevel.DEBUG, 'CaseNPIWorkflowCtrlExt - reSubmit end');
        return prResponse;
    }

    @testVisible private Boolean areNewSamplesRequired() {

        for(CV_Case_Issue_Comment__c cvcicIssue : cvcicIssesList) {

            if(!cvcicIssue.Resolved__c && cvcicIssue.New_Samples_Required__c) {

                return true;
            }
        }
        return false;
    }
//******************************************************************************************************************************

//******************************************************************************************************************************
//Shipping info
//******************************************************************************************************************************
    public Boolean showShippingPopoupLicensee {get; set;}
    {
        showShippingPopoupLicensee = false;
    }

    public Product_Sample_Shipping_Info__c shippingInfoLicensee {get; private set;}

    public PageReference addShippingInfoLicensee() {
        System.debug(LoggingLevel.DEBUG, 'CaseProductChangeWorkflowCtrlExt - addshippingInfoLicensee start');
        showShippingPopoupLicensee = true;
        shippingInfoLicensee = ProductSampleshippingInfoManager.createShipmentInforForCaseId(cLicenseeCase.Id);
        if(cLicenseeCase.Status == CaseManager.STATUS_T1_SAMPLES_NOT_SHIPPED) {

            shippingInfoLicensee.Shipping_Info_Case_Status__c = CaseManager.STATUS_T1_GE_APPROVAL_PROCESS;
        }
        if(cLicenseeCase.Status == CaseManager.STATUS_T2_SAMPLES_NOT_SHIPPED) {

            shippingInfoLicensee.Shipping_Info_Case_Status__c = CaseManager.STATUS_T2_GE_APPROVAL_PROCESS;
        }

        System.debug(LoggingLevel.DEBUG, 'CaseProductChangeWorkflowCtrlExt - addshippingInfoLicensee end');
        return null;
    }

    public PageReference saveShippingInfoLicensee() {
        System.debug(LoggingLevel.DEBUG, 'CaseProductChangeWorkflowCtrlExt - saveshippingInfoLicensee start');
        try {

            List<String> wfRoles = cLicenseeCase.Participating_Roles__c.split(',');
            showShippingPopoupLicensee = false;
            insert shippingInfoLicensee;
            insert ProductSampleshippingInfoManager.createShipmentConfirmations(shippingInfoLicensee.Id, wfRoles);
            if(cLicenseeCase.Status == CaseManager.STATUS_T1_SAMPLES_NOT_SHIPPED) {

                cLicenseeCase.Status = CaseManager.STATUS_T1_SAMPLES_SHIPPED;
            }
            else if(cLicenseeCase.Status == CaseManager.STATUS_T2_SAMPLES_NOT_SHIPPED) {

                cLicenseeCase.Status = CaseManager.STATUS_T2_SAMPLES_SHIPPED;
            }

            update cLicenseeCase;
            init();
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Shipping info was successfully added.'));
        }
        catch(Exception ex) {
            System.debug(LoggingLevel.ERROR, ex.getMessage() + '\n' + ex.getStackTraceString());
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error while creating Shipping info, please try again later.'));
        }
        System.debug(LoggingLevel.DEBUG, 'CaseProductChangeWorkflowCtrlExt - saveshippingInfoLicensee end');

        return null;
    }

    public PageReference cancelShippingInfoLicensee() {
        showShippingPopoupLicensee = false;
        return null;
    }

    public Product_Sample_Shipping_Info__c shippingInfoWfRole {get; private set;}
    public Product_Sample_Ship_Info_Confirmation__c productSampleShipInfoConfirmationCurrentRole {get; private set;}
    private Boolean showShippingPopoupWfRole;
    public Boolean getShowShippingPopoupWfRole() {
        if(roleLicensee == currentUserWorkflowRole) {
            return false;
        } else {
            showShippingPopoupWfRole = productSampleShipInfoConfirmationCurrentRole != null ? !productSampleShipInfoConfirmationCurrentRole.Reception_Confirmed__c : false;
        }
        return showShippingPopoupWfRole;

    }


    public PageReference confirmShippingInfoWfRole() {

        System.debug(LoggingLevel.DEBUG, 'CaseProductChangeWorkflowCtrlExt - confirmShippingInfoWfRole start');
        try {

            productSampleShipInfoConfirmationCurrentRole.Reception_Confirmed__c = true;
            Boolean shippingInfoConfirmed = true;
            update productSampleShipInfoConfirmationCurrentRole;

            Product_Sample_Shipping_Info__c shippingInfo = ProductSampleShippingInfoManager.getShippingInfoId(shippingInfoWfRole.Id);

            for(Product_Sample_Ship_Info_Confirmation__c pssic : shippingInfoWfRole.Confirmations__r) {

                shippingInfoConfirmed &= pssic.Reception_Confirmed__c;
            }

            if(shippingInfoConfirmed != shippingInfo.Confirmed__c) {

                shippingInfo.Confirmed__c = shippingInfoConfirmed;
                update shippingInfo;
            }

            showShippingPopoupWfRole = false;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Sample reception confirmed.'));
        }
        catch(Exception ex) {
            System.debug(LoggingLevel.ERROR, ex.getMessage() + '\n' + ex.getStackTraceString());
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error while creating Shipping info, please try again later.'));
        }
        System.debug(LoggingLevel.DEBUG, 'CaseProductChangeWorkflowCtrlExt - confirmShippingInfoWfRole end');
        init();
        return null;
    }

    public PageReference cancelShippingInfoWfRole() {
        System.debug('shippingInfoWfRole' + shippingInfoWfRole);
        return new PageReference('/'+cLicenseeCase.Id);
    }
//******************************************************************************************************************************
}