trigger setDefaultCaseValues on Case (before insert) {
    for (Case oCase : trigger.new) {
            if (oCase.Requestor__c==null) {
                oCase.Requestor__c = oCase.OwnerId;
            }
    }
}