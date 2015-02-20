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

var modulemapper = require('cordova/modulemapper');

// keep hold of notification for future use
var mozNotifications = {};
var mozNotification = modulemapper.getOriginalSymbol(window, 'window.Notification');

function makeNotification(successCB, errorCB, options) {
    var nId = options.notificationId;
    var title = options.title;
    delete options.notificationId;
    delete options.title;

    var notification = new mozNotification(title, options);
    mozNotifications[nId] = notification;
    successCB();
}

// errors currently reporting String for debug only
function create(successCB, errorCB, options) {
    console.log('FxOS DEBUG: create', options);
    successCB = (successCB) ? successCB : function() {};
    errorCB = (errorCB) ? errorCB : function() {};

    if (mozNotification.permission === 'denied') {
        errorCB('FxOS Notification: Permission denied');
        return;
    }
    if (mozNotification.permission === 'granted') {
        makeNotification(successCB, errorCB, options);
        return;
    }
    mozNotification.requestPermission(function (permission) {
        if (permission === 'granted') {
            makeNotification(successCB, errorCB, options);
        } else {
            errorCB('FxOS Notification: User denied');
        }
    });
}

function remove(successCB, errorCB, params) {
    successCB = (successCB) ? successCB : function() {};
    errorCB = (errorCB) ? errorCB : function() {};
    var nId = params.notificationId;
    mozNotifications[nId].close();
    successCB();
}


module.exports = {
    create: create,
    remove: remove
};    
    
require("cordova/exec/proxy").add("Notification", module.exports);
