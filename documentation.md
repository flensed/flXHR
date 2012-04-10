Browser/Platform Testing

A new test-suite tool is available for more consistent testing of CheckPlayer and flXHR in various browser environments. It runs each library through all of their demo examples. This is a great way to easily cycle through the examples and verify flensed projects working in your specific environment.

The latest releases of flensedCore, CheckPlayer, and flXHR have been fully tested with the following browser/platform combinations (and Flash Player plugin versions 9.0.124 and 10.0.12.36), with test failures footnoted in ( ) after each:

    Windows 2k/XP: IE6, IE7, IE8b2, FF1.5, FF2, FF3, SF3.1, OP9.64(*), OP10.0:rc1, NS8.1(**), NS9, Chr3.0
    Windows Vista: IE7, IE8b2(***), Chr3.0
    OSX 10.4: SF2(X), FF2
    OSX 10.5: SF3.1/Webkit, OP9.62(*), NS9, FF1.5, FF2, FF3
    Linux(Fedora4/9): FF1.5, FF2, FF3, NS9, OP9.62(*), KQ3.4(X)

(X) Fails all tests
(*) Fails some flXHR tests (silently): large responses (text and binary)
(**) Fails the flXHR test for large binary responses
(***) "Protected Mode" causes some tests to appear to misbehave (with alerts being suppressed), but the underlying code seems to still work just fine, since turning off "Protected Mode" resolves any issues seen
