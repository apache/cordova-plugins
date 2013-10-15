WebSQL Plugin for Android
-------------------------------

Adds WebSQL support on Android.

* iOS supports WebSQL out of the box.
* Android supports it as well, but needs a hack (provided by this plugin) for 3.0+

Caveats
----------------
* Only a single call to openDatabase is allowed or an exception is thrown.
* You must never change the name of your database or an exception is thrown.
* The plugin creates a hidden iframe in the DOM. It must not be removed or the database callbacks will stop being called.

