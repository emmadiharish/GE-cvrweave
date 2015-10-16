/******************************************************************************************************************************
* Name - RoyaltyPaymentManager
* Description
* 	- Manager class that contains all the methods and constants for handling Royalty Payment tracking records.
*  	- To be used as a single source of business logic and data loading methods in order to ease reuse.
* Modification Log :
* ---------------------------------------------------------------------------
* Developer Date Description
* ---------------------------------------------------------------------------
* Siva Gunda 10/15/2015 Created.
******************************************************************************************************************************/
public with sharing class RoyaltyPaymentManager {
	/**
     * returns the oldest skipped payment.
     * @param list of royalty payments ordered by EndDate__c.
     * @return oldest CV_Royalty_Payment_Tracking__c where isReceived__c = false;
     */
	public static CV_Royalty_Payment_Tracking__c getnextdueRoyaltyPayment(List<CV_Royalty_Payment_Tracking__c> royaltypayments){
		
        System.debug(LoggingLevel.DEBUG, 'RoyaltyPaymentManager - getnextdueRoyaltyPayment start');
        for(CV_Royalty_Payment_Tracking__c rpt : royaltypayments){
            if(rpt.isReceived__c == false)
            {   
                return rpt;
            }
        }
        System.debug(LoggingLevel.DEBUG, 'RoyaltyPaymentManager - getnextdueRoyaltyPayment end');
		return null;
	}
}