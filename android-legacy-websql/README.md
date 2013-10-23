Legacy WebSQL Plugin for Android
---------------------------------
This plugin provided WebSQL support on Android prior to version 3.0 and is obsoleted by [org.apache.cordova.websql](http://plugins.cordova.io/#/org.apache.cordova.websql).

To transfer data from from the old database to the new one, you need to:
1. Install both plugins
2. Open your old database via `cordova.plugins.legacySQL.openDatabase()`
3. Open your new database via `window.openDatabase()`
4. Copy data from one to the other by going through JS.

Since this is pretty annoying code to write, you might not want to use the new websql plugin for existing apps. Instead, continue to use the old one.
