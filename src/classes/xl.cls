//_______________________________________________________________________________________________________________
public without sharing class xl {
//_______________________________________________________________________________________________________________
/*
<class name="xl" longname="xlogs">
	<description>
		force.com library to track, log and monitor into a custom object.
		Also function for limit-analysis and resource usage are included.
	<description>
	<changelog>
		<v n="1.1.9"> added active switch																(2014-03-27) </v>
		<v n="1.1.8"> log as HTML, colored output														(2014-03-26) </v>
		<v n="1.1.7"> spikes																			(2014-03-26) </v>
		<v n="1.1.6"> added description for log() and logWrite() (dev28)								(2014-03-25) </v>
		<v n="1.1.5"> prepend new entries instead of append ==> newest topmost! (dev28)					(2014-03-25) </v>
		<v n="1.1.4"> +timestamp (dev28)																(2014-03-23) </v>
		<v n="1.1.3"> +timestamp (dev28)																(2014-03-23) </v>
		<v n="1.1.2"> at log() use instanceof to handle strings better  (dev19)							(2014-03-18) </v>
		<v n="1.1.1"> added milliseconds (dev29)														(2014-03-17) </v>
		<v n="1.1.0"> checked out on dev28. Goal: write a limit tracker. Changed to xml-header			(2014-03-17) </v>
		<v n="1.0.1"> renamed to xl (still limits only) 												 			 </v>
		<v n="0.9.1"> new functions 																	 			 </v>
		<v n="0.1.0"> created first only for limits, called xlimits 									(2013-10-23) </v>
	</changelog>
</class>
*/
//_______________________________________________________________________________________________________________


//_______________________________________________________________________________________________________________
// new log functions
//_______________________________________________________________________________________________________________
	public static 	boolean			active				= true; // indicates, wheter logs will be written or not

	private static	string			logObjectNamespace		{get; set;}
	//public static   boolean			logHtmlMode				{get; set;}
	//public static   string      	logLineBreaks			{get; set;}
	public static 	string 			logBody 				{get; set;}
	public static 	datetime		logStart				{get; set;}
	public static 	integer			logStartMilliseconds	{get; set;}




	//public static datetime		logEnd					{get; set;}


/*
	public static void log(object o) {
		if(logStart==null) 	{ logStart 	= datetime.now();  logStartMilliseconds = datetime.now().millisecond(); }
		if(logBody==null) 	logBody 	= '';
		if(o instanceof string) {
			logBody = getTimestamp() + ' '+ (string) o +'\n' + logBody;
		} else {
			logBody = getTimestamp() + ' '+ xt.dump0(o)+'\n' + logBody;
		}
	}
*/

	public static void log(object o) { log(null,o);	}
	public static void log(string description, object o) {
		//logLineBreaks = '<br>';
		if(!active) 						return;
		if(logStart==null) 		{ logStart 	= datetime.now();  logStartMilliseconds = datetime.now().millisecond(); }
		if(logBody==null) 		logBody 	= '';
		if(description == null) description = '';
		if(description!='' ) {
			description = '' + '<b>' + description + '</b> ' +' ▶ ';
		}
		string logEntry = '';
		if(o instanceof string) {
			logEntry = (string) o;
		} else {
			logEntry = xt.dump(o);
		}

		logBody = ''
			+ '<span class="ts">'+getTimestamp() + '</span> '
			+ description  
			+ logEntry + '<br>' 
			+ logBody
		;




	}


	public static void logWrite(object o) { log(o);	logWrite();	}
	public static void logWrite(string description, object o) { log(description,o);	logWrite();	}
	public static void logWrite() {
		if(!active)							return;
		if(logBody==null || logBody=='') 	return;
		sobject
			l 						= null;
		logObjectNamespace 			= '';

		try {
			l 						= (sobject) Type.forName(logObjectNamespace + 'elfXLog__c').newInstance();
		} catch(exception e) {
			logObjectNamespace 		= 'elfXLog__';
			l 						= (sobject) Type.forName(logObjectNamespace + 'elfXLog__c').newInstance();
		}

//		put(logObjectNamespace + 'l.BodyBody__c',				logBody);
		l.put(logObjectNamespace + 'Start__c',				logStart);
		l.put(logObjectNamespace + 'StartMilliseconds__c',	logStartMilliseconds);
		l.put(logObjectNamespace + 'End__c',				datetime.now() );
		l.put(logObjectNamespace + 'EndMilliseconds__c',	datetime.now().millisecond() );


		string
			f 						= logBody.unescapeHtml4();

		try {
			//l.put(logObjectNamespace + 'Body__c',  	 f.substring(000000, f.length()-1 < 025000 ? f.length()-1 : 025000 ); // not longer in use
			l.put(logObjectNamespace + 'Body0__c', 	 f.substring(000000, f.length()-1 < 025000 ? f.length()-1 : 025000 ));
			l.put(logObjectNamespace + 'Body1__c', 	 f.substring(025000, f.length()-1 < 050000 ? f.length()-1 : 050000 ));
			l.put(logObjectNamespace + 'Body2__c', 	 f.substring(050000, f.length()-1 < 075000 ? f.length()-1 : 075000 ));
			l.put(logObjectNamespace + 'Body3__c',	 f.substring(075000, f.length()-1 < 100000 ? f.length()-1 : 100000 ));
			l.put(logObjectNamespace + 'Body4__c', 	 f.substring(100000, f.length()-1 < 125000 ? f.length()-1 : 125000 ));
			l.put(logObjectNamespace + 'Body5__c', 	 f.substring(125000, f.length()-1 < 150000 ? f.length()-1 : 150000 ));
			l.put(logObjectNamespace + 'Body6__c', 	 f.substring(150000, f.length()-1 < 175000 ? f.length()-1 : 175000 ));
			l.put(logObjectNamespace + 'Body7__c', 	 f.substring(175000, f.length()-1 < 200000 ? f.length()-1 : 200000 ));
			l.put(logObjectNamespace + 'Body8__c', 	 f.substring(200000, f.length()-1 < 225000 ? f.length()-1 : 225000 ));
			l.put(logObjectNamespace + 'Body9__c', 	 f.substring(225000, f.length()-1 < 250000 ? f.length()-1 : 250000 ));
		} catch(exception e) { } 		// do nothing here, we will get out-of-bounds exceptions all the time!



		insert l;
		logBody = '';
	}

/*
 * experimental UNUSED !!
 *
	public static void logWrite2() {
		if(logBody==null || logBody=='') return;
		sobject
			l 						= null;
		logObjectNamespace 			= 'elfXLog__';
		l 							= (sobject) Type.forName(logObjectNamespace + 'elfXLog__c').newInstance();
		l.put(logObjectNamespace + 'Body__c',				logBody);
		l.put(logObjectNamespace + 'Start__c',				logStart);
		l.put(logObjectNamespace + 'StartMilliseconds__c',	logStartMilliseconds);
		l.put(logObjectNamespace + 'End__c',				datetime.now() );
		l.put(logObjectNamespace + 'EndMilliseconds__c',	datetime.now().millisecond() );

		insert l;
		logBody = '';
	}
*/

	public static string getTimestamp() {
		return '['+Datetime.now().format('yyyy-MM-dd@HH:mm:ss.S').rightPad(23).replace(' ','0')+']';
	}




//_______________________________________________________________________________________________________________
// older limit functions
//_______________________________________________________________________________________________________________

public static org org = new org();

public static String getAllLimitsTable() {
	string out='';
	org.refresh();
	string  style   = ' style="padding: 0px; margin: 0px;" ';

	for(string name : org.limits.keyset()) {
		integer current = org.limits.get(name).current;
		integer max	    = org.limits.get(name).max;
		out += ''
			+'<tr>'
				+'<td '+style+' >'+''+ name + ''+'</td>'
				+'<td '+style+' align="right">'+ xt.roundNumber( current,0 )+'</td>'
				+'<td '+style+' align="right">'+''+ xt.roundNumber( max,0 )+'</td>'
				+'<td '+style+' align="right">'+ ''+   xt.roundNumber( ((decimal) current) / ((decimal) max) * 100 ,2    ) +'%'+'</td>'
			+'</tr>'
		;
	}


	out = ''
		+'<table style="margin-left: 0px;" cellspacing="0" cellpadding="0"  >' //class="elfAllLimitsTable"
			+'<tr>'
				+'<td '+style+' >'				+'Limit Name'+'</td>'
				+'<td '+style+' align="right">'	+'Actual'+'</td>'
				+'<td '+style+' align="right">'	+'Maximal'+'</td>'
				+'<td '+style+' align="right">'	+'Usage'+'</td>'
			+'</tr>'
			+out
		+'</table>'
	;
	return out;
}


private static String formatResultRow(String name) {
	return ''
		+'<tr>'
			+'<td>'+'<b>'+ name + '</b>'+'</td>'
//			+'<td>'+ xt.roundNumber( current,0 )+'</td>'
//			+'<td>'+' / '+ xt.roundNumber( max,0 )+'</td>'
//			+'<td>'+ ''+   xt.roundNumber( ((decimal) current) / ((decimal) max) * 100 ,2    ) +'%'+'</td>'
		+'</tr>'
	;
}


public static void addLimit(Map<string,orgLimit> limits, String name,integer current, integer max) {
	orgLimit l;
	l 			= new orgLimit();
	l.name		= name;
	l.current   = current;
	l.max		= max;
	limits.put(name,l);
	//return l;
}


class orgLimit {
	string name;
	integer current;
	integer max;

}

class org {
	Map<string,orgLimit> limits = new Map<string,orgLimit>();

	public org() { }

	public void refresh() {

		addLimit( limits, 'HeapSize'
			,system.limits.getHeapSize()
			,system.limits.getLimitHeapSize()
		);

		addLimit( limits, 'CpuTime'
			,system.limits.getCpuTime()
			,system.limits.getLimitCpuTime()
		);

		addLimit( limits, 'DmlStatements'
			,system.limits.getDmlStatements()
			,system.limits.getLimitDmlStatements()
		);

		addLimit( limits, 'Queries'
			,system.limits.getQueries()
			,system.limits.getLimitQueries()
		);

		addLimit( limits, 'FieldsDescribes'
			,system.limits.getFieldsDescribes()
			,system.limits.getLimitFieldsDescribes()
		);

		addLimit( limits, 'PicklistDescribes'
			,system.limits.getPicklistDescribes()
			,system.limits.getLimitPicklistDescribes()
		);

	}
}


	public static testMethod void test() {
	    String s = '';
		xl.org.refresh();
		s = xl.getAllLimitsTable();
	}



/*
public static String heap() {
	return formatResult('Heap', system.limits.getHeapSize(), system.limits.getLimitHeapSize() ) ;
}

public static String cpuTime() {
	return formatResult('CPU Time', system.limits.getCpuTime(), system.limits.getLimitCpuTime() ) ;
}

public static String DmlStatements() {
	return formatResult('DML Statements', system.limits.getDmlStatements(), system.limits.getLimitDmlStatements() ) ;
}

public static String soqlQueries() {
	return formatResult('SOQL Qeries', system.limits.getQueries(), system.limits.getLimitQueries() );
}

public static String fieldsDescribes() {
	return formatResult('Fields Describes', system.limits.getFieldsDescribes(), system.limits.getLimitFieldsDescribes() );
}

public static String picklistDescribes() {
	return formatResult('Picklist Describes', system.limits.getPicklistDescribes(), system.limits.getLimitPicklistDescribes() );
}







private static String formatResult(String name, Integer current, Integer max) {
	return ''
		+'<b>'+ name + '</b> : ' + xt.roundNumber( current,0 )  +' / '+ xt.roundNumber( max,0 )
		+ ' ('+   xt.roundNumber( ((decimal) current) / ((decimal) max) * 100 ,2    ) +'%)'
	;
}
*/



}