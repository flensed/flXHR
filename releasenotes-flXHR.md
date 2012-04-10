flXHR 1.0.6 RELEASE NOTES

23 February 2011
Issue #21 fixed.
flXHR 1.0.5 RELEASE NOTES

15 January 2010
The release of jQuery 1.4 required some minor changes to how flXHR manages the public readyState property to keep flXHR working with jQuery via the jQuery.flXHRproxy plugin. If you are not using flXHR with jQuery, this update is probably not as relevant to you.
jQuery flXHRproxy plugin 1.2.2 RELEASE NOTES

25 August 2009
Reduced code size by a few bytes, in addressing a bug with Opera and the way it handled array manipulation. Now using jQuery's $.makeArray() utility function, which reliably works cross-browser.

Also, added an if-statement check to prevent calling the success handler if the jQuery framework call doesn't define one, like for instance if you use flXHR with the $.load() function which doesn't use a success handler.
flXHR 1.0.4 RELEASE NOTES

11 August 2009
This patch release addresses some minor behaviors of flXHR which are non-standard compared to the native XHR object, which created integration issues for some projects, including Strophe. The behaviors are related to the allowed values of 'readyState' property, and when the 'onreadystatechange' handler is called. In addition, the minified/compressed build-ready version of flXHR.js reduced ~0.6k, a 5% reduction!

'readyState' will now never publicly have a '-1' value (which it still keeps internally during the initial object construction phase while it queues API calls). 'onreadystatechange' will not be called on the '0' state as it was previously.
jQuery flXHRproxy plugin 1.2.1 RELEASE NOTES

10 July 2009
Better integration with the framework's error mechanism now. Preferred to use the "error" event in the $.ajax call rather than manually specifying "onerror" property of flXHR instance.

Also, improved the signature of the "success" handler. It now has a third parameter, which is the flXHR instance (XHR) object the success is in reference to. Helps identify requests and their responses to keep them in sync.
DojoX.io | XHR Plugins extension | flXHRproxy plugin 1.1 RELEASE NOTES

9 July 2009
Better integration with the framework's error mechanism now. Preferred to use the "error" event in the Xhr call rather than manually specifying "onerror" property of flXHR instance.
Prototype extension flXHRproxy plugin 1.1 RELEASE NOTES

9 July 2009
Better integration with the framework's error mechanism now. Preferred to use the "onFailure" and "onException" events rather than manually specifying "onerror" property of flXHR instance.
Mootools extension flXHRproxy plugin 1.0 RELEASE NOTES

8 July 2009
Initial release of the Mootools flXHRproxy plugin. Works the same as the other frameworks' plugins. Thanks to Zohaib (MaXPert) for helping get the initial code written!
flXHR 1.0.3.1 RELEASE NOTES

3 June 2009
This is a build-version release (sub patch level) since no flXHR code is changed, but the bundled CheckPlayer release was changed due to a CheckPlayer bug relating to auto upgrades failing to happen. This affected flXHR since the "autoUpdatePlayer" flag was essentially failing to operate correctly. All flXHR deployments should upgrade to get the latest CheckPlayer logic with the bug fixed, so that flXHR can upgrade player plugins when necessary/desired.
jQuery flXHRproxy plugin 1.1 RELEASE NOTES

2 June 2009
Issue #17 fixed.
Prototype extension flXHRproxy plugin 1.0.1 RELEASE NOTES

2 June 2009
Minor bug fix to code logic for url matching logic
Prototype extension flXHRproxy plugin 1.0 RELEASE NOTES

22 May 2009
Initial public release of Prototype plugin which registers flXHR as a transport for use with cross-domain Ajax calls.
DojoX.io | XHR Plugins extension | flXHRproxy plugin 1.0 RELEASE NOTES

10 May 2009
Initial public release of Dojo plugin which registers flXHR as a transport for use with the DojoX.io | XHR Plugins extension External Link.
jQuery flXHRproxy plugin 1.0 RELEASE NOTES

7 March 2009
Initial public release of jQuery plugin which registers flXHR as a transport for use with the XHR Registry plugin External Link.
flXHR 1.0.3 RELEASE NOTES

7 March 2009
Issue #16 fixed.
Also, some minor internal changes for efficiency and robustness.
flXHR 1.0.2 RELEASE NOTES

16 January 2009
Issue #15 fixed.
An IE bug was discovered with jQuery 1.3 External Link (unrelated to flXHR) which requires a patch to make jQuery 1.3 work inside an iframe where the iframe domain and the main page domain are different.

The bug report can be found here: http://dev.jquery.com/ticket/3898 External Link
The patch can be found here: http://dev.jquery.com/changeset/6120 External Link
A patched version of jQuery can be found here: http://flxhr.flensed.com/js/jquery-1.3.js

jQuery 1.3.1 External Link has been released and works fine inside of iframes and with flXHR.
flXHR 1.0.1 RELEASE NOTES

14 January 2009
Issue #14 fixed.
Suggestion implemented.
A few minor bug fixes, and the new configurable "noCacheHeader" boolean flag option, which controls if a 'pragma:no-cache' request header is automatically appended to all requests (defaults to 'true', as before).
flXHR 1.0 RELEASE NOTES

19 December 2008
Issue #11 fixed.
NOTE: flXHR 1.0 is only compatible with flensedCore 1.0 (or higher) and CheckPlayer 1.0 (or higher).
Significant bug fixes, code optimizations, and code compression. Also, flXHR.swf can now be open-source compiled using the Flex SDK 'mxmlc' compiler.

