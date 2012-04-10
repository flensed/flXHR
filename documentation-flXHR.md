flXHR Documentation

flXHR Integration

flXHR relies on the following files being available:

    flensedCore
    CheckPlayer
    flXHR.swf
    flXHR.vbs (only needed to emulate the binary object 'responseBody' property in IE browsers)

IMPORTANT: The download files (.zip or .tar.gz) for all flensed assets create a tiered directory structure when uncompressed which keeps all parts separated, but unzips all your assets into a single consistent directory structure (ie, "flensed-1.0/flXHR"). However, you should take the deployable build assets (from /deploy) and place them all in one single directory on your web server.

flXHR will lazy-load these assets as it needs them. However, to do so, if the files are in any other location than the relative directory of your page (like a subfolder called "js"), you need to specify a base-path URL for it to use to find these files. This is done as a script block in your HTML page *before* the flXHR library is loaded. flXHR will auto-detect the value for the base path, but certain advanced situations may require the author to manually define it as shown below.

<script type="text/javascript">var flensed={base_path:"path/to/"};</script>

Note: If specifying anything other than an empty value for this setting, make sure to end with a trailing / character.

flXHR can then be included on a page as a standard <script> tag in the HEAD of a page:

<script type="text/javascript" src="path/to/flXHR.js"></script>

Or, it can be dynamically injected with a call to document.createElement("script");.

IMPORTANT NOTE: flXHR may be used and automatically loaded by some flensed projects, so this explicit inclusion is only necessary if flXHR is the only flensed project being used on a page, or if it is otherwise not going to loaded by the flensed projects being used. Otherwise, it is best to let flXHR be automatically loaded as needed. See the project's documentation for instructions specific to that project.

A new test-suite tool is available for more consistent testing of flXHR in various browser environments. It runs the flXHR library through all of the demo examples. It's available here.

flXHR has been fully tested with a wide-range of browser/platform combinations, with passes and test failures noted here.
flXHR Feature Notes

flXHR is instantiated in a similar way to the native browser XMLHttpRequest (XHR) object. The constructor parameter can be used to configure all properties. Some must be set with the constructor, because they affect the construction of the object. However, all other properties of flXHR can be set/altered later, via the Configure() method. Also, the normal native XHR API properties can be set/altered directly on the object instance, just like with the native browser's XHR object.

Some important extensions to the normal XHR API include a 'timeout' property (configured with 'sendTimeout') and 'ontimeout' event callback (to match IE8's API additions), as well as an 'onerror' event callback. In addition, flXHR provides the Configure() method for convenience configuration, the Reset() method for resetting the internal state of the object for cleaner object re-use, and an explicit Destroy() destructor to use to manually deconstruct the object for better memory management practices.

Another extension feature for flXHR is called 'instancePooling'. This feature is designed specifically for framework integrations, where normally XHR instances are instantiated and discarded, as there is generally no noticeable memory/time penalty for doing so. However, flXHR takes more in both memory and time for each instance, and clean-up/memory release is only automatic on page unload as opposed to normal native JS object GC rules. So, to compensate for this, if 'instancePooling' is flagged on for an instance, it is kept around in a pool of instances and when a new instantiation request comes in, if any instances are already used and idle sitting in the pool, they will be re-used rather than a new instance being created. This should greatly improve time and memory efficiency with multiple flXHR instantiation usages across the lifetime of a page, especially when being used with a framework.

It should still be observed though that this only helps reduce time delay on subsequent requests. Each time a new instantiation occurs, the delay will be present. To alleviate this concern, I have presented a coding suggestion/strategy in this forum post which attempts to address that concern as it was brought forth by one of the community members using flXHR with a framework and frustrated by the delays. The strategy is simple: Just like in the old days, when image loading was slow, and javascript image pre-loading techniques were employed, to pre-fetch an image and get it in the cache of the browser to make it quicker to access. In the same way, one or more flXHR instances can be created during page load which fire off throwaway type requests, and then are just sitting there idle and ready for recycling by the "instancePooling" feature. So, later in the page's lifetime, when a framework method is called to fire off a request, it will attempt to instantiate a new flXHR instance, but it will just get handed a ready-to-go, recycled instance, and the delays will be eliminated.

The Flash Player plugin does not support synchronous communication, thus flXHR does not either, which is a departure from the native XHR object's functionality. While this is a limitation, my opinion is that this feature is not a useful one for modern client-to-server web application communication, because it locks up the browser during this communication, which is a very undesirable user experience. Synchronous communication should be avoided in web applications, and so this limitation is not considered an issue with flXHR, but a design decision which happens to correspond with a design limitation imposed by the Flash Player plugin. Web authors who think they need to use a feature like this should re-architect their user experience and use the asynchronous communication with callbacks, and choose what elements (if any) on the page should be 'disabled' while this communication sequence is occuring.

flXHR supports emulating the IE-proprietary 'responseBody' property, which is a binary representation of the response. Because Javascript is very poor at emulating or dealing with binary data types, flXHR does so with a couple of binary helper functions implemented in VBScript (in flXHR.vbs). Since this property is only supported in the IE browser, this emulation is turned off by default. If it is turned on, and the flXHR.vbs file is not available, or if it is ignored by a non-IE browser, the fall back behavior for this property is to create an array of integers which represent the 256-base ascii codes of the response. Note: This emulation conversion is not particularly efficient in processing, so it should only be turned on if specifically needed for some code-logic purpose.

If this binary object property is created (in IE only), it can be inspected/altered with Javascript's binary operators, or it can be converted back to a string using a binary helper function 'flXHR_vb_StringToBinary()'. Note: This resulting string after conversion will be identical to the responseText property that will already be returned for the response, so this conversion probably has a very limited use benefit.

flXHR supports emulating the 'responseXML' property, which is an XMLDOM node representation of the response. Since the majority of client-to-server communication generally results in XML-formed responses, and most Javascript libraries use the XML automatically, this emulation is turned on by default. However, it should be turned off if the response will instead be JSON, HTML, or plain-text, as the conversion emulation takes processing time and is likely to fail anyway if presented with non-well-formed XML.

This emulation conversion relies on the browser having XML parsing capabilities built into it. For IE, it relies on the XMLDOM ActiveX control, and for other browsers (such as Mozilla-based browsers), it relies on DOMParser(). For browsers without this support, the conversion will not occur, and the resulting property will be empty/null.

Because of restrictions imposed by the Flash Player plugin, flXHR *may* (behavior on this topic is unclear at this time) only be able to set an HTTP request header if it is *not* on the list in this article External Link. All other standard and custom HTTP headers can be set, including 'Content-Type'. Note: 'Authorization' seems to be allowed, despite being on that list, but flXHR does not currently automatically create this header for you when passing the username/password parameters to the open() function; open() currently just ignores them. Hopefully a future release of flXHR will create this 'Authorization' header for you, but will require a base64 encoder either in the Javascript or in the .swf.
flXHR Cross-domain security

IMPORTANT UPDATE: An important update to the following security information has been applied to flXHR's code base. In addition, please note this discussion where I address a recently found security hole in Adobe's Security model related to cross-domain communication.

I highly recommend understanding these issues and developing a sensible approach to your cross-domain policies *before* using flXHR in a production project.
Cross-domain security is not a particularly simple concept to wrap your brain completely around. Current browsers (prior to next-generation releases) have opted to prevent most if not all of this kind of communication in the Javascript layer to avoid malicious code injection and XSS (cross-site scripting) attacks/vulnerabilities.

However, since Flash Player has created a security model (completely implemented with 9.0.124 version of the plugin) to navigate these tricky waters, and since flXHR fully leverages this model to enable it's cross-domain communication ability, it is encumbent on a web author using flXHR to understand the issues with cross-domain communication and Adobe's model, and to properly and securely configure its usage. Like a tool with a sharp blade, it can accomplish much in the hands of an experienced knowledgable user, but it can also be very dangerous if used without proper caution and attention to detail.

In particular, flXHR allows you to specify an alternate location for the cross-domain policy (by default, "/crossdomain.xml"). However, to prevent malicious or careless policies, Adobe additionally implemented a "policy on policies" method, where the server must publish an additional policy to explicitly allow non-standard cross-domain-policy locations. This server-level policy *must* be located in the web-root "/crossdomain.xml" location, and must define which custom policy locations are valid.

It's also important to note that whatever directory level you implement your cross-domain policy file at, Flash Player will interpret this policy to apply to that level and all levels "beneath" (that is, nested in) it. In addition, unless you lock down the policy to only apply to specific remote domains, you are opening up your entire directory structure at and below the policy file to any other remote Flash Player instance which decides to target your server. For this reason, it is generally a best idea to put your cross-domain policy in a directory and at a level that exposes the least amount of your server's content as needed for your purposes.

There are many resources (print and online) which the web author can (and should) consult to help understand these complex issues, and Adobe's attempt to address them with their security model for the Flash Player. I recommend fully digesting the following articles from Adobe, here External Link, here External Link, here External Link, and here External Link.
flXHR Javascript API
Methods

    flensed.flXHR()
    open()
    send()
    abort()
    setRequestHeader()
    getResponseHeader()
    getAllResponseHeaders()
    Configure()
    Reset()
    Destroy()


Instance Properties

    instanceId
    loadPolicyURL
    noCacheHeader
    binaryResponseBody
    xmlResponseText
    readyState
    responseBody
    responseText
    responseXML
    status
    statusText
    timeout
    onreadystatechange
    onerror
    ontimeout


Static Constants (do not change)

    flensed.flXHR.HANDLER_ERROR
    flensed.flXHR.CALL_ERROR
    flensed.flXHR.TIMEOUT_ERROR
    flensed.flXHR.DEPENDENCY_ERROR
    flensed.flXHR.PLAYER_VERSION_ERROR
    flensed.flXHR.SECURITY_ERROR
    flensed.flXHR.COMMUNICATION_ERROR
    flensed.flXHR.MIN_PLAYER_VERSION


Static Functions/Properties (do not change)

    flensed.flXHR.module_ready()
    flensed.flXHR._id_counter

constructor flensed.flXHR(object configurationObject [={ }])

Creates an instance of the 'flXHR' object via the 'new' operator. The constructor takes an object as a single parameter which contains name/value pairs for object initialization configuration. All flXHR configuration properties are exposed as configurable through this constructor parameter.

The following configuration parameters can only be set in this initial constructor parameter object: 'swfIdPrefix', 'styleClass', 'appendToId', and 'autoUpdatePlayer'. These parameters can not be changed after instantiation, so a new flXHR instance would be required if a change was necessary.

Parameters
configurationObject : an object which contains name/value pairs for the configuration of flXHR in any combination and order:

    instancePooling: Boolean (true/false) that allows this instance to participate in instance-pooling reuse.
    swfIdPrefix: an optional string with a DOM id prefix to be used for the flXHR.swf object's DOM identifier property. This is mostly useful if you particularly need to control the DOM identifier namespace.
    styleClass: an optional string class name to use for the CSS styling applied to the flXHR.swf object. flXHR will still set its own values for the CSS, so this is mostly useful if you particularly need to control the CSS namespace. Defaults to "flXHRhideSwf". Note: This means that unless specified otherwise, all flXHR instances will share the same CSS style class.
    appendToId: an optional string identifier for the DOM object to hold the flXHR.swf object as its child. This is mostly useful if you need to control where the flXHR.swf is added to the DOM, for page rendering reasons. If omitted, the flXHR.swf object will be appended to the end of the BODY.
    autoUpdatePlayer: an optional boolean (which defaults to false) to control whether the underlying CheckPlayer Auto-Update functionality should be enabled, which would detect if the browser's Flash Player plugin version was at least the value of the flensed.flXHR.MIN_PLAYER_VERSION constant, and if not, initiate an update prompt to update the plugin for the user.
    instanceId: sets the value of the instanceId property.
    loadPolicyURL: sets the value of the loadPolicyURL property.
    noCacheHeader: sets the value of the noCacheHeader property.
    binaryResponseBody: sets the value of the binaryResponseBody property.
    xmlResponseText: sets the value of the xmlResponseText property.
    sendTimeout: sets the value of the timeout property.
    onreadystatechange: sets the value of the onreadystatechange property.
    onerror: sets the value of the onerror property.
    ontimeout: sets the value of the ontimeout property.

Returns
'flXHR' instance

void open(string method, string url, bool asynch [=true], string user [=""], string password [=""])

This function prepares the flXHR object to make a request connection to a server.

Parameters
method : a string with "GET" or "POST" to represent the type of request to be sent to the server. Note: "HEAD" is not supported.
url : a string representing the server URL to make the request to.
asynch : this parameter is a placeholder and is ignored by flXHR.
user : this parameter is used as the 'username' for an 'Authorization' header appended to the request.
password : this parameter is used as the 'password' for an 'Authorization' header appended to the request.
Returns
none

void send(string requestBody [=null])

This function sends the requestBody string to the server as the body of the request. It can be ommitted or set to null to force a standard empty GET/POST request.

Parameters
requestBody : an optional string of the request body to send.
Returns
none

void abort(void)

This function unconditionally aborts the currently running send/response sequence (if any), and resets the object. Note: This is *not* the same thing as calling the Reset() function, as that function calls this one in addition to other internal reset code.

Parameters
none
Returns
none

void setRequestHeader(string name, string value)

This function adds an HTTP header to the request. Note: Because of restrictions imposed by the Flash Player plugin, only a subset of standard HTTP request headers may be set, as well as *any* custom headers; others will silently be ignored. Headers specified which are not allowed, either disallowed by the Flash Player, or by the target server's cross-domain policy, will result in security sandbox errors. Refer to this article External Link for complete details.

Parameters
name : a string with the name of the HTTP request header to set.
value : a string with the value for the HTTP request header.
Returns
none

string getResponseHeader(string name)

Because the Flash Player plugin does not support retrieving response headers, this is a placeholder function, and always returns an empty string.

Parameters
name : a string with the name of the HTTP response header to retrieve.
Returns
string : empty string

array getAllResponseHeaders(void)

Because the Flash Player plugin does not support retrieving response headers, this is a placeholder function, and always returns an empty array.

Parameters
none
Returns
array : empty array

void Configure(object configurationObject)

This function can be called to change some of the configuration of the flXHR instance. All these settings changes can instead be made directly on the exposed properties of the flXHR instance, so this function is purely a convenience function for changing multiple properties at once.

Parameters
configurationObject : an object which contains name/value pairs for the configuration of flXHR in any combination and order:

    instanceId: sets the value of the instanceId property.
    loadPolicyURL: sets the value of the loadPolicyURL property.
    noCacheHeader: sets the value of the noCacheHeader property.
    binaryResponseBody: sets the value of the loadPolicyURL property.
    xmlResponseText: sets the value of the xmlResponseText property.
    sendTimeout: sets the value of the timeout property.
    onreadystatechange: sets the value of the onreadystatechange property.
    onerror: sets the value of the onerror property.
    ontimeout: sets the value of the ontimeout property.

Returns
none

void Reset(void)

Fully resets the API state of the flXHR instance, to make it cleaner for re-use. This is an optional function call, but it's good practice to call this before reusing a flXHR instance. The onreadystatechange, onerror, and ontimeout properties are *not* reset, however. Note: This call does *not* alter the instanceId property nor does it alter the basic instantiation of the object, such as the embedded flXHR.swf instance, its styling, or the plugin auto-update feature.

Parameters
none
Returns
none

void Destroy(void)

Completely deconstructs the object, releasing all events, bindings, and object references (including removing the flXHR.swf object from the DOM). This function is useful if you plan to use many different instances of flXHR at the same time and want to manage the memory usage of your page. It will be called automatically on the window.onunload() event, unless first called explicitly by your code.

Parameters
none
Returns
none

string instanceId

This property is a string containing the identifier (either author-defined or auto-generated) to be used for the flXHR instance. This id is mostly useful if you will have multiple flXHR instances with a shared set of handlers and need to determine logic based on which object is firing a particular event.

string loadPolicyURL

This property is an optional string to specify a custom URL to use for looking up the cross-domain policy External Link. If omitted, the Flash Player plugin will look for a policy file at the root of the page's domain (ie, "/crossdomain.xml"). Note: PLEASE consult the flXHR Security section above, including its article links, before using flXHR to make cross-domain calls, and especially before using this configuration parameter.

boolean noCacheHeader

This property is a boolean (which defaults to true) to control whether a 'pragma:no-cache' request header should automatically be sent with each request. The name of this property may be confusing, so to clarify, the meaning is should the "no-cache" request-header be sent. In other words, a value of 'true' sends the header, and a value of 'false' does not send it.

This auto header sending feature is an attempt to combat pesky caching issues with flash and certain browsers, and should be left to its default (true), unless you are targetting a server whose policy does not permit this header, in which case you must turn this off to succeed with the request.

Note: If you manually set a different 'pragma' header using setRequestHeader(), the automatic 'no-cache' header value will not be sent regardless of this flag state.

boolean binaryResponseBody

This property is a boolean (which defaults to false) to control whether the responseBody property should be populated with a binary representation of the response.

boolean xmlResponseText

This property is a boolean (which defaults to true) to control whether the responseXML property should be populated with the XMLDOM node representation of the response. Note: This property should probably be changed to false if the expected response from the server will not be a valid, well-formed XML document, because the conversion takes extra processing time and will fail if the response is not XML parseable.

integer readyState (read-only)

This property is an integer representing the state of a request/response sequence. It can have the following values:

    -1: Object Unitialized - This value is only present in this property until the flXHR instance has been fully initialized. API calls can still be made against the object, and will be queued until processing is ready to execute when this property has value "0".
    0: Connection Uninitialized - The open() command has not yet been called.
    1: Connection Open - The send() command has not yet been called.
    2: Request Sent - The send() command has been called.
    3: Response Receiving - Some data has been received, but is not yet available for inspection.
    4: Response Loaded - All data has been fully received and is available for inspection.

object responseBody (read-only)

This property is the binary representation of the response. It is not populated by default, but can be configured to be populated by the 'binaryResponseBody' configuration parameter. See the flXHR Feature Notes above for more information.

string responseText (read-only)

This property is the text of the response body.

object responseXML (read-only)

This property is the XMLDOC node representation of the response. It is populated by default, but can (and should) be turned off with the 'xmlResponseText' configuration parameter if the request will not result in a valid well-formed XML response (such as JSON, HTML, or text). See the flXHR Feature Notes above for more information.

integer status (read-only)

This property represents the HTTP Status Code received from the server.

string statusText (read-only)

This property represents the friendly HTTP Status Text for the HTTP Status Code received from the server.

integer timeout

This property is an integer representing the number of milliseconds to use to timeout a send/response sequence. If this omitted, it defaults to 0 and no timeout will be applied.

function onreadystatechange

This property is a function handler to receive the callback events as the 'readyState' property of the object changes during a send/response sequence. This handler is passed one parameter, which is a reference to the flXHR object instance which initiated the event.

fuction onerror

This property is a function handler to receive the callback events if any kind of error occurs during construction or usage of the flXHR object. This handler is passed one parameter, which is a reference to the flXHR object instance which initiated the event. Note: This handler (if defined) will also be called if a timeout event happens but no ontimeout handler has been defined.

fuction ontimeout

This property is a function handler to receive the callback events if a timeout event occurs during a send/response sequence. This handler is passed one parameter, which is a reference to the flXHR object instance which initiated the event.

int flensed.flXHR.HANDLER_ERROR (read-only)

This constant represents the event state when a Javascript error/exception occurs while calling one of the three author-defined callback handlers (onreadystatechange, onerror, ontimeout).

int flensed.flXHR.CALL_ERROR (read-only)

This constant represents the event state when a call to the flXHR.swf instance fails.

int flensed.flXHR.TIMEOUT_ERROR (read-only)

This constant represents the event state when a timeout event occurs during a send/response sequence and no ontimeout handler has been defined to handle the event.

int flensed.flXHR.DEPENDENCY_ERROR (read-only)

This constant represents the event state when a call to a dependent library (SWFObject or CheckPlayer) fails.

int flensed.flXHR.PLAYER_VERSION_ERROR (read-only)

This constant represents the event state when flXHR is instantiated on a page where the version check does not meet at least the value of flensed.flXHR.MIN_PLAYER_VERSION, and the autoUpdatePlayer configuration parameter was not set to true.

int flensed.flXHR.SECURITY_ERROR (read-only)

This constant represents the event state when flXHR is unable to make the request because the cross-domain policy either was not present, failed to load, or was not sufficient for the request.

int flensed.flXHR.COMMUNICATION_ERROR (read-only)

This constant represents the event state when flXHR encounters an error in the communication, such as a network issue or a server failure.

int flensed.flXHR.MIN_PLAYER_VERSION (read-only)

This constant represents the minimum version of the Flash Player plugin required for flXHR.swf to operate correctly (currently "9.0.124").

void flensed.flXHR.module_ready(void)

This stub function can be called inside a try/catch block to determine if the entire flXHR definition has been parsed. This is particularly useful when using dynamic-script-tag injection to add flXHR to a page after it's already been displayed, and then checking to see when the flXHR code is fully available.

object flensed.flXHR._id_counter (read-only)

This static property is an integer counter for the flXHR instances, starting with 1, which is used to assign the postfixes to the Id strings. You should not need to access the property, and it should not be altered.
jQuery XHR Registry plugin | 'flXHRproxy' plugin

This plugin allows an author to register a set of flXHR configuration options to be tied to each URL that will be communicated with. Typical usage might be:

jQuery.ajaxSetup({transport:'flXHRproxy'});
jQuery.flXHRproxy.registerOptions('http://www.mydomain.com/',{xmlResponseText:false...});
jQuery.flXHRproxy.registerOptions('http://rss.mydomain.com/',{xmlResponseText:true...});
...
jQuery.ajax({url:'http://www.mydomain.com/something.html'...});
...
jQuery.ajax({url:'http://rss.mydomain.com/feed.html'...});

-or-

jQuery.flXHRproxy.registerOptions('http://www.mydomain.com/',{xmlResponseText:false...});
jQuery.flXHRproxy.registerOptions('http://rss.mydomain.com/',{xmlResponseText:true...});
...
jQuery.ajax({transport:'flXHRproxy',url:'http://www.mydomain.com/something.html'...});
...
jQuery.ajax({transport:'flXHRproxy',url:'http://rss.mydomain.com/feed.html'...});

Discussion topic about 'registerOptions(...)'

Read more about the jQuery plugin

This plugin requires:

    flXHR
    jQuery 1.3.1+ External Link
    jQuery XHR Registry Plugin External Link
    jquery.flXHRproxy.js

DojoX.io | XHR Plugins extension | 'flXHRproxy' plugin

This plugin allows an author to register a set of flXHR configuration options to be tied to each URL that will be communicated with. Typical usage might be:

dojox.io.flXHRproxy.registerOptions('http://www.mydomain.com/',{xmlResponseText:false...});
dojox.io.flXHRproxy.registerOptions('http://rss.mydomain.com/',{xmlResponseText:true...});
...
dojo.xhrGet({url:'http://www.mydomain.com/something.html'...});
...
dojo.xhrGet({url:'http://rss.mydomain.com/feed.html'...});

Discussion topic about 'registerOptions(...)'

Read more about the Dojo plugin

This plugin requires:

    flXHR
    Dojo 1.3.1+ External Link, including "AdapterRegistry.js"
    DojoX.io | XHR Plugins extension External Link, including "xhrPlugins.js"
    flXHRproxy.js

Prototype 'flXHRproxy' plugin

This plugin allows an author to register a set of flXHR configuration options to be tied to each URL that will be communicated with. Typical usage might be:

Ajax.flXHRproxy.registerOptions('http://www.mydomain.com/',{xmlResponseText:false...});
Ajax.flXHRproxy.registerOptions('http://rss.mydomain.com/',{xmlResponseText:true...});
...
Ajax.Request('http://www.mydomain.com/something.html',{...});
...
Ajax.Request('http://rss.mydomain.com/feed.html',{...});

Discussion topic about 'registerOptions(...)'

Read more about the Prototype plugin

This plugin requires:

    flXHR
    Prototype 1.6.0.3+ External Link
    prototype.flXHRproxy.js

Mootools 'flXHRproxy' plugin

This plugin allows an author to register a set of flXHR configuration options to be tied to each URL that will be communicated with. Typical usage might be:

Request.flXHRproxy.registerOptions('http://www.mydomain.com/',{xmlResponseText:false...});
Request.flXHRproxy.registerOptions('http://rss.mydomain.com/',{xmlResponseText:true...});
...
var req1 = new Request({url:'http://www.mydomain.com/something.html',...});
req1.send(...);
...
var req2 = new Request({url:'http://rss.mydomain.com/feed.html',...});
req2.send(...);

Discussion topic about 'registerOptions(...)'

Read more about the Mootools plugin

This plugin requires:

    flXHR
    Mootools 1.2.3+ External Link
    moo.flXHRproxy.js


