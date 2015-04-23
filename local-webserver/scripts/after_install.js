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
// The <content> tag "src" attribute is modified to point to http://localhost:0

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
        old_content_src_value = content_tags[0].get('src');
        var backup_json = path.join(context.opts.plugin.dir, 'backup.json');
        var backup_value = { content_src : old_content_src_value };
        fs.writeFileSync(backup_json, JSON.stringify(backup_value));

        content_tags[0].set('src', content_src_value);
    }

    var altcontentsrcTag = etree.findall("./preference[@name='AlternateContentSrc']");
    if (altcontentsrcTag.length > 0) {
        altcontentsrcTag[0].set('value', old_content_src_value);
    } else {
      var pref = et.Element('preference', { name: 'AlternateContentSrc', value: old_content_src_value });
      etree.getroot().append(pref);
    }

    data = etree.write({'indent': 4});
    fs.writeFileSync(config_xml, data);
}
