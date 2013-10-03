/*
 *
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 *
*/

// WebSQL is broken only for file: URLs.
if (location.protocol == 'file:') {
    var androidVersion = /Android (\d+)/.exec(navigator.userAgent);
    // Don't apply hack for Android 2 since the native side can't override the URL loading.
    // The database isn't broken on 2 anyways.
    if (!androidVersion || +androidVersion[1] > 2) {
        var channel = require('cordova/channel');

        channel.createSticky('onWebSQLReady');
        channel.waitForInitialization('onWebSQLReady');

        channel.onCordovaReady.subscribe(function() {
            var ifr = document.createElement('iframe');
            ifr.src = "websql://foo";
            ifr.onload = function() {
                ifr.onload = null;
                openDatabase = function() {
                    return ifr.contentWindow.openDatabase.apply(ifr.contentWindow, arguments);
                };
                channel.initializationComplete('onWebSQLReady');
            };
            ifr.style.display = 'none';
            document.body.appendChild(ifr);
        });
    }
}
