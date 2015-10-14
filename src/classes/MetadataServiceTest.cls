/*
<class name="MetadataServiceTest" longname="MetadataServiceTest"> 
	<description>
		MetadataService APEX Library 
	<description>
	<changelog>
		<v n="1.0.6"> created 															(2015-07-13) </v>
		<v n="0.9.9"> created 															(2014-01-01) </v>
	</changelog>
</class>
*/

/**
 * Copyright (c) 2012, FinancialForce.com, inc 
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification, 
 *   are permitted provided that the following conditions are met:
 *
 * - Redistributions of source code must retain the above copyright notice, 
 *      this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright notice, 
 *      this list of conditions and the following disclaimer in the documentation 
 *      and/or other materials provided with the distribution.
 * - Neither the name of the FinancialForce.com, inc nor the names of its contributors 
 *      may be used to endorse or promote products derived from this software without 
 *      specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
 *  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES 
 *  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL 
 *  THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, 
 *  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 *  OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 *  OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 *  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
**/

/**
 * This is a dummy test class to obtain 100% coverage for the generated WSDL2Apex code, it is not a funcitonal test class
 *   You should follow the usual practices to cover your other code, as shown in the MetadataCreateJobTest.cls
 **/ 
@isTest  
private class MetadataServiceTest
{    
    /**
     * Dummy Metadata API web service mock class (see MetadataCreateJobTest.cls for a better example)
     **/
	private class WebServiceMockImpl implements WebServiceMock 
	{
		public void doInvoke(
			Object stub, Object request, Map<String, Object> response,
			String endpoint, String soapAction, String requestName,
			String responseNS, String responseName, String responseType) 
		{
			if(request instanceof MetadataService.retrieve_element)
				response.put('response_x', new MetadataService.retrieveResponse_element());
			else if(request instanceof MetadataService.checkDeployStatus_element)
				response.put('response_x', new MetadataService.checkDeployStatusResponse_element());

			else if(request instanceof MetadataService.checkStatus_element)
				response.put('response_x', new MetadataService.checkStatusResponse_element());
			
			else if(request instanceof MetadataService.IReadResponseElement)
				response.put('response_x', new MetadataService.ReadWorkflowRuleResult());

			else if(request instanceof MetadataService.checkDeployStatus_element)
				response.put('response_x', new MetadataService.checkDeployStatusResponse_element());
			else if(request instanceof MetadataService.listMetadata_element)
				response.put('response_x', new MetadataService.listMetadataResponse_element());
			else if(request instanceof MetadataService.checkRetrieveStatus_element)
				response.put('response_x', new MetadataService.checkRetrieveStatusResponse_element());
			else if(request instanceof MetadataService.describeMetadata_element)
				response.put('response_x', new MetadataService.describeMetadataResponse_element());
			else if(request instanceof MetadataService.deploy_element)
				response.put('response_x', new MetadataService.deployResponse_element());
            else if(request instanceof MetadataService.updateMetadata_element)
                response.put('response_x', new MetadataService.updateMetadataResponse_element());
            else if(request instanceof MetadataService.renameMetadata_element)
                response.put('response_x', new MetadataService.renameMetadataResponse_element());
            else if(request instanceof  MetadataService.cancelDeploy_element)
                response.put('response_x', new MetadataService.cancelDeployResponse_element());
            else if(request instanceof  MetadataService.deleteMetadata_element)
                response.put('response_x', new MetadataService.deleteMetadataResponse_element());
            else if(request instanceof  MetadataService.upsertMetadata_element)
                response.put('response_x', new MetadataService.upsertMetadataResponse_element());
            else if(request instanceof  MetadataService.createMetadata_element)
                response.put('response_x', new MetadataService.createMetadataResponse_element());
            else if(request instanceof  MetadataService.createMetadata_element)
                response.put('response_x', new MetadataService.createMetadataResponse_element());
			return;
		}
	}    
		
	@IsTest
	private static void coverGeneratedCodeCRUDOperations()
	{	
    	// Null Web Service mock implementation
        System.Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        // Only required to workaround a current code coverage bug in the platform
        MetadataService metaDataService = new MetadataService();
        // Invoke operations         
        MetadataService.MetadataPort metaDataPort = new MetadataService.MetadataPort();
	}
	
	@IsTest
    private static void coverGeneratedCodeFileBasedOperations1()
    {    	
    	// Null Web Service mock implementation
        System.Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        // Only required to workaround a current code coverage bug in the platform
        MetadataService metaDataService = new MetadataService();
        // Invoke operations         
        MetadataService.MetadataPort metaDataPort = new MetadataService.MetadataPort();
        metaDataPort.retrieve(null);

        metaDataPort.checkStatus(null);
        metaDataPort.readMetadata(null,null);

        metaDataPort.checkDeployStatus(null);
        metaDataPort.checkDeployStatus(null, false);
        metaDataPort.listMetadata(null, null);
        metaDataPort.describeMetadata(null);
        metaDataPort.checkRetrieveStatus(null);
        metaDataPort.deploy(null, null);
        metaDataPort.checkDeployStatus(null, false);
        metaDataPort.updateMetadata(null);
        metaDataPort.renameMetadata(null, null, null);
        metaDataPort.cancelDeploy(null);
    }

    @IsTest
    private static void coverGeneratedCodeFileBasedOperations2()
    {       
        // Null Web Service mock implementation
        System.Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        // Only required to workaround a current code coverage bug in the platform
        MetadataService metaDataService = new MetadataService();
        // Invoke operations         
        MetadataService.MetadataPort metaDataPort = new MetadataService.MetadataPort();
        metaDataPort.deleteMetadata(null, null);
        metaDataPort.upsertMetadata(null);
        metaDataPort.createMetadata(null);
    }
        
	@IsTest
    private static void coverGeneratedCodeTypes()
    {    	       
        // Reference types
        new MetadataService();
        new MetadataService.listMetadataResponse_element();
        new MetadataService.WorkflowRule();
        new MetadataService.AccountOwnerSharingRule();
        new MetadataService.RecordTypeTranslation();
        new MetadataService.checkDeployStatus_element();
        new MetadataService.CodeCoverageWarning();
        new MetadataService.FlowApexPluginCall();
        new MetadataService.FlowInputValidationRule();
        new MetadataService.FlowFormula();
        new MetadataService.CustomObjectCriteriaBasedSharingRule();
        new MetadataService.PasswordPolicies();
        new MetadataService.QueueSobject();
        new MetadataService.CaseSharingRules();
        new MetadataService.PicklistValueTranslation();
        new MetadataService.OpportunityOwnerSharingRule();
        new MetadataService.ContactOwnerSharingRule();
        new MetadataService.CustomDataType();
        new MetadataService.PrimaryTabComponents();
        new MetadataService.WorkflowEmailRecipient();
        new MetadataService.DescribeMetadataResult();
        new MetadataService.RecordType();
        new MetadataService.Scontrol();
        new MetadataService.DashboardComponent();
        new MetadataService.ContactCriteriaBasedSharingRule();
        new MetadataService.FilterItem();
        new MetadataService.Profile();
        new MetadataService.ReportFilter();
        new MetadataService.PermissionSetApexClassAccess();
        new MetadataService.LogInfo();
        new MetadataService.Layout();
        new MetadataService.WebLink();
        new MetadataService.WorkflowTaskTranslation();
        new MetadataService.FlowElement();
        new MetadataService.ObjectNameCaseValue();
        new MetadataService.FlowInputFieldAssignment();
        new MetadataService.CustomDataTypeTranslation();
        new MetadataService.DashboardComponentSection();
        new MetadataService.ReportTypeColumn();
        new MetadataService.CallOptions_element();
        new MetadataService.CustomObjectOwnerSharingRule();
        new MetadataService.CustomFieldTranslation();
        new MetadataService.AnalyticSnapshot();
        new MetadataService.FlowRule();
        new MetadataService.FlowRecordUpdate();
        new MetadataService.CustomSite();
        new MetadataService.ReportBlockInfo();
        new MetadataService.describeMetadataResponse_element();
        new MetadataService.CaseOwnerSharingRule();
        new MetadataService.ScontrolTranslation();
        new MetadataService.DeployMessage();
        new MetadataService.FlowSubflowInputAssignment();
        new MetadataService.Group_x();
        new MetadataService.ReportColumn();
        new MetadataService.ReportType();
        new MetadataService.CustomPageWebLink();
        new MetadataService.CodeCoverageResult();
        new MetadataService.ApexComponent();
        new MetadataService.BaseSharingRule();
        new MetadataService.WorkflowKnowledgePublish();
        new MetadataService.NetworkAccess();
        new MetadataService.Workflow();
        new MetadataService.RecordTypePicklistValue();
        new MetadataService.describeMetadata_element();
        new MetadataService.DashboardFilterColumn();
        new MetadataService.FlowChoice();
        new MetadataService.ReportParam();
        new MetadataService.RoleOrTerritory();
        new MetadataService.FlowStep();
        new MetadataService.FlowApexPluginCallInputParameter();
        new MetadataService.WorkflowActionReference();
        new MetadataService.ProfileObjectPermissions();
        new MetadataService.Role();
        new MetadataService.RetrieveResult();
        new MetadataService.SecuritySettings();
        new MetadataService.WorkflowTimeTrigger();
        new MetadataService.CustomObjectSharingRules();
        new MetadataService.retrieve_element();
        new MetadataService.DescribeMetadataObject();
        new MetadataService.DashboardFilterOption();
        new MetadataService.LayoutColumn();
        new MetadataService.WorkflowOutboundMessage();
        new MetadataService.RunTestSuccess();
        new MetadataService.Queue();
        new MetadataService.LeadSharingRules();
        new MetadataService.ListViewFilter();
        new MetadataService.CampaignOwnerSharingRule();
        new MetadataService.CustomField();
        new MetadataService.WorkflowTask();
        new MetadataService.deployResponse_element();
        new MetadataService.DataCategory();
        new MetadataService.FlowOutputFieldAssignment();
        new MetadataService.EmailTemplate();
        new MetadataService.ReportAggregateReference();
        new MetadataService.ObjectUsage();
        new MetadataService.FileProperties();
        new MetadataService.CustomTabTranslation();
        new MetadataService.BusinessProcess();
        new MetadataService.Flow();
        new MetadataService.PermissionSet();
        new MetadataService.PermissionSetObjectPermissions();
        new MetadataService.ReportCrossFilter();
        new MetadataService.Report();
        new MetadataService.FlowSubflowOutputAssignment();
        new MetadataService.ListView();
        new MetadataService.FlowRecordCreate();
        new MetadataService.DashboardTableColumn();
        new MetadataService.ContactSharingRules();
        new MetadataService.AccountTerritorySharingRules();
        new MetadataService.AsyncResult();
        new MetadataService.ArticleTypeChannelDisplay();
        new MetadataService.checkRetrieveStatus_element();
        new MetadataService.ProfileLayoutAssignment();
        new MetadataService.ReportFolder();
        new MetadataService.FlowTextTemplate();
        new MetadataService.RelatedListItem();
        new MetadataService.FlowNode();
        new MetadataService.RetrieveRequest();
        new MetadataService.ListMetadataQuery();
        new MetadataService.FlowConnector();
        new MetadataService.CustomApplicationComponent();
		new MetadataService.FlowRecordLookup();
        new MetadataService.FieldSet();
        new MetadataService.ProfileApexClassAccess();
        new MetadataService.AccountCriteriaBasedSharingRule();
        new MetadataService.DebuggingHeader_element();
        new MetadataService.CustomDataTypeComponentTranslation();
        new MetadataService.FlowRecordDelete();
        new MetadataService.FlowDecision();
        new MetadataService.ReportTypeSectionTranslation();
        new MetadataService.IpRange();
        new MetadataService.FlowApexPluginCallOutputParameter();
        new MetadataService.ReportBucketField();
        new MetadataService.CaseCriteriaBasedSharingRule();
        new MetadataService.CustomLabel();
        new MetadataService.Attachment();
        new MetadataService.SharingRules();
        new MetadataService.CustomConsoleComponents();
        new MetadataService.Portal();
        new MetadataService.DomainWhitelist();
        new MetadataService.ChartSummary();
        new MetadataService.RunTestFailure();
        new MetadataService.Territory();
        new MetadataService.SharedTo();
        new MetadataService.FlowRecordFilter();
        new MetadataService.SubtabComponents();
        new MetadataService.FlowScreen();
        new MetadataService.WorkflowAlert();
        new MetadataService.Picklist();
        new MetadataService.ReportLayoutSection();
        new MetadataService.SummaryLayoutItem();
        new MetadataService.LayoutSection();
        new MetadataService.ReportTimeFrameFilter();
        new MetadataService.LayoutSectionTranslation();
        new MetadataService.DataCategoryGroup();
        new MetadataService.listMetadata_element();
        new MetadataService.ValidationRule();
        new MetadataService.WorkspaceMapping();
        new MetadataService.MetadataWithContent();
        new MetadataService.ValidationRuleTranslation();
        new MetadataService.AccountTerritorySharingRule();
        new MetadataService.Metadata();
        new MetadataService.ReportBucketFieldValue();
        new MetadataService.OpportunitySharingRules();
        new MetadataService.HomePageLayout();
        new MetadataService.FlowSubflow();
        new MetadataService.FlowScreenField();
        new MetadataService.SiteWebAddress();
        new MetadataService.RetrieveMessage();
        new MetadataService.Dashboard();
        new MetadataService.EmailFolder();
        new MetadataService.SessionHeader_element();
        new MetadataService.SummaryLayout();
        new MetadataService.FlowCondition();
        new MetadataService.DeployOptions();
        new MetadataService.FlowAssignment();
        new MetadataService.ProfileApplicationVisibility();
        new MetadataService.CustomApplicationComponents();
        new MetadataService.FlowElementReferenceOrValue();
        new MetadataService.EntitlementTemplate();
        new MetadataService.ProfileTabVisibility();
        new MetadataService.ActionOverride();
        new MetadataService.WorkspaceMappings();
        new MetadataService.WorkflowAction();
        new MetadataService.DashboardFolder();
        new MetadataService.PermissionSetApexPageAccess();
        new MetadataService.LayoutTranslation();
        new MetadataService.CustomObject();
        new MetadataService.Translations();
        new MetadataService.ApexTrigger();
        new MetadataService.ReportTypeTranslation();
        new MetadataService.FlowAssignmentItem();
        new MetadataService.CustomApplicationTranslation();
        new MetadataService.CustomLabels();
        new MetadataService.PackageTypeMembers();
        new MetadataService.PicklistValue();
        new MetadataService.RemoteSiteSetting();
        new MetadataService.deploy_element();
        new MetadataService.retrieveResponse_element();
        new MetadataService.ArticleTypeTemplate();
        new MetadataService.ReportGrouping();
        new MetadataService.PermissionSetFieldPermissions();
        new MetadataService.AnalyticSnapshotMapping();
        new MetadataService.LeadCriteriaBasedSharingRule();
        new MetadataService.SharingRecalculation();
        new MetadataService.ProfileLoginIpRange();
        new MetadataService.WebLinkTranslation();
        new MetadataService.ObjectRelationship();
        new MetadataService.ListPlacement();
        new MetadataService.SiteRedirectMapping();
        new MetadataService.OwnerSharingRule();
        new MetadataService.WorkflowFieldUpdate();
        new MetadataService.LetterheadLine();
        new MetadataService.OpportunityCriteriaBasedSharingRule();
        new MetadataService.CustomTab();
        new MetadataService.FlowChoiceUserInput();
        new MetadataService.Letterhead();
        new MetadataService.ReportTypeColumnTranslation();
        new MetadataService.CustomPageWebLinkTranslation();
        new MetadataService.DocumentFolder();
        new MetadataService.FlowConstant();
        new MetadataService.ProfileRecordTypeVisibility();
        new MetadataService.PackageVersion();
        new MetadataService.CustomLabelTranslation();
        new MetadataService.ReportChart();
        new MetadataService.checkRetrieveStatusResponse_element();
        new MetadataService.LeadOwnerSharingRule();
        new MetadataService.ProfileFieldLevelSecurity();
        new MetadataService.SharingReason();
        new MetadataService.RunTestsResult();
        new MetadataService.PermissionSetUserPermission();
        new MetadataService.MiniLayout();
        new MetadataService.FlowVariable();
        new MetadataService.ProfileLoginHours();
        new MetadataService.DashboardFilter();
        new MetadataService.CodeLocation();
        new MetadataService.ReportBucketFieldSourceValue();
        new MetadataService.FieldSetItem();
        new MetadataService.ReportFilterItem();
        new MetadataService.FlowDynamicChoiceSet();
        new MetadataService.CustomDataTypeComponent();
        new MetadataService.CustomObjectTranslation();
        new MetadataService.CustomApplication();
        new MetadataService.ReportAggregate();
        new MetadataService.ApexClass();
        new MetadataService.CampaignSharingRules();
        new MetadataService.DebuggingInfo_element();
        new MetadataService.Package_x();
        new MetadataService.SessionSettings();
        new MetadataService.Document();
        new MetadataService.Folder();
        new MetadataService.DeployResult();
        new MetadataService.CampaignCriteriaBasedSharingRule();
        new MetadataService.LayoutItem();
        new MetadataService.ProfileApexPageAccess();
        new MetadataService.SharingReasonTranslation();
        new MetadataService.checkDeployStatusResponse_element();
        new MetadataService.ReportColorRange();
        new MetadataService.SearchLayouts();
        new MetadataService.LetterheadHeaderFooter();
        new MetadataService.HomePageComponent();
        new MetadataService.AccountSharingRules();
        new MetadataService.MobileSettings();
        new MetadataService.EscalationRules();
        new MetadataService.KnowledgeAnswerSettings();
        new MetadataService.ExternalDataSource();
        new MetadataService.EntitlementProcess();
        new MetadataService.IdeasSettings();
        new MetadataService.Country();
        new MetadataService.ReputationLevels();
        new MetadataService.KnowledgeSitesSettings();
        new MetadataService.AddressSettings();
        new MetadataService.ProfileExternalDataSourceAccess();
        new MetadataService.CallCenterItem();
        new MetadataService.CallCenter();
        new MetadataService.PermissionSetExternalDataSourceAccess();
        new MetadataService.PermissionSetTabSetting();
        new MetadataService.AuthProvider();
        new MetadataService.EmailToCaseSettings();
        new MetadataService.EscalationAction();
        new MetadataService.State();
        new MetadataService.AssignmentRule();
        new MetadataService.AutoResponseRule();
        new MetadataService.CaseSettings();
        new MetadataService.ChatterAnswersSettings();
        new MetadataService.CountriesAndStates();
        new MetadataService.SFDCMobileSettings();
        new MetadataService.EntitlementProcessMilestoneItem();
        new MetadataService.TouchMobileSettings();
        new MetadataService.AssignmentRules();
        new MetadataService.ContractSettings();
        new MetadataService.KnowledgeCaseSettings();
        new MetadataService.ChatterAnswersReputationLevel();
        new MetadataService.KnowledgeSettings();
        new MetadataService.Community();
        new MetadataService.AutoResponseRules();
        new MetadataService.EmailToCaseRoutingAddress();
        new MetadataService.RuleEntry();
        new MetadataService.EntitlementSettings();
        new MetadataService.CriteriaBasedSharingRule();
        new MetadataService.ApexPage();
        new MetadataService.WorkflowSend();
        new MetadataService.ChatterMobileSettings();
        new MetadataService.CallCenterSection();
        new MetadataService.EntitlementProcessMilestoneTimeTrigger();
        new MetadataService.StaticResource();
        new MetadataService.MilestoneType();
        new MetadataService.FiscalYearSettings();
        new MetadataService.CompanySettings();
        new MetadataService.WebToCaseSettings();
        new MetadataService.EscalationRule();
        new MetadataService.DashboardMobileSettings();
        new MetadataService.FieldOverride();
        new MetadataService.QuotasSettings();
        new MetadataService.Skill();
        new MetadataService.AgentConfigProfileAssignments();
        new MetadataService.LiveAgentSettings();
        new MetadataService.SkillAssignments();
        new MetadataService.ActivitiesSettings();
        new MetadataService.LiveAgentConfig();
        new MetadataService.ApprovalPageField();
        new MetadataService.QuickActionList();
        new MetadataService.LiveChatButtonDeployments();
        new MetadataService.InstalledPackage();
        new MetadataService.PushNotification();
        new MetadataService.LiveChatAgentConfig();
		new MetadataService.AdjustmentsSettings();                               
		new MetadataService.ForecastingSettings();                                
		new MetadataService.QuickActionListItem();           
		new MetadataService.Branding();          
		new MetadataService.QuickActionLayoutItem();                     
		new MetadataService.OpportunityListFieldsSelectedSettings();        
		new MetadataService.ApprovalStepRejectBehavior();
		new MetadataService.FolderShare();   
		new MetadataService.ApprovalEntryCriteria();                                
		new MetadataService.ProductSettings();                                
		new MetadataService.OpportunitySettings();              
		new MetadataService.LiveChatDeployment();                                
		new MetadataService.QuickActionLayoutColumn();           
		new MetadataService.GlobalQuickActionTranslation();      
		new MetadataService.ApprovalStepApprover();                                
		new MetadataService.QuoteSettings();         
		new MetadataService.LiveChatButton();                                
		new MetadataService.Network();
		new MetadataService.LiveChatDeploymentDomainWhitelist();
		new MetadataService.KnowledgeLanguageSettings();
		new MetadataService.Approver();
		new MetadataService.SamlSsoConfig();
		new MetadataService.ApprovalSubmitter();
		new MetadataService.KeyboardShortcuts();
		new MetadataService.ApprovalStep();
		new MetadataService.AgentConfigAssignments();
		new MetadataService.QuickAction();
		new MetadataService.DefaultShortcut();
		new MetadataService.ApprovalAction();
		new MetadataService.KnowledgeLanguage();
		new MetadataService.LiveChatButtonSkills();
		new MetadataService.SkillUserAssignments();
		new MetadataService.NextAutomatedApprover();
		new MetadataService.ApprovalProcess();
		new MetadataService.QuickActionLayout();
		new MetadataService.PushNotifications();
		new MetadataService.ForecastRangeSettings();
		new MetadataService.IdeaReputationLevel();
		new MetadataService.NetworkTabSet();
		new MetadataService.SkillProfileAssignments();
		new MetadataService.CustomShortcut();
		new MetadataService.PagesToOpen();
		new MetadataService.AgentConfigUserAssignments();
		new MetadataService.NetworkMemberGroup();
		new MetadataService.FindSimilarOppFilter();
		new MetadataService.QuickActionTranslation();				
        new MetadataService.WorkflowFlowActionParameter();
        new MetadataService.ConnectedAppOauthConfig();
        new MetadataService.FlowLoop();
        new MetadataService.UserSharingRules();
        new MetadataService.renameMetadata_element();
        new MetadataService.ForecastingTypeSettings();
        new MetadataService.PermissionSetApplicationVisibility();
        new MetadataService.FeedLayout();
        new MetadataService.AppMenuItem();
        new MetadataService.deleteMetadataResponse_element();
        new MetadataService.ConnectedAppAttribute();
        new MetadataService.ReportChartComponentLayoutItem();
        new MetadataService.AppMenu();
        new MetadataService.ConnectedAppIpRange();
        new MetadataService.Error();
        new MetadataService.ComponentInstanceProperty();
        new MetadataService.BusinessHoursEntry();
        new MetadataService.RelatedContent();
        new MetadataService.SupervisorAgentConfigSkills();
        new MetadataService.ComponentInstance();
        new MetadataService.SidebarComponent();
        new MetadataService.Holiday();
        new MetadataService.SaveResult();
        new MetadataService.readMetadataResponse_element();
        new MetadataService.FlexiPageRegion();
        new MetadataService.deleteMetadata_element();
        new MetadataService.ConnectedAppMobileDetailConfig();
        new MetadataService.AccountSettings();
        new MetadataService.PermissionSetRecordTypeVisibility();
        new MetadataService.OrderSettings();
        new MetadataService.ProfileUserPermission();
        new MetadataService.UserCriteriaBasedSharingRule();
        new MetadataService.LookupFilterTranslation();
        new MetadataService.WorkflowFlowAction();
        new MetadataService.ConnectedApp();
        new MetadataService.SiteDotCom();
        new MetadataService.createMetadataResponse_element();
        new MetadataService.updateMetadata_element();
        new MetadataService.LookupFilter();
        new MetadataService.updateMetadataResponse_element();
        new MetadataService.FlexiPage();
        new MetadataService.ConnectedAppSamlConfig();
        new MetadataService.createMetadata_element();
        new MetadataService.FeedLayoutComponent();
        new MetadataService.PostTemplate();
        new MetadataService.RelatedContentItem();
        new MetadataService.readMetadata_element();
        new MetadataService.ReadWorkflowRuleResult().getRecords();
        new MetadataService.readWorkflowRuleResponse_element().getResult();
        new MetadataService.ReadSamlSsoConfigResult().getRecords();
        new MetadataService.readSamlSsoConfigResponse_element().getResult();
        new MetadataService.ReadCustomLabelResult().getRecords();
        new MetadataService.readCustomLabelResponse_element().getResult();
        new MetadataService.ReadBusinessHoursEntryResult().getRecords();
        new MetadataService.readBusinessHoursEntryResponse_element().getResult();
        new MetadataService.ReadMobileSettingsResult().getRecords();
        new MetadataService.readMobileSettingsResponse_element().getResult();
        new MetadataService.ReadChatterAnswersSettingsResult().getRecords();
        new MetadataService.readChatterAnswersSettingsResponse_element().getResult();
        new MetadataService.ReadSharingRulesResult().getRecords();
        new MetadataService.readSharingRulesResponse_element().getResult();
        new MetadataService.ReadPortalResult().getRecords();
        new MetadataService.readPortalResponse_element().getResult();
        new MetadataService.ReadSkillResult().getRecords();
        new MetadataService.readSkillResponse_element().getResult();
        new MetadataService.ReadEscalationRulesResult().getRecords();
        new MetadataService.readEscalationRulesResponse_element().getResult();
        new MetadataService.ReadCustomDataTypeResult().getRecords();
        new MetadataService.readCustomDataTypeResponse_element().getResult();
        new MetadataService.ReadExternalDataSourceResult().getRecords();
        new MetadataService.readExternalDataSourceResponse_element().getResult();
        new MetadataService.ReadEntitlementProcessResult().getRecords();
        new MetadataService.readEntitlementProcessResponse_element().getResult();
        new MetadataService.ReadRecordTypeResult().getRecords();
        new MetadataService.readRecordTypeResponse_element().getResult();
        new MetadataService.ReadScontrolResult().getRecords();
        new MetadataService.readScontrolResponse_element().getResult();
        new MetadataService.ReadDataCategoryGroupResult().getRecords();
        new MetadataService.readDataCategoryGroupResponse_element().getResult();
        new MetadataService.ReadValidationRuleResult().getRecords();
        new MetadataService.readValidationRuleResponse_element().getResult();
        new MetadataService.ReadProfileResult().getRecords();
        new MetadataService.readProfileResponse_element().getResult();
        new MetadataService.ReadIdeasSettingsResult().getRecords();
        new MetadataService.readIdeasSettingsResponse_element().getResult();
        new MetadataService.ReadConnectedAppResult().getRecords();
        new MetadataService.readConnectedAppResponse_element().getResult();
        new MetadataService.ReadApexPageResult().getRecords();
        new MetadataService.readApexPageResponse_element().getResult();
        new MetadataService.ReadProductSettingsResult().getRecords();
        new MetadataService.readProductSettingsResponse_element().getResult();
        new MetadataService.ReadLiveAgentSettingsResult().getRecords();
        new MetadataService.readLiveAgentSettingsResponse_element().getResult();
        new MetadataService.ReadOpportunitySettingsResult().getRecords();
        new MetadataService.readOpportunitySettingsResponse_element().getResult();
        new MetadataService.ReadLiveChatDeploymentResult().getRecords();
        new MetadataService.readLiveChatDeploymentResponse_element().getResult();
        new MetadataService.ReadActivitiesSettingsResult().getRecords();
        new MetadataService.readActivitiesSettingsResponse_element().getResult();
        new MetadataService.ReadLayoutResult().getRecords();
        new MetadataService.readLayoutResponse_element().getResult();
        new MetadataService.ReadWebLinkResult().getRecords();
        new MetadataService.readWebLinkResponse_element().getResult();
        new MetadataService.ReadSiteDotComResult().getRecords();
        new MetadataService.readSiteDotComResponse_element().getResult();
        new MetadataService.ReadCompanySettingsResult().getRecords();
        new MetadataService.readCompanySettingsResponse_element().getResult();
        new MetadataService.ReadHomePageLayoutResult().getRecords();
        new MetadataService.readHomePageLayoutResponse_element().getResult();
        new MetadataService.ReadDashboardResult().getRecords();
        new MetadataService.readDashboardResponse_element().getResult();
        new MetadataService.ReadAssignmentRulesResult().getRecords();
        new MetadataService.readAssignmentRulesResponse_element().getResult();
        new MetadataService.ReadAnalyticSnapshotResult().getRecords();
        new MetadataService.readAnalyticSnapshotResponse_element().getResult();
        new MetadataService.ReadEscalationRuleResult().getRecords();
        new MetadataService.readEscalationRuleResponse_element().getResult();
        new MetadataService.ReadCustomSiteResult().getRecords();
        new MetadataService.readCustomSiteResponse_element().getResult();
        new MetadataService.ReadGroupResult().getRecords();
        new MetadataService.readGroupResponse_element().getResult();
        new MetadataService.ReadReportTypeResult().getRecords();
        new MetadataService.readReportTypeResponse_element().getResult();
        new MetadataService.ReadQuickActionResult().getRecords();
        new MetadataService.readQuickActionResponse_element().getResult();
        new MetadataService.ReadCustomPageWebLinkResult().getRecords();
        new MetadataService.readCustomPageWebLinkResponse_element().getResult();
        new MetadataService.ReadApexComponentResult().getRecords();
        new MetadataService.readApexComponentResponse_element().getResult();
        new MetadataService.ReadBaseSharingRuleResult().getRecords();
        new MetadataService.readBaseSharingRuleResponse_element().getResult();
        new MetadataService.ReadEntitlementTemplateResult().getRecords();
        new MetadataService.readEntitlementTemplateResponse_element().getResult();
        new MetadataService.ReadFlexiPageResult().getRecords();
        new MetadataService.readFlexiPageResponse_element().getResult();
        new MetadataService.ReadWorkflowResult().getRecords();
        new MetadataService.readWorkflowResponse_element().getResult();
        new MetadataService.ReadWorkflowActionResult().getRecords();
        new MetadataService.readWorkflowActionResponse_element().getResult();
        new MetadataService.ReadAddressSettingsResult().getRecords();
        new MetadataService.readAddressSettingsResponse_element().getResult();
        new MetadataService.ReadContractSettingsResult().getRecords();
        new MetadataService.readContractSettingsResponse_element().getResult();
        new MetadataService.ReadCustomObjectResult().getRecords();
        new MetadataService.readCustomObjectResponse_element().getResult();
        new MetadataService.ReadTranslationsResult().getRecords();
        new MetadataService.readTranslationsResponse_element().getResult();
        new MetadataService.ReadRoleOrTerritoryResult().getRecords();
        new MetadataService.readRoleOrTerritoryResponse_element().getResult();
        new MetadataService.ReadApexTriggerResult().getRecords();
        new MetadataService.readApexTriggerResponse_element().getResult();
        new MetadataService.ReadCustomLabelsResult().getRecords();
        new MetadataService.readCustomLabelsResponse_element().getResult();
        new MetadataService.ReadSecuritySettingsResult().getRecords();
        new MetadataService.readSecuritySettingsResponse_element().getResult();
        new MetadataService.ReadCallCenterResult().getRecords();
        new MetadataService.readCallCenterResponse_element().getResult();
        new MetadataService.ReadPicklistValueResult().getRecords();
        new MetadataService.readPicklistValueResponse_element().getResult();
        new MetadataService.ReadRemoteSiteSettingResult().getRecords();
        new MetadataService.readRemoteSiteSettingResponse_element().getResult();
        new MetadataService.ReadQuoteSettingsResult().getRecords();
        new MetadataService.readQuoteSettingsResponse_element().getResult();
        new MetadataService.ReadSynonymDictionaryResult().getRecords();
        new MetadataService.readSynonymDictionaryResponse_element().getResult();
        new MetadataService.ReadPostTemplateResult().getRecords();
        new MetadataService.readPostTemplateResponse_element().getResult();
        new MetadataService.ReadCustomTabResult().getRecords();
        new MetadataService.readCustomTabResponse_element().getResult();
        new MetadataService.ReadLetterheadResult().getRecords();
        new MetadataService.readLetterheadResponse_element().getResult();
        new MetadataService.ReadInstalledPackageResult().getRecords();
        new MetadataService.readInstalledPackageResponse_element().getResult();
        new MetadataService.ReadQueueResult().getRecords();
        new MetadataService.readQueueResponse_element().getResult();
        new MetadataService.ReadAuthProviderResult().getRecords();
        new MetadataService.readAuthProviderResponse_element().getResult();
        new MetadataService.ReadEntitlementSettingsResult().getRecords();
        new MetadataService.readEntitlementSettingsResponse_element().getResult();
        new MetadataService.ReadCustomFieldResult().getRecords();
        new MetadataService.readCustomFieldResponse_element().getResult();
        new MetadataService.ReadStaticResourceResult().getRecords();
        new MetadataService.readStaticResourceResponse_element().getResult();
        new MetadataService.ReadEmailTemplateResult().getRecords();
        new MetadataService.readEmailTemplateResponse_element().getResult();
        new MetadataService.ReadSharingReasonResult().getRecords();
        new MetadataService.readSharingReasonResponse_element().getResult();
        new MetadataService.ReadLiveChatButtonResult().getRecords();
        new MetadataService.readLiveChatButtonResponse_element().getResult();
        new MetadataService.ReadNetworkResult().getRecords();
        new MetadataService.readNetworkResponse_element().getResult();
        new MetadataService.ReadApprovalProcessResult().getRecords();
        new MetadataService.readApprovalProcessResponse_element().getResult();
        new MetadataService.ReadMilestoneTypeResult().getRecords();
        new MetadataService.readMilestoneTypeResponse_element().getResult();
        new MetadataService.ReadAssignmentRuleResult().getRecords();
        new MetadataService.readAssignmentRuleResponse_element().getResult();
        new MetadataService.ReadCompactLayoutResult().getRecords();
        new MetadataService.readCompactLayoutResponse_element().getResult();
        new MetadataService.ReadLiveChatAgentConfigResult().getRecords();
        new MetadataService.readLiveChatAgentConfigResponse_element().getResult();
        new MetadataService.ReadAccountSettingsResult().getRecords();
        new MetadataService.readAccountSettingsResponse_element().getResult();
        new MetadataService.ReadBusinessProcessResult().getRecords();
        new MetadataService.readBusinessProcessResponse_element().getResult();
        new MetadataService.ReadFlowResult().getRecords();
        new MetadataService.readFlowResponse_element().getResult();
        new MetadataService.ReadAutoResponseRuleResult().getRecords();
        new MetadataService.readAutoResponseRuleResponse_element().getResult();
        new MetadataService.ReadPermissionSetResult().getRecords();
        new MetadataService.readPermissionSetResponse_element().getResult();
        new MetadataService.ReadBusinessHoursSettingsResult().getRecords();
        new MetadataService.readBusinessHoursSettingsResponse_element().getResult();
        new MetadataService.ReadForecastingSettingsResult().getRecords();
        new MetadataService.readForecastingSettingsResponse_element().getResult();
        new MetadataService.ReadReportResult().getRecords();
        new MetadataService.readReportResponse_element().getResult();
        new MetadataService.ReadAppMenuResult().getRecords();
        new MetadataService.readAppMenuResponse_element().getResult();
        new MetadataService.ReadListViewResult().getRecords();
        new MetadataService.readListViewResponse_element().getResult();
        new MetadataService.ReadOrderSettingsResult().getRecords();
        new MetadataService.readOrderSettingsResponse_element().getResult();
        new MetadataService.ReadCustomObjectTranslationResult().getRecords();
        new MetadataService.readCustomObjectTranslationResponse_element().getResult();
        new MetadataService.ReadCustomApplicationResult().getRecords();
        new MetadataService.readCustomApplicationResponse_element().getResult();
        new MetadataService.ReadKnowledgeSettingsResult().getRecords();
        new MetadataService.readKnowledgeSettingsResponse_element().getResult();
        new MetadataService.ReadCaseSettingsResult().getRecords();
        new MetadataService.readCaseSettingsResponse_element().getResult();
        new MetadataService.ReadApexClassResult().getRecords();
        new MetadataService.readApexClassResponse_element().getResult();
        new MetadataService.ReadPackageResult().getRecords();
        new MetadataService.readPackageResponse_element().getResult();
        new MetadataService.ReadCommunityResult().getRecords();
        new MetadataService.readCommunityResponse_element().getResult();
        new MetadataService.ReadDocumentResult().getRecords();
        new MetadataService.readDocumentResponse_element().getResult();
        new MetadataService.ReadAutoResponseRulesResult().getRecords();
        new MetadataService.readAutoResponseRulesResponse_element().getResult();
        new MetadataService.ReadFolderResult().getRecords();
        new MetadataService.readFolderResponse_element().getResult();
        new MetadataService.ReadCustomApplicationComponentResult().getRecords();
        new MetadataService.readCustomApplicationComponentResponse_element().getResult();
        new MetadataService.ReadFieldSetResult().getRecords();
        new MetadataService.readFieldSetResponse_element().getResult();
        new MetadataService.ReadSharingSetResult().getRecords();
        new MetadataService.readSharingSetResponse_element().getResult();
        new MetadataService.ReadHomePageComponentResult().getRecords();
        new MetadataService.readHomePageComponentResponse_element().getResult();
        new MetadataService.ReadResult();
        new MetadataService.UserMembershipSharingRule();
        new MetadataService.BusinessHoursSettings();
        new MetadataService.FeedLayoutFilter();
        new MetadataService.ReportHistoricalSelector();
        new MetadataService.ConnectedAppCanvasConfig();
        new MetadataService.DeployDetails();
        new MetadataService.ReportDataCategoryFilter();
        new MetadataService.SynonymGroup();
        new MetadataService.renameMetadataResponse_element();
        new MetadataService.cancelDeploy_element();
        new MetadataService.CancelDeployResult();
        new MetadataService.SynonymDictionary();
        new MetadataService.cancelDeployResponse_element();
        new MetadataService.CompactLayout();
        new MetadataService.AccessMapping();
        new MetadataService.Container();
        new MetadataService.DeleteResult();
        new MetadataService.SharingSet();
        new MetadataService.ReputationPointsRule();
        new MetadataService.FlowActionCallInputParameter();
        new MetadataService.CustomMetadata();
        new MetadataService.VisualizationPlugin();
        new MetadataService.RelatedList();
        new MetadataService.FlowActionCallOutputParameter();
        new MetadataService.FlowActionCall();
        new MetadataService.CustomPermission();
        new MetadataService.ReputationLevelDefinitions();
        new MetadataService.PermissionSetCustomPermissions();
        new MetadataService.upsertMetadata_element();
        new MetadataService.ProfileCustomPermissions();
        new MetadataService.AgentConfigButtons();
        new MetadataService.AgentConfigSkills();
        new MetadataService.upsertMetadataResponse_element();
        new MetadataService.ReputationLevel();
        new MetadataService.ReadWorkflowAlertResult();
        new MetadataService.readWorkflowAlertResponse_element();
        new MetadataService.ReadCustomPermissionResult();
        new MetadataService.readCustomPermissionResponse_element();
        new MetadataService.ReadSiteDotComResult();
        new MetadataService.ReadEmailFolderResult();
        new MetadataService.readEmailFolderResponse_element();
        new MetadataService.ReadCustomMetadataResult();
        new MetadataService.readCustomMetadataResponse_element();
        new MetadataService.ReadAnalyticSnapshotResult();
        new MetadataService.readAnalyticSnapshotResponse_element();
        new MetadataService.ReadVisualizationPluginResult();
        new MetadataService.readVisualizationPluginResponse_element();
        new MetadataService.ReadEscalationRuleResult();
        new MetadataService.ReadMarketingActionSettingsResult();
        new MetadataService.readMarketingActionSettingsResponse_element();
        new MetadataService.ReadWorkflowKnowledgePublishResult();
        new MetadataService.readWorkflowKnowledgePublishResponse_element();
        new MetadataService.ReadDashboardFolderResult();
        new MetadataService.readDashboardFolderResponse_element();
        new MetadataService.ReadWorkflowSendResult();
        new MetadataService.readWorkflowSendResponse_element();
        new MetadataService.ReadWorkflowOutboundMessageResult();
        new MetadataService.readWorkflowOutboundMessageResponse_element();
        new MetadataService.ReadWorkflowFieldUpdateResult();
        new MetadataService.readWorkflowFieldUpdateResponse_element();
        new MetadataService.ReadDocumentFolderResult();
        new MetadataService.readDocumentFolderResponse_element();
        new MetadataService.ReadWorkflowTaskResult();
        new MetadataService.readWorkflowTaskResponse_element();
        new MetadataService.ReadNameSettingsResult();
        new MetadataService.readNameSettingsResponse_element();
        new MetadataService.ReadReportFolderResult();
        new MetadataService.readReportFolderResponse_element();
        new MetadataService.ReadCustomApplicationComponentResult();
        new MetadataService.NameSettings();
        new MetadataService.ReputationPointsRules();
        new MetadataService.FlowMetadataValue();
        new MetadataService.VisualizationResource();
        new MetadataService.MarketingActionSettings();
        new MetadataService.VisualizationType();
        new MetadataService.CustomMetadataValue();
        new MetadataService.HistoryRetentionPolicy();
        new MetadataService.UpsertResult();
        new MetaDataService.Territory2RuleAssociation();
        new MetadataService.ManagedTopics();
        new MetaDataService.XOrgHub();
        new MetaDataService.FlowWaitEventInputParameter();
        new MetadataService.ManagedTopic();
        new MetadataService.Territory2RuleItem();
        new MetadataService.DataPipeline();
        new MetadataService.UiPlugin();
        new MetadataService.Territory2Rule();
        new MetaDataService.XOrgHubSharedObject();
        new MetadataService.Territory2Type();
        new MetadataService.CorsWhitelistOrigin();
        new MetadataService.StandardFieldTranslation();
        new MetadataService.Territory2Model();
        new MetadataService.PersonListSettings();
        new MetadataService.ChannelLayoutItem();
        new MetadataService.FlowWait();
        new MetadataService.Territory2Settings();
        new MetadataService.FieldValue();
        new MetadataService.ChannelLayout();
        new MetadataService.ReadXOrgHubResult();
        new MetadataService.readXOrgHubResponse_element();
        new MetadataService.ReadAuraDefinitionBundleResult();
        new MetadataService.readAuraDefinitionBundleResponse_element();
        new MetadataService.ReadTerritory2SettingsResult();
        new MetadataService.readTerritory2SettingsResponse_element();
        new MetadataService.ReadTerritory2TypeResult();
        new MetadataService.readTerritory2TypeResponse_element();
        new MetadataService.ReadQuoteSettingsResult();
        new MetadataService.readQuoteSettingsResponse_element();
        new MetadataService.ReadCorsWhitelistOriginResult();
        new MetadataService.readCorsWhitelistOriginResponse_element();
        new MetadataService.ReadManagedTopicsResult();
        new MetadataService.readManagedTopicsResponse_element();
        new MetadataService.ReadTerritory2Result();
        new MetadataService.readTerritory2Response_element();
        new MetadataService.ReadCommunityResult();
        new MetadataService.readCommunityResponse_element();
        new MetadataService.ReadDocumentResult();
        new MetadataService.readDocumentResponse_element();
        new MetadataService.ReadTerritory2ModelResult();
        new MetadataService.readTerritory2ModelResponse_element();
        new MetadataService.FlowWaitEventOutputParameter();
        new MetadataService.FlowWaitEvent();
        new MetadataService.CustomPermissionDependencyRequired();
        new MetadataService.ReputationBranding();
        new MetadataService.AuraDefinitionBundle();
        new MetadataService.FeedItemSettings();
        new MetadataService.FlowBaseElement();
        new MetadataService.Territory2();
        new MetadataService.checkStatus_element();
        new MetadataService.checkStatusResponse_element();
        
        
    }
}