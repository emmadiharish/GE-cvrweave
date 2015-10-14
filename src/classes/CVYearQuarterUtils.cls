/******************************************************************************************************************************
* Name - CVYearQuarterUtils

* Description - This class does the following:
    - Determines program year and quarter for a given period.

* Modification Log :
* ---------------------------------------------------------------------------
* Developer     Date            Description
* ---------------------------------------------------------------------------
* Siva Gunda    10/13/2015      Created.
******************************************************************************************************************************/
public with sharing class CVYearQuarterUtils {
	
	/*******************************
	* @param periodDate
	* @return start of quarter date
	*******************************/
	public static Date getProgramQuarterStartDate(Date periodDate) {
		if (periodDate.month() == 1 
			|| periodDate.month() == 2 
			|| periodDate.month() == 3){
			return date.newinstance(periodDate.year(), 01, 01);
		}else if (periodDate.month() == 4 
			|| periodDate.month() == 5 
			|| periodDate.month() == 6){
			return date.newinstance(periodDate.year(), 04, 01);
		}else if (periodDate.month() == 7 
			|| periodDate.month() == 8 
			|| periodDate.month() == 9){
			return date.newinstance(periodDate.year(), 07, 01);
		}else if (periodDate.month() == 10 
			|| periodDate.month() == 11 
			|| periodDate.month() == 12){
			return date.newinstance(periodDate.year(), 10, 31);
		}
		return null;					
	}

	/*******************************
	* @param periodDate
	* @return end of quarter date
	*******************************/
	public static Date getProgramQuarterEndDate(Date periodDate) {
		if (periodDate.month() == 1 
			|| periodDate.month() == 2 
			|| periodDate.month() == 3){
			return date.newinstance(periodDate.year(), 03, 31);
		}else if (periodDate.month() == 4 
			|| periodDate.month() == 5 
			|| periodDate.month() == 6){
			return date.newinstance(periodDate.year(), 06, 30);
		}else if (periodDate.month() == 7 
			|| periodDate.month() == 8 
			|| periodDate.month() == 9){
			return date.newinstance(periodDate.year(), 09, 30);
		}else if (periodDate.month() == 10 
			|| periodDate.month() == 11 
			|| periodDate.month() == 12){
			return date.newinstance(periodDate.year(), 12, 31);
		}
		return null;					
	}
}