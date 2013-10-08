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

#import <Cordova/CDVPlugin.h>

enum FileSystemPurpose {
    DATA = 0,
    DOCUMENTS = 1,
    CACHE = 2,
    TEMP = 3,
    IOS_BUNDLE = 4,
};
typedef int FileSystemPurpose;

@interface FileExtras : CDVPlugin
@end

@implementation FileExtras

- (void)makeNonSyncable:(NSString*)path {
    [[NSFileManager defaultManager] createDirectoryAtPath:path
              withIntermediateDirectories:YES
                               attributes:nil
                                    error:nil];
    NSURL* url = [NSURL fileURLWithPath:path];
    [url setResourceValue: [NSNumber numberWithBool: YES]
                   forKey: NSURLIsExcludedFromBackupKey error:nil];

}

- (void)getDirectoryForPurpose:(CDVInvokedUrlCommand *)command {
    FileSystemPurpose purpose = [[command argumentAtIndex:0] intValue];
    // BOOL sandboxed = [[command argumentAtIndex:1] boolValue];
    BOOL syncable = [[command argumentAtIndex:2] boolValue];

    NSString *path = nil;

    switch (purpose) {
        case DATA:
            path = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            if (!syncable) {
                path = [path stringByAppendingPathComponent:@"NoCloud"];
                [self makeNonSyncable:path];
            }
            break;
      case DOCUMENTS:
            path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            if (!syncable) {
                path = [path stringByAppendingPathComponent:@"NoCloud"];
                [self makeNonSyncable:path];
            }
            break;
      case CACHE:
          path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
          break;
      case TEMP:
          path = NSTemporaryDirectory();
          break;
      case IOS_BUNDLE:
          path = [[NSBundle mainBundle] bundlePath];
          break;
    }

    CDVPluginResult *pluginResult = nil;

    if (!path) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
    } else {
        // Remove the trailing slash if it's there.
        if ([path hasSuffix:@"/"]) {
            path = [path substringToIndex:[path length] - 1];
        }

        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:path];
    }

    [[self commandDelegate] sendPluginResult:pluginResult callbackId:[command callbackId]];
}

@end
