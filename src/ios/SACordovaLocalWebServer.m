
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

#import "SACordovaLocalWebServer.h"
#import <Cordova/CDVViewController.h>

@implementation SACordovaLocalWebServer

- (id)settingForKey:(NSString*)key
{
    return [self.commandDelegate.settings objectForKey:[key lowercaseString]];
}

- (void) pluginInitialize {
    
    NSString* indexPage = @"index.html";
    NSUInteger port = 64000;
    
    // grab the port preference
    NSString* setting  = @"CordovaLocalWebServerPort";
    if ([self settingForKey:setting]) {
        port = [[self settingForKey:setting] integerValue];
    } else {
        NSLog(@"CordovaLocalWebServerPort preference missing, using %ld", port);
    }

    // Create server
    self.server = [[GCDWebServer alloc] init];
    NSString* path = [self.commandDelegate pathForResource:indexPage];
    
    [self.server addGETHandlerForBasePath:@"/" directoryPath:[path stringByDeletingLastPathComponent] indexFilename:@"index.html" cacheAge:0 allowRangeRequests:YES];
    [self.server startWithPort:port bonjourName:nil];
    [GCDWebServer setLogLevel:kGCDWebServerLogLevel_Error];
    
    // check the content tag src
    CDVViewController* vc = (CDVViewController*)self.viewController;
    NSString* expectedStartPage = [NSString stringWithFormat:@"http://localhost:%ld", port];
    if (![expectedStartPage isEqualToString:vc.startPage]) {
        NSString* error = [NSString stringWithFormat:@"ERROR: <content> tag src in config.xml is incorrect. Expected src of '%@' but actual src of '%@'",  expectedStartPage, vc.startPage ];
        [self.server logError:@"%@", error];
    }
}

@end