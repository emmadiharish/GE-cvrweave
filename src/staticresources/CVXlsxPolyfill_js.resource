/*
* elfPolyfill.js (library to enhance basic JS objects with polyfills)
*
* (c)2012-2015 elastify GmbH & Co. KG
* All rights reserved.
* Redistribution and use in source and binary forms, with or without modification,
* are permitted provided that the following conditions are met:
*
* Redistributions of source code must retain the above copyright notice,
* this list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright notice,
* this list of conditions and the following disclaimer in the documentation
* and/or other materials provided with the distribution.
* 
* Neither the name of elastify GmbH & Co. KG nor the names of its contributors
* may be used to endorse or promote products derived from this software without
* specific prior written permission.
*
* THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
* ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
* OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
* THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
* EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
* OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
* OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
* ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*
*
<resource name="elfPolyfill_js" type="js" >
	<description>
		library to enhance basic JS object with polyfills
		(c)2012-2015 elastify GmbH & Co. KG
	<description>
	<require>
		// has no dependencies! keep it like that!
	</require>
	<changelog>
		<v n="0.1.4"> added UTF8<==>Base64 converter														(2015-08-09) </v>
		<v n="0.1.3"> added string.contains()																(2015-07-30) </v>
		<v n="0.1.2"> augmentation of Array breaks CodeFusion ==> deactivated until fix						(2015-07-27) </v>
		<v n="0.1.1"> start track 																			(2015-07-27) </v>
	</changelog>
</resurce>
*
*/


(function(){
// Augment basic objects only, if there is no native implementation
	var addMethod = function(object,name,method) { // works
		object.prototype[name] = object.prototype[name] || method;		
	}


// String
	addMethod(String,"contains", function(suffix) {
        return String.prototype.indexOf.apply(this, arguments) !== -1;
    });
	addMethod(String,"endsWith", function(suffix) {
        return this.indexOf(suffix, this.length - suffix.length) !== -1;
    });
	addMethod(String,"startsWith", function (searchString, position) {
		position = position || 0;
		return this.indexOf(searchString, position) === position;
	});
	addMethod(String,"substringAfterLast",function (searchString) {
		if(this.indexOf(searchString) != -1) {
		    return this.substring(this.lastIndexOf(searchString)+searchString.length);
		} else { return ''; }
	});

	addMethod(String,"substringAfter", String.prototype.substringAfter || function (searchString) {
		if(this.indexOf(searchString) != -1) {
		    return this.substring(this.indexOf(searchString)+searchString.length);
		} else { return ''; }
	});
	addMethod(String,"substringBeforeLast", function (searchString) {
		if(this.indexOf(searchString) != -1) {
		    return this.substring(0,this.lastIndexOf(searchString));
		} else { return ''; }
	});
	addMethod(String,"substringBefore", function (searchString) {
		if(this.indexOf(searchString) != -1) {
		    return this.substring(0,this.indexOf(searchString));
		} else { return ''; }
	});
    addMethod(String,"toBoolean", function() {                                                  
        result = null;
        try { result = JSON.parse(this); } catch(e) { }
        return result;
    });
    addMethod(String,"lpad", function(padString, length) {
	    var str = this;
	    while (str.length < length) str = padString + str;
	    return str;
	});
	addMethod(String,"reverse", function(){
		return this.split("").reverse().join("");
	});
	addMethod(String,"replaceAll", function(find, replace) {
	    var str = this;
	    return str.replace(new RegExp(find, 'g'), replace);
	});	

	addMethod(String,"convertUtf8ToBase64", function() {
   		var str = this;
   		return window.btoa(unescape(encodeURIComponent( str )));
	});	
	
	addMethod(String,"convertBase64ToUtf8", function() {
		var str = this;
		return decodeURIComponent(escape(window.atob(str)));
	});	
	
	
        
  //      convertUtf8ToBase64: function ( str ) {
  //  		return window.btoa(unescape(encodeURIComponent( str )));
		// },                

		// convertBase64ToUtf8: function(str) {
		//     return decodeURIComponent(escape(window.atob(str)));
		// },
	
	
	

// CAUTION: DO NOT AUGMENT Array! It will break CodeFusion! No property can be defined at Array at this time (2015-07-27)
// Array
	// 	addMethod(Array,"contains", function(needle) { 
	// 		for (i in this) { if (this[i] == needle) return true; } return false; 
	// 	});

// Storage
	addMethod(Storage,"setObject", function(key, value) {
	    this.setItem(key, JSON.stringify(value));
	});
	addMethod(Storage,"getObject", function(key) {
	    var value = this.getItem(key);
	    return value && JSON.parse(value);
	});
	addMethod(Storage,"push", function(key, value) {
	    var currentObject = this.getObject(key);
	    if( currentObject===null || typeof(currentObject)=='undefined' ) currentObject = [];
	    if( Array.isArray(currentObject) ) {
	    	currentObject.push(value);
	    } else {
	    	currentObject = [ currentObject, value ];
	    }
	    this.setObject(key, currentObject);
	});
	addMethod(Storage,"pushUniqueTail", function(key, value) {
		var currentObject = this.getObject(key);
		if( ! Array.isArray(currentObject) ) {
			this.push(key,value);
		} else {
			newArray = [];
			currentObject.forEach(function( currentValue ){ if(currentValue!=value) newArray.push(currentValue); });
			newArray.push(value);
			this.setObject(key,newArray);
		}
	});

}());





// Assumes Array extras already present (one may use polyfills for these as well)
(function() {
  'use strict';

  var i,
    // We could also build the array of methods with the following, but the
    //   getOwnPropertyNames() method is non-shimable:
    // Object.getOwnPropertyNames(Array).filter(function(methodName) {
    //   return typeof Array[methodName] === 'function'
    // });
    methods = [
      'join', 'reverse', 'sort', 'push', 'pop', 'shift', 'unshift',
      'splice', 'concat', 'slice', 'indexOf', 'lastIndexOf',
      'forEach', 'map', 'reduce', 'reduceRight', 'filter',
      'some', 'every'
    ],
    methodCount = methods.length,
    assignArrayGeneric = function(methodName) {
      if (!Array[methodName]) {
        var method = Array.prototype[methodName];
        if (typeof method === 'function') {
          Array[methodName] = function() {
            return method.call.apply(method, arguments);
          };
        }
      }
    };

  for (i = 0; i < methodCount; i++) {
    assignArrayGeneric(methods[i]);
  }
}());
