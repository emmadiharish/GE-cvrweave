trigger AutoPopulatePricebookEntry on Product2 (after insert) {

//sObject s = [select ID from Pricebook2 where IsStandard = TRUE];

/*for (Product2 newProduct: Trigger.new) {

//PricebookEntry z = new PricebookEntry(Pricebook2Id=s.ID,Product2Id=newProduct.ID, UnitPrice=0.00, IsActive=TRUE, UseStandardPrice=FALSE);
PricebookEntry z = new PricebookEntry(Pricebook2Id='01sG00000013cw7',Product2Id=newProduct.ID, UnitPrice=0.00, IsActive=TRUE, UseStandardPrice=FALSE);

insert z;

}*/

}