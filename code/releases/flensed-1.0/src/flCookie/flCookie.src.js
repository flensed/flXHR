/*	flCookie 0.1 <http://flcookie.flensed.com/>
	Copyright (c) 2009 Kyle Simpson, Getify Solutions, Inc.
	This software is released under the MIT License <http://www.opensource.org/licenses/mit-license.php>

	====================================================================================================
*/

(function(global){
	// frequently used variable declarations, for optimized compression
	var oWIN = global,
		oDOC = global.document,
		bTRUE = true,
		bFALSE = false,
		sEMPTY = "",
		sUNDEF = "undefined",
		sOBJECT = "object",
		sFUNCTION = "function",
		sSTRING = "string",
		sDIV = "div",
		sONUNLOAD = "onunload",
		tmp = null,
		_flcookie_idc = 0,
		_flensed = null,
		_chkplyr = null,
		_cp_ins = null,
		js_type = "text/javascript",
		flCookie_js = "flCookie.js",			// SHOULD NOT rename the file or change this line
		flensed_js = "flensed.js",				// ditto
		checkplayer_js = "checkplayer.js",		// ditto
		flCookie_swf = "flCookie.swf",			// ditto
		this_script = flCookie_js,
		fPARSEINT = global.parseInt,
		fSETTIMEOUT = global.setTimeout,
		fCLEARTIMEOUT = global.clearTimeout
	;

	if (typeof global.flensed === sUNDEF) { global.flensed = {}; }
	if (typeof global.flensed.flCookie !== sUNDEF) { return; }	// flCookie already defined, so quit
	
	_flensed = global.flensed;
	
	fSETTIMEOUT(function() {
		var base_path_known = bFALSE,
			scriptArry = oDOC.getElementsByTagName("script"),
			oHEAD = oDOC.getElementsByTagName("head")[0],
			scrlen = scriptArry.length;
		try { _flensed.base_path.toLowerCase(); base_path_known = bTRUE; } catch(err) { _flensed.base_path = sEMPTY; }
	
		function load_script(src,type) {
			for (var k=0; k<scrlen; k++) {
				if (typeof scriptArry[k].src !== sUNDEF) {
					if (scriptArry[k].src.indexOf(src) >= 0) { break; }  // this script already loaded/loading...
				}
			}
			var scriptElem = oDOC.createElement("script");
			scriptElem.setAttribute("src",_flensed.base_path+src);
			if (typeof type !== sUNDEF) { scriptElem.setAttribute("type",type); }
			oHEAD.appendChild(scriptElem);
		}
		
		if ((typeof scriptArry !== sUNDEF) && (scriptArry !== null)) {
			if (!base_path_known) {
				var idx=0;
				for (var k=0; k<scrlen; k++) {
					if (typeof scriptArry[k].src !== sUNDEF) {
						if (((idx=scriptArry[k].src.indexOf(flensed_js)) >= 0) || ((idx=scriptArry[k].src.indexOf(flCookie_js)) >= 0)) {
							_flensed.base_path = scriptArry[k].src.substr(0,idx);
							break;
						}
					}
				}
			}
		}
		try { _flensed.checkplayer.module_ready(); } catch (err2) { load_script(checkplayer_js,js_type); }
		load_script(flensed_js,js_type);
	
		var coreInterval = null;
		(function waitForCore() {
			try { _flensed.ua.pv.join("."); } catch (err) { coreInterval = fSETTIMEOUT(arguments.callee,25); return; }
			_flensed.bindEvent(oWIN,sONUNLOAD,function(){
				try {
					global.flensed.unbindEvent(oWIN,sONUNLOAD,arguments.callee);
					for (var k in _flcookie) {
						if (_flcookie.hasOwnProperty(k)) {
							try { _flcookie[k] = null; } catch (err2) { }
						}
					}
					_flensed.flCookie = _flcookie = _flensed = _cp_ins = _chkplyr = null;
				}
				catch (err3) { }
			});
		})();
		function clearCoreInterval() { fCLEARTIMEOUT(coreInterval); try { oWIN.detachEvent(sONUNLOAD,clearCoreInterval); } catch (err) {} }
		if (coreInterval !== null) { try { oWIN.attachEvent(sONUNLOAD,clearCoreInterval); } catch(err3) {} }

		var dependencyTimeout = null;
		function clearDependencyTimeout() { fCLEARTIMEOUT(dependencyTimeout); try { oWIN.detachEvent(sONUNLOAD,clearDependencyTimeout); } catch (err) {} }
		try { oWIN.attachEvent(sONUNLOAD,clearDependencyTimeout); } catch (err4) {}
		dependencyTimeout = fSETTIMEOUT(function(){
			clearDependencyTimeout();
			try { 
				_flensed.checkplayer.module_ready(); 
			} catch (err2) { throw new global.Error("flCookie dependencies failed to load."); }
		},20000);	// only wait 20 secs max for CheckPlayer to load
	},0);

	_flensed.flCookie = function(cookieLocation,cookieNameSuffix,readyCB,errorCB) {
		if (typeof cookieLocation === sSTRING) {
			if (cookieLocation.length > 0 && cookieLocation.charAt(cookieLocation.length-1) !== "/") cookieLocation += "/";
		}
		else cookieLocation = sEMPTY;
		if (typeof cookieNameSuffix !== sSTRING) {
			cookieNameSuffix = sEMPTY;
		}
		if (typeof readyCB !== sFUNCTION) readyCB = function(){};
		
		// Private Properties
		var	idNumber = ++_flcookie_idc,
			publicAPI,
			appendTo = null,
			constructInterval,
			styleClass = "flCookieHideSwf",
			_flcookie_css = bFALSE,
			_ready = bFALSE,
			_error = bFALSE,
			cookieId = sEMPTY,
			cookieObj,
			oBODY = oDOC.getElementsByTagName("body"),
	
			autoUpdatePlayer = bFALSE, 	// TODO: hook up configuration to allow author to set these at instantiation time
			appendToId = null,
			cookieIdPrefix = "flCookie_swf"
		;
	
		// Private Methods
		var constructor = function() {
			cookieId = cookieIdPrefix+"_"+idNumber;
			
			function clearConstructInterval() { fCLEARTIMEOUT(constructInterval); try { oWIN.detachEvent(sONUNLOAD,clearConstructInterval); } catch (err) { } }
			try { oWIN.attachEvent(sONUNLOAD,clearConstructInterval); } catch (err) { }	// only IEoWIN would leak memory this way
			(function waitForCore() {
				try { _flensed.bindEvent(oWIN,sONUNLOAD,destructor); } catch (err) { constructInterval = fSETTIMEOUT(arguments.callee,25); return; }
				clearConstructInterval();
				constructInterval = fSETTIMEOUT(continueConstructor,1);
			})();
		}();
			
		function continueConstructor() {
			if (appendToId === null) { appendTo = oBODY[0]; }
			else { appendTo = _flensed.getObjectById(appendToId); }
			
			try { appendTo.nodeName.toLowerCase(); _flensed.checkplayer.module_ready(); _chkplyr = _flensed.checkplayer; } catch (err) {	// make sure DOM object and checkplayer are ready
				// maybe set a timeout here in case the DOM obj (appendTo) never gets ready?
				constructInterval = fSETTIMEOUT(continueConstructor,25);
				return;
			}
			
			_flensed.bindEvent(oWIN,sONUNLOAD,destructor);
			_chkplyr = _flensed.checkplayer;
						
			if ((_cp_ins === null) && (typeof _chkplyr._ins === sUNDEF)) {
				try {
					_cp_ins = new _chkplyr(_flcookie.MIN_PLAYER_VERSION,checkCallback,bFALSE,updateCallback);
				}
				catch (err2) { doError(_flcookie.DEPENDENCY_ERROR,"flCookie: checkplayer Init Failed","The initialization of the 'checkplayer' library failed to complete."); return; }
			}
			else {
				_cp_ins = _chkplyr._ins;
				stillContinueConstructor();
			}
		}
	
		function stillContinueConstructor() {
			if (_flcookie_css === null && appendToId === null) {	// only if CSS hasn't been defined yet, and if flCookie is being added to the BODY of the page
				_flensed.createCSS("."+styleClass,"left:-1px;top:0px;width:1px;height:1px;position:absolute;");	// CSS to hide any flCookie instances added automatically to the BODY
				_flcookie_css = bTRUE;
			}

			var holder = oDOC.createElement(sDIV);
			holder.id = cookieId;
			holder.className = styleClass;
			appendTo.appendChild(holder);
			appendTo = null;
	
			var flashvars = {},
				params = { allowScriptAccess:"always" },
				attributes = { id:cookieId, name:cookieId, styleclass:styleClass },
				optionsObj = { swfCB:initSWF, swfEICheck:"setId" }
			;
	
			try {
				_cp_ins.DoSWF(cookieLocation+flCookie_swf, cookieId, "1", "1", flashvars, params, attributes, optionsObj);
			}
			catch (err2) { doError(_flcookie.DEPENDENCY_ERROR,"flCookie: checkplayer Call Failed","A call to the 'checkplayer' library failed to complete."); return; }
		}
	
		function checkCallback(checkObj) {
			if (checkObj.checkPassed) {
				stillContinueConstructor();
			}
			else if (!autoUpdatePlayer) {
				doError(_flcookie.PLAYER_VERSION_ERROR,"flCookie: Insufficient Flash Player Version","The Flash Player was either not detected, or the detected version ("+checkObj.playerVersionDetected+") was not at least the minimum version ("+_flcookie.MIN_PLAYER_VERSION+") needed by the 'flCookie' library.");
			}
			else {
				_cp_ins.UpdatePlayer();
			}
		}

		function updateCallback(checkObj) {
			if (checkObj.updateStatus === _chkplyr.UPDATE_CANCELED) {
				doError(_flcookie.PLAYER_VERSION_ERROR,"flCookie: Flash Player Update Canceled","The Flash Player was not updated.");
			}
			else if (checkObj.updateStatus === _chkplyr.UPDATE_FAILED) {
				doError(_flcookie.PLAYER_VERSION_ERROR,"flCookie: Flash Player Update Failed","The Flash Player was either not detected or could not be updated.");
			}
		}

		function initSWF(loadStatus) {
			//console.log("initSWF-1");
			if (loadStatus.status !== _chkplyr.SWF_EI_READY) { return; }
			//console.log("initSWF-2");

			clearIntervals();
			cookieObj = _flensed.getObjectById(cookieId);
			cookieObj.setId(cookieId);

			cookieObj.doOnError = doError;
			cookieObj.doOnReady = doReady;
			
			cookieObj.initCookie(cookieNameSuffix);
		}
		
		function finishConstructor(loadStatus) {
			//console.log("finishConstructor");
			_ready = bTRUE;
			fSETTIMEOUT(function(){
				try { readyCB(publicAPI); } catch (err) { doError(_flcookie.HANDLER_ERROR,"flCookie::readyCallback(): Error","An error occurred in the handler function. ("+err.message+")"); return; }
			},0);
		}
		
		function destructor() {
			try { global.flensed.unbindEvent(oWIN,sONUNLOAD,destructor); } catch (err) { }
			try {
				for (var j in publicAPI) {
					if (publicAPI.hasOwnProperty(j)) {
						try { publicAPI[j] = null; } catch (err3) { }
					}
				}
			}
			catch (err4) { }
			publicAPI = null;
	
			clearIntervals();
			if ((typeof cookieObj !== sUNDEF) && (cookieObj !== null)) {
				try { cookieObj.doOnError = null; doOnError = null; } catch (err5) { }
				try { cookieObj.doOnReady = null; doOnReady = null; } catch (err6) { }
				cookieObj = null;
			
				try { global.swfobject.removeSWF(cookieId); } catch(err10) { }
			}
			
			readyCB = null;
			errorCB = null;
		}

		function doReady() {
			//console.log("doReady");
			if (!_ready && !_error) finishConstructor();
		}
	
		function doError() {
			clearIntervals();
			_error = bTRUE;
			var errorObj;
			try {
				errorObj = new _flensed.error(arguments[0],arguments[1],arguments[2],publicAPI);
			}
			catch (err) {
				function ErrorObjTemplate() { this.number=0;this.name="flCookie Error: Unknown";this.description="Unknown error from 'flCookie' library.";this.message=this.description;this.srcElement=publicAPI;var a=this.number,b=this.name,c=this.description;function toString() { return a+", "+b+", "+c; } this.toString=toString; }
				errorObj = new ErrorObjTemplate();
			}
			var handled = bFALSE;
			try { 
				if (typeof errorCB === sFUNCTION) { errorCB(errorObj); handled = bTRUE; }
			}
			catch (err2) { 
				var prevError = errorObj.toString();
				function ErrorObjTemplate2() { this.number=_flcookie.HANDLER_ERROR;this.name="flCookie::errorCallback(): Error";this.description="An error occured in the handler function. ("+err2.message+")\nPrevious:["+prevError+"]";this.message=this.description;this.srcElement=publicAPI;var a=this.number,b=this.name,c=this.description;function toString() { return a+", "+b+", "+c; } this.toString=toString; }
				errorObj = new ErrorObjTemplate2();
			}
	
			if (!handled) {
				SETTIMEOUT(function() { _flensed.throwUnhandledError(errorObj.toString()); },1);
			}
		}

		function clearIntervals() {
			fCLEARTIMEOUT(constructInterval);
			constructInterval = null;
		}
		
		function getValue(name) {
			if (!_error) {
				if (typeof name !== sSTRING || name.length < 1) return null;
				var now = new Date().getTime(), parts, tmp;
				try { parts = cookieObj.getValue(name); } catch (err) {
					doError(_flcookie.CALL_ERROR,"flCookie::getValue(): Failed","The getValue() call failed to complete.");
					return null;
				}
				if (parts !== null) {
					parts = parts.match(/^([^\;]+);(.*)/m);
					if (parts.length !== 3 || (parts[1] !== "." && now >= fPARSEINT(parts[1]))) { // cookie is invalid or value has expired
						deleteValue(name);
						return null;
					}
					return parts[2];
				}
				else return null;
			}
			else return null;
		}
		
		function setValue(name,val,expires) {
			if (!_error) {
				if (typeof name !== sSTRING || name.length < 1 || typeof val !== sSTRING || val.length < 1) return null;
				if (typeof expires !== sUNDEF) {
					if (typeof expires !== sSTRING) expires = sEMPTY + expires;
					if (expires !== "." && expires.match(/[^0-9]/g)) expires = Date.parse(expires);
					else if (expires === sEMPTY) expires = ".";
				}
				else expires = ".";
				try { return cookieObj.setValue(name,expires+";"+val); } catch (err) {
					doError(_flcookie.IO_ERROR,"flCookie::setValue(): Failed","The setValue() call failed to complete.");
					return bFALSE;
				}
			}
			else return bFALSE;
		}
		
		function deleteValue(name) {
			if (!_error) {
				if (typeof name !== sSTRING || name.length < 1) return bFALSE;
				try { return cookieObj.deleteValue(name); } catch (err) {
					doError(_flcookie.IO_ERROR,"flCookie::deleteValue(): Failed","The deleteValue() call failed to complete.");
					return bFALSE;
				}
			}
			else return bFALSE;
		}		
	
		// Public API
		publicAPI = {
			instanceId:cookieId,
			ready:function(){return _ready;},
			getValue:getValue,
			setValue:setValue,
			deleteValue:deleteValue,
			Destroy:destructor
		};
		return publicAPI;
	};
	_flcookie = _flensed.flCookie;	// frequently used variable declarations
	
	// Static Properties
	_flcookie.HANDLER_ERROR = 10;
	_flcookie.CALL_ERROR = 11;
	_flcookie.DEPENDENCY_ERROR = 13;
	_flcookie.PLAYER_VERSION_ERROR = 14;
	_flcookie.SECURITY_ERROR = 15;
	_flcookie.IO_ERROR = 16;
	_flcookie.MIN_PLAYER_VERSION = "9";
	_flcookie.module_ready = function(){};
	

})(window);
