org.apache.cordova.file-system-roots plugin
===========================================

This plugin grants a Cordova application access to several additional filesystem roots, and provides a cross-platform means of accessing these filesystems based on their intended purpose.

The set of available filesystems depends on the platform.

Android
-------

    - files: The application's internal file storage directory
    - files-external: The application's external file storage directory
    - sdcard: The global external file storage directory (this is the root of the SD card, if one is installed)
    - cache: The application's internal cache directory
    - cache-external: The application's external cache directory
    - root: The entire device filesystem

Android also supports a special filesystem named "documents", which represents a "/Documents/" subdirectory within the "files" filesystem.

iOS
---

    - library: The application's Library directory
    - documents: The application's Documents directory
    - cache: The application's Cache directory
    - app-bundle: The application's bundle; the location of the app itself on disk
    - root: The entire device filesystem

By default, the library and documents directories can be synced to iCloud. You can also request two additional filesystems, "library-nosync" and "documents-nosync", which represent a special non-synced directory within the Library or Documents filesystem.

Configuring the plugin
----------------------

The set of available filesystems can be configured at build time per-platform. Both iOS and Android recognize a <preference> tag in `config.xml` which names the filesystems to be installed. The defaults for these preferences, if not set, are

    <preference name="iosExtraFilesystems" value="library,library-nosync,documents,documents-nosync,cache,bundle" />

    <preference name="AndroidExtraFilesystems" value="files,files-external,documents,sdcard,cache,cache-external" />

These defaults contain all available filesystems except for "root".

Accessing the filesystems
-------------------------

The simplest method of using these new filesystems is to call `cordova.filesystem.getFilesystem` with the name of the filesystem you want to use.

    cordova.filesystem.getFilesystemRoot(filesystemName, successCallback, errorCallback);

If successful, `successCallback` will be called with a `DirectoryEntry` object representing the root of the filesystem. Otherwise, `errorCallback` will be called with a `FileError`.

It is also possible to request a `DirectoryEntry` object for a particular purpose. This provides a cross-platform way of accessing the various filesystem locations.

    cordova.filesystem.getDirectoryForPurpose(purpose, options, successCallback, failureCallback)

will call successCallback with a `DirectoryEntry` object suitable for the specified purpose.

The following string constants are defined for the `purpose` field:

    data
    documents
    cache
    temp        (returns the TEMPORARY filesystem)
    app-bundle  (iOS only)

The `options` field is an object. On iOS, it is possible to set it to `{syncable: false}` to obtain the non-synced versions of `data` or `documents`. On Android, you can set `{sandboxed: false}` to get the external (not confined to your app) versions of `data`, `documents` or `cache`.
