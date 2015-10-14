global class YearToDate_schedule implements Schedulable {
   global void execute(SchedulableContext SC) {
       //Do stuff
      ProductYTD_schedulebatch.resetFinancials();
      ProductYTD_schedulebatch.updateYTD();
      ProductYTD_schedulebatch.updatePreviousYTD();
      ProductYTD_schedulebatch.updateInceptionYTD();
      ContractYTD_schedulebatch.updateAllFinancials(); 
      LicenseeYTD_schedulebatch.updateAllFinancials();
   }
}