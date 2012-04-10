CheckPlayer Demos
Demo #1

CheckPlayer can be instantiated with a version, autoUpdate, and no callbacks, to create the simplest approach to verifying minimum plugin version and updating if need be.

If you visit this page from a browser that has no Flash Player plugin installed, and click the button, it will say the version check failed. If you visit it with a plugin version less than 6.0.65, it will also say the version check failed. If you visit the page from a browser with at least version 6.0.65, but less than 9.0.115 (what the demo checks for), you will be prompted to update the plugin. If you visit the page with at least version 9.0.115, and click the button, it will say the version check passed.

Show Demo #1
Demo #2

CheckPlayer can be instantiated with a check status callback, but no autoUpdate, which allows your code to programmatically (as opposed to waiting for use action) respond to the event that the check passed or failed.

This demo illustrates how the checkCB function can be used to automatically initiate an update in a similar way to passing a 'true' value for the autoUpdate parameter. The same behavior as Demo #1 should apply depending on plugin version when you visit this page.

Show Demo #2
Demo #3

CheckPlayer can be instantiated with a check status callback and an update status callback. Both callbacks respond accordingly based on the status detected for each "event" stage.

This demo illustrates how the updateCB function can be used to apply CSS styling changes to the Update SWF container.

Note: Notice how clicking the button subsequent times results in no further action, because the singleton object has already performed its duty and doesn't get re-instantiated subsequent times.

Show Demo #3
Demo #4

CheckPlayer will queue calls to DoSWF() until the version check passes and the library is ready.

Show Demo #4
Demo #5

This demo illustrates the same behavior as Demo #4, but with no queue'd call to DoSWF(), but instead it is called from the checkCB() callback if the version check passes.

Show Demo #5
Demo #6

These demos illustrate the 'targetElem' parameter (formerly 'replaceElemIdStr') to DoSWF, the callback functionality, and the SWFObject "Alternate Content" functionality, which replaces the alternate content with the SWF.

Demo 'a' shows the simple, legacy SWFObject 2.1 syntax for the second parameter, which is a string with the Id of the DOM object to replace with the SWF.

Demo 'b' shows an alternate syntax for the behavior of demo 'a', with an object and a key called 'replaceId' with the string as the Id of the DOM object to replace with the SWF.

Demo 'c' shows an extension syntax for the second parameter, which is a string with the Id of the DOM object to append the SWF as a child to.

Demo 'd' shows passing 'false' (or 'null') for the second parameter, so that CheckPlayer adds a new DOM object onto the end of the BODY.

Note: To prevent any flicker effect where the "Alternate Content" is shown briefly before being replaced, this demo shows how the alternate content can initially be hidden, and then shown only if the SWF fails to load, according to the callbacks. You can test this by saying "No" to the question of if you want to install the update. Also, the DoSWFCB() shows the flash content once the SWF content starts loading (so as to make your SWF preloader visible, for instance), and it displays an alert when it completes.

Show Demo #6a

Show Demo #6b

Show Demo #6c

Show Demo #6d

Demo #7

These demos illustrate the 'options' parameter (formerly 'DoSWFCallback') to DoSWF.

Demo 'a' shows the 'swfCB' property, which is the callback that will receive the status event notifications during SWF embedding.

Demo 'b' shows the 'swfTimeout' property, which specifies a number of milliseconds (in this demo, only 1, to ensure it fires) to wait after starting the SWF embed for it to start downloading. When the timeout fires, the swfCB callback is notified with the SWF_TIMEOUT event status value.

Demo 'c' shows the 'swfEICheck' property, which specifies the name (string value) of an ExternalInterface callback function to check for on the loaded SWF. The swfCB callback is notified when this function is detected and ready, and in this demo, it shows the function responding to this event by calling the EI function on the SWF knowing for sure that it's initialized and ready to be called.

Show Demo #7a

Show Demo #7b

Show Demo #7c
