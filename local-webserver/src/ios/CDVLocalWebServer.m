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

#import "CDVLocalWebServer.h"
#import "GCDWebServerPrivate.h"
#import "GCDWebServer+LocalhostOnlyBaseHandler.h"
#import <Cordova/CDVViewController.h>
#import "CDVLocalFileSystem+NativeURL.h"
#import "CDVAssetLibraryFileSystem+NativeURL.h"

@implementation CDVLocalWebServer

- (void) pluginInitialize {

    BOOL useLocalWebServer = NO;
    NSString* indexPage = @"index.html";
    NSString* subPath = @"www";
    NSUInteger port = 80;

    // check the content tag src
    CDVViewController* vc = (CDVViewController*)self.viewController;
    NSURL* startPageUrl = [NSURL URLWithString:vc.startPage];
    if (startPageUrl != nil) {
        if ([[startPageUrl scheme] isEqualToString:@"http"] && [[startPageUrl host] isEqualToString:@"localhost"]) {
            port = [[startPageUrl port] unsignedIntegerValue];
            useLocalWebServer = YES;
        }
    }
    
    // check setting
#if TARGET_IPHONE_SIMULATOR
    if (useLocalWebServer) {
        NSNumber* startOnSimulatorSetting = [[self.commandDelegate settings] objectForKey:[@"CordovaLocalWebServerStartOnSimulator" lowercaseString]];
        if (startOnSimulatorSetting) {
            useLocalWebServer = [startOnSimulatorSetting boolValue];
        }
    }
#endif
    if (useLocalWebServer) {
		// Create server
        self.server = [[GCDWebServer alloc] init];
        NSString* path = [self.commandDelegate pathForResource:indexPage];
		NSString* authToken = [NSString stringWithFormat:@"cdvToken=%@", [[NSProcessInfo processInfo] globallyUniqueString]];
        NSString* appPath = [NSString stringWithFormat:@"/%@/", subPath];
		[self.server addLocalhostOnlyGETHandlerForBasePath:appPath directoryPath:[path stringByDeletingLastPathComponent] indexFilename:indexPage cacheAge:0 allowRangeRequests:YES authToken:authToken];
        
        [self.server startWithPort:port bonjourName:nil];
        [GCDWebServer setLogLevel:kGCDWebServerLoggingLevel_Error];
        
        [self addFileSystemHandlers];
        
        // Update the startPage (supported in cordova-ios 3.7.0, see https://issues.apache.org/jira/browse/CB-7857)
		vc.startPage = [NSString stringWithFormat:@"http://localhost:%lu/%@/%@?%@", self.server.port, subPath, indexPage, authToken];
        
    } else {
        NSLog(@"WARNING: CordovaLocalWebServer: <content> tag src is not http://localhost[:port] (is %@), local web server not started.", vc.startPage);
    }
}

-  (void) addFileSystemHandlers
{
    [self addLocalFileSystemHandler];
    [self addAssetLibraryFileSystemHandler];
    
    CDVFile* filePlugin = (CDVFile*)[self.commandDelegate getCommandInstance:@"File"];
    NSURL* localServerURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:%lu", self.server.port]];
    
    // set the localWebServerURL for the Obj-C categories
    if (filePlugin) {
        NSArray* fileSystems = filePlugin.fileSystems;
        for (NSObject<CDVFileSystem>* fileSystem in fileSystems) {
            SEL sel = NSSelectorFromString(@"setLocalWebServerURL:");
            if ([fileSystem respondsToSelector:sel]) {
                ((void (*)(id, SEL, id))[fileSystem methodForSelector:sel])(fileSystem, sel, localServerURL);
            }
        }
    }
}

- (void) addLocalFileSystemHandler
{
    // TODO:
    // add the GCD GET handler
    // extract the path after /local-filesystem/
    // convert to file URL
    // stream the file back
}

- (void) addAssetLibraryFileSystemHandler
{
    // TODO:
    // add the GCD GET handler
    // extract the path after /asset-library/ prepend "assets-library:/"
    // use ALAssetsLibrary assetForURL
    // stream the file back
}

@end