/*	mootools.flXHRproxy 1.0 <http://flxhr.flensed.com/>
	Adapted from code by MaXPert [Zohaib Sibt-e-Hassan] 

	Copyright (c) 2009 Kyle Simpson, Zohaib Sibt-e-Hassan
	This software is released under the MIT License <http://www.opensource.org/licenses/mit-license.php>
	
	flXHR works as a replacement of native XHR, additionally allowing authorized cross-domain communication 
	through flash's crossdomain.xml policy model.
	
	This plugin extends the core Ajax functions so that you can register a URL (or partial URL) with a set 
	of flXHR configuration options. When an Ajax call is made, if the URL matches a registered URL, flXHR
	will be chosen as the transport and the options applied to the flXHR instance.
	
	Request.flXHRproxy.registerOptions('http://www.mydomain.com/',{xmlResponseText:false...});
	Request.flXHRproxy.registerOptions('http://rss.mydomain.com/',{xmlResponseText:true...});
	...
	var req1 = new Request({url:'http://www.mydomain.com/something.html',...});
	req1.send(...);
	...
	var req2 = new Request({url:'http://rss.mydomain.com/feed.html',...});
	req2.send(...);
*/

(function(){
	var regHash = new Hash(), XHRRequest = Request;
	
	Request = new Class({
		Extends: XHRRequest,
		send: function(options){
			var url = $pick(options.url, this.options.url);
			var flxopts = Request.flXHRproxy.getOptionsForURL(url);

			if (flxopts && (typeof this.options.async === "undefined" || this.options.async)) {
				if (typeof flxopts.onerror === "function") {
					this.setOptions({onFailure:flxopts.onerror});
				}
				var _this = this;
				flxopts.onerror = function(){ _this.onFailure.apply(_this,arguments); };
				this.xhr = new flensed.flXHR(flxopts);
			}
			this.parent(options);
		},
		onFailure: function(errObj){
			this.fireEvent('complete').fireEvent('failure', [this.xhr, errObj]);
		},
		success: function(text, xml) {
			this.onSuccess(this.processScripts(text), xml, this.xhr);
		}
	});
		
	Request.JSON = new Class({
		Implements: [XHRRequest.JSON],
		Extends: Request,
		success: function(text){
			this.response.json = JSON.decode(text, this.options.secure);
			this.onSuccess(this.response.json, text, this.xhr);
		}
	});
	
	Request.HTML = new Class({
		Implements: [XHRRequest.HTML],
		Extends: Request,
		success: function(text){
			var options = this.options, response = this.response;
			response.html = text.stripScripts(function(script){
				response.javascript = script;
			});
			var temp = this.processHTML(response.html);
			response.tree = temp.childNodes;
			response.elements = temp.getElements('*');
			if (options.filter) response.tree = response.elements.filter(options.filter);
			if (options.update) document.id(options.update).empty().set('html', response.html);
			else if (options.append) document.id(options.append).adopt(temp.getChildren());
			if (options.evalScripts) $exec(response.javascript);
			this.onSuccess(response.tree, response.elements, response.html, response.javascript, this.xhr);
		}
	});

	Request.flXHRproxy = {
		registerOptions: function(url, options){
			options = $extend({instancePooling:true, autoUpdatePlayer:true}, options);
			regHash.set(url, options);
			return true;
		},
		getOptionsForURL: function(url){
			var ret = null;
			if(!url) return null;
			regHash.each(function(v, k){
				if (url.substring(0,k.length)===k) ret = v;
			});
			return ret;
		}
	};
})();