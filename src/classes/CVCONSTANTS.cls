/******************************************************************************************************************************
* Name - CVCONSTANTS

* Description - This class does the following:
    - Class to hold hardcoded values like picklists and record types.

* Modification Log :
* ---------------------------------------------------------------------------
* Developer     Date            Description
* ---------------------------------------------------------------------------
* Siva Gunda    10/13/2015      Created.
******************************************************************************************************************************/
public with sharing class CVCONSTANTS {
	// Due Date Rule related
	public static final String DDR_PERIOD_MONTH_END = 'Month end';
	public static final String DDR_PERIOD_QUARTER_END = 'Quarter end';
	public static final String DDR_PERIOD_QUARTER_START = 'Quarter start';

	// Contract Related
	public static final String C_RT_AGREEMENT = 'Agreement';
    public static final String C_RT_AMENDMENT = 'Amendment';
}