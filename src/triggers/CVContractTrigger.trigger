/******************************************************************************************************************************
* Name - CVException

* Description - This trigger does the following:
      - trigger for contract object. Look at the Handler class for functionalities.

* Modification Log :
* ---------------------------------------------------------------------------
* Developer Date Description
* ---------------------------------------------------------------------------
* Siva Gunda 10/13/2015 Created.
******************************************************************************************************************************/

trigger CVContractTrigger on Contract (after delete, after insert, after undelete, after update, 
                                        before delete, before insert, before update) {
    CVTriggerFactory.createHandlerAndExecute(Contract.sObjectType);
}