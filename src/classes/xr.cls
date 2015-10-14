//_______________________________________________________________________________________________________________
public without sharing class xr {
//_______________________________________________________________________________________________________________
/*
<class name="xr" longname="xregex">
	<description>
		force.com wrapper for matcher and pattern
	<description>
	<require>
	</require>
	<changelog>
		<v n="1.0.0"> changed header to xml																(2014-03-23) </v>
		<v n="0.9.3"> HEAD		 																					 </v>
		<v n="0.9.2"> HEAD 																							 </v>
		<v n="0.9.1"> renamed to xr 																				 </v>
		<v n="0.9.0"> start track as xregex-class																	 </v>
	</changelog>
</class>
*/
//_______________________________________________________________________________________________________________

	public static xr build(string regex, string haystack) {
		return new xr(regex,haystack);
	}

	public pattern p;
	public matcher m;

	public xr(string regex, string haystack) {
		p = pattern.compile( regex );
		m = p.matcher(haystack);
	}

	public boolean find() {
		return m.find();
	}

	public string group(integer i) {
		try {
			return m.group(i);
		} catch(exception e) {
			return null;
		}
	}

	public integer end(integer i) {
		try {
			return m.end(i);
		} catch(exception e) {
			return null;
		}
	}

	public integer start(integer i) {
		try {
			return m.start(i);
		} catch(exception e) {
			return null;
		}
	}

	public string pick(integer i) {
		//if(m.find()) return m.group(1); else return '';
		if(m.find()) return m.group(i); else return '';
	}




}