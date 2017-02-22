#!/usr/bin/env node

/*
    Licensed to the Apache Software Foundation (ASF) under one
    or more contributor license agreements. See the NOTICE file
    distributed with this work for additional information
    regarding copyright ownership. The ASF licenses this file
    to you under the Apache License, Version 2.0 (the
    "License"); you may not use this file except in compliance
    with the License. You may obtain a copy of the License at
        http://www.apache.org/licenses/LICENSE-2.0
    Unless required by applicable law or agreed to in writing,
    software distributed under the License is distributed on an
    "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
    KIND, either express or implied. See the License for the
    specific language governing permissions and limitations
    under the License.
*/

var shell = require('shelljs');
var path = require('path');
var argv = require('nopt')({
    'help' : Boolean,
    'template-path' : String
});

var projectName = argv.argv.remain[0];
var repoName = argv.argv.remain[1]; 

if (argv.help || !projectName || !repoName) {
    console.log('Usage: $0 [--template-path] <project_name> <repo_name>');
    console.log('   <project_name>: Plugin name, i.e. CDVFoo');
    console.log('   <repo_name>: Repo name');
    console.log('   [--template-path]: Path to test template (override).');
    process.exit(0);
}

var tests_template_folder = argv.template-path || path.join(__dirname, "tests-template");

processTemplateFiles(projectName, repoName);

function processTemplateFiles(project_name, repo_name) {

    var project_name_esc = project_name.replace(/&/g, '\\&');
    var repo_name_esc = repo_name.replace(/&/g, '\\&');

    /*
        tests-template/ios/__PROJECT_NAME__Test/__PROJECT_NAME__LibTests/__PROJECT_NAME__Test.m
        tests-template/ios/__PROJECT_NAME__Test/__PROJECT_NAME__LibTests/Info.plist
        tests-template/ios/__PROJECT_NAME__Test/__PROJECT_NAME__Test.xcodeproj/project.pbxproj
        tests-template/ios/__PROJECT_NAME__Test/__PROJECT_NAME__Test.xcodeproj/project.xcworkspace/contents.xcworkspacedata
        tests-template/ios/__PROJECT_NAME__Test/__PROJECT_NAME__Test.xcodeproj/project.xcworkspace/xcshareddata/__PROJECT_NAME__Test.xccheckout
        tests-template/ios/__PROJECT_NAME__Test/__PROJECT_NAME__Test.xcodeproj/xcshareddata/xcschemes/__PROJECT_NAME__Lib.xcscheme
        tests-template/ios/__PROJECT_NAME__Test/__PROJECT_NAME__Test.xcodeproj/xcshareddata/xcschemes/__PROJECT_NAME__LibTests.xcscheme
        tests-template/ios/__PROJECT_NAME__Test.xcworkspace/xcshareddata/__PROJECT_NAME__Test.xccheckout
        tests-template/ios/__PROJECT_NAME__Test.xcworkspace/contents.xcworkspacedata
        tests-template/ios/package.json
        tests-template/ios/README.md
        tests-template/plugin.xml
        tests-template/tests.js
    */
    
    // substitute token __PROJECT_NAME__ in files
    var r = tests_template_folder;

    shell.sed('-i', /__PROJECT_NAME__/g, project_name_esc, path.join(r, 'plugin.xml'));
    shell.sed('-i', /__PROJECT_NAME__/g, project_name_esc, path.join(r, 'tests.js'));
    shell.sed('-i', /__PROJECT_NAME__/g, project_name_esc, path.join(r, 'ios', 'README.md'));
    shell.sed('-i', /__PROJECT_NAME__/g, project_name_esc, path.join(r, 'ios', 'package.json'));
    shell.sed('-i', /__PROJECT_NAME__/g, project_name_esc, path.join(r, 'ios', '__PROJECT_NAME__Test.xcworkspace', 'contents.xcworkspacedata'));
    shell.sed('-i', /__PROJECT_NAME__/g, project_name_esc, path.join(r, 'ios', '__PROJECT_NAME__Test.xcworkspace', 'xcshareddata', '__PROJECT_NAME__Test.xccheckout'));

    var x = path.join(r, 'ios', '__PROJECT_NAME__Test', '__PROJECT_NAME__Test.xcodeproj');

    shell.sed('-i', /__PROJECT_NAME__/g, project_name_esc, path.join(x, 'xcshareddata', 'xcschemes', '__PROJECT_NAME__LibTests.xcscheme'));
    shell.sed('-i', /__PROJECT_NAME__/g, project_name_esc, path.join(x, 'xcshareddata', 'xcschemes', '__PROJECT_NAME__Lib.xcscheme'));
    shell.sed('-i', /__PROJECT_NAME__/g, project_name_esc, path.join(x, 'project.xcworkspace', 'xcshareddata','__PROJECT_NAME__Test.xccheckout'));
    shell.sed('-i', /__PROJECT_NAME__/g, project_name_esc, path.join(x, 'project.xcworkspace', 'contents.xcworkspacedata'));
    shell.sed('-i', /__PROJECT_NAME__/g, project_name_esc, path.join(x, 'project.pbxproj'));

    var l = path.join(r, 'ios', '__PROJECT_NAME__Test', '__PROJECT_NAME__LibTests');

    shell.sed('-i', /__PROJECT_NAME__/g, project_name_esc, path.join(l, 'Info.plist'));
    shell.sed('-i', /__PROJECT_NAME__/g, project_name_esc, path.join(l, '__PROJECT_NAME__Test.m'));

    // substitute token __REPO_NAME__ in files

    shell.sed('-i', /__REPO_NAME__/g, repo_name_esc, path.join(r, 'plugin.xml'));
    shell.sed('-i', /__REPO_NAME__/g, repo_name_esc, path.join(r, 'tests.js'));
    shell.sed('-i', /__REPO_NAME__/g, repo_name_esc, path.join(r, 'ios', 'README.md'));
    shell.sed('-i', /__REPO_NAME__/g, repo_name_esc, path.join(r, 'ios', 'package.json'));
    shell.sed('-i', /__REPO_NAME__/g, repo_name_esc, path.join(r, 'ios', '__PROJECT_NAME__Test.xcworkspace', 'contents.xcworkspacedata'));
    shell.sed('-i', /__REPO_NAME__/g, repo_name_esc, path.join(r, 'ios', '__PROJECT_NAME__Test.xcworkspace', 'xcshareddata', '__PROJECT_NAME__Test.xccheckout'));

    shell.sed('-i', /__REPO_NAME__/g, repo_name_esc, path.join(x, 'xcshareddata', 'xcschemes', '__PROJECT_NAME__LibTests.xcscheme'));
    shell.sed('-i', /__REPO_NAME__/g, repo_name_esc, path.join(x, 'xcshareddata', 'xcschemes', '__PROJECT_NAME__Lib.xcscheme'));
    shell.sed('-i', /__REPO_NAME__/g, repo_name_esc, path.join(x, 'project.xcworkspace', 'xcshareddata','__PROJECT_NAME__Test.xccheckout'));
    shell.sed('-i', /__REPO_NAME__/g, repo_name_esc, path.join(x, 'project.xcworkspace', 'contents.xcworkspacedata'));
    shell.sed('-i', /__REPO_NAME__/g, repo_name_esc, path.join(x, 'project.pbxproj'));

    shell.sed('-i', /__REPO_NAME__/g, repo_name_esc, path.join(l, 'Info.plist'));
    shell.sed('-i', /__REPO_NAME__/g, repo_name_esc, path.join(l, '__PROJECT_NAME__Test.m'));

    /*
        tests-template/ios/__PROJECT_NAME__/__PROJECT_NAME__Test.xcodeproj/project.xcworkspace/xcshareddata/__PROJECT_NAME__Test.xccheckout
        tests-template/ios/__PROJECT_NAME__/__PROJECT_NAME__Test.xcodeproj/xcshareddata/xcschemes/__PROJECT_NAME__Lib.xcscheme
        tests-template/ios/__PROJECT_NAME__/__PROJECT_NAME__Test.xcodeproj/xcshareddata/xcschemes/__PROJECT_NAME__LibTests.xcscheme
        tests-template/ios/__PROJECT_NAME__/__PROJECT_NAME__Test.xcodeproj
        tests-template/ios/__PROJECT_NAME__Test.xcworkspace/xcshareddata/__PROJECT_NAME__Test.xccheckout
        tests-template/ios/__PROJECT_NAME__Test.xcworkspace
        tests-template/ios/__PROJECT_NAME__/__PROJECT_NAME__LibTests/__PROJECT_NAME__Test.m
        tests-template/ios/__PROJECT_NAME__/__PROJECT_NAME__LibTests
        tests-template/ios/__PROJECT_NAME__
    */

    // rename folders

    shell.mv('-f', 
        path.join(x, 'project.xcworkspace', 'xcshareddata', '__PROJECT_NAME__Test.xccheckout'), 
        path.join(x, 'project.xcworkspace', 'xcshareddata', project_name_esc + 'Test.xccheckout')
    );
    shell.mv('-f', 
        path.join(x, 'xcshareddata', 'xcschemes', '__PROJECT_NAME__Lib.xcscheme'), 
        path.join(x, 'xcshareddata', 'xcschemes', project_name_esc + 'Lib.xcscheme')
    );
    shell.mv('-f', 
        path.join(x, 'xcshareddata', 'xcschemes', '__PROJECT_NAME__LibTests.xcscheme'), 
        path.join(x, 'xcshareddata', 'xcschemes', project_name_esc + 'LibTests.xcscheme')
    );
    shell.mv('-f', 
        path.join(r, 'ios', '__PROJECT_NAME__Test', '__PROJECT_NAME__Test.xcodeproj'), 
        path.join(r, 'ios', '__PROJECT_NAME__Test', project_name_esc + 'Test.xcodeproj')
    );
    shell.mv('-f', 
        path.join(r, 'ios', '__PROJECT_NAME__Test.xcworkspace', 'xcshareddata', '__PROJECT_NAME__Test.xccheckout'), 
        path.join(r, 'ios', '__PROJECT_NAME__Test.xcworkspace', 'xcshareddata', project_name_esc + 'Test.xccheckout') 
    );
    shell.mv('-f', 
        path.join(r, 'ios', '__PROJECT_NAME__Test.xcworkspace'), 
        path.join(r, 'ios', project_name_esc + 'Test.xcworkspace')
    );
    shell.mv('-f', 
        path.join(r, 'ios', '__PROJECT_NAME__Test', '__PROJECT_NAME__LibTests', '__PROJECT_NAME__Test.m'), 
        path.join(r, 'ios', '__PROJECT_NAME__Test', '__PROJECT_NAME__LibTests', project_name_esc + 'Test.m') 
    );
    shell.mv('-f', 
        path.join(r, 'ios', '__PROJECT_NAME__Test', '__PROJECT_NAME__LibTests'), 
        path.join(r, 'ios', '__PROJECT_NAME__Test', project_name_esc + 'LibTests')
    );
    shell.mv('-f', 
        path.join(r, 'ios', '__PROJECT_NAME__Test'), 
        path.join(r, 'ios', project_name_esc + "Test")
    );
}

