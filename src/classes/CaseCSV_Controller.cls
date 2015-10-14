public class CaseCSV_Controller {
    public Case theCase {get;set;}
    public List<WrapperClass> csvAttachmentList {get;set;}

    public class WrapperClass
    {
        public Attachment obj{get;set;}
        public Boolean checked{get;set;}
        public WrapperClass() {
            obj = new Attachment();
            checked = true;
        }
        
        public WrapperClass(Attachment attach) {
            obj = attach;
            checked = true;
        }

    }

    
    public CaseCSV_Controller(ApexPages.StandardController stdController){
        //if (!Test.isRunningTest()) {
        //    stdController.addFields(new List<String>{'AccountId', 'Account'});
        //}
        this.theCase = (Case)stdController.getRecord();
        System.debug('>>>> THECASE: ' + theCase);
        
        try {
            System.debug('>>>> theCase.AccountId: ' + theCase.AccountId);
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
        try {
            System.debug('>>>> theCase.Id: ' + theCase.Id);
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
        
		List<Attachment> queryResults = 
             [SELECT Id,Name,Description,BodyLength,
              		CreatedById,CreatedDate,
              		LastModifiedById,LastModifiedDate,SystemModstamp,
              		OwnerId,ParentID 
              FROM Attachment 
              WHERE ContentType = 'text/csv' AND ParentID = :theCase.id 
              		AND isDeleted = false AND isPrivate = false
             ORDER BY CreatedDate desc];

        csvAttachmentList = new List<WrapperClass>(); 
        for(Attachment attach : queryResults) {
			csvAttachmentList.add(new WrapperClass(attach));			            
        }
        

        System.debug('>>>> csvAttachmentList.size: ' + csvAttachmentList.size());
        
    }
    
    public PageReference process() {
        System.debug('START process()');
        List<String> checkedIDs = new List<String>();
        for(WrapperClass wc : csvAttachmentList) {
            if(wc.checked) {
                checkedIDs.add(wc.obj.Id);
            }
        }
        
        List<Attachment> csvAttachments = 
            [SELECT id, Name 
             FROM Attachment 
             WHERE ContentType = 'text/csv' AND ParentID = :theCase.id 
             AND isDeleted = false AND isPrivate = false AND id in :checkedIDs];

        for(Attachment attach : csvAttachments) {
            Id batchInstanceId = Database.executeBatch(new CaseCSV_BatchProcess(attach.Name, attach.id, theCase.id, theCase.AccountId), 20); 
            System.debug('batchinstanceid: ' + batchinstanceid);
        }
        System.debug('END process()');
        
        return new PageReference('javascript:window.close()');
    }
    
    /*
    public PageReference process(String[] attachmentIDs) {
        List<Attachment> csvAttachments = 
            [SELECT id, Name 
             FROM Attachment 
             WHERE ContentType = 'text/csv' AND ParentID = :theCase.id 
             AND isDeleted = false AND isPrivate = false AND id in :attachmentIDs];

        for(Attachment attach : csvAttachments) {
            Id batchInstanceId = Database.executeBatch(new CaseCSV_BatchProcess(attach.Name, attach.id, theCase.id, theCase.AccountId), 5); 
            System.debug('batchinstanceid: ' + batchinstanceid);
            
            
        }
        
        return null;
    }
    */
}