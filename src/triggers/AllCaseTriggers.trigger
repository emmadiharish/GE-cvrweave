trigger AllCaseTriggers on Case (
	before insert,
	before update,
	before delete,
	after insert,
	after update,
	after delete,
	after undelete) {

	System.debug(LoggingLevel.DEBUG, 'AllCaseTriggers - start');
	System.debug(LoggingLevel.DEBUG, 'Trigger.newMap: ' + Trigger.newMap);
	GE_TriggerDispatch.Entry('Case', trigger.IsBefore, trigger.IsDelete, trigger.isAfter,
                                    trigger.IsInsert, trigger.IsUpdate, trigger.IsExecuting, 
                                    Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
	System.debug(LoggingLevel.DEBUG, 'AllCaseTriggers - end');
}