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

#import "CDVAssetLibraryFileSystem+NativeURL.h"

#import <objc/runtime.h>

static void* LocalWebServerURLPropertyKey = &LocalWebServerURLPropertyKey;

@implementation CDVAssetLibraryFilesystem (LocalWebServerNativeURL)


- (NSString*) nativeURL:(NSString*)fullPath
{
    return [NSString stringWithFormat:@"%@://%@:%lu/assets-library/%@",
            self.localWebServerURL.scheme,
            self.localWebServerURL.host,
            [self.localWebServerURL.port unsignedIntegerValue],
            fullPath];
}

- (void) setLocalWebServerURL:(NSURL *)localWebServerURL {
    objc_setAssociatedObject(self, LocalWebServerURLPropertyKey, localWebServerURL, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSURL*) localWebServerURL {
    return objc_getAssociatedObject(self, LocalWebServerURLPropertyKey);
}


@end
