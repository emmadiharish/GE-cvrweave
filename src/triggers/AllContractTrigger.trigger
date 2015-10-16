/******************************************************************************************************************************
* Name - CVException

* Description - This trigger does the following:
      - trigger for contract object. Check Handler classes for use cases.

* Modification Log :
* ---------------------------------------------------------------------------
* Developer Date Description
* ---------------------------------------------------------------------------
* Siva Gunda 10/13/2015 Created.
******************************************************************************************************************************/
trigger AllContractTriggers on Contract (
	before insert,
	before update,
	before delete,
	after insert,
	after update,
	after delete,
	after undelete) {

	System.debug(LoggingLevel.DEBUG, 'AllContractTriggers - start');
	System.debug(LoggingLevel.DEBUG, 'Trigger.newMap: ' + Trigger.newMap);
	GE_TriggerDispatch.Entry('Contract', trigger.IsBefore, trigger.IsDelete, trigger.isAfter,
                                    trigger.IsInsert, trigger.IsUpdate, trigger.IsExecuting, 
                                    Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
	System.debug(LoggingLevel.DEBUG, 'AllContractTriggers - end');
}