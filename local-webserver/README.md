# Cordova Local WebServer

This Apache Cordova plugin will install a local web server in your iOS app, and will serve the contents of your `www` directory, looking for an index page of `index.html`.

After the plugin is installed, it changes the `config.xml` in your project root by modifying this tag to:
    
        <content src="http://localhost:0" />
    
For the local web server to start, the url **must** be http://localhost, and you can set the port to whatever you want in the url, the local web server will use this as the port automatically. `If you set the port to "0", it will select a randomized and free port.`
    
Check your console log for errors in configuration. 

### localStorage, IndexedDB persistence

If you plan on using HTML5 localStorage and/or IndexedDB, you must choose a fixed port in the `content` tag specified above. This is because of the HTML5 Origin policy (scheme, domain and port must be the same).

In the `config.xml` in your project root, change the '0' port to a number between 1 and 49152 (avoiding the ephemeral port range of 49152 to 65535 on iOS). For example:
    
        <content src="http://localhost:49000" />
    

This port number must be consistent across all app launches for saved data to be accessed.


## Security Caveats

    In order to limit access to your app, requests are restricted to localhost and are protected with an auth token.
    This should effectively restrict access to the server to your app.
    
This plugin is only compatible with the 3.7.0 release of cordova-ios, or greater.
    

## Credits

The local web server implementation is from https://github.com/swisspol/GCDWebServer

To update with the latest from that repo:

        git remote add GCDWebServer https://github.com/swisspol/GCDWebServer.git
        git subtree pull --prefix=src/ios/GCDWebServer --squash GCDWebServer master
