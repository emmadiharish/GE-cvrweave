public with sharing class xui {
////////////////////////////////////////////////////////////////////////////
//xui - xUserInferface
//User Interface Hacks, Tweaks, Workarounds
////////////////////////////////////////////////////////////////////////////
//v0.1.1b	...
//v0.1.1a	created

	public static string getDevSliderForView(id ObjectId) {
		PageReference p = new PageReference('/'+ObjectId);
	    String html = p.getContent().toString();
	    html = html.replace('\r','');html = html.replace('\n','');
	    xr r = new xr ('<script>window\\.sfdcPage\\.appendToOnloadQueue\\(function\\(\\) \\{DevSlide.addTools(.*?)</script>',  html  );
	    return ( r.pick(0) );
	}

	public static string getDevSliderForTab(string ObjectName) {
		string prefix = xs.getObjectKeyPrefix(ObjectName);
		PageReference p = new PageReference('/'+prefix);
	    String html = p.getContent().toString();
	    html = html.replace('\r','');html = html.replace('\n','');
	    xr r = new xr ('<script>window\\.sfdcPage\\.appendToOnloadQueue\\(function\\(\\) \\{DevSlide.addTools(.*?)</script>',  html  );
	    return ( r.pick(0) );
	}


}