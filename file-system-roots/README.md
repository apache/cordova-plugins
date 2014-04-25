org.apache.cordova.file-system-roots plugin
===========================================

This plugin provides getters for important filesystem locations (based on OS).

The simplest method of using these new filesystems is to call `cordova.filesystem.getFileSystemRoot` with the name of the filesystem you want to use.

    cordova.filesystem.getFileSystemRoot(fileSystemName, successCallback, errorCallback);

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

The `options` field is an object. On iOS, it is possible to set it to
`{syncable: false}` to obtain the non-synced versions of `data` or `documents`.
On Android, you can set `{sandboxed: false}` to get the external (not confined
to your app) versions of `data`, `documents` or `cache`.
