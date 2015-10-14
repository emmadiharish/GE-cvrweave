public class CaseUploadCSV_schedulebatch
	implements Schedulable, Database.Batchable<SObject>, Database.AllowsCallouts {
    
        @TestVisible execute mode;

    public CaseUploadCSV_schedulebatch() {
        Map<Boolean, Type> modes = new Map<Boolean, Type>();
        modes.put(test.isRunningTest(), testmode.class);
        modes.put(!test.isrunningtest(), livemode.class);
        mode = (execute)modes.get(true).newinstance();
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([select id from account]);
    }

    public interface execute {
        void execute(Account[] records);
    }

    public class testMode implements execute {
        public void execute(Account[] records) {
        }
    }
    public class liveMode implements execute {
        public void execute(Account[] records) {
            Http http = new Http();
            HttpRequest req = new HttpRequest();
            req.setMethod('GET');
            req.setEndpoint('https://www.google.com/');
            HttpResponse res = http.send(req);
        }
    }            
        
    public void execute(Database.BatchableContext bc, Account[] records) {
        mode.execute(records);
        System.debug('*** Do Something Here ***');
    }
        
    public void finish(Database.BatchableContext bc) {
        System.debug('*** Do Something Here ***');
        String responseEmailAddress = 'matt.vagnoni@gmail.com';
        String[] messages = new String[] {};
        String fileName = 'testupload.csv';
        
        String[] toAddresses = new String[] {responseEmailAddress}; 
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        system.debug(toAddresses);

        mail.setToAddresses(toAddresses);
        
        mail.setSenderDisplayName('Case Upload CSV - Testing scheduled batch');
        mail.setUseSignature(false);
        mail.setBccSender(true);
        if(messages.size() == 0)
        {
        	mail.setPlainTextBody( String.format('Document: {0} was successfully imported.', 
                                                        new List<String>{fileName}));
        }
        else
        {
        	String body = '';
        	for(String msg : messages)
        	{
        		body += msg +'\n';
        	}
        	mail.setPlainTextBody( String.format('There were errors while importing document: {0}. \nErrors:\n{1}', 
                                                        new List<String>{fileName, body}));
        }

        Messaging.SendEmailResult [] r = 
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});  
        System.debug(r);
    }
        
    public void execute(SchedulableContext sc) {
        Database.executeBatch(new CaseUploadCSV_schedulebatch());
    }
}