/*	jQuery.flXHRproxy 1.1 <http://flxhr.flensed.com/>
	Copyright (c) 2009 Kyle Simpson
	This software is released under the MIT License <http://www.opensource.org/licenses/mit-license.php>
	
	This plugin registers flXHR with the new jQuery XHR registry, so it can be chosen as a custom transport
	for Ajax communication. flXHR will work as a replacement of the native XHR, additionally allowing
	authorized cross-domain communication through flash's crossdomain.xml policy model.
	
	This plugin allows an author to register a set of flXHR configuration options to be tied to each URL
	that will be communicated with. Typical usage might be:
	
	jQuery.ajaxSetup({transport:'flXHRproxy'});
	jQuery.flXHRproxy.registerOptions('http://www.mydomain.com/',{xmlResponseText:false...});
	jQuery.flXHRproxy.registerOptions('http://rss.mydomain.com/',{xmlResponseText:true...});
	...
	jQuery.ajax({url:'http://www.mydomain.com/something.html'...});
	...
	jQuery.ajax({url:'http://rss.mydomain.com/feed.html'...});

*/

;(function( $ ){
	$.flXHRproxy = flensed.flXHR;	// make jQuery.flXHRproxy a reference alias to flensed.flXHR, for convenience
	var _opts = [];
	$.flXHRproxy.registerOptions = function(url,fopts) {	// call to define a set of flXHR options to be applied to a 
															// matching request URL
		// set up flXHR defaults, if not already defined
		if (typeof fopts==="undefined"||fopts===null) fopts = {};
		if (typeof fopts.instancePooling==="undefined"||fopts.instancePooling===null) fopts.instancePooling = true;
		if (typeof fopts.autoUpdatePlayer === "undefined"||fopts.autoUpdatePlayer===null) fopts.autoUpdatePlayer = true;
		_opts.push(function(callUrl) {	// save this set of options with a matching function for the target URL
			if (callUrl.substring(0,url.length)===url) return fopts;
			else return null;
		});
	}
	$.xhr.register('flXHRproxy',function(as) {
		var tmp = null, useopts = null;
		if (as.async&&(as.type==="POST"||as.type==="GET")) {	// flXHR only supports async and GET/POST
			for (var i=0; i<_opts.length; i++) {	// loop through all registered options for flXHR
				if ((tmp=_opts[i](as.url))!==null) useopts = tmp;	// if URL match is found, use those options
			}
		}
		if (useopts !== null) {	// if any matching options were found, use them
			return new $.flXHRproxy(useopts);
		}
		else {	// else, fall back on standard XHR
			return $.xhr.registry['xhr'](as);
		}
	});
})(jQuery);
