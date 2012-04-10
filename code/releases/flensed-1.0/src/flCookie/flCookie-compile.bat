@ECHO OFF
REM		flCookie 0.1 <http://flcookie.flensed.com/>
REM		Copyright (c) 2009 Kyle Simpson, Getify Solutions, Inc.
REM		This software is released under the MIT License <http://www.opensource.org/licenses/mit-license.php>
REM
REM		====================================================================================================
REM		This batch file compiles 'flCookie.as' into 'flCookie.swf' using the configuration stored in 
REM		'flCookie-compile.xml' and Adobe's 'mxmlc' compiler (3.1.0), obtained as part of the Flex Builder SDK,
REM		from: http://www.adobe.com/products/flex/flexdownloads/
REM
REM		====================================================================================================

ECHO Compiling flCookie.swf...
del flCookie.swf 1>nul 2>&1
mxmlc -load-config=flCookie-compile.xml MainCOOKIE.as
echo Done, press any key...
pause > nul