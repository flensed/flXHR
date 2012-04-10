/*	flCookie 0.1 (CookiePolicyChecker) <http://flcookie.flensed.com/>
	Copyright (c) 2009 Kyle Simpson, Getify Solutions, Inc.
	This software is released under the MIT License <http://www.opensource.org/licenses/mit-license.php>
	
	====================================================================================================
	Portions of this code were extracted and/or derived from:

	parseUri 1.2.1
	(c) 2007 Steven Levithan <stevenlevithan.com>
	MIT License	
*/

package {
/* Flash Class Imports */
import flash.events.Event;
import flash.events.HTTPStatusEvent;
import flash.events.IEventDispatcher;
import flash.events.ProgressEvent;
import flash.events.SecurityErrorEvent;
import flash.events.IOErrorEvent;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.net.URLRequestHeader;
import flash.net.URLRequestMethod;
import flash.net.URLLoaderDataFormat;
import flash.display.LoaderInfo;
import flash.display.DisplayObject;

import flash.external.ExternalInterface;
import flash.system.Security;
import flash.net.LocalConnection;

public class CookiePolicyChecker extends Object {
	
/* Public */

	public function CookiePolicyChecker(rootObj:DisplayObject) {
		_policy_files_contents = new Object();
		_policy_file_loaders = new Object();
		_policy_complete_handlers = new Object();
		_policy_definitions = new Object();

		_page_url = "";
		var pageloc:String = ExternalInterface.call("self.location.href.toString");
		if (pageloc != null) {
			_page_url = __url_wipe_case(pageloc);
			_page_domain = __url_domain(_page_url);
		}
		else _page_url = "";
		
		_swf_url = rootObj.loaderInfo.loaderURL;
		_swf_url = __url_wipe_case(_swf_url);
		_swf_domain = __url_domain(_swf_url);
		
		targetLocation = _swf_url;
		
		_policies_resolving = 0;
	}
	
	public function LoadPolicy():void {
		if (PolicyCheckNeeded()) {
			var policyURL:String = ApplicableMasterPolicyURL();
			policyURL = __url_wipe_case(policyURL);
			for (var k in _policy_file_loaders) {
				if (k == policyURL) { return; }
			}
			_policies_resolving++;
			_policy_file_loaders[policyURL] = new URLLoader();
	
			_policy_file_loaders[policyURL].dataFormat = URLLoaderDataFormat.TEXT;
			_policy_complete_handlers[policyURL] = function (cEvent:Event) {
				try { _policy_files_contents[policyURL] = new XML(cEvent.target.data); }
				catch (err) { _policies_resolving--; }
			};
			_policy_file_loaders[policyURL].addEventListener(Event.COMPLETE, _policy_complete_handlers[policyURL]);
	
			_policy_file_loaders[policyURL].addEventListener(SecurityErrorEvent.SECURITY_ERROR, __policySecurityErrorHandler);
			_policy_file_loaders[policyURL].addEventListener(HTTPStatusEvent.HTTP_STATUS, __policyHttpStatusHandler);
			_policy_file_loaders[policyURL].addEventListener(IOErrorEvent.IO_ERROR, __policyIoErrorHandler);
	
			var urlRequest = new URLRequest();
			urlRequest.method = "GET";
			urlRequest.url = policyURL;
				
			_policy_file_loaders[policyURL].load(urlRequest);
		}
	}
	
	public function PolicyCheckNeeded():Boolean {
		if (_page_domain == "" || _swf_domain == "") return false;	// something prevented proper URL detection,
																	// so policy checking will be futile
		return (_page_domain != _swf_domain);
	}
	
	public function CheckPolicies():Boolean {
		if (PoliciesStillLoading()) return false;
		
		var commAllowed:Boolean = true;
		if (PolicyCheckNeeded()) {
			commAllowed = false;
			var tunique:String = __target_unique(targetLocation);
			var targetparts:Object = ParseUri(targetLocation);
			var targetpath:String = targetparts.directory;
			
			if (typeof _policy_definitions[tunique] == "undefined") {
				__process_policies();
			}
			
			// now, check the policy tree against _page_url
			commAllowed = (__check_target_domain(_policy_definitions[tunique]["from"],targetpath));
		}
		return commAllowed;
	}
	
	public function ObjectLength(obj:Object):uint {
		var len:uint = 0;
		for each (var k in obj) { len++; }
		return len;		
	}
	
	public function PoliciesStillLoading():Boolean {
		return (_policies_resolving > ObjectLength(_policy_files_contents));
	}
	
	public function FullyQualifiedURL(targetURL:String):String {
		return __qualified_url(targetURL);
	}
	
	public function ApplicableMasterPolicyURL():String {
		var targetURL = FullyQualifiedURL(targetLocation);
		var urlparts:Object = ParseUri(targetURL);
		var unpw:String = ((urlparts.userInfo != "")?urlparts.userInfo+"@":"");
		var port:String = ((urlparts.port != "")?":"+urlparts.port:"");
		return urlparts.protocol+"://"+unpw+urlparts.host+port+"/crossdomain.xml";
	}

	public function __Destroy() {
		for (var j in _policy_files_contents) {
			delete(_policy_files_contents[j]);
			_policy_files_contents[j] = false;
		}
		_policy_files_contents = new Object();
		for (var k in _policy_file_loaders) {
			try { _policy_file_loaders[k].close(); } catch (err) { }
			_policy_file_loaders[k].removeEventListener(Event.COMPLETE, _policy_complete_handlers[k]);
			_policy_file_loaders[k].removeEventListener(SecurityErrorEvent.SECURITY_ERROR, __policySecurityErrorHandler);
			_policy_file_loaders[k].removeEventListener(HTTPStatusEvent.HTTP_STATUS, __policyHttpStatusHandler);
			_policy_file_loaders[k].removeEventListener(IOErrorEvent.IO_ERROR, __policyIoErrorHandler);
			_policy_file_loaders[k] = false;
		}
		for (var l in _policy_complete_handlers) {
			_policy_complete_handlers[l] = false;
		}
		_policy_file_loaders = new Object();
		_policy_complete_handlers = new Object();
		_policy_definitions = new Object();
		_policies_resolving = 0;
	}

	public function ParseUri(str:String,strictMode:Boolean=false):Object {
		var o:Object = new Object();
		o.strictMode = strictMode;
		o.key = new Array("source","protocol","authority","userInfo","user","password","host","port","relative","path","directory","file","query","anchor");
		o.q = new Object();
		o.q.name = "queryKey";
		o.q.parser = /(?:^|&)([^&=]*)=?([^&]*)/g;
		o.parser = new Object();
		o.parser.strict = /^(?:([^:\/?#]+):)?(?:\/\/((?:(([^:@]*):?([^:@]*))?@)?([^:\/?#]*)(?::(\d*))?))?((((?:[^?#\/]*\/)*)([^?#]*))(?:\?([^#]*))?(?:#(.*))?)/
		o.parser.loose = /^(?:(?![^:@]+:[^:@\/]*@)([^:\/?#.]+):)?(?:\/\/)?((?:(([^:@]*):?([^:@]*))?@)?([^:\/?#]*)(?::(\d*))?)(((\/(?:[^?#](?![^?#\/]*\.[^?#\/.]+(?:[?#]|$)))*\/?)?([^?#\/]*))(?:\?([^#]*))?(?:#(.*))?)/

		var m:Object = o.parser[o.strictMode ? "strict" : "loose"].exec(str);
		var uri:Object = new Object();
		var i:int = 14;
		while (i--) uri[o.key[i]] = m[i] || "";
		uri[o.q.name] = new Object();
		uri[o.key[12]].replace(o.q.parser, function ($0, $1, $2) {
			if ($1) uri[o.q.name][$1] = $2;
		});
		if (uri.protocol == "") uri.protocol = "http";	// if no protocol can be found, assume most insecure protocol
		return uri;
	}
	
/* Private */
	private var _swf_domain:String;
	private var _page_domain:String;
	private var _swf_url:String;
	private var _page_url:String;
	private var targetLocation:String;
	
	private var _policies_resolving:uint;
	private var _policy_files_contents:Object;
	private var _policy_file_loaders:Object;
	private var _policy_complete_handlers:Object;
	private var _policy_definitions:Object;
	
	private function __valid_ip(domain:String):Boolean {
		var ipv4 = /^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$/;
		var ipv6 = /^(^(([0-9A-F]{1,4}(((:[0-9A-F]{1,4}){5}::[0-9A-F]{1,4})|((:[0-9A-F]{1,4}){4}::[0-9A-F]{1,4}(:[0-9A-F]{1,4}){0,1})|((:[0-9A-F]{1,4}){3}::[0-9A-F]{1,4}(:[0-9A-F]{1,4}){0,2})|((:[0-9A-F]{1,4}){2}::[0-9A-F]{1,4}(:[0-9A-F]{1,4}){0,3})|(:[0-9A-F]{1,4}::[0-9A-F]{1,4}(:[0-9A-F]{1,4}){0,4})|(::[0-9A-F]{1,4}(:[0-9A-F]{1,4}){0,5})|(:[0-9A-F]{1,4}){7}))$|^(::[0-9A-F]{1,4}(:[0-9A-F]{1,4}){0,6})$)|^::$)|^((([0-9A-F]{1,4}(((:[0-9A-F]{1,4}){3}::([0-9A-F]{1,4}){1})|((:[0-9A-F]{1,4}){2}::[0-9A-F]{1,4}(:[0-9A-F]{1,4}){0,1})|((:[0-9A-F]{1,4}){1}::[0-9A-F]{1,4}(:[0-9A-F]{1,4}){0,2})|(::[0-9A-F]{1,4}(:[0-9A-F]{1,4}){0,3})|((:[0-9A-F]{1,4}){0,5})))|([:]{2}[0-9A-F]{1,4}(:[0-9A-F]{1,4}){0,4})):|::)((25[0-5]|2[0-4][0-9]|[0-1]?[0-9]{0,2})\.){3}(25[0-5]|2[0-4][0-9]|[0-1]?[0-9]{0,2})$$/i;
		return (ipv4.test(domain) || ipv6.test(domain));
	}
	
	private function __valid_domain(domain:String):Boolean {
		var alphabetic = /[a-z]/i;
		var ascii_fqdn = /^(?!-)(([0-9a-z\-]*[0-9a-z]+\.)*([0-9a-z]+[0-9a-z\-]*))(?<!-)$/i;
		return (domain.length<=64 && alphabetic.test(domain) && ascii_fqdn.test(domain));
	}
		
	private function __target_unique(targetURL:String):String {
		var urlParts:Object = ParseUri(targetURL);
		return urlParts.protocol+"://"+urlParts.authority;
	}
	
	private function __glue_url(urlparts:Object):String {
		return (((urlparts.protocol!="")?urlparts.protocol+"://":"")+((urlparts.userInfo!="")?urlparts.userInfo+"@":"")+urlparts.host+((urlparts.port!="")?":"+urlparts.port:"")+((urlparts.relative.charAt("/")<0)?"/":"")+urlparts.relative);
	}
	
	private function __url_wipe_case(url:String):String {
		var urlparts:Object = ParseUri(__qualified_url(url));
		urlparts.protocol = urlparts.protocol.toLowerCase();
		urlparts.host = urlparts.host.toLowerCase();
		return __glue_url(urlparts);
	}
	
	private function __qualified_url(url:String):String {
		var sepPosition:int = 0;
		if (url != "") sepPosition = url.indexOf("://");
		if ((sepPosition < 0 || sepPosition > 5) && _page_url != "") {	// URL doesn't have a valid "protocol" specifier at the beginning
			var pageurlparts:Object = ParseUri(_page_url);
			if (__valid_ip(url) || __valid_domain(url)) {	// URL is just a valid IP or domain name, so simply qualify it with the page's protocol
				return pageurlparts.protocol+"://"+url+"/";
			}
			else {	// assume this is a relative path URL and use the page's URL to fully-qualify it
				var unpw:String = ((pageurlparts.userInfo != "")?pageurlparts.userInfo+"@":"");
				var port:String = ((pageurlparts.port != "")?":"+pageurlparts.port:"");
				return pageurlparts.protocol+"://"+unpw+pageurlparts.host+port+((url.charAt(0)!="/")?"/":"")+url;
			}
		}
		else if (url != "") {
			var urlparts:Object = ParseUri(url);
			if (typeof urlparts.directory == "undefined" || urlparts.directory == "") url += "/";
		}
		return url;
	}
	
	private function __url_domain(url:String):String {
		if (__valid_ip(url) || __valid_domain(url)) return url;	// URL is already a valid IP or domain name, so just return it
		
		var domain:String = "";
		var sepPosition:int = 0;
		if (url != "") sepPosition = url.indexOf("://");
		if ((sepPosition < 0 || sepPosition) > 5 && _page_url != "") {	// doesn't have a valid "protocol" specifier at the beginning,
													// so assume this is a relative URL and use the page's domain
			var pageurlparts:Object = ParseUri(_page_url);
			domain = pageurlparts.host;
		}
		else if (url != "") {
			var urlparts:Object = ParseUri(url);
			domain = urlparts.host;
		}
		return ((__valid_ip(domain)||__valid_domain(domain))?domain:"");
	}

	private function __policySecurityErrorHandler(sEvent:SecurityErrorEvent):void {
		_policies_resolving--;
	}
	
	private function __policyHttpStatusHandler(hEvent:HTTPStatusEvent):void {
		if (hEvent.status == 404) _policies_resolving--;
	}
	
	private function __policyIoErrorHandler(iEvent:IOErrorEvent):void {
		_policies_resolving--;
	}
		
	private function __initialize_object(theObj:Object,index:String):void {
		if (typeof theObj[index] == "undefined") theObj[index] = new Object();
	}
	
	private function __initialize_to(theObj:Object,to:String):void {
		__initialize_object(theObj,to);
		__initialize_object(theObj[to],"to");
		if (typeof theObj[to]["comm"] == "undefined") theObj[to]["comm"] = false;
	}
	
	private function __initialize_from(theObj:Object,from:String):void {
		__initialize_object(theObj,from);
		__initialize_object(theObj[from],"from");
		__initialize_object(theObj[from],"to");
		__initialize_to(theObj[from]["to"],"/");
	}
		
	private function __path_parts(path:String):Array {
		if (path == "") return new Array("");
		var parts:Array = path.split("/");
		if (parts[parts.length-1] == "") parts.pop();
		return parts;
	}

	private function __domain_parts(domain:String):Array {
		if (domain == "") return new Array();
		if (domain == "*") return new Array(domain);
		var parts:Array = domain.split(".");
		return parts;
	}
		
	private function __glue_partial_path(pathparts:Array,depth:uint):String {
		var str:String = "";
		if (depth > pathparts.length) depth = pathparts.length;
		str = "";
		for (var i:uint=0; i<depth; i++) {
			if (pathparts[i] != "") str += "/"+pathparts[i];
		}
		return str+"/";
	}
	
	private function __glue_partial_domain(domainparts:Array,startIndex:uint):String {
		var str:String = "";
		for (var i:uint=startIndex; i<domainparts.length; i++) {
			str += ((str!="")?".":"")+domainparts[i];
		}
		return str;
	}
	
	private function __insert_allow_to(toNode:Object,path:String):void {
		if (path == "" || path.charAt(0) != "/") return;
		var cardinality:uint = 1;
		var theNode:Object = toNode;
		var pparts:Array = __path_parts(path);
		var pstr:String = "";
		
		while (cardinality<=15) {	// no paths deeper than 15 levels, to limit memory and recursion performance issues
			if (pparts.length < cardinality) break;
			pstr = __glue_partial_path(pparts,cardinality);
			
			__initialize_to(theNode,pstr);

			if (pparts.length == cardinality) {
				theNode[pstr]["comm"] = true;
				break;
			}
			else {
				cardinality++;
				theNode = theNode[pstr]["to"];
			}
		}
	}
			
	private function __insert_allow_from(fromNode:Object,domain:String,path:String):void {
		if (domain=="" || domain=="*" || domain.indexOf("*")>0 || (domain.indexOf("*")==0 && domain.split(".").length<2)) return;
		var cardinality:uint = 1;
		var theNode:Object = fromNode;
		var dparts:Array = __domain_parts(domain);
		var dstr:String = "";
		
		while (cardinality<=15) {	// no sub-domains deeper than 15 levels, to limit memory and recursion performance issues
			if (dparts.length < cardinality) break;
			dstr = __glue_partial_domain(dparts,dparts.length-cardinality);
			
			__initialize_from(theNode,"*."+dstr);
			__initialize_from(theNode,dstr);

			if (dparts.length == cardinality) {
				__insert_allow_to(theNode[dstr]["to"],path);
				break;
			}
			else if (dparts[dparts.length-cardinality-1] == "*") {
				__insert_allow_to(theNode[dstr]["to"],path);
				__insert_allow_to(theNode["*."+dstr]["to"],path);
				break;
			}
			else {
				cardinality++;
				theNode = theNode["*."+dstr]["from"];
			}
		}
	}

	private function __insert_allow_from_ip(fromNode:Object,ip:String,path:String):void {
		__initialize_from(fromNode,ip);
		__insert_allow_to(fromNode[ip]["to"],path);
	}
	
	private function __domain_match(domainPattern:String,domainTest:String):Boolean {
		if (domainPattern=="*") return true;
		if (domainPattern.indexOf("*")<0) return (domainPattern==domainTest);
		else {
			var subpattern:String = domainPattern.substr(2);	// remove the leading '*.'
			if (subpattern.length>domainTest.length) return false;
			return (domainTest.indexOf(subpattern)==(domainTest.length-subpattern.length));	// subpattern must appear at the end of domainTest
		}
	}
	
	private function __path_match(pathPattern:String,pathTest:String):Boolean {
		if (pathPattern.length<pathTest.length) return false;
		return (pathPattern.indexOf(pathTest)==0);
	}
		
	private function __check_target_domain(fromNode:Object,path:String):Boolean {
		for (var j in fromNode) {
			if (__domain_match(j,_page_domain)) {
				if (__check_target_path(fromNode[j]["to"],path)) return true;
				if (__check_target_domain(fromNode[j]["from"],path)) return true;
			}
		}
		return false;
	}
	
	private function __check_target_path(toNode:Object,path:String):Boolean {
		for (var j in toNode) {
			if (__path_match(path,j)) {
				if (toNode[j]["comm"]) return true;
				if (__check_target_path(toNode[j]["to"],path)) return true;
			}
		}
		return false;
	}
	
	private function __process_policies():void {
		var targetURL:String = targetLocation;
		var custompoliciesallowed:Boolean = false;
		var policyxml:XML = null;
		var policyentries:XML = null;
		var elementlist:XMLList = null;
		var attrval:String = "";
		var attrval2:String = "";
		var attrval3:String = "";
		var tmp_attrval:String = "";
		var toPath:String = "";
		var xmlnode:XML = null;
		var j,k,l,m,n;
		var urlparts:Object = null;
		var dparts:Array = null;
		var headers:Array = null;
		
		var masterPolicyURL:String = ApplicableMasterPolicyURL();
		var targetunique:String = __target_unique(targetURL);
		var targetparts:Object = ParseUri(targetURL);
		
		var wildcarddomain = /^(\*|((\*\.)?)[^\*\.][^\*]*)$/i;
				
		__initialize_object(_policy_definitions,targetunique);
		__initialize_object(_policy_definitions[targetunique],"from");
		__initialize_from(_policy_definitions[targetunique]["from"],"*");
		
		
		if (typeof _policy_files_contents[masterPolicyURL] != "undefined" && _policy_files_contents[masterPolicyURL] != null) {
			policyentries = _policy_files_contents[masterPolicyURL];
			if (policyentries.name() == "cross-domain-policy") {
				for (k in _policy_files_contents) {
					k = __url_wipe_case(k);
					var kparts:Object = ParseUri(k);
					if (targetunique === __target_unique(k)) {	// this policy applies to the request being checked
						policyentries = _policy_files_contents[k];
						if (policyentries.name() == "cross-domain-policy") {
							toPath = kparts.directory;
							
							elementlist = policyentries.child("allow-cookies-from");
							if (elementlist.length() > 0) {
								for (j in elementlist) {
									tmp_attrval = (attrval = elementlist[j].attribute("domain"));
									if (wildcarddomain.test(attrval)) { // check 'domain' to make sure it's valid with respect to wildcard
										if (attrval.indexOf("*.")==0) tmp_attrval = attrval.substr(2);
										if (__valid_ip(attrval)) {	// use full attrval since ip's don't allow wildcards
											__insert_allow_from_ip(_policy_definitions[targetunique]["from"]["*"]["from"],attrval,toPath);
										}
										else if (__valid_domain(tmp_attrval)) {	// use tmp_attrval since domains do allow wildcards
											__insert_allow_from(_policy_definitions[targetunique]["from"]["*"]["from"],attrval,toPath);
										}
										else if (attrval == "*") {
											__insert_allow_to(_policy_definitions[targetunique]["from"]["*"]["to"],toPath);
										}
									}
								}
							}
						}
					}
				}
			}
		}
	}
	
	
}

}
