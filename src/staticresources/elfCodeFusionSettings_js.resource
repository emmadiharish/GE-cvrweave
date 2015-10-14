elfCodeFusionSettings = { 
    snippets : {
        javascript : [ 
            { name: "xfu : function",     	tabTrigger: "xfu",        content: ""
    			+"function ${1?:name}(${2:params}) {\n"
    			+"	${3:// body...}\n"
    			+"}\n"
            },
            { name: "xob : object",       	tabTrigger: "xob",        content: ""
				+"var ${1:name} = {\n"
				+"    ${10:}\n"
				+"}$0\n"
            },
            { name: "xme : method",       	tabTrigger: "xme",        content: ""
				+"${1:name}: function(${2:params}){\n"
				+"    ${10:}\n"
				+"},${0:}\n"
            },
            { name: "xpr : property",      	tabTrigger: "xpr",        content: ""
				+"${1:name}: ${2:params},${0:}"
            },
            { name: "xaf : anon function",   tabTrigger: "xaf",        content: ""
				+"function(${1:}){${10:}}${0:}"
            },
            { name: "xxl : console.log()",  tabTrigger: "xxl",        content: ""
                +"console.log('${1:topic}', ${2:object} );${0:} "
            },
            { name: "xj : $(..).method(params)", tabTrigger: "xj",        content: ""
                +"$(${1:selector}).${2:method}(${3:params});${0:}"
            },
            { name: "xjcs : $(..).css(attr)",  		tabTrigger: "xjcs",        content: ""
                +"$(${1:selector}).css(${2:attr});${0:}"
            },
            { name: "xjat : $(..).attr(attr)",  		tabTrigger: "xjat",        content: ""
                +"$(${1:selector}).attr(${2:attr});${0:}"
            },
            { name: "xjcl : $(..).click(attr)",  		tabTrigger: "xjcl",        content: ""
                +"$(${1:selector}).click(${2:attr});${0:}"
            },
            { name: "xjhide : $(..).hide()",  		tabTrigger: "xjhide",        content: ""
                +"$(${1:selector}).hide();${0:}"
            },
            { name: "xjshow : $(..).show()",  		tabTrigger: "xjshow",        content: ""
                +"$(${1:selector}).show();${0:}"
            },

            { name: "xfe : forEach",  		tabTrigger: "xfe",        content: ""
                +"forEach(function(${1:item}){${2:}})${0:}"
            },
            { name: "xfi : for in",  		tabTrigger: "xfi",        content: ""
                +"for(${1:key} : ${2:items}) {\n"
                +"    var ${3:item} = ${2:items}[${1:key}]\n"	
                +"}${0:}\n"
            },
        ],
        java : [
            { name: "xxl : xt.log",         tabTrigger: "xxl",        content: ""
                +"xt.log( ${1:object} );${0:}\n "
            },
            { name: "xxlq : xt.log+query",  tabTrigger: "xxlq",       content: ""
                +"xt.log(database.query(xs.soql( 'select * from ${1:Account} where Id!=0 ' )));${0:}\n " 
            },
        ],
    }
 }
