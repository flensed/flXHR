/*	dojox.io.flXHRproxy 1.1 <http://flxhr.flensed.com/>
	Copyright (c) 2009 Kyle Simpson
	This software is released under the MIT License <http://www.opensource.org/licenses/mit-license.php>
	
	This plugin registers flXHR with the new XHR Plugins DojoX registry extension, so it can be chosen as a 
	custom transport for Ajax communication. flXHR will work as a replacement of the native XHR, additionally 
	allowing authorized cross-domain communication through flash's crossdomain.xml policy model.
	
	This plugin allows an author to register a set of flXHR configuration options to be tied to each URL
	that will be communicated with. Typical usage might be:
	
	dojox.io.flXHRproxy.registerOptions('http://www.mydomain.com/',{xmlResponseText:false...});
	dojox.io.flXHRproxy.registerOptions('http://rss.mydomain.com/',{xmlResponseText:true...});
	...
	dojo.xhrGet({url:'http://www.mydomain.com/something.html'...});
	...
	dojo.xhrGet({url:'http://rss.mydomain.com/feed.html'...});

*/

dojo.provide("dojox.io.flXHRproxy");
dojo.require("dojox.io.xhrPlugins");

;(function(io){
	io.flXHRproxy = flensed.flXHR;	// actually make dojox.io.flXHRproxy a reference alias to flensed.flXHR, for convenience
	var _matches = [],_opts = [];
	io.flXHRproxy.registerOptions = function(url,fopts){	// call to define a set of flXHR options to be 
															// applied to a matching request URL
		// set up flXHR defaults, if not already defined
		if (typeof fopts === "undefined" || fopts === null) fopts = {};
		if (typeof fopts.instancePooling === "undefined" || fopts.instancePooling === null) fopts.instancePooling = true;
		if (typeof fopts.autoUpdatePlayer === "undefined" || fopts.autoUpdatePlayer === null) fopts.autoUpdatePlayer = true;
	
		_opts.push(function(callUrl) { // save this set of options with a matching function for the target URL
			if (callUrl.substring(0,url.length) === url) return fopts;
			else return null;
		});
	
		_matches.push(function(method,args) {	// define a matching function for the request parameters and the target URL
			return (args.sync !== true) && (args.url.substring(0,url.length) === url) && (method == "GET" || method == "POST");
		});
	};
	
	io.xhrPlugins.register("flXHRproxy",	// register this proxy plugin with the XHR registry
		function(method,args){
			// indicates whether or not this plugin can be used for the given request
			for (var i=0; i<_matches.length; i++) {	// loop through all registered matches for flXHR
				if (_matches[i](method,args)) return true;
			}
			return false;
		},
		function(method,args,hasBody){
			// save the default XHR object retriever
			var browserXhr = dojo._xhrObj;
	
			// retrieve the registered flXHR options for a matching URL, if any
			var tmp, useopts = {instancePooling:true,autoUpdatePlayer:true};
			for (var i=0; i<_opts.length; i++) {	// loop through all registered options for flXHR
				if ((tmp=_opts[i](args.url))!==null) useopts = tmp;
			}
			
			var deferred = {};
			
			var old_onerror = useopts.onerror, _this = this;
			useopts.onerror = function() {
				var errObj = arguments[0];
				var newErrObj = new Error(errObj);
				for (var i in errObj) 
					if (errObj[i]!==Object.prototype[i]) newErrObj[i] = errObj[i];
				if (typeof old_onerror === "function") old_onerror.call(_this,newErrObj);
				deferred.errback(newErrObj);		// trigger error event in dojo
				deferred.cancel();
			};
			
			// adapt the XHR transport retriever for flXHR
			dojo._xhrObj = function() {
				return new io.flXHRproxy(useopts);	// instantiate flXHR through this dojox alias reference to flensed.flXHR
			};
			// make the dojox XHR call
			deferred = io.xhrPlugins.plainXhr.call(dojo, method, args, hasBody);
			// restore the default XHR retriever
			dojo._xhrObj = browserXhr;
			return deferred;
		}
	);
})(dojox.io);