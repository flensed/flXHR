/*	flCookie 0.1 <http://flcookie.flensed.com/>
	Copyright (c) 2009 Kyle Simpson, Getify Solutions, Inc.
	This software is released under the MIT License <http://www.opensource.org/licenses/mit-license.php>
*/

package {
/* Flash Class Imports */
import flash.display.MovieClip;
import flash.events.Event;
import flash.net.SharedObject;
import flash.net.SharedObjectFlushStatus;

import flash.external.ExternalInterface;
import flash.system.Security;
import flash.utils.setTimeout;
import flash.utils.clearTimeout;

import CookiePolicyChecker;


public class MainCOOKIE extends MovieClip {
	
/* Public */
	public static const CALL_ERROR_CODE:int = 11;
	public static const SECURITY_ERROR_CODE:int = 15;
	public static const IO_ERROR_CODE:int = 16;
	
	public function MainCOOKIE() {
		Security.allowDomain("*");
		Security.allowInsecureDomain("*");
		_instance_id = ((ExternalInterface.objectID!=null)?ExternalInterface.objectID:"flcookie_noinstance");
		
		try { ExternalInterface.addCallback("setId",_set_id); } catch (err) { }
		try { ExternalInterface.addCallback("initCookie",_init_cookie); } catch (err) { }

		try { ExternalInterface.addCallback("getValue",_get_value); } catch (err) { }
		try { ExternalInterface.addCallback("setValue",_set_value); } catch (err) { }
		try { ExternalInterface.addCallback("deleteValue",_delete_value); } catch (err) { }
		
		_error = false;
		_ready = false;
	}
	
	public function _init_cookie(cookieNameSuffix:String="") {
		if (cookieNameSuffix != "") cookieNameSuffix = "_" + cookieNameSuffix;
		_policy_checker = new CookiePolicyChecker(root);
		_policy_checker.LoadPolicy();
		__check_policies();
				
		try {
			_cookie_name_suffix = cookieNameSuffix;
			_get_cookie();
		}
		catch (err:Error) {
			_error = true;
			ThrowError(IO_ERROR_CODE,"Cookie Creation Error","The cookie could not be created.");
		}
	}
	
	public function _set_id(instanceId:String="") {
		_instance_id = instanceId;
	}
	
	public function _get_value(name:String="") {
		if (_ready && !_error) {
			_get_cookie();
			if (typeof _cookie.data[name] !== "undefined") return _cookie.data[name];
		}
		return null;
	}
	
	public function _set_value(name:String="",value=".") {
		if (_ready && !_error) {
			_get_cookie();
			_cookie.data[name] = value;
			var commit;
			try { commit = _cookie.flush(); }
			catch (err) {
				commit = "Write Error";
			}
			if (commit != SharedObjectFlushStatus.FLUSHED) {
				_error = true;
				ThrowError(IO_ERROR_CODE,"Cookie Save Error","The cookie could not be saved.");
				return false;
			}
			return true;
		}
		return false;
	}
	
	public function _delete_value(name:String="") {
		if (_ready && !_error) {
			_get_cookie();
			delete _cookie.data[name];
			var commit;
			try { commit = _cookie.flush(); }
			catch (err) {
				commit = "Write Error";
			}
			if (commit != SharedObjectFlushStatus.FLUSHED) {
				_error = true;
				ThrowError(IO_ERROR_CODE,"Cookie Save Error","The cookie could not be saved.");
				return false;
			}
			return true;
		}
		return false;
	}
	
	public function ThrowError(...exceptionParams):void {
		try {
			_error = true;
			exceptionParams.unshift("flensed.getObjectById('"+_instance_id+"').doOnError");
			ExternalInterface.call.apply(this,exceptionParams);
		}
		catch (err) {}
	}
	
	public function SignalReady():void {
		try {
			_ready = true;
			var args = Array("flensed.getObjectById('"+_instance_id+"').doOnReady");
			ExternalInterface.call.apply(this,args);
		}
		catch (err) {}
	}
		
/* Private */
	private var _instance_id:String;
	private var _cookie_name_suffix:String;
	private var _error:Boolean;
	private var _ready:Boolean;
	private var _cookie:SharedObject;
	private var _check_interval:int;
	private var _policy_checker:CookiePolicyChecker;
	
	private function _get_cookie() {
		_cookie = null;
		_cookie = SharedObject.getLocal("flCookie"+_cookie_name_suffix,"/");
	}

	private function __check_policies():void {
		if (_policy_checker.PolicyCheckNeeded()) {
			if (_policy_checker.PoliciesStillLoading()) {
				_check_interval = setTimeout(__check_policies,100);
				return;
			}
			if (_policy_checker.CheckPolicies()) { SignalReady(); }
			else {
				ThrowError(SECURITY_ERROR_CODE,"Security Sandbox Error","A security sandbox error occured when creating/accessing a cross-domain cookie. The page-domain must be authorized via 'allow-cookies-from' in the 'crossdomain.xml' policy file at flCookie.swf's domain root.");
			}
		}
		else { SignalReady(); }
	}

	
}

}
