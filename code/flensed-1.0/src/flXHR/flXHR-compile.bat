@ECHO OFF
REM		flXHR 1.0.6 <http://flxhr.flensed.com/>
REM		Copyright (c) 2008-2010 Kyle Simpson, Getify Solutions, Inc.
REM		This software is released under the MIT License <http://www.opensource.org/licenses/mit-license.php>
REM
REM		====================================================================================================
REM		This batch file compiles 'flXHR.as' into 'flXHR.swf' using the configuration stored in 
REM		'flXHR-compile.xml' and Adobe's 'mxmlc' compiler (3.1.0), obtained as part of the Flex Builder SDK,
REM		from: http://www.adobe.com/products/flex/flexdownloads/
REM
REM		====================================================================================================

ECHO Compiling flXHR.swf...
del flXHR.swf 1>nul 2>&1
mxmlc -load-config=flXHR-compile.xml Main.as
echo Done, press any key...
pause > nul