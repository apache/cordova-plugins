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
package org.apache.cordova.fileextras;

import android.os.Environment;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaArgs;
import org.apache.cordova.CordovaPlugin;
import org.json.JSONException;

import java.io.File;

public class FileExtras extends CordovaPlugin {
    private static final int PURPOSE_DATA = 0;
    private static final int PURPOSE_DOCUMENTS = 1;
    private static final int PURPOSE_CACHE = 2;
    private static final int PURPOSE_TEMP = 3;

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
        // boolean syncable = args.getInt(2);

        String path = null;
        switch (purpose) {
            case PURPOSE_DATA:
                if (sandboxed) {
                    path = cordova.getActivity().getApplicationContext().getFilesDir().getAbsolutePath();
                } else {
                    path = cordova.getActivity().getApplicationContext().getExternalFilesDir(null).getAbsolutePath();
                }
                break;
            case PURPOSE_DOCUMENTS:
                if (sandboxed) {
                    path = new File(cordova.getActivity().getApplicationContext().getFilesDir(), "Documents").getAbsolutePath();
                } else {
                    path = Environment.getExternalStorageDirectory().getAbsolutePath();
                }
                break;
            case PURPOSE_CACHE:
            case PURPOSE_TEMP:
                if (sandboxed) {
                    path = cordova.getActivity().getApplicationContext().getCacheDir().getAbsolutePath();
                } else {
                    path = cordova.getActivity().getApplicationContext().getExternalCacheDir().getAbsolutePath();
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
