# CordovaLocalWebServer

This Apache Cordova plugin will install a local web server in your iOS app, and will serve the contents of your `www` directory, looking for an index page of `index.html`.

After installing the plugin, change the `src` attribute of your `<content>` tag in `config.xml`:
    
        <!-- port can be whatever you want -->
        <content src="http://localhost:8088" />
    
For the local web server to start, the url **must** be http://localhost, and you can set the port to whatever you want in the url, the local web server will use this as the port automatically.
    
Check your console log for errors in configuration. 

## Security Caveats

1. Any backgrounded app can potentially access this local web server when your app is running.
2. There may be port collisions for the local web server.

Points 1 and 2 can be solved by an enhancement to the cordova-ios source. This plugin is compatible with all 3.x releases of Cordova.
    

## Credits

The local web server implementation is from https://github.com/swisspol/GCDWebServer

To update with the latest from that repo:

        git remote add GCDWebServer https://github.com/swisspol/GCDWebServer.git
        git subtree pull --prefix=src/ios/GCDWebServer --squash GCDWebServer master