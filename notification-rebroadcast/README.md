Cordova Notification Rebroadcast Plugin
======

See [CB-8475](https://issues.apache.org/jira/browse/CB-8475). This plugin rebroadcasts remote push notifications as well as local notifications to other plugins.

Install:

        cordova plugin add https://github.com/apache/cordova-plugins.git#master:notification-rebroadcast

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
