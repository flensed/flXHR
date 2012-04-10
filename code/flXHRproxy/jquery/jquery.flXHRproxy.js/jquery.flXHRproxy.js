/*	jQuery.flXHRproxy 2.0a <http://flxhr.flensed.com/>
	Copyright (c) 2009-2011 Kyle Simpson
	Contributions by Julian Aubourg
	This software is released under the MIT License <http://www.opensource.org/licenses/mit-license.php>
	
	This plugin causes jQuery to treat flXHR as an XHR object, as a replacement of the native XHR, additionally 
	allowing authorized cross-domain communication through flash's crossdomain.xml policy model.
	
	This plugin allows an author to register a set of flXHR configuration options to be tied to each URL
	that will be communicated with. Typical usage might be:
	
	jQuery.flXHRproxy.registerOptions('http://www.mydomain.com/',{xmlResponseText:false...});
	jQuery.flXHRproxy.registerOptions('http://rss.mydomain.com/',{xmlResponseText:true...});
	...
	jQuery.ajax({url:'http://www.mydomain.com/something.html'...});
	...
	jQuery.ajax({url:'http://rss.mydomain.com/feed.html'...});

*/

;(function($){
	$.flXHRproxy = flensed.flXHR;	// make jQuery.flXHRproxy a reference alias to flensed.flXHR, for convenience
	
	var _opts = [],
		r_type = /^(?:post|get)$/i,
		defaultOptions = {
			instancePooling: true,
			autoUpdatePlayer: true
		}
	;
	
	$.flXHRproxy.registerOptions = function(url,fopts) {	// call to define a set of flXHR options to be applied to a 
															// matching request URL
		fopts = $.extend( {}, defaultOptions, fopts || {} );

		_opts.push(function(callUrl) {	// save this set of options with a matching function for the target URL
			if (callUrl.substring(0,url.length)===url) return fopts;
		});
	};

	// Prefilter to control if we need to use flXHR
	$.ajaxPrefilter(function( as ) {
		var useopts, tmp;
		if ( as.async && r_type.test( as.type ) ) {
			for (var i=0; i<_opts.length; i++) {	// loop through all registered options for flXHR
				if (tmp = _opts[i](as.url)) useopts = tmp;	// if URL match is found, use those flXHR options
			}
			
			// Use flXHR if we have options OR if said to do so
			// with the explicit as.flXHR option
			if ( useopts || as.flXHR ) {
				as.flXHROptions = useopts || defaultOptions;
				// Derail the transport selection
				return "__flxhr__";
			}
		}
	});
	
	// flXHR transport
	$.ajaxTransport( "__flxhr__", function( as, _, jqXHR ) {
		// Remove the fake dataType
		as.dataTypes.shift();
		// Make sure it won't be trigerred for async requests
		// if the dataType is set manually (users can be crazy)
		if ( !as.async ) {
			return;
		}
		// The flXHR instance
		var callback;
		// The transport
		return {
			send: function( headers, complete ) {
				var options = as.flXHROptions || defaultOptions,
					xhr = jqXHR.__flXHR__ = new $.flXHRproxy( options ),
					isError;
				// Define callback
				callback = function( status, error ) {
					if ( callback && ( error || xhr.readyState === 4 ) ) {
						callback = xhr.onreadystatechange = xhr.onerror = null;
						if ( error ) {
							if (! ( isError = ( error !== "abort" ) ) ) {
								xhr.abort();
							}
							complete( status, error );
						} else {
							var responses = {},
								responseXML = xhr.responseXML;
							if ( responseXML && responseXML.documentElement ) {
								responses.xml = responseXML;
							}
							responses.text = xhr.responseText;
							complete( xhr.status, xhr.statusText, responses, xhr.getAllResponseHeaders() );
						}
					}
				};
				// Attach onerror handler
				if ( $.isFunction( options.onerror ) ) {
					jqXHR.fail(function() {
						if ( isError ) {
							options.onerror.apply( this, arguments );
						}
					});
				}
				// Attach xhr handlers
				xhr.onreadystatechange = callback;
				xhr.onerror = function( flXHR_errorObj ) {
					complete( -1, flXHR_errorObj );
				};
				// Issue the request
				xhr.open( as.type, as.url, as.async, as.username, as.password );
				for ( var i in headers ) {
					xhr.setRequestHeader( i, headers[ i ] );
				}
				xhr.send( ( as.hasContent && as.data ) || null );
			},
			abort: function() {
				if ( callback ) {
					callback( 0, "abort" );
				}
			}
		};
	});

})(jQuery);

