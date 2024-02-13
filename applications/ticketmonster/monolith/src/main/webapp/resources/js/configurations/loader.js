//detect the appropriate module to load
define(function () {

    /*
     A simple check on the client. For touch devices or small-resolution screens)
     show the mobile client. By enabling the mobile client on a small-resolution screen
     we allow for testing outside a mobile device (like for example the Mobile Browser
     simulator in JBoss Tools and JBoss Developer Studio).
     */

    var environment;

    if (document.URL.indexOf("mobileapp.html") > -1) {
        environment = "hybrid";
    }
    else if (Modernizr.touch || Modernizr.mq("only all and (max-width: 768px)")) {
        environment = "mobile";
    } else {
        environment = "desktop";
    }

    require([environment]);
});