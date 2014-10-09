# CordovaLocalWebServer

This Apache Cordova plugin will install a local web server in your iOS app, and will serve the contents of your `www` directory, with an index page of `index.html`.

After installing the plugin, change the `src` attribute of your `<content>` tag in `config.xml`:
    
    <content src="http://localhost:64000" />
    

Check your console log for errors in configuration. 

You can also add this preference in `config.xml`:

    <preference name="CordovaLocalWebServerPort" src="64000" />
    
Remember to change your `config.xml` `<content>` tag `src` accordingly.

## Security Caveats

1. Any backgrounded app can potentially access this local web server when your app is running.
2. There may be port collisions for the local web server.

Points 1 and 2 can be solved by an update to cordova-ios. This plugin is compatible with all 3.x releases of Cordova that support the `<content>` tag in `config.xml`.
    

## Credits

The local web server implementation is from https://github.com/swisspol/GCDWebServer