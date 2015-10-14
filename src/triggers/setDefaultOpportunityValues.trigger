trigger setDefaultOpportunityValues on Opportunity (before insert, before update) {
    for (Opportunity oOpportunity : trigger.new) {
        if(oOpportunity.AccountId != null && oOpportunity.Internal_Customer__c == null){
            oOpportunity.Internal_Customer__c = oOpportunity.AccountId;}
        else if(oOpportunity.Internal_Customer__c != null){
            oOpportunity.AccountId = oOpportunity.Internal_Customer_Id__c;}

    }
}