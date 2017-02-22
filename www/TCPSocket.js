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

var cordova = require('cordova'),
    exec = require('cordova/exec');

var TCPSocket = {
    open: function(host, port, successCB, errorCB, setup) {
      setup = setup || {};
      setup.useSecureTransport = setup.useSecureTransport || false;
      setup.binaryType = setup.binaryType || 'string'; 
      options = {
        host: host,
        port: port,
        setup: setup
      }
      exec(successCB, errorCB, "TCPSocket", "open", options)
    },
    listen: function(port, successCB, errorCB, setup, queueLimit) {
      setup = setup || {};
      setup.binaryType = setup.binaryType || 'string'; 
      options = {
        port: port,
        setup: setup
      };
      if (queueLimit) {
          options.queueLimit = queueLimit;
      }
      exec(successCB, errorCB, "TCPSocket", "listen", options)
    }
}

module.exports = TCPSocket;
