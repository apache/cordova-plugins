Cordova WKWebView Engine with http server (localhost) support
======

This plugin uses the:
- [cordova-plugin-wkwebview-engine](https://git-wip-us.apache.org/repos/asf/cordova-plugin-wkwebview-engine.git) plugin
- [cordova-labs-local-webserver](https://git-wip-us.apache.org/repos/asf/cordova-plugins.git#master:local-webserver) plugin

This plugin requires at least version 4.1.0 `cordova-ios`.

To try this:

    cordova create wkwvtest my.project.id wkwvtest
    cd wkwvtest
    cordova platform add ios@4
    cordova plugin add https://github.com/apache/cordova-plugins.git#master:wkwebview-engine-localhost


Supported Platforms
-------------------

- iOS
