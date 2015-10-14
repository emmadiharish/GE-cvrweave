/******************************************************************************************************************************
* Name - CVITrigger

* Description - This class does the following:
    - Interface containing methods Trigger Handlers must implement to enforce best practice and bulkification of triggers.

* Modification Log :
* ---------------------------------------------------------------------------
* Developer Date Description
* ---------------------------------------------------------------------------
* Siva Gunda 10/13/2015 Created.
******************************************************************************************************************************/

public interface  CVITrigger {

  // -------------------------------
  // bulkBefore: This method is called prior to execution of a BEFORE trigger. Use this to cache any data required into maps prior execution of the trigger.
  // -------------------------------
  void bulkBefore();

  // -------------------------------
  // bulkAfter: This method is called prior to execution of an AFTER trigger. Use this to cache any data required into maps prior execution of the trigger.
  // ------------------------------- 
  void bulkAfter();

  // -------------------------------
  // beforeInsert: This method is called iteratively for each record to be inserted during a BEFORE trigger. Never execute any SOQL/SOSL etc in this and other iterative methods.
  // ------------------------------- 
  void beforeInsert(SObject so);
  
  // -------------------------------
  // beforeUpdate: This method is called iteratively for each record to be updated during a BEFORE trigger. Never execute any SOQL/SOSL etc in this and other iterative methods.
  // -------------------------------   
  void beforeUpdate(SObject oldSo, SObject so);

  // -------------------------------
  // beforeDelete: This method is called iteratively for each record to be deleted during a BEFORE trigger. Never execute any SOQL/SOSL etc in this and other iterative methods.
  // -------------------------------   
  void beforeDelete(SObject so);

  // -------------------------------
  // afterInsert: This method is called iteratively for each record inserted during an AFTER trigger.  The record is 'read only' by this point.
  // -------------------------------
  void afterInsert(SObject so);

  // -------------------------------
  // afterUpdate: This method is called iteratively for each record updated during an AFTER trigger.  The record is 'read only' by this point.
  // -------------------------------
  void afterUpdate(SObject oldSo, SObject so);

  // -------------------------------
  // afterDelete: This method is called iteratively for each record deleted during an AFTER trigger.  The record is 'read only' by this point.
  // -------------------------------
  void afterDelete(SObject so);

  // -------------------------------
  // afterUndelete: This method is called iteratively for each record undeleted during an AFTER trigger.  The record is 'read only' by this point.
  // -------------------------------
  void afterUndelete(SObject so);

  // -------------------------------
  // andFinally: This method is called once all records have been processed by the trigger. Use this method to accomplish any final operations such as creation or updates of other records.
  // -------------------------------   
  void andFinally();
}