@isTest
public class testAutoPopulatePricebookEntry_TestClass {

static testMethod void testInsertLine() { 
Product2 p = new product2(name='x',isactive=TRUE);


insert p;



System.assertEquals(0.00, [select UnitPrice from PricebookEntry 
where product2id = :p.id].UnitPrice); 



}
}