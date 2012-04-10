@ECHO OFF
REM		CheckPlayer 1.0.1 <http://checkplayer.flensed.com/>
REM		Copyright (c) 2008 Kyle Simpson, Getify Solutions, Inc.
REM		This software is released under the MIT License <http://www.opensource.org/licenses/mit-license.php>
REM
REM		====================================================================================================
REM		Portions of this code were extracted and/or derived from:
REM
REM		SWFObject v2.1 & 2.2a6 <http://code.google.com/p/swfobject/>
REM		Copyright (c) 2007-2008 Geoff Stearns, Michael Williams, and Bobby van der Sluis
REM		This software is released under the MIT License <http://www.opensource.org/licenses/mit-license.php>
REM
REM		====================================================================================================
REM		This batch file compiles 'updateplayerMTASC.as' into 'updateplayer.swf' using Motion-Twin's 'mtasc' 
REM		compiler (1.14), obtained from: http://www.mtasc.org/
REM
REM		====================================================================================================

ECHO Compiling updateplater.swf...
del updateplayer.swf 1>nul 2>&1
mtasc -swf updateplayer.swf -main -header 219:143:12 -version 6 updateplayerMTASC.as
echo Done, press any key...
pause > nul