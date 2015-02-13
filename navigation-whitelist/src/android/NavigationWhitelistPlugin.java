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

package org.apache.cordova.whitelist;

import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CordovaWebView;
import org.apache.cordova.ConfigXmlParser;
import org.apache.cordova.Whitelist;
import android.content.res.XmlResourceParser;
import android.util.Log;

public class NavigationWhitelistPlugin extends CordovaPlugin {

    private Whitelist allowedNavigationPatterns = new Whitelist();

    private static final String TAG = "NavigationWhitelist";

    public void initialize(CordovaInterface cordova, CordovaWebView webView) {

        new ConfigXmlParser(){
            public void handleStartTag(XmlResourceParser xml) {
                String strNode = xml.getName();
                if (strNode.equals("content")) {
                    String startPage = xml.getAttributeValue(null, "src");
                    allowedNavigationPatterns.addWhiteListEntry("file:///*", false);
                } else if (strNode.equals("allow-navigation")) {
                    String origin = xml.getAttributeValue(null, "href");
                    if ("*".equals(origin)) {
                        // Special-case * origin to mean http and https when used for internal
                        // whitelist. This prevents external urls like sms: and geo: from being
                        // handled internally.
                        allowedNavigationPatterns.addWhiteListEntry("http://*/*", false);
                        allowedNavigationPatterns.addWhiteListEntry("https://*/*", false);
                    } else {
                        allowedNavigationPatterns.addWhiteListEntry(origin, false);
                    }
                }
            }
            public void handleEndTag(XmlResourceParser xml) {
            }
        }.parse(cordova.getActivity());
    }

    public Boolean shouldAllowNavigation(String url) {
        return allowedNavigationPatterns.isUrlWhiteListed(url);
    }

    public Boolean shouldAllowRequest(String url) {
        return shouldAllowNavigation(url);
    }


}
