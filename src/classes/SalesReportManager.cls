/******************************************************************************************************************************
* Name - SalesReportManager
* Description
* 	- Manager class that contains all the methods and constants for handling Sales Report Tracking records.
*  	- To be used as a single source of business logic and data loading methods in order to ease reuse.
* Modification Log :
* ---------------------------------------------------------------------------
* Developer Date Description
* ---------------------------------------------------------------------------
* Siva Gunda 10/15/2015 Created.
******************************************************************************************************************************/
public with sharing class SalesReportManager {
	/**
     * returns the oldest skipped report.
     * @param list of royalty payments ordered by EndDate__c.
     * @return oldest CV_Sales_Report_Tracking__c where isReceived__c = false;
     */
	public static CV_Sales_Report_Tracking__c getnextdueSalesReport(List<CV_Sales_Report_Tracking__c> salesReports){
		System.debug(LoggingLevel.DEBUG, 'SalesReportManager - getnextdueSalesReport start salesReports are: '+salesReports);
        for(CV_Sales_Report_Tracking__c srt : salesReports){
            if(srt.isReceived__c == false)
            {   
                return srt;
            }
        }
        System.debug(LoggingLevel.DEBUG, 'SalesReportManager - getnextdueSalesReport end');
		return null;
	}
}