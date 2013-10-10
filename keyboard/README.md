Keyboard
======

> The `Keyboard` object provides some functions to customize the iOS keyboard.

This plugin has only been tested in Cordova 3.2 or greater, and its use in previous Cordova versions is not recommended (potential conflict with keyboard customization code present in the core in previous Cordova versions). 

If you do use this plugin in an older Cordova version (again, not recommended), you have to make sure the HideKeyboardFormAccessoryBar and KeyboardShrinksView preference values are *always* false, and only use the API functions to turn things on/off.

This plugin supports the __HideKeyboardFormAccessoryBar__ (boolean) and __KeyboardShrinksView__ (boolean) preferences in config.xml.

Methods
-------

- Keyboard.shrinkView
- Keyboard.hideFormAccessoryBar
- Keyboard.disableScrollingInShrinkView

Properties
--------

- Keyboard.isVisible


Permissions
-----------

#### config.xml

            <feature name="Keyboard">
                <param name="ios-package" value="CDVKeyboard" onload="true" />
            </feature>

Keyboard.shrinkView
=================

Shrink the WebView when the keyboard comes up.

    Keyboard.shrinkView(true);

Description
-----------

Set to true to shrink the WebView when the keyboard comes up. The WebView shrinks instead of the viewport shrinking and the page scrollable. This applies to apps that position their elements relative to the bottom of the WebView. This is the default behaviour on Android, and makes a lot of sense when building apps as opposed to webpages.


Supported Platforms
-------------------

- iOS

Quick Example
-------------

    Keyboard.shrinkView(true);
    Keyboard.shrinkView(false);

Keyboard.hideFormAccessoryBar
=================

Hide the keyboard toolbar.

    Keyboard.hideFormAccessoryBar(true);

Description
-----------

Set to true to hide the additional toolbar that is on top of the keyboard. This toolbar features the Prev, Next, and Done buttons.


Supported Platforms
-------------------

- iOS

Quick Example
-------------

    Keyboard.hideFormAccessoryBar(true);
    Keyboard.hideFormAccessoryBar(false);


Keyboard.disableScrollingInShrinkView
=================

Disable scrolling when the the WebView is shrunk.

    Keyboard.disableScrollingInShrinkView(true);

Description
-----------

Set to true to disable scrolling when the WebView is shrunk.


Supported Platforms
-------------------

- iOS

Quick Example
-------------

    Keyboard.disableScrollingInShrinkView(true);
    Keyboard.disableScrollingInShrinkView(false);

Keyboard.isVisible
=================

Determine if the keyboard is visible.

    if (Keyboard.isVisible) {
    	// do something
    }

Description
-----------

Read this property to determine if the keyboard is visible.


Supported Platforms
-------------------

- iOS

    