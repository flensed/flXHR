/*	flXHR 1.0.6 <http://flxhr.flensed.com/>
	Copyright (c) 2008-2010 Kyle Simpson, Getify Solutions, Inc.
	This software is released under the MIT License <http://www.opensource.org/licenses/mit-license.php>

	====================================================================================================
	Portions of this code were extracted and/or derived from:

	Base64 - 1.1.0
	Copyright (c) 2006 Steve Webster
	
	Permission is hereby granted, free of charge, to any person obtaining a copy of
	this software and associated documentation files (the "Software"), to deal in
	the Software without restriction, including without limitation the rights to
	use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
	the Software, and to permit persons to whom the Software is furnished to do so,
	subject to the following conditions: 
	
	The above copyright notice and this permission notice shall be included in all
	copies or substantial portions of the Software.
	
	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
	FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
	COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
	IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
	CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

package {
/* Flash Class Imports */
import flash.display.MovieClip;
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
import flash.utils.ByteArray;

import flash.external.ExternalInterface;
import flash.system.Security;
import flash.net.LocalConnection;
import flash.utils.setTimeout;
import flash.utils.clearTimeout;

import PolicyChecker;

public class Main extends MovieClip {
	
/* Public */
	public static const CALL_ERROR_CODE:int = 11;
	public static const IO_ERROR_CODE:int = 16;
	public static const SECURITY_ERROR_CODE:int = 15;
	
	public static const READY_STATE_INIT:int = 0;
	public static const READY_STATE_OPEN:int = 1;
	public static const READY_STATE_SENT:int = 2;
	public static const READY_STATE_RECEIVING:int = 3;
	public static const READY_STATE_LOADED:int = 4;

	public function Main() {
		Security.allowDomain("*");
		Security.allowInsecureDomain("*");
		_ready_state = -1;
		_instance_id = ((ExternalInterface.objectID!=null)?ExternalInterface.objectID:"flxhr_noinstance");
		
		try { ExternalInterface.addCallback("setId",_set_id); } catch (err) { }
		try { ExternalInterface.addCallback("abort",XHR_abort); } catch (err) { }
		try { ExternalInterface.addCallback("getAllResponseHeaders",XHR_getAllResponseHeaders); } catch (err) { }
		try { ExternalInterface.addCallback("getResponseHeader",XHR_getResponseHeader); } catch (err) { }
		try { ExternalInterface.addCallback("open",XHR_open); } catch (err) { }
		try { ExternalInterface.addCallback("send",XHR_send); } catch (err) { }
		try { ExternalInterface.addCallback("setRequestHeader",XHR_setRequestHeader); } catch (err) { }
		try { ExternalInterface.addCallback("autoNoCacheHeader",XHR_autoNoCacheHeader); } catch (err) { }
		try { ExternalInterface.addCallback("returnBinaryResponseBody",XHR_returnBinaryResponseBody); } catch (err) { }
		try { ExternalInterface.addCallback("reset",XHR_reset); } catch (err) { }
		try { ExternalInterface.addCallback("loadPolicy",XHR_loadPolicy); } catch (err) { }

		_policy_checker = new PolicyChecker(root);
		
		_urlLoader = new URLLoader();
		_urlRequest = new URLRequest();

		_urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
		_urlLoader.addEventListener(Event.COMPLETE, __completeHandler);
		_urlLoader.addEventListener(ProgressEvent.PROGRESS, __progressHandler);
		_urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, __securityErrorHandler);
		_urlLoader.addEventListener(HTTPStatusEvent.HTTP_STATUS, __httpStatusHandler);
		_urlLoader.addEventListener(IOErrorEvent.IO_ERROR, __ioErrorHandler);
		
		_http_status = 0;
		_auto_no_cache_header = false;
		_send_response_binary = false;

		_pragma = null;
		_authorization = null;
		_pragma_header_defined = false;

		_http_status_text = new Array();
		_http_status_text[100] = "Continue";
		_http_status_text[200] = "OK";
		_http_status_text[201] = "Created";
		_http_status_text[204] = "No Content";
		_http_status_text[206] = "Partial Content";
		_http_status_text[301] = "Moved Permanently";
		_http_status_text[302] = "Found";
		_http_status_text[303] = "See Other";
		_http_status_text[304] = "Not Modified";
		_http_status_text[307] = "Temporary Redirect";
		_http_status_text[400] = "Bad Request";
		_http_status_text[401] = "Unauthorized";
		_http_status_text[403] = "Forbidden";
		_http_status_text[404] = "Not Found";
		_http_status_text[500] = "Internal Server Error";
		_http_status_text[503] = "Service Unavailable";
		
		_open_called = false;
		_error = false;
		_response_loading = false;
		_ready_state = READY_STATE_INIT;

		_send_interval = 0;
		_check_interval = 0;
	}
	
	public function _set_id(instanceId:String="") {
		_instance_id = instanceId;
	}
	
	public function XHR_autoNoCacheHeader(noCacheHeader:Boolean=true):void {
		_auto_no_cache_header = noCacheHeader;
	}
	
	public function XHR_returnBinaryResponseBody(returnBinary:Boolean=false):void {
		if (!_response_loading) _send_response_binary = returnBinary;
	}
	
	public function XHR_abort(...abortParams):void {
		try { 
			_urlLoader.close();
		}
		catch (err) { }
	}

	public function XHR_getAllResponseHeaders():String {
		return "";
	}
	
	public function XHR_getResponseHeader(headerName:String):String {
		return headerName;
	}
	
	public function XHR_open(method:String,url:String,async:Boolean,username:String,pw:String):void {
		if (_error) return;
		if (_ready_state == READY_STATE_INIT) {
			_open_called = true;
			url = _policy_checker.FullyQualifiedURL(url);
			
			if (_pragma == null && _auto_no_cache_header && !_pragma_header_defined) {
				_pragma = new URLRequestHeader("pragma", "no-cache");
			}
			else if (!_auto_no_cache_header) {
				_pragma = null;
			}
			
			if (username != "" && pw != "") {
				_authorization = new URLRequestHeader("authorization","Basic "+__encode(username+":"+pw));
			}
			try {
				_policy_checker.LoadPolicy(_policy_checker.ApplicableMasterPolicyURL(url),_pragma,_authorization);	// load master policy
			}
			catch (err) { }

			_urlRequest.method = method;
			_urlRequest.url = url;
			__check_policies(url);	// will set the ready state = 1 once all the policies are resolved, or
									// throw a security error if this url can't be communicated with according
									// to the security policies examined.
		}
		else {
			ThrowError(CALL_ERROR_CODE,"flXHR::open(): Failed","The open() call cannot be made at this time.");
		}
	}
	
	public function XHR_send(body:String):void {
		if (_error) return;
		if (_open_called && !_response_loading) {
			var checkpolicy:Boolean = _policy_checker.PolicyCheckNeeded();
			if ((checkpolicy && _policy_checker.PoliciesStillLoading()) || _ready_state != READY_STATE_OPEN) {
				_send_interval = setTimeout(XHR_send,100,body);
				return;
			}
			_response_loading = true;
			_open_called = false;
			try { ExternalInterface.call("flensed.getObjectById('"+_instance_id+"').sendProcessed"); } catch (err) { }
			
			if (_pragma == null && _auto_no_cache_header && !_pragma_header_defined) {
				_pragma = new URLRequestHeader("pragma", "no-cache");
			}
			else if (!_auto_no_cache_header) {
				_pragma = null;
			}
			
			if (_pragma != null) _headers.push(_pragma);
			if (_authorization != null) _headers.push(_authorization);
			
			var urlstr:String = _urlRequest.url;
			for (var i:uint=0; i<_headers.length; i++) {
				if (!checkpolicy || _policy_checker.CheckHeaderPolicies(urlstr,_headers[i].name)) _urlRequest.requestHeaders.push(_headers[i]);
				else {
					__securityErrorHandler(new SecurityErrorEvent(SecurityErrorEvent.SECURITY_ERROR));
					return;
				}
			}
	
			if (_send_response_binary) _urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
			else _urlLoader.dataFormat = URLLoaderDataFormat.TEXT;
	
			_urlRequest.data = body;
			try {
				_urlLoader.load(_urlRequest);
			}
			catch (err:Error) {
				ThrowError(CALL_ERROR_CODE,"flXHR::send(): Failed","The send() call failed. ("+err.toString()+")");
			}
			
			_ready_state = READY_STATE_SENT;
		}
		else {
			ThrowError(CALL_ERROR_CODE,"flXHR::send(): Failed","The send() call cannot be made at this time.");
		}
	}
	
	public function XHR_setRequestHeader(...setParams):void {
		if (_error) return;
		if (_open_called) {	// open already called (policies may still be loading), but send call not yet processed
			try {
				setParams[0] = setParams[0].toLowerCase();
				if (setParams[0] == "pragma") {	_pragma = null; _pragma_header_defined = true; }
				if (setParams[0] == "authorization") _authorization = null;
				if (setParams[0] == "content-type") _urlRequest.contentType = setParams[1];
				var header = new URLRequestHeader(setParams[0],setParams[1]);
				_headers.push(header);
			}
			catch (err) { }
		}
		else {
			ThrowError(CALL_ERROR_CODE,"flXHR::setRequestHeader(): Failed","The setRequestHeader() call cannot be made at this time.");
		}
	}
	
	public function XHR_reset():void {
		XHR_abort();
		clearTimeout(_send_interval);
		clearTimeout(_check_interval);
		_http_status = 0;
		
		_policy_checker.__Destroy();
		_policy_checker = new PolicyChecker(root);
		
		_urlLoader.removeEventListener(Event.COMPLETE, __completeHandler);
		_urlLoader.removeEventListener(ProgressEvent.PROGRESS, __progressHandler);
		_urlLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, __securityErrorHandler);
		_urlLoader.removeEventListener(HTTPStatusEvent.HTTP_STATUS, __httpStatusHandler);
		_urlLoader.removeEventListener(IOErrorEvent.IO_ERROR, __ioErrorHandler);

		_urlLoader = new URLLoader();
		_urlRequest = new URLRequest();
		_pragma = null;
		_authorization = null;
		_pragma_header_defined = false;

		_urlLoader.addEventListener(Event.COMPLETE, __completeHandler);
		_urlLoader.addEventListener(ProgressEvent.PROGRESS, __progressHandler);
		_urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, __securityErrorHandler);
		_urlLoader.addEventListener(HTTPStatusEvent.HTTP_STATUS, __httpStatusHandler);
		_urlLoader.addEventListener(IOErrorEvent.IO_ERROR, __ioErrorHandler);
		
		_headers = new Array();
		
		_response_loading = false;
		_open_called = false;
		_error = false;
		_ready_state = READY_STATE_INIT;
	}
	
	public function XHR_loadPolicy(fromURL:String=""):void {
		if (_error) return;
		if (fromURL != "") {
			if (_pragma == null && _auto_no_cache_header && !_pragma_header_defined) {
				_pragma = new URLRequestHeader("pragma", "no-cache");
			}
			else if (!_auto_no_cache_header) {
				_pragma = null;
			}

			fromURL = _policy_checker.FullyQualifiedURL(fromURL);
			Security.loadPolicyFile(fromURL);
			_policy_checker.LoadPolicy(fromURL,_pragma,_authorization);
		}
	}
	
	public function ChunkResponse(chunk):void {
		try {
			ExternalInterface.call("flensed.getObjectById('"+_instance_id+"').chunkResponse",chunk);
		}
		catch (err) { }
	}

	public function ReadyStateChange(...callbackParams):void {
		_ready_state = callbackParams[0];
		try {
			callbackParams.unshift("flensed.getObjectById('"+_instance_id+"').doOnReadyStateChange");
			ExternalInterface.call.apply(this,callbackParams);
		}
		catch (err) { }
	}
	
	public function ThrowError(...exceptionParams):void {
		try {
			_error = true;
			clearTimeout(_send_interval);
			clearTimeout(_check_interval);
			exceptionParams.unshift("flensed.getObjectById('"+_instance_id+"').doOnError");
			ExternalInterface.call.apply(this,exceptionParams);
		}
		catch (err) { }
	}
		
/* Private */
	private var _http_status_text:Array;
	private var _auto_no_cache_header:Boolean;
	private var _send_response_binary:Boolean;
	private var _instance_id:String;

	private var _urlLoader:URLLoader;
	private var _headers:Array;
	private var _urlRequest:URLRequest;
	private var _pragma:URLRequestHeader;
	private var _authorization:URLRequestHeader;
	private var _http_status:int;

	private var _open_called:Boolean;
	private var _pragma_header_defined:Boolean;
	private var _response_loading:Boolean;
	private var _error:Boolean;
	private var _ready_state:int;
	
	private var _policy_checker:PolicyChecker;
	
	private var _send_interval:int;
	private var _check_interval:int;
	
	private const BASE64_CHARS:String = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";

	private function __encode(data:String):String {
		var bytes:ByteArray = new ByteArray();
		bytes.writeUTFBytes(data);
		return __encode_byte_array(bytes);
	}
	
	private function __encode_byte_array(data:ByteArray):String {
		var output:String = "";
		var dataBuffer:Array;
		var outputBuffer:Array = new Array(4);
		data.position = 0;
		while (data.bytesAvailable > 0) {
			dataBuffer = new Array();
			for (var i:uint = 0; i < 3 && data.bytesAvailable > 0; i++) {
				dataBuffer[i] = data.readUnsignedByte();
			}
			outputBuffer[0] = (dataBuffer[0] & 0xfc) >> 2;
			outputBuffer[1] = ((dataBuffer[0] & 0x03) << 4) | ((dataBuffer[1]) >> 4);
			outputBuffer[2] = ((dataBuffer[1] & 0x0f) << 2) | ((dataBuffer[2]) >> 6);
			outputBuffer[3] = dataBuffer[2] & 0x3f;
			for (var j:uint = dataBuffer.length; j < 3; j++) {
				outputBuffer[j + 1] = 64;
			}
			for (var k:uint = 0; k < outputBuffer.length; k++) {
				output += BASE64_CHARS.charAt(outputBuffer[k]);
			}
		}
		return output;
	}
		
	private function __check_policies(targetLocation:String):void {
		if (_policy_checker.PolicyCheckNeeded()) {
			if (_policy_checker.PoliciesStillLoading()) {
				_check_interval = setTimeout(__check_policies,100,targetLocation);
				return;
			}
			if (_policy_checker.CheckPolicies(targetLocation)) {
				_ready_state = READY_STATE_OPEN;
			}
			else {
				ThrowError(SECURITY_ERROR_CODE,"Policy Failure","A security sandbox error occured with the flXHR request.");
			}
		}
		else { _ready_state = READY_STATE_OPEN; }
	}
		
	private function __http_status_text(statusCode:int):String {
		if (_http_status_text[statusCode] != "undefined") return _http_status_text[statusCode];
		else return "Unknown";
	}
	
	private function __completeHandler(cEvent:Event):void {
		var rawresponse = null, chunk = null;
		var chunkmarker:uint = 0, chunksize:uint = 0;
		if (_send_response_binary) {
			rawresponse = new Array();
			for (var i=0; i<_urlLoader.data.length; i++) {
				rawresponse.push(_urlLoader.data.readUnsignedByte());
			}
		}
		else {
			rawresponse = _urlLoader.data;
		}
		if (_http_status == 0) _http_status = 200;
		while (chunkmarker < rawresponse.length) {
			chunksize = (((chunksize=chunkmarker+500)>rawresponse.length)?rawresponse.length-chunkmarker:chunksize);
			chunk = rawresponse.slice(chunkmarker,chunkmarker+chunksize);
			if (!_send_response_binary) {
				// sending as string, so escape any literal \'s (for pass through EI)
				chunk = chunk.replace(/\\/g,'\\\\');
			}
			ChunkResponse(chunk);
			chunkmarker += chunksize;
		}
		
		_response_loading = false;
		ReadyStateChange(READY_STATE_LOADED,_http_status,__http_status_text(_http_status));
	}
	
	private function __progressHandler(pEvent:ProgressEvent):void {
		ReadyStateChange(READY_STATE_RECEIVING,"","","",_http_status,__http_status_text(_http_status));
	}
	
	private function __securityErrorHandler(sEvent:SecurityErrorEvent):void {
		_response_loading = false;
		XHR_abort();
		ThrowError(SECURITY_ERROR_CODE,sEvent.type,"A security sandbox error occured with the flXHR request.");
	}
	
	private function __httpStatusHandler(hEvent:HTTPStatusEvent):void {
		_http_status = hEvent.status;
	}
	
	private function __ioErrorHandler(iEvent:IOErrorEvent):void {
		_response_loading = false;
		XHR_abort();
		if (_http_status > 0) ThrowError(_http_status,__http_status_text(_http_status),"An error occured preventing completion of the request.");
		else ThrowError(IO_ERROR_CODE,iEvent.type,"An error occured preventing completion of the request.");
	}
	
	
}

}
