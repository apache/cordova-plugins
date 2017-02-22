Cordova Notification Rebroadcast Plugin
======

See [CB-8475](https://issues.apache.org/jira/browse/CB-8475). This plugin rebroadcasts remote push notifications as well as local notifications to other plugins.

This plugin currently needs to use the `4.0.x` branch of `cordova-ios`. 

To `alpha test` this:

You may have to remove the cached 4.0.x platform:

    rm -rf ~/.cordova/lib/ios/cordova/4.0.x
        
Then:

    cordova create nrtest my.project.id nrtest
    cd nrtest
    cordova platform add ios@4.0.x --usegit
    cordova plugin add https://github.com/apache/cordova-plugins.git#master:notification-rebroadcast

Document Events
-----------

Listen for these 3 types of document events in JavaScript:

1. CDVLocalNotification

        data is a JSON object of the UILocalNotification details
    
2. CDVRemoteNotification

        data is a JSON object containing one key, "token" which is the push device token
    
3. CDVRemoteNotificationError

        data is a JSON object containing one key, "error", which is the localized error message

Usage
=====

    document.addEventListener('CDVLocalNotification', function(event) { console.log(event.data); });
    document.addEventListener('CDVRemoteNotification', function(event) { console.log(event.data.token); });
    document.addEventListener('CDVRemoteNotificationError', function(event) { console.log(event.data.error); });

Permissions
-----------

#### config.xml

        <feature name="CDVNotificationRebroadcast">
            <param name="ios-package" value="CDVNotificationRebroadcast" />
            <param name="onload" value="true" />
        </feature>

Supported Platforms
-------------------

- iOS
