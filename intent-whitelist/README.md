cordova-plugin-intent-whitelist
===============================

This plugin implements a whitelist policy for firing external intents on Cordova 4.0

Currently only supports the "unplug-whitelist" branch of cordova-android and cordova-ios

Usage:
  In config.xml, add `<allow-intent>` tags, like this:

    <!-- Allow links to example.com to open in a browser -->
    <allow-intent href="http://example.com/*" />

    <!-- Wildcards are allowed for the protocol, as a prefix
         to the host, or as a suffix to the path -->
    <allow-intent href="*://*.example.com/*" />

  On Android, intent urls will launch external applications, if allowed
  by the `<allow-intent>` tags. For example:

    <!-- Allow SMS links to open messaging app -->
    <allow-intent href="sms:*" />

    <!-- Allow tel: links to open the dialer -->
    <allow-intent href="tel:*" />

    <!-- Allow geo: links to open maps -->
    <allow-intent href="geo:*" />

    <!-- Allow all unrecognized URLs to open installed apps
         *NOT RECOMMENDED* -->
    <allow-intent href="*" />
