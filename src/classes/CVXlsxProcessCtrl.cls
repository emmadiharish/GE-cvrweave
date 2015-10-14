/******************************************************************************************************************************
* Name - CVXlsxProcessCtrl
* Description
* APEX to Process the transaltion of XLSX to CSV Files
* ---------------------------------------------------------------------------
* Developer Date Description
* ---------------------------------------------------------------------------
* Uwe Heim 2015-08-10 Created.
******************************************************************************************************************************/

public class CVXlsxProcessCtrl {

	public static String GeneratorTokenPrefix = 'CV-XLSX-';

	public static String getGeneratorToken() {
		return '['+GeneratorTokenPrefix+getTimestamp()+'] - ';
	}	

	public class getCaseDataResult {
		Case				item				= new Case();
		Attachment			attachmentInput		= new Attachment();
		String				attachmentInputBody = '';
		Map<String,String>	sheetMappings		= new Map<String,String>();
	}
	@RemoteAction public static getCaseDataResult getCaseData(Map<String,String> params) {
		Id id 				= params.get('id');
		GetCaseDataResult result = new GetCaseDataResult();	
		result.item = (Case) database.query( xs.soql(''
			+'SELECT * FROM Case WHERE Id=\''+id+'\' '
		))[0];		
		if(result.item!=null) {
		 // get relevant attachment
			result.attachmentInput = (Attachment) database.query( xs.soql(''
				+'SELECT * FROM Attachment WHERE ParentId=\''+id+'\' and Name like \'%.xlsx\' ORDER BY LastModifiedDate DESC LIMIT 1 '
			))[0];	
			result.attachmentInputBody = EncodingUtil.base64Encode( result.attachmentInput.Body );
			result.attachmentInput.Body = null; // need to set this to null, otherwise Serialization-Errors
		 // get list of sheet mappings
			List<CVXlsxInputSheetMappings__c> sms = (List<CVXlsxInputSheetMappings__c>) database.query( xs.soql(''
				+'select Name,OutputFilename__c from CVXlsxInputSheetMappings__c '
			)) ;
			for(CVXlsxInputSheetMappings__c sm : sms) {
				result.sheetMappings.put(sm.Name,sm.OutputFilename__c);
			}
		 // ...
		}
		return result;
	}	
	
	@RemoteAction public static string addCaseAttachments(List<Map<String,String>> outputItems) {
		string result = '';
		List<Attachment> attachments = new List<Attachment>();
		for(Map<String,String> outputItem : outputItems) {
			Attachment attachment = new Attachment();
				attachment.Name			= getGeneratorToken() + outputItem.get(	'outputFilename');
				attachment.Body			= Blob.valueOf( outputItem.get(			'body') );
				attachment.ParentId		= outputItem.get(						'parentId');
			attachments.add( attachment );
		}
		insert attachments;
		return result;
	}

	@RemoteAction public static string deleteCaseAttachments(Map<String,String> params) {
		Id id 							= params.get('id'); 
		List<Attachment> attachments 	= (List<Attachment>) database.query( xs.soql(''
			+'SELECT * FROM Attachment WHERE ParentId=\''+id+'\' and Name like \'%'+GeneratorTokenPrefix+'%.csv\' '
		));	
		delete attachments;
 		return null;
	}

	public static string getTimestamp() {
		return ''+Datetime.now().format('yyyy-MM-dd@HH:mm:ss.S').rightPad(24).replace(' ','0')+'';
	}

	public static string dump(Object o) {
		return system.JSON.serializePretty(o).replace('\n','<br>').replace('  ','&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;');
	}
	
	public static string dump0(Object o) {
		return system.JSON.serializePretty(o);
	}
	
	public static string dump2(Object o) {
		return system.JSON.serializePretty(o).escapeXml().replace('\n','<br>').replace('  ','&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;');
	}
	
	public static string dump3(Object o) {
		return system.JSON.serializePretty(o).replace('\n','<br>');
	}

	
	
}