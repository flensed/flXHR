/*	CheckPlayer 1.0.1 <http://checkplayer.flensed.com/>
	Copyright (c) 2008 Kyle Simpson, Getify Solutions, Inc.
	This software is released under the MIT License <http://www.opensource.org/licenses/mit-license.php>

	====================================================================================================
	Derived From: 
	SWFObject v2.1 <http://code.google.com/p/swfobject/>
	Copyright (c) 2007-2008 Geoff Stearns, Michael Williams, and Bobby van der Sluis
	This software is released under the MIT License <http://www.opensource.org/licenses/mit-license.php>

	====================================================================================================
	Express Install
	Copyright © 2005-2007 Adobe Systems Incorporated and its licensors. All Rights Reserved.

	AS2 version (mtasc compilation only)
*/

class updateplayerMTASC {
	 static var app;

	 var loaderClip = null;
	 var time		= 0;
	 var timeOut		= 3;	// expressed in seconds
	 var delay		= 10;	// expressed in milliseconds
	 var int_id		= 0;
	 var old_si = null;
	
	function updateplayerMTASC() {
		System.security.allowDomain("fpdownload.macromedia.com");
		var cacheBuster	= Math.random();
		var updateSWF	= "http://fpdownload.macromedia.com/pub/flashplayer/update/current/swf/autoUpdater.swf?"+cacheBuster;
		int_id	= setInterval(this,"checkLoaded",delay);
		loaderClip = _root.createEmptyMovieClip("loaderClip",0);
		loaderClip.loadMovie(updateSWF);
		_root.installStatus = installStatus;
	}

	function checkLoaded(){
		time += delay/1000;
		if(time > timeOut){
			// updater did not load in time, abort load and force alternative content
			clearInterval(int_id);
			loaderClip.unloadMovie();
			loadTimeOut();
			return;
		}
		if (loaderClip.startInstall.toString() == "[type Function]"){
			// updater has loaded successfully
			if (old_si == null) {
				old_si = loaderClip.startInstall;
				loaderClip.startInstall = new_startInstall;
				loadComplete();
			}
		}
	}
	
	function new_startInstall() {
		clearInterval(app.int_id);
		app.old_si();
	}
		
	function loadComplete(){
		loaderClip.redirectURL	= _root.MMredirectURL;
		loaderClip.MMplayerType	= _root.MMplayerType;
		loaderClip.MMdoctitle	= _root.MMdoctitle;
		loaderClip.startUpdate();
	}
	
	function loadTimeOut(){
		installStatus("Download.Timeout");
	}
	
	function installStatus(statusValue){
		switch(statusValue){
			case "Download.Complete":
				// Installation is complete.
				// In most cases the browser window that this SWF is hosted in will be closed by the installer or 
				// otherwise it has to be closed manually by the end user.
				// The Adobe Flash installer will reopen the browser window and reload the page containing the SWF. 
				app.callbackCheckPlayer(0);
			break;
			case "Download.Cancelled":
				// The end user chose "NO" when prompted to install the new player.
				app.callbackCheckPlayer(1);
			break;
			case "Download.Failed":
				// The end user failed to download the installer due to a network failure.
				app.callbackCheckPlayer(2);
			break;
			case "Download.Timeout":
				// The download timed out because it failed to complete in a timely manner.
				app.callbackCheckPlayer(3);
			break;
		}
	}
	
	function callbackCheckPlayer(code){
		getURL("javascript:flensed.getObjectById('"+_root.swfId+"').updateSWFCallback("+code+");");
	}

	static function main(mc) {
		app = new updateplayerMTASC();
	}
}
