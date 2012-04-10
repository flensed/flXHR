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

	AS1 version (Flash IDE/MMC compilation only)
*/

System.security.allowDomain("fpdownload.macromedia.com");

var cacheBuster	= Math.random();
var updateSWF	= "http://fpdownload.macromedia.com/pub/flashplayer/update/current/swf/autoUpdater.swf?"+cacheBuster;
loaderClip.loadMovie(updateSWF);

var time		= 0;
var timeOut		= 3;	// expressed in seconds
var delay		= 10;	// expressed in milliseconds
var int_id		= setInterval(checkLoaded, delay);

var old_si = null;

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
			loaderClip.startInstall = function() {
				clearInterval(int_id);
				old_si();
			}
			loadComplete();
		}
	}
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
			callbackCheckPlayer(0);
		break;
		case "Download.Cancelled":
			// The end user chose "NO" when prompted to install the new player.
			callbackCheckPlayer(1);
		break;
		case "Download.Failed":
			// The end user failed to download the installer due to a network failure.
			callbackCheckPlayer(2);
		break;
		case "Download.Timeout":
			// The download timed out because it failed to complete in a timely manner.
			callbackCheckPlayer(3);
		break;
	}
}

function callbackCheckPlayer(code){
	getURL("javascript:flensed.getObjectById('"+_root.swfId+"').updateSWFCallback("+code+");");
}
