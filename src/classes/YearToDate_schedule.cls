global class YearToDate_schedule implements Schedulable {
   global void execute(SchedulableContext SC) {
	   //Do stuff
		Id batchInstanceId = Database.executeBatch(new ProductYTD_schedulebatch(), 20); 
		System.debug('batchinstanceid: ' + batchinstanceid);
		CaseYTD_schedulebatch.updateFinancials();
   }
}