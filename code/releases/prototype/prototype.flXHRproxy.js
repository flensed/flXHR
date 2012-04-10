/*	prototype.flXHRproxy 1.1 <http://flxhr.flensed.com/>
	Adapted from code by Andrew Dupont at: http://gist.github.com/114444

	Copyright (c) 2009 Kyle Simpson
	This software is released under the MIT License <http://www.opensource.org/licenses/mit-license.php>
	
	flXHR works as a replacement of native XHR, additionally allowing authorized cross-domain communication 
	through flash's crossdomain.xml policy model.
	
	This plugin extends the core Ajax functions so that you can register a URL (or partial URL) with a set 
	of flXHR configuration options. When an Ajax call is made, if the URL matches a registered URL, flXHR
	will be chosen as the transport and the options applied to the flXHR instance.
	
	Ajax.flXHRproxy.registerOptions('http://www.mydomain.com/',{xmlResponseText:false...});
	Ajax.flXHRproxy.registerOptions('http://rss.mydomain.com/',{xmlResponseText:true...});
	...
	Ajax.Request('http://www.mydomain.com/something.html',{...});
	...
	Ajax.Request('http://rss.mydomain.com/feed.html',{...});
*/

(function(){
	var _registry = $H();
	
	Object.extend(Ajax, {
		flXHRproxy: {
			registerOptions: function(url, options) {
				options = Object.extend({
					instancePooling: true,
					autoUpdatePlayer: true
				},
				options || {});
				_registry.set(url, options);
			},
			getOptionsForURL: function(url) {
				var options = null;
				_registry.detect(function(pair) {
					if (url.substring(0,pair.key.length)===pair.key) options = pair.value;
				});
				return options;
			}
		}
	});
	Ajax.Request.addMethods({
		initialize: function($super, url, options) {
			$super(options); 
			
			var flXHRoptions = Ajax.flXHRproxy.getOptionsForURL(url);
			if (flXHRoptions && this.options.asynchronous && $w('POST GET').include(this.options.method.toUpperCase())) {
				if (typeof flXHRoptions.onerror === "function") {
					Ajax.Responders.register({onException:flXHRoptions.onerror});
				}
				var _this = this;
				flXHRoptions.onerror = function() {
					if (arguments[0].number >= 200) {
						(_this.options.onFailure || Prototype.emptyFunction)(_this, arguments[0]);
						Ajax.Responders.dispatch.apply(Ajax.Responders,['onFailure',_this].concat(arguments));
					}
					else _this.dispatchException.apply(_this,arguments); 
				};
				this.transport = new flensed.flXHR(flXHRoptions);
			}
			else {
				this.transport = Ajax.getTransport();
			}
			this.request(url);
		}
	});
})();