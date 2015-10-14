/******************************************************************************************************************************
* Name - CaseProductChangeWorkflowCtrlExt
* Description
* Controller Extension class for Product Change workflow
* - does not fit the naming convention due to 40 char name limit
* Modification Log :
* ---------------------------------------------------------------------------
* Developer Date Description
* ---------------------------------------------------------------------------
* Zoran Zunko 06/04/2015 Created.
******************************************************************************************************************************/
public with sharing class CaseProductChangeWorkflowCtrlExt extends CaseWorkflowExtensionControllerBase {
//TODO: check if one user can have multiple roles in one process
//******************************************************************************************************************************
//base property method overrides
//******************************************************************************************************************************
    public override String getCurrentUserWorkflowRole() {
        if(this.currentUserWorkflowRole == null) {
            this.currentUserWorkflowRole = CVWorkflowSettingsManager.getProductChangeWorkflowRoleForUser(UserInfo.getUserId());
        }
        return this.currentUserWorkflowRole;
    }

    public Boolean shippingButtonsVisible {
        get {
            return
                (getCurrentUserWorkflowRole() == roleLicensee)
                &&
                (cLicenseeCase.Status == CaseManager.STATUS_SAMPLES_NOT_SHIPPED);
        }
    }
//******************************************************************************************************************************
//******************************************************************************************************************************
//controller properties
//******************************************************************************************************************************

//******************************************************************************************************************************

    public CaseProductChangeWorkflowCtrlExt(ApexPages.StandardController stdController) {

        super(stdController);

        System.debug(LoggingLevel.DEBUG, 'CaseProductChangeWorkflowCtrlExt - constructor start');
        init();
        System.debug(LoggingLevel.DEBUG, 'CaseProductChangeWorkflowCtrlExt - constructor end');
    }

    /**
     * initializes the controller and adds the messages to the running user if no action is required
     */
    public override void init() {
        super.init();

        System.debug(LoggingLevel.DEBUG, 'CaseProductChangeWorkflowCtrlExt - init start');
        try {
            if(roleLicensee != getCurrentUserWorkflowRole() && !gecvButtonsVisible) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'No action is required from your side at this time.'));
                return;
            } else if(roleLicensee == getCurrentUserWorkflowRole() && !getLicenseeButtonsVisible() && areAllIssuesResponded() && !shippingButtonsVisible) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'No action is required from your side at this time.'));
            } else if(roleLicensee == getCurrentUserWorkflowRole() && shippingButtonsVisible) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Please add shipping information'));
            }

            if (roleLicensee == getCurrentUserWorkflowRole() && !areAllIssuesResponded()) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'One or more Issues are pending your comment. Please respond to all the issues and then re-submit.'));
            }
            System.debug('currentUserWorkflowRole:' + currentUserWorkflowRole);
            if(roleLicensee != getCurrentUserWorkflowRole()) {
                shippingInfoWfRole = ProductSampleShippingInfoManager.getShippingInfosForCaseId(cLicenseeCase.Id)[0];
                for(Product_Sample_Ship_Info_Confirmation__c pssic : shippingInfoWfRole.Confirmations__r) {
                    if(pssic.Role__c == currentUserWorkflowRole) {
                        productSampleShipInfoConfirmationCurrentRole = pssic;
                        System.debug('shippingInfoWfRole' + shippingInfoWfRole);
                        break;
                    }
                }
            }

        }
        catch(Exception ex) {
            System.debug(LoggingLevel.ERROR, ex.getMessage() + '\n' + ex.getStackTraceString());
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error while loading the page please try again later.'));
        }
        System.debug(LoggingLevel.DEBUG, 'CaseProductChangeWorkflowCtrlExt - init end');
    }

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
            cLicenseeCase.Status = CaseManager.STATUS_SAMPLES_SHIPPED;
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
            update productSampleShipInfoConfirmationCurrentRole;
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

//******************************************************************************************************************************
//method overrides
//******************************************************************************************************************************
   
//******************************************************************************************************************************
}