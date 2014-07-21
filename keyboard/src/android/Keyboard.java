/*
       Licensed to the Apache Software Foundation (ASF) under one
       or more contributor license agreements.  See the NOTICE file
       distributed with this work for additional information
       regarding copyright ownership.  The ASF licenses this file
       to you under the Apache License, Version 2.0 (the
       "License"); you may not use this file except in compliance
       with the License.  You may obtain a copy of the License at

         http://www.apache.org/licenses/LICENSE-2.0

       Unless required by applicable law or agreed to in writing,
       software distributed under the License is distributed on an
       "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
       KIND, either express or implied.  See the License for the
       specific language governing permissions and limitations
       under the License.
*/
package org.apache.cordova.labs.keyboard; 

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CordovaWebView;
import org.apache.cordova.LOG;
import org.json.JSONArray;
import org.json.JSONException;

import android.app.Activity;
import android.content.Context;
import android.graphics.Rect;
import android.util.DisplayMetrics;
import android.view.View;
import android.view.ViewTreeObserver.OnGlobalLayoutListener;
import android.view.inputmethod.InputMethodManager;

public class Keyboard extends CordovaPlugin {
    /**
    * Delta height of the visible area, to be treated as keyboard opening.
    */
    private final static int MinHeghtDelta = 100;
    private static final String TAG = "Keyboard";

    public void initialize(CordovaInterface cordova, CordovaWebView webView) {
        super.initialize(cordova, webView);
        
        Activity activity = cordova.getActivity();
        DisplayMetrics metrics = new DisplayMetrics();
        activity.getWindowManager().getDefaultDisplay().getMetrics(metrics);
        final float density = metrics.density;
        
        final CordovaWebView appView = webView;
        
        final View rootView = activity.getWindow().getDecorView().findViewById(android.R.id.content).getRootView();
        OnGlobalLayoutListener list = new OnGlobalLayoutListener() {
            int previousHeightDifference = 0;
            
            @Override
            public void onGlobalLayout() {
                LOG.d(TAG, "Entering global layout notification");
                
            	Rect visibleRect = new Rect();
                //r will be populated with the coordinates of your view that area still visible.
                rootView.getWindowVisibleDisplayFrame(visibleRect);

                int visibleHeight = visibleRect.bottom - visibleRect.top;
                int viewHeight = rootView.getRootView().getHeight();
                int heightDifference = (int)((viewHeight - visibleHeight) / density);
                if (heightDifference > MinHeghtDelta 
                    && heightDifference != previousHeightDifference) {
                    // If the height of the view is bigger then 
                    // visible area by delta, then assume that keyboard
                    // is shown on the screen.
                    appView.sendJavascript("Keyboard.isVisible = true; if (Keyboard.onshow) Keyboard.onshow();");
                }
                else if (heightDifference != previousHeightDifference 
                         && (previousHeightDifference - heightDifference) > MinHeghtDelta){
                    // If the difference between visible and view area dropped by the delta
                    // then assume that this means that keyboard is hidden.
                    appView.sendJavascript("Keyboard.isVisible = false; if (Keyboard.onhide) Keyboard.onhide();");
                }

                previousHeightDifference = heightDifference;
             }
        }; 
        
        rootView.getViewTreeObserver().addOnGlobalLayoutListener(list);
    }
	
    public boolean execute(String action, JSONArray args, final CallbackContext callbackContext) throws JSONException {
        if ("close".equals(action)) {
            cordova.getThreadPool().execute(new Runnable() {
                public void run() {
                	if (closeKeyboard()) {
                        callbackContext.error("Keyboard could not be closed.");
                    }
                    
                    callbackContext.success();
                }
            });
            return true;
        }

        return false;  // Returning false results in a "MethodNotFound" error.
    }
    
    /**
    * Close keyboard
    *
    * @returns true if keyboard closed succesfully, false otherwise.
    */
    private boolean closeKeyboard() {
        Activity activity = cordova.getActivity();
        InputMethodManager inputManager = (InputMethodManager)activity.getSystemService(Context.INPUT_METHOD_SERVICE);
        View v = activity.getCurrentFocus();

        if (v == null) {
            return false;
        }

        inputManager.hideSoftInputFromWindow(v.getWindowToken(), 0);
        return true;
    }
}
