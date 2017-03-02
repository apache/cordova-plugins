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

var argscheck = require('cordova/argscheck'),
    utils = require('cordova/utils'),
    exec = require('cordova/exec');
   
// counter for a notification id
var nId = 0;

// This might not be the best idea
// from http://stackoverflow.com/questions/22186467/how-to-use-javascript-eventtarget

function Emitter () {
  var eventTarget = document.createDocumentFragment();

  function delegate (method) {
    this[method] = eventTarget[method].bind(eventTarget);
  }

  Emitter.methods.forEach(delegate, this);
}

Emitter.methods = ["addEventListener", "dispatchEvent", "removeEventListener"];

function Notification(title, options, successCB, errorCB) {

    options = (options) ? options : {};
    successCB = (successCB) ? successCB : function() {};
    errorCB = (errorCB) ? errorCB : function() {};

    // return object in success callback
    var self = this;
    function success() {
        successCB(self);
    }

    // add emitter methods to Notification
    Emitter.call(this);

    // set parameters
    this.title = options.title = title;
    this.dir = options.dir || null;
    this.lang = options.lang || null;
    this.body = options.dir || null;
    this.dir = options.dir || null;
    this.dir = options.dir || null;
    this.dir = options.dir || null;
    // add and store notificationId
    this._notificationId = options.notificationId = nId++;
    options.pluginObject = self;
    exec(success, errorCB, "Notification", "create", options);
}

// handling closing an event
Notification.prototype.close = function(successCB, errorCB) {
    var options = {notificationId: this._notificationId};
    exec(successCB, errorCB, "Notification", "remove", options);
};

module.exports = Notification;
