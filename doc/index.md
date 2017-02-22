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

# org.apache.cordova.labs.tcpsocket

This plugin is used to run sockets

## Objects

- navigator.TCPSocket

## Methods

### navigator.TCPSocket.open

	navigator.TCPSocket.open(host, port, successCallback, errorCallback, options)


- host is a string representing the hostname of the server to connect to (it can also be its raw IP address).
- port is a umber representing the TCP port to be used by the socket (some protocols have a standard port, for example 80 for HTTP, 447 for SSL, 25 for SMTP, etc. Port numbers beyond 1024 are not assigned to any specific protocol and can be used for any purpose.)
- options is an object containing
	- useSecureTransport (Boolean) false (default)
	- binaryType (String) "string" (default) or "arrayBuffer"

an instantiation of a new TCPSocket object is returned in success callback

#### Firefox OS quirks

Only certified apps can use a port below 1024.

### navigator.TCPSocket.listen

	navigator.TCPSocket.listen(port, successCallback, errorCallback, options, queueLimit)

- port is a number representing the TCP port to be used to listen for connections. 
- options is an optional object expecting a property called binaryType which is a string that can have two possible values: string and arraybuffer. If the value is arraybuffer then the TCPSocket.send() will use ArrayBuffers and the data received from the remote connection will also be available in that format.
- queueLimit is a number representing the maximum lenght that the pending connections queue can grow.

an instantiation of a new TCPSocket object is returned in success callback

#### Firefox OS quirks

Only certified apps can use a port below 1024.

