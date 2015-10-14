@isTest public class xtest { 

	@isTest(seeAllData=true) public static void xt_testPricebook() {
		Object pb = xt.getDefaultPricebook();
	
	}



	public static testMethod void xt_testList() { xt.testListHelper(); }		// wrapper only

	
	public static testMethod void xt() {
		xt.log('test');
		xt.log2('test');
		xt.dump('test');
		xt.dump2('test');
		xt.dump3('test');
		xt.msg('test');
		xt.msg('test','confirm');
		xt.msg('test','error');
		xt.msg('test','fatal');
		xt.msg('test','warning');
		xt.msgP('test');
		String s = '';
		s = xt.roundNumber(10.5353,3);
		s = xt.stripHTMLTags('<b>test</b> more <i>stuff</i>');
		s = xt.soqlDate( date.newinstance(1960, 2, 17) );
		s = xt.soqlDate( null );
	
		Map<String,String> testSwapMap = new Map<String,String>();
		testSwapMap.put('123','345');
		testSwapMap = xt.MapSwapKeyValue(testSwapMap);
		testSwapMap.put('666','A');
		testSwapMap = xt.MapAddToValue(testSwapMap,'666','B','ää');
	
		Map<String,Decimal> testMap = new Map<String,Decimal>();
		testMap.put('1',1.77);
		xt.MapAddToValue(testMap, '1', 4.99);
		Account a1 = new Account(Name='Test1');
		Account a2 = new Account(Name='Test2');
		Boolean b = xt.isObjectModified(a1, a2);
	
		set<string> st = new set<string>(); st.add('asdfsdf1');st.add('asdfsdf2');st.add('asdfsdf3');st.add('asdfsdf4');
		s 	= xt.implode(',',st);
	
		list<string> ss = new list<string>(); ss.add('asdfsdf1');ss.add('asdfsdf2');ss.add('asdfsdf3');ss.add('asdfsdf4');
		list<string> s2 = new list<string>(); s2.add('asdfsdf1');s2.add('asdfsdf2');
		ss 	= xt.listSort(ss);
		s 	= xt.implode(',',ss);
		ss 	= xt.explode(',',s);
		ss 	= xt.unique(ss);
	
		s 	= xt.replace(ss, ss, 'f.oorrece.coom.ort');
		ss 	= xt.toList(st);
		ss 	= xt.toListSorted(st);
		b 	= xt.inList(ss,'sdf');
	
		set<integer> intSet =  new set<integer>(); intSet.add(1); intSet.add(4);
		xt.toList( intSet );
	
		list<integer> intList =  new list<integer>(); intList.add(1); intList.add(4);
		xt.toSet( intList );
	
		string[] s3 = xt.notInSecondList(ss,s2);
		System.assertEquals( true, true );
	
	}


	public static testMethod void xs() {
	    String 									s 					= '';
		List<String> 							ls 					= new List<String>();
		Map<String,String> 						ms 					= new Map<String,String>();
		Map<String, Schema.SObjectField> 		mSObjectField		= new Map<String, Schema.SObjectField>();
		Object 									o;
		SObject 								so;
		Boolean 								b;
		Account									a;
		Account									a1;
		Account									a2;
		xs.xsField 								xsf;
		list<SObject>							os;
		xs.InstalledPackage						ip					= new xs.InstalledPackage();
		map<string, xs.InstalledPackage>		mips				= new map<string, xs.InstalledPackage>();
		
		s 					= xs.getObjectKeyPrefix('Account');
		s 					= xs.getObjectNamespacePrefix('Account');
		s 					= xs.getObjectNamespacePrefixedName('Account');
	    s 					= xs.soqlSelectAsterix('Account');
	    s 					= xs.soqlSelectAsterix('Account','a');
	    s 					= xs.getFieldType('Account','Name');
	    a2 					= new Account(Name='Test2');
	    upsert a2;
	    a1 					= new Account(Name='Test1',ParentId=a2.Id);
	    upsert a1;
	    a 					= [select Id, Name, Owner.LastName, Parent.Owner.LastName from Account where Id=:a1.Id limit 1];
	    
	    o 					= xs.getFieldValue(a,'Name');
	    o 					= xs.getFieldValue(a,'Owner.LastName');
	    o 					= xs.getFieldValue(a,'Parent.Owner.LastName');
	    o 					= xs.getFieldType(a,'Name');
	    o 					= xs.getFieldType(a,'Owner.LastName');
	    o 					= xs.getFieldType(a,'Parent.Owner.LastName');
	    o 					= xs.getFieldType(a,'987345908 unoirtgj ²³');  
	    ms 					= xs.getChildRelationships('Account');
	    ms 					= xs.getChildRelationshipsByObjectNames('Account');
	    
	    b 					= xs.isNumber('Account','Name');
	    b 					= xs.isNumber(new Account(),'Name');
	    b 					= xs.isText('Account','Name');
	    b 					= xs.isText(new Account(),'Name');
	    b 					= xs.isDateOrTime('Account','Name');
	    b 					= xs.isPicklist(new Account(),'Name');
	    
	    s 					= xs.org.get('Account').get('Name').type;
	    //s 					= xs.org.get('Account').get('Name').type;
	    s 					= xs.getFieldType('Account','Name');//xs.org.get('Account').get('Namee').type;
	    s 					= xs.getFieldType('Account','Nameeee');//xs.org.get('Account').get('Namee').type;
	    mSObjectField 		= xs.getFieldMap('Account');
	    s 					= xs.removeNamespacePrefix('prefix__test__c');
	    
	    ls 					= xs.org.get('Account').getFieldNames();
	    s 					= xs.getObjectType('Opportunity.Account.Owner');
	    
	    xsf 				= xs.getField('Opportunity.Account.Owner.Name');
	    ls 					= xs.getField('Account.Type').getPickListValues() ;
	    ms 					= xs.org.get('Account').getFieldLabels() ;
	    ms 					= xs.org.getObjectLabels() ;
	    s					= xs.soql('select * from Account limit 1');
	    os					= xs.query('select * from Account limit 1');
	    os					= xs.query('select *.not(Name|Employees), Account.Name, Account.CreatedBy.* from Opportunity limit 1');
	    s					= xs.getOrgNamespacePrefix();
	    mips				= xs.getInstalledPackages();
	    
	    so					= xs.newSObject('Account');
	    o					= xs.newObject('Account');
	    s					= xs.getType(so);
	    
	 
	
	    ls					= xs.getVerifiedFieldList( new Account(Name='testVFL') , new string[]{ 'Name','Id' } );
	    
	    ls					= xs.getPickListValues('Account','Type');
	    
	}
		
	
	
}