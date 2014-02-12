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
#import "CDVFile.h"
#import "CDVLocalFilesystem.h"

enum FileSystemPurpose {
    DATA = 0,
    DOCUMENTS = 1,
    CACHE = 2,
    TEMP = 3,
    IOS_BUNDLE = 4,
};
typedef int FileSystemPurpose;

@interface FileSystemRoots : CDVPlugin {
    NSDictionary *availableFilesystems;
    NSMutableSet *installedFilesystems;
}
@end

@implementation FileSystemRoots

- (void)pluginInitialize
{
    NSString *libPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    availableFilesystems = @{
        @"library": libPath,
        @"library-nosync": [libPath stringByAppendingPathComponent:@"NoCloud"],
        @"documents": docPath,
        @"documents-nosync": [docPath stringByAppendingPathComponent:@"NoCloud"],
        @"cache": [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0],
        @"bundle": [[NSBundle mainBundle] bundlePath],
        @"root": @"/"
    };
    installedFilesystems = [[NSMutableSet alloc] initWithCapacity:7];

    /* Get filesystems to be installed from settings */
    id vc = self.viewController;
    
    NSDictionary *settings = [vc settings];
    NSString *filesystemsStr = [settings[@"iosextrafilesystems"] lowercaseString];
    if (!filesystemsStr) {
        filesystemsStr = @"library,library-nosync,documents,documents-nosync,cache,bundle";
    }
    NSArray *filesystems = [filesystemsStr componentsSeparatedByString:@","];
    
    /* Build non-syncable directories as necessary */
    for (NSString *nonSyncFS in @[@"library-nosync", @"documents-nosync"]) {
        if ([filesystems containsObject:nonSyncFS]) {
            [self makeNonSyncable:availableFilesystems[nonSyncFS]];
        }
    }
    
    CDVFile *filePlugin = [[vc commandDelegate] getCommandInstance:@"File"];
    if (filePlugin) {
        /* Register filesystems in order */
        for (NSString *fsName in filesystems) {
            if (![installedFilesystems containsObject:fsName]) {
                NSString *fsRoot = availableFilesystems[fsName];
                if (fsRoot) {
                    [filePlugin registerFilesystem:[[CDVLocalFilesystem alloc] initWithName:fsName root:fsRoot]];
                    [installedFilesystems addObject:fsName];
                } else {
                    NSLog(@"Unrecognized extra filesystem identifier: %@", fsName);
                }
            }
        }
    } else {
        NSLog(@"File plugin not found; cannot initialize file-system-roots plugin");
    }
}

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
        if (syncable && [installedFilesystems containsObject:@"library"]) {
            path = @"cdvfile://localhost/library/";
        } else if ([installedFilesystems containsObject:@"library-nosync"]) {
            path = @"cdvfile://localhost/library-nosync/";
        }
        break;
      case DOCUMENTS:
        if (syncable && [installedFilesystems containsObject:@"documents"]) {
            path = @"cdvfile://localhost/documents/";
        } else if ([installedFilesystems containsObject:@"documents-nosync"]) {
            path = @"cdvfile://localhost/documents-nosync/";
        }
        break;
      case CACHE:
        if ([installedFilesystems containsObject:@"cache"]) {
            path = @"cdvfile://localhost/cache/";
        }
        break;
      case TEMP:
        path = @"cdvfile://localhost/temporary/";
        break;
      case IOS_BUNDLE:
        if ([installedFilesystems containsObject:@"bundle"]) {
            path = @"cdvfile://localhost/bundle/";
        }
        break;
    }

    CDVPluginResult *pluginResult = nil;

    if (!path) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:path];
    }

    [[self commandDelegate] sendPluginResult:pluginResult callbackId:[command callbackId]];
}

@end
