Cross-Domain Ajax with Flash, not Ajax vs. Flash

flXHR [flĕkʹsər],(flex-er) is a *client-based* cross-browser, XHR-compatible tool for cross-domain Ajax (Flash) communication. It utilizes an invisible flXHR.swf instance that acts as sort of a client-side proxy for requests, combined with a Javascript object/module wrapper that exposes an identical interface to the native XMLHttpRequest (XHR) browser object, with a few helpful additions and a couple of minor limitations (see the documentation for more details).

flXHR requires plugin v9.0.124 for security reasons. See the documentation for a configuration flag "autoUpdatePlayer" which will attempt to automatically inline update the plugin if need be.

The result is that flXHR can be used as a drop-in replacement for XHR based Ajax, giving you consistent, secure, efficient cross-domain client-to-server cross-domain Ajax communication, without messy workarounds such as IFRAME proxies, dynamic script tags, or server-side proxying.

flXHR brings a whole new world of cross-domain Ajax and API-consistency to any browser with Javascript and Flash Player plugin v9+ support (Adobe claims Flash has 99% browser support now External Link). No other methods or workarounds can claim that kind of wide-spread support or consistency. In addition, flXHR boasts the ability to be dropped-in to many different Javascript frameworks (Dojo, Prototype, jQuery, etc) for even easier and more robust Ajax usage.

Here's a brief overview of flXHR's capability compared to other Flash-Ajax solutions:
Feature	flXHR	Fjax	SWFHttpRequest	FlashXMLHttpRequest	F4A
cross-domain communication 	X 	X(1) 	X(1) 	X(1) 	X(1)
automatic SWF embed 	X 	X(2) 	-- 	X(2) 	X(2)
native XHR API compatible 	X 	-- 	-- 	-- 	--
easily integrated with JS frameworks 	X 	-- 	X(4) 	X(4) 	X(4)
Flash plugin version compatible (3) 	9.0.124+ 	6+ 	9+ 	6+ 	8+
Flash plugin auto-update 	X 	-- 	-- 	-- 	--
XHR API extensions, like robust error-callbacks, timeouts, etc 	X 	-- 	-- 	-- 	--

(1) Does not allow any other cross-domain policy besides the root /crossdomain.xml, which makes it less flexible and thus less secure than flXHR.
(2) These libraries use more primitive, less mature/stable solutions, compared to flXHR's use of SWFObject 2.1 library.
(3) It may seem like a benefit to have more backwards-compatibility, but actually, since the later plugins have had better security and better communication efficiency, the later the plugin version leveraged, the better the solution will ultimately be. flXHR is the only one to specifically leverage the full security model just implemented with the 9.0.124 plugin release.
(4) While these solutions can be integrated with some frameworks under special circumstances, they each have limitations which will prevent this consistently from working in all frameworks, all browsers, and in all circumstances. flXHR is much more robust, and will work under any number of circumstances and with virtually any JS framework which is already XHR-aware.

Here's a brief overview of flXHR's capability compared to XHR and other non-flash client-side cross-domain workarounds:
Feature	flXHR	XHR	IFRAME	<SCRIPT>
interoperable with major Javascript frameworks 	X 	X 	X(1) 	X(1)
cross-domain requests 	X 	X(2) 	X 	X
--> robust author/server security authorization 	X 	-- 	-- 	--
--> consistent cross-browser usage 	X 	-- 	-- 	--
response event driven (readyState, etc) 	X 	X 	-- 	X(3)
response content-type agnostic 	X 	X 	X 	--
callback error handling 	X 	-- 	-- 	--
timeout event handling 	X 	X(4) 	-- 	--
robust memory management compatible 	X 	X 	-- 	--

(1) Depending on framework, these methods may or may not be implemented.
(2) XHR in the new FF3/IE8 generation will support this, but the implementation and usage details are not going to be consistent, which will require custom browser-dependent code to create a consistent usage interface. It's not supported natively at all prior to the next-gen browsers.
(3) Depending on the type and style of content sent back from the server, the eval()'d Javascript/JSON code can set itself to automatically execute once it fully loads, simulating the response event-driven behavior.
(4) IE8 has announced support for the timeout event and ontimeout handler. Unknown support for FF3. Not supported directly (that is, without custom code logic around it) in any other browsers.

As you can see, for the most part, flXHR implements an XHR API-compatible interface with a pile of extra/enhanced functionality, including most notably, direct non-proxy'd cross-domain client-to-server communication. 
