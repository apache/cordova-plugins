cordova-plugin-navigation-whitelist
===================================

This plugin implements a whitelist policy for navigating the application webview on Cordova 4.0

Currently only supports the "unplug-whitelist" branch of cordova-android and cordova-ios

Usage:
  In config.xml, add `<allow-navigation>` tags, like this:

    <!-- Allow links to example.com -->
    <allow-navigation href="http://example.com/*" />

    <!-- Wildcards are allowed for the protocol, as a prefix
         to the host, or as a suffix to the path -->
    <allow-havigation href="*://*.example.com/*" />

    <!-- A wildcard can be used to whitelist the entire network,
         over HTTP and HTTPS.
         *NOT RECOMMENDED* -->
    <allow-navigation href="*" />

    <!-- The above is equivalent to these two declarations -->
    <allow-navigation href="http://*/*" />
    <allow-navigation href="https://*/*" />
