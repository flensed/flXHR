CheckPlayer Integration

CheckPlayer relies on the following files being available:

    flensedCore
    swfobject.js (SWFObject 2.1)
    updateplayer.swf (if an auto-update is to occur)

IMPORTANT: The download files (.zip or .tar.gz) for all flensed assets create a tiered directory structure when uncompressed which keeps all parts separated, but unzips all your assets into a single consistent directory structure (ie, "flensed-1.0/CheckPlayer"). However, you should take the deployable build assets (from /deploy) and place them all in one single directory on your web server.

CheckPlayer will lazy-load these assets as it needs them. However, to do so, if the files are in any other location than the relative directory of your page (like a subfolder called "js"), you need to specify a base-path URL for it to use to find these files. This is done as a script block in your HTML page *before* the CheckPlayer library is loaded. CheckPlayer will auto-detect the value for the base path, but certain advanced situations may require the author to manually define it as shown below.

<script type="text/javascript">var flensed={base_path:"path/to/"};</script>

Note: If specifying anything other than an empty value for this setting, make sure to end with a trailing / character.

CheckPlayer can then be included on a page as a standard <script> tag in the HEAD of a page:

<script type="text/javascript" src="path/to/checkplayer.js"></script>

Or, it can be dynamically injected with a call to document.createElement("script");.

IMPORTANT NOTE: CheckPlayer will be automatically loaded by all other flensed projects, so this explicit inclusion is only necessary if CheckPlayer is the only flensed project being used on a page. Otherwise, follow that project's documentation for instructions specific to that project.

A new test-suite tool is available for more consistent testing of CheckPlayer in various browser environments. It runs the CheckPlayer library through all of the demo examples. It's available here.

CheckPlayer has been fully tested with a wide-range of browser/platform combinations, with passes and test failures noted here.
CheckPlayer Feature Notes

CheckPlayer has 3 main functionalities:

    Flash Player plugin version check
    Inline plugin update - "UpdatePlayer()"
    Easy, anytime, anywhere dynamic embedding of SWF assets - "DoSWF()"

For all 3 functionalities, CheckPlayer implements the helpful feature of having status callback event handling, meaning the author can have functions that are notified of the different status progress events as those 3 functionalities are executed. Especially helpful is the callback mechanism for the DoSWF() embedding, which allows an author to know when a SWF begins downloading, progress as it goes along, when it completes downloading, and even when the ExternalInterface callbacks are initialized and ready.
CheckPlayer Javascript API
Methods

    flensed.checkplayer()
    UpdatePlayer()
    DoSWF()
    ready()


Instance Properties

    playerVersionDetected
    versionChecked
    checkPassed
    updateable
    updateStatus
    updateControlsContainer


Static Constants (do not change)

    flensed.checkplayer.UPDATE_INIT
    flensed.checkplayer.UPDATE_SUCCESSFUL
    flensed.checkplayer.UPDATE_CANCELED
    flensed.checkplayer.UPDATE_FAILED
    flensed.checkplayer.SWF_INIT
    flensed.checkplayer.SWF_LOADING
    flensed.checkplayer.SWF_LOADED
    flensed.checkplayer.SWF_FAILED
    flensed.checkplayer.SWF_TIMEOUT
    flensed.checkplayer.SWF_EI_READY


Static Functions/Properties (do not change)

    flensed.checkplayer.module_ready()
    flensed.checkplayer._instance

constructor flensed.checkplayer(string playerVersionCheck [='0.0.0'], function checkCallback [=null], bool autoUpdate [=false], function updateCallback [=null])

Instantiates the 'checkplayer' library via the 'new' operator. 'checkplayer' is a singleton object External Link, meaning that it restricts itself to only one actual instantiation per page. Subsequent calls to instantiate the library will just return a reference to the existing reference. Note: Parameters passed to subsequent instantiation calls will silently be discarded when the singleton instance is returned.

Parameters
playerVersionCheck : a string representing the 3-part (Major.Minor.Build) version string for the Flash Player version, to check as a minimum requirement for the page's SWF assets.
checkCallback : a function callback reference to be called when the version check is complete. This callback will receive a single parameter, a reference to the 'checkplayer' instance, which has properties that represent the status of the version check.
autoUpdate : if true, and the version check fails to meet the minimum as specified to the constuctor, UpdatePlayer() will automatically be called.
updateCallback : a function callback reference to be called at the stages of inline Flash Player plugin update. This callback will receive a single parameter, a reference to the 'checkplayer' instance, which has properties that represent the status of the update process (INIT, SUCCESSFUL, FAILED, and CANCELED), as well as a reference to the container of the AutoUpdate SWF, for custom CSS styling. Note: If an error occurs in the update process, but no updateCallback handler has been defined, a Javascript error will be thrown.
Returns
'checkplayer' singleton instance

void UpdatePlayer(void)

Initializes the inline Player update process. UpdatePlayer() will only proceed if Flash Player version 6.0.65+ is detected, otherwise it will trigger a FAILED update status call (or error -- see above).

Parameters
none
Returns
none

void DoSWF(string swfUrlStr, mixed targetElem, string width, string height, object flashvars [=null], object params [=null], object attributes [=null], function DoSWFCallback)

This function corresponds closely to the SWFObject embedSWF() function, in that all of its parameters are the same for this function, except that DoSWF() adds one additional *optional* parameter (DoSWFCallback), and some alternate behavior. The DoSWFCallback is called with the status stages of the SWF embed process, including a '100% LOADED' status. In addition, DoSWF() queues any requests made to it until the Library is ready (DOM Inspection is complete). In this way, DoSWF() can be called at any point in the page lifespan, before or after the DOM loads. For further information on these parameters, see the SWFObject API External Link.

Parameters
swfUrlStr : a string representing the path and/or filename of the SWF file to embed.
targetElem : (formerly the SWFObject 'replaceElemIdStr') Either a string, or an object with a single named key ('replaceId' or 'appendToId'). Also, a boolean false or 'null' value may be passed, to create a new auto-generated Id container element. The string value is the Id to either replace, append to, or create the container of the SWF with. The 'replace' functionality corresponds to SWFObject's concept of "Alternate Content", where the content of this replaceable element is only shown if the SWF fails to load and replace it.
width : a string representing the whole number width (measured in pixels) of the SWF, without unit specifier.
height : a string representing the whole number height (measured in pixels) of the SWF, without unit specifier.
flashvars : an object that specifies the 'flashvars' as name:value pairs to pass to the SWF.
params : an object that specifies the object element 'params' as name:value pairs to pass to the SWF.
attributes : an object that specifies the DOM object's additional 'attributes' as name:value pairs.
options : an object that specifies one or more of the following optional SWF embed features:

    swfCB: a function callback reference to be called at the various stages of SWF embedding. This callback will receive a single parameter, an object which contains the status code (INIT, LOADING, LOADED, FAILED, TIMEOUT, EI_READY), the 'id' of the SWF, and a reference to the SWF object.
    swfTimeout: a numeric value representing the number of milliseconds to wait for a SWF to begin downloading before cancelling and timing out the load. If the timeout occurs, and a swfCB callback is defined, it will be notified with a SWF_TIMEOUT status value.
    swfEICheck: a string value with the name of a ExternalInterface function callback to test for on the loaded SWF. Once the specified function is detected and ready, the swfCB callback, if defined, will be notified with a SWF_EI_READY status value.

Returns
none

boolean ready(void)

Returns a boolean indicating if CheckPlayer is ready to go or is still constructing and instantiating.

Parameters
none
Returns
boolean : true if CheckPlayer is fully instantiated and ready to go, false otherwise.

string playerVersionDetected (read-only)

This property is assigned the string version (Major.Minor.Build) for the Flash Player plugin detected, or '0.0.0' if undetected.

string versionChecked (read-only)

This property is the value of the version string to check, as specified by the 'checkplayer' constructor call.

bool checkpassed (read-only)

This property is true if the minimum version check passes, false otherwise.

bool updateable (read-only)

This property is true if the Flash Player plugin is detected as updateable (that is, at least version 6.0.65+).

string updateStatus (read-only)

This property is assigned the value of one of the four constants (UPDATE_INIT, UPDATE_SUCCESSFUL, UPDATE_CANCELED, or UPDATE_FAILED) before a callback is made to the updateCallback (if defined).

object updateControlsContainer (read-only)

This property is a reference to the automatically created container object (div) that holds the Update SWF. The purpose of this property is to provide the calling code with the ability to override the DOM position or CSS styling of the surrounding container of the Update SWF. Note: For best results, the updateControlsContainer is initially hidden (display:none) when passed with the UPDATE_INIT event status, which is when the author should override it's position or CSS style, before the Update SWF has finished loading and taken over, rather than during any later events. Note 2: The updateControlsContainer (and thus the Update SWF) will be hidden automatically when the update succeeds, fails, or is canceled by the user.

int flensed.checkplayer.UPDATE_INIT (read-only)

This constant represents the event state when the Update SWF and its container are first added to the page and handed to the author for CSS styling. After this callback event is handled, the container will be displayed and the user will be prompted with the yes/cancel question of if they want to upgrade.

int flensed.checkplayer.UPDATE_SUCCESSFUL (read-only)

This constant represents the event state when the Update SWF completes its update of the player, and must restart the browser. Note: For user experience sake, the author may want to automatically close the browser window for the user at this event, as the plugin updater doesn't automatically, but instead prompts the user to do so and click "Try Again".

int flensed.checkplayer.UPDATE_CANCELED (read-only)

This constant represents the event state when the user responds to the "Upgrade?" question with a no/cancel.

int flensed.checkplayer.UPDATE_FAILED (read-only)

This constant represents the event state when the Update SWF fails to complete for any reason.

int flensed.checkplayer.SWF_INIT (read-only)

This constant represents the event state when the SWF is successfully added to the page.

int flensed.checkplayer.SWF_LOADING (read-only)

This constant represents the event state when the SWF has begun loading.

int flensed.checkplayer.SWF_LOADED (read-only)

This constant represents the event state when the SWF has loaded 100%.

int flensed.checkplayer.SWF_FAILED (read-only)

This constant represents the event state when the SWF fails to be added to the page.

int flensed.checkplayer.SWF_TIMEOUT (read-only)

This constant represents the event state when the SWF fails to begin downloading within a specified interval of time.

int flensed.checkplayer.SWF_EI_READY (read-only)

This constant represents the event state when the SWF is loaded and additionally the specified ExternalInterface callback function is detected and ready.

void flensed.checkplayer.module_ready(void)

This stub function can be called inside a try/catch block to determine if the entire CheckPlayer definition has been parsed.

object flensed.checkplayer._instance (read-only)

This static property is a reference to the instantiated singleton object for 'checkplayer', if it exists yet.

