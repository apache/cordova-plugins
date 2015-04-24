#!/usr/bin/env node

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

// This script modifies the project root's config.xml
// This restores the content tag's src attribute to its original value.

var content_src_value = "http://localhost:0";
var fs = require('fs');
var path = require('path');
var old_content_src_value;

module.exports = function(context) {
    var config_xml = path.join(context.opts.projectRoot, 'config.xml');
    var et = context.requireCordovaModule('elementtree');

    var data = fs.readFileSync(config_xml).toString();
    var etree = et.parse(data);

    var content_tags = etree.findall('./content[@src]');
    if (content_tags.length > 0) {
        var backup_json = path.join(context.opts.plugin.dir, 'backup.json');
        var backup_data = JSON.parse(fs.readFileSync(backup_json).toString());

        var config_content_src_value = content_tags[0].get('src');
        // it's our value, we can restore old value
        if (config_content_src_value === content_src_value) {
            content_tags[0].set('src', backup_data.content_src);
        }
    }

    var altcontentsrcTag = etree.findall("./preference[@name='AlternateContentSrc']");
    if (altcontentsrcTag.length > 0) {
      try {
         // elementtree 0.1.6
         etree.getroot().remove(altcontentsrcTag[0]);
      } catch (e) {
         // elementtree 0.1.5
         etree.getroot().remove(0, altcontentsrcTag[0]);
      }
    }

    data = etree.write({'indent': 4});
    fs.writeFileSync(config_xml, data);
}
