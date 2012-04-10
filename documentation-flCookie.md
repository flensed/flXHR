flCookie Documentation

flCookie Integration

flCookie relies on the following files being available:

    flensedCore
    CheckPlayer
    flCookie.swf

IMPORTANT: The download files (.zip or .tar.gz) for all flensed assets create a tiered directory structure when uncompressed which keeps all parts separated, but unzips all your assets into a single consistent directory structure (ie, "flensed-1.0/flCookie"). However, you should take the deployable build assets (from /deploy) and place them all in one single directory on your web server.

flCookie will lazy-load these assets as it needs them. flCookie will auto-detect the value for the base path, but certain advanced situations may require the author to manually define it as shown below.

<script type="text/javascript">var flensed={base_path:"path/to/"};</script>

Note: If specifying anything other than an empty value for this setting, make sure to end with a trailing / character.

flCookie can then be included on a page as a standard <script> tag in the HEAD of a page:

<script type="text/javascript" src="path/to/flCookie.js"></script>

Or, it can be dynamically injected with a call to document.createElement("script");.

IMPORTANT NOTE: flCookie may be used and automatically loaded by some flensed projects, so this explicit inclusion is only necessary if flCookie is the only flensed project being used on a page, or if it is otherwise not going to loaded by the flensed projects being used. Otherwise, it is best to let flCookie be automatically loaded as needed. See the project's documentation for instructions specific to that project.

flCookie has been fully tested with a wide-range of browser/platform combinations, with passes and test failures noted here.
flCookie Feature Notes

This needs to be filled out. But, this email thread External Link is a good source of documentation about the project until that time.
flCookie Cross-domain security

This needs to be filled out. But, this email thread External Link is a good source of documentation about the project until that time.
flCookie Javascript API
Methods

    flensed.flCookie()
    setValue()
    getValue()
    deleteValue()
    ready()
    Destroy()


Instance Properties

    instanceId


Static Constants (do not change)

    flensed.flCookie.HANDLER_ERROR
    flensed.flCookie.CALL_ERROR
    flensed.flCookie.DEPENDENCY_ERROR
    flensed.flCookie.PLAYER_VERSION_ERROR
    flensed.flCookie.SECURITY_ERROR
    flensed.flCookie.IO_ERROR
    flensed.flCookie.MIN_PLAYER_VERSION


Static Functions/Properties (do not change)

    flensed.flCookie.module_ready()

constructor flensed.flCookie(...)

Creates an instance of the 'flCookie' object via the 'new' operator.

Parameters

Returns
'flCookie' instance

boolean setValue(string name, varies value, varies expires [=""])

This sets a variable in the cookie.

Parameters
name : a string with the name of the variable to set in the cookie.
value : a string with the value to set in the variable in the cookie.
expires : a string, number, or Date object which represents when to have this cookie's variable expire. If omitted, the variable never expires.
Returns
boolean : true/false if the set was successful or not

varies getValue(string name)

This gets a variable from the cookie.

Parameters
name : a string with the name of the variable to get from the cookie.
Returns
varies : the value of the variable from the cookie

boolean deleteValue(string name)

This deletes a variable from the cookie.

Parameters
name : a string with the name of the variable to delete from the cookie.
Returns
boolean : true/false if the delete was successful or not

boolean ready(void)

Indicates if the flCookie instance is fully initialized and ready.

Parameters
none
Returns
boolean : true/false if the flCookie instance is initialized and ready

void Destroy(void)

Completely deconstructs the object, releasing all events, bindings, and object references (including removing the flCookie.swf object from the DOM). This function is useful if you plan to use many different instances of flCookie at the same time and want to manage the memory usage of your page. It will be called automatically on the window.onunload() event, unless first called explicitly by your code.

Parameters
none
Returns
none

string instanceId

This property is a string containing the identifier (either author-defined or auto-generated) to be used for the flCookie instance. This id is mostly useful if you will have multiple flCookie instances with a shared set of handlers and need to determine logic based on which object is firing a particular event.

int flensed.flCookie.HANDLER_ERROR (read-only)

This constant represents the event state when a Javascript error/exception occurs while calling one of the two author-defined callback handlers (readyCallback, errorCallback).

int flensed.flCookie.CALL_ERROR (read-only)

This constant represents the event state when a call to the flCookie.swf instance fails.

int flensed.flCookie.DEPENDENCY_ERROR (read-only)

This constant represents the event state when a call to a dependent library (SWFObject or CheckPlayer) fails.

int flensed.flCookie.PLAYER_VERSION_ERROR (read-only)

This constant represents the event state when flCookie is instantiated on a page where the version check does not meet at least the value of flensed.flCookie.MIN_PLAYER_VERSION, and the autoUpdatePlayer configuration parameter was not set to true.

int flensed.flCookie.SECURITY_ERROR (read-only)

This constant represents the event state when flCookie is unable to set the cross-domain cookie because the cross-domain policy either was not present, failed to load, or was not sufficient for the request.

int flensed.flCookie.IO_ERROR (read-only)

This constant represents the event state when flCookie encounters an error in reading/writing the cookie, such as a storage authorization/size issue.

int flensed.flCookie.MIN_PLAYER_VERSION (read-only)

This constant represents the minimum version of the Flash Player plugin required for flCookie.swf to operate correctly (currently "9").

void flensed.flCookie.module_ready(void)

This stub function can be called inside a try/catch block to determine if the entire flCookie definition has been parsed. This is particularly useful when using dynamic-script-tag injection to add flCookie to a page after it's already been displayed, and then checking to see when the flCookie code is fully available. 
