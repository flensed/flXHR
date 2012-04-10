flXHR Demos

flXHR Tutorials
Tutorial #1

This tutorial text (with step-by-step instructions and explanation) itself is still being written, but the fully functioning code for the tutorial is available here.

The tutorial is a made up scenario where I wanted to have a simple photo album viewer that needed to load lists of albums and photos, and then the photos and their descriptive text, all from different server locations than where the page is being shown, which creates the cross-domain problem that flXHR so easily solves. The idea is that the album list loads on page load from an XML "POST" request. Then, clicking on an album fires another request, this time a "GET" to ask for the photos in that album, which is also returned as a simple XML document. The list of photos in the album is then shown, and clicking on any one of them makes a third request to get text-only descriptive content for the image, while the browser loads the photo from another remote location using a standard IMG tag.

This tutorial demo is INCREDIBLY bare-bones stripped down. This is intentional, so as to provide as few barriers between the reader and gaining an understanding of the main core flXHR use-case examples, avoiding (hopefully) getting mired in all the other mess of Javascript-rich pages.

For only the purposes of showing how to use flXHR, there are several functions which can basically be ignored, where all they do is standard XML traversal and DOM manipulation stuff, or other UI cleanup functionality, which is tangential to the flXHR itself, but was put in this tutorial to help make the implementation behavior a little bit cleaner. Please try not to get hung up on those types of details, but instead focus on seeing how flXHR works.

The key concepts to grab from examining the code are:

    There are two places with intentional loading failures. The album "First House" fails to load, and the "Hotel" photo inside of "Honeymoon" album fails to load. They both illustrate the handleError function being able to trap such events and respond appropriately (in this case, message to the user what failed).
    On lines 67 and 68, the "albumlistloader" flXHR instance is queued with calls to open() and send(), which will automatically be executed as soon as the flXHR instance is ready to do so. This has the effect of basically making the album list load "on page load". The other two loaders are instantiated at "page load", but they are not used until a user clicks on one of the album of photo links that are generated.
    The code has many references to a flensedCore function called 'flensed.getObjectById()', which is a cross-browser aware convenience function for grabbing a reference to a DOM object based on it's Id.
    The 'photolistloader' and 'photoloader' instances have their 'instanceId' property set on-the-fly including the item Id, when each request is made. This is so the handler function can inspect this instanceId property and know not just which instance it belongs to but which request (item) caused it as well.
    The dynamically generated links in the album and photo lists have dynamically attached events using another flensedCore function called 'flensed.bindEvent'. This function is a cross-browser script for binding an event to an object, in this case the "onclick" event to the <a> tag for each list item. Conversely, to prevent memory leaks in IE, the clearList() function does a detach of the event before removing the item from the list. Notice though that it's surrounded by a try/catch, and it only uses IE's syntax, and makes no attempt to be cross-browser safe. This is because IE is the only browser where the memory-leak in this situation would occur.
    The two main non-flXHR related functions ('buildAlbumList()' and 'buildPhotoList()'), which do XML and DOM stuff, have a special looking syntax in them related to closures and function scoping. It looks like: "(function(){ ...... })();" Explaining exactly what that is or why it's needed is beyond the scope of the tutorial, but the simple explanation is that it's a necessary syntax for creating the correct variable scoping/binding when inside a loop and creating a function reference (which in this case gets passed to bindEvent()).
    The behavior of the tutorial demo is fairly solid and straightforward, but there are some quirks and issues. However, these are not at all anything flXHR-related, but purely core Javascript'ing and user experience issues. It is left as an exercise for the reader to improve the scenario code.

Show Tutorial Demo #1
flXHR Demos
Demo #0

Ok, first, this is demo #0 because I had to add it later, and didn't want to re-number all the other demos. This demo shows the same thing as demo #1, except it illustrates the (perhaps simpler to understand) syntax of setting properties on the instantiated object rather than sending the configuration as parameters to the constructor of the instance.

Show Demo #0
Demo #1

flXHR can be instantiated during page load (in a script in the HEAD, for instance), and subsequent calls to it will be queued (if necessary) and executed once the DOM and the flXHR object are ready. This example shows usage *without* an error handler. If an error is encountered, a Javascript exception/error will be thrown instead, which your browser may or may not report, depending on your configuration settings.

Show Demo #1
Demo #2

Demo 'a' shows how flXHR can also be instantiated during page load (in a script in the HEAD, for instance), but used later, in response to a user action, for instance. This example also shows how the user can use the object more than once, and in this simple case where the configuration doesn't change between requests, there is no need to even reset the object. This example also defines an error handler in case an error occurs.

Demo 'b' shows how flXHR does server policy checking for cross-domain communication. The two links for 'b' below load the same demo but with a different main URL domain (page-domain), which triggers either the communication to be authorized or blocked, according to the remote server policy. More detailed information on flXHR's cross-domain checking behavior can be found here: http://www.flensed.com/fresh/2008/08/adobe-flash-player-security-hole/

Show Demo #2a

Show Demo #2b (notice page-domain -- *won't* work)

Show Demo #2b (notice page-domain -- *will* work)

Demo #3

This example demonstrates receiving XML content as a response. Note: For display purposes, the XML string is serialized into a string, which makes it identical to the value already in responseText (so that line is commented out for easier readability).

Show Demo #3
Demo #4

This example demonstrates using a timeout value and callback handler to make sure the response doesn't take too long. In this example, the server is configured to delay it's response on every other request, so the first time will not timeout, the second will, the third won't, etc.

Show Demo #4
Demo #5

This example demonstrates using multiple instances of flXHR at the same time, with a common 'onreadystatechange' handler (and 'onerror' handler) shared between the calls. Each click fires off 3 requests to the server, which should come back roughly (though not always) in that order (though depending on your browser you may be limited to 2 simultaneous requests, which may slightly delay the third response).

Show Demo #5
Demo #6

This example demonstrates flXHR with a "GET" method instead of a "POST". Notice this type of request must be encoded with valid GET style parameters as the 'requestBody'.

Show Demo #6
Third-party Library/Framework Adapter and Integration demos (Dojo, Prototype, YUI, ExtJS, and jQuery)
Demo #7

These examples demonstrate a very basic proof-of-concept of how to adapt various JS frameworks to use flXHR instead of its other XHR (and workaround) methods. The basic concept is that each framework has a "factory" function which gives it a new XHR object to use for each request. If you overwrite the default method with a function that instead instantiates a new flXHR object (or returns an existing reusable one) each time, then the framework will not know the difference, because flXHR is compatible with the native XHR API. These examples are by no means a "best practice" on how to integrate flXHR with various frameworks, as there may be other efficient ways of accomplishing the integration tasks.

Note: flXHR does experience a slight (~1-2 sec) time delay from the first time you instantiate it to when the full object is ready to fire off a request. This time includes the processing to embed the flXHR.swf invisible proxy file, and get all the wrapper javascript ready to go. Each *new* instance will experience a similar delay, so the "instancePooling" feature was conceived, especially for the case where a JS framework is being adapted to use flXHR where those frameworks always create a new instance for each request and then throw it away when done. What "instancePooling" does is cause flXHR to hold onto an internal reference to each instance that the feature is enabled for, and when later requests are made to instantiate new flXHR instances, if a suitable instance is sitting around idle (meaning, already used at least once), then it can simply be recycled and used for that request, thereby eliminating the painful time delay of instantiation.

It should still be observed though that this only helps reduce time delay on subsequent requests. Each time a new instantiation occurs, the delay will be present. To alleviate this concern, I have presented a coding suggestion/strategy in this forum post which attempts to address that concern as it was brought forth by one of the community members using flXHR with a framework and frustrated by the delays. The strategy is simple: Just like in the old days, when image loading was slow, and javascript image pre-loading techniques were employed, to pre-fetch an image and get it in the cache of the browser to make it quicker to access. In the same way, one or more flXHR instances can be created during page load which fire off throwaway type requests, and then are just sitting there idle and ready for recycling by the "instancePooling" feature. So, later in the page's lifetime, when a framework method is called to fire off a request, it will attempt to instantiate a new flXHR instance, but it will just get handed a ready-to-go, recycled instance, and the delays will be eliminated.

Notice a few things about the code examples:

    All examples demonstrate a new flXHR feature called 'instancePooling'. This feature is designed specifically for framework integrations, where normally XHR instances are instantiated and discarded, as there is generally no noticeable memory/time penalty for doing so. However, flXHR takes more in both memory and time for each instance, and clean-up/memory release is only automatic on page unload as opposed to normal native JS object GC rules. So, to compensate for this, if 'instancePooling' is flagged on for an instance, it is kept around in a pool of instances and when a new instantiation request comes in, if any instances are already used and idle sitting in the pool, they will be re-used rather than a new instance being created. This should greatly improve time and memory efficiency with multiple flXHR instantiation usages across the lifetime of a page, especially when being used with a framework.
    To better demonstrate the 'instancePooling' feature, these demos are set up to instantiate twice as many instances/requests on each click as the previous click (ie, 1, 2, 4, 8, etc). You should notice by the id's of the instances that previous instances are re-used with each new click, which in general means they should be fired off and response returned quicker than the new instances.
    Demo 'a' shows integration with Dojo framework. IMPORTANT: This demo requires at least Dojo 1.3.1.

    This demo shows the use of the DojoX.io | XHR Plugins extension | flXHRproxy plugin.
    Demo 'b' shows integration with Prototype framework. Important: You'll want to make sure to use the Javascript escape() function (or some equivalent) around any data you send to POST or GET requests, as the Prototype library seems to choke on non-properly encoded free form string data (with spaces, hash characters, etc).

    This demo shows the use of the Prototype extension plugin flXHRproxy.
    Demo 'c' shows integration with YUI framework.
    Demo 'd' shows integration with ExtJS framework.
    Demo 'e' shows integration with jQuery framework. IMPORTANT: This demo requires at least jQuery 1.3.1.

    This demo shows the use of the new flXHRproxy plugin for the jQuery XHR Registry.
    Demo 'f' actually shows overwriting the native XHR object (or ActiveX object in the case of IE). This method is probably the best option if the framework you are choosing to try and integrate flXHR with is for some reason not able to provide an easy way to override the transport layer with a flXHR instance. All the framework examples shown previously could have been done like this, but those frameworks had a slightly more direct (and hopefully better) way of doing the adaptation, so they are probably the better approach. Two examples of frameworks where no easy way to override the factory XHR creation is evident would be the ASP.NET Ajax library, and the DWR framework External Link.
    Demo 'g' shows integration with Mootools framework. IMPORTANT: This demo requires at least Mootools 1.2.3.

    This demo shows the use of the new flXHRproxy plugin for the Mootools framework.

Show Demo #7a

Show Demo #7b

Show Demo #7c

Show Demo #7d

Show Demo #7e

Show Demo #7f

Show Demo #7g

Demo #8

These examples demonstrate some miscellaneous response types. Demo #8a demonstrates a JSON response type which is eval'd. Demo #8b demonstrates text responses, one small and one large (> 65k), each either transported as text, or binary converted to text.

Show Demo #8a

Show Demo #8b
