/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 *
*/
package org.apache.cordova.filesystemroots;

import android.app.Activity;
import android.content.Context;
import android.os.Environment;
import android.util.Log;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaArgs;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CordovaWebView;
import org.apache.cordova.file.FileUtils;
import org.apache.cordova.file.LocalFilesystem;
import org.json.JSONException;

import java.io.File;
import java.util.HashMap;
import java.util.HashSet;

public class FileSystemRoots extends CordovaPlugin {
    private static final int PURPOSE_DATA = 0;
    private static final int PURPOSE_DOCUMENTS = 1;
    private static final int PURPOSE_CACHE = 2;
    private static final int PURPOSE_TEMP = 3;
    private static final String TAG = "file-system-roots";

    private HashSet<String> installedFilesystems;
    private HashMap<String, String> availableFilesystems;

    @Override
    public void initialize(CordovaInterface cordova, CordovaWebView webView) {
        super.initialize(cordova, webView);

        Activity activity = cordova.getActivity();
        Context context = activity.getApplicationContext();

        availableFilesystems = new HashMap<String,String>();
        availableFilesystems.put("files", context.getFilesDir().getAbsolutePath());
        availableFilesystems.put("files-external", context.getExternalFilesDir(null).getAbsolutePath());
        availableFilesystems.put("documents", new File(context.getFilesDir(), "Documents").getAbsolutePath());
        availableFilesystems.put("sdcard", Environment.getExternalStorageDirectory().getAbsolutePath());
        availableFilesystems.put("cache", context.getCacheDir().getAbsolutePath());
        availableFilesystems.put("cache-external", context.getExternalCacheDir().getAbsolutePath());
        availableFilesystems.put("root", "/");

        installedFilesystems = new HashSet<String>();

        String filesystemsStr = activity.getIntent().getStringExtra("androidextrafilesystems");
        if (filesystemsStr == null) {
            filesystemsStr = "files,files-external,documents,sdcard,cache,cache-external";
        }

        String[] filesystems = filesystemsStr.split(",");

        FileUtils filePlugin = (FileUtils)webView.pluginManager.getPlugin("File");
        if (filePlugin != null) {
            /* Register filesystems in order */
            for (String fsName : filesystems) {
                if (!installedFilesystems.contains(fsName)) {
                    String fsRoot = availableFilesystems.get(fsName);
                    if (fsRoot != null) {
                        File newRoot = new File(fsRoot);
                        if (newRoot.mkdirs() || newRoot.isDirectory()) {
                            filePlugin.registerFilesystem(new LocalFilesystem(fsName, cordova, fsRoot));
                            installedFilesystems.add(fsName);
                        } else {
                           Log.d(TAG, "Unable to create root dir for fileystem \"" + fsName + "\", skipping");
                        }
                    } else {
                        Log.d(TAG, "Unrecognized extra filesystem identifier: " + fsName);
                    }
                }
            }
        } else {
            Log.w(TAG, "File plugin not found; cannot initialize file-system-roots plugin");
        }

    }

    @Override
    public boolean execute(String action, CordovaArgs args, final CallbackContext callbackContext) throws JSONException {
        if ("getDirectoryForPurpose".equals(action)) {
            getDirectoryForPurpose(args, callbackContext);
            return true;
        }

        return false;
    }

    private void getDirectoryForPurpose(final CordovaArgs args, final CallbackContext callbackContext) throws JSONException {
        int purpose = args.getInt(0);
        boolean sandboxed = args.getBoolean(1);

        String path = null;
        switch (purpose) {
            case PURPOSE_DATA:
                if (sandboxed && installedFilesystems.contains("files")) {
                    path = "cdvfile://localhost/files/";
                } else if (installedFilesystems.contains("files-external")) {
                    path = "cdvfile://localhost/files-external/";
                }
                break;
            case PURPOSE_DOCUMENTS:
                if (sandboxed && installedFilesystems.contains("documents")) {
                    path = "cdvfile://localhost/documents/";
                } else if (installedFilesystems.contains("scdard")) {
                    path = "cdvfile://localhost/sdcard/";
                }
                break;
            case PURPOSE_TEMP:
                path = "cdvfile://localhost/temporary/";
            case PURPOSE_CACHE:
                if (sandboxed && installedFilesystems.contains("cache")) {
                    path = "cdvfile://localhost/cache/";
                } else if (installedFilesystems.contains("cache-external")) {
                    path = "cdvfile://localhost/cache-external";
                }
                break;
        }

        if (path == null) {
            callbackContext.error("No path found.");
            return;
        }

        callbackContext.success(path);
    }
}
