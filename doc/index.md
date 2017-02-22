<!---
    Licensed to the Apache Software Foundation (ASF) under one
    or more contributor license agreements.  See the NOTICE file
    distributed with this work for additional information
    regarding copyright ownership.  The ASF licenses this file
    to you under the Apache License, Version 2.0 (the
    "License"); you may not use this file except in compliance
    with the License.  You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing,
    software distributed under the License is distributed on an
    "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
    KIND, either express or implied.  See the License for the
    specific language governing permissions and limitations
    under the License.
-->

# org.apache.cordova.labs.notification

This plugin is used to configure and display desktop notifications to the user.
It's usage for the user should 

## Objects

- Notification
- NotificationError


## Contructor

    var notification = new Notification(title, options, successCallback, errorCallback)

The `title` parameter is the title that must be shown within the notification

The `options` parameter is optional. It is an object that allows to configure 
the notification. It can have the following properties:

- dir : The direction of the notification; it can be auto, ltr, or rtl
- lang: Specify the lang used within the notification. This string must be a valid BCP 47 language tag.
- body: A string representing an extra content to display within the notification
- tag: An ID for a given notification that allows to retrieve, replace or remove it if necessary
- icon: The URL of an image to be used as an icon by the notification

## Instance methods

- Notification.close

Notification inherits from EventTarget

- Notification.addEventListener
- Notification.removeEventListener
- Notification.dispatchEvent

## Example

    var notification = new Notification('Hi There!');

One can also use success callback:

	var options = {};
	function successCallback(notification) {
		// notification is instantiated here
    };
    new Notification('Hi There!', options, successCallback);

## Events

One can listen to following events:

- close : displatched when a notification is closed (either from within the app or by closing the notification in the system
- click
- show : dispatched right after a notification is visible
- error

