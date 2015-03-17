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

#import "CDVNotificationRebroadcast.h"
#import <objc/runtime.h>

@implementation CDVAppDelegate (SwizzledMethods)

+ (void)load
{
    Method original, custom;
    
    original = class_getInstanceMethod(self, @selector(application:didReceiveLocalNotification:));
    custom   = class_getInstanceMethod(self, @selector(customApplication:didReceiveLocalNotification:));
    method_exchangeImplementations(original, custom);
    
    original = class_getInstanceMethod(self, @selector(application:didRegisterForRemoteNotificationsWithDeviceToken:));
    custom   = class_getInstanceMethod(self, @selector(customApplication:didRegisterForRemoteNotificationsWithDeviceToken:));
    method_exchangeImplementations(original, custom);

    original = class_getInstanceMethod(self, @selector(application:didFailToRegisterForRemoteNotificationsWithError:));
    custom   = class_getInstanceMethod(self, @selector(customApplication:didFailToRegisterForRemoteNotificationsWithError:));
    method_exchangeImplementations(original, custom);
}

- (void) customApplication:(UIApplication*)application didReceiveLocalNotification:(UILocalNotification*)notification
{
    // re-post ( broadcast )
    [[NSNotificationCenter defaultCenter] postNotificationName:CDVLocalNotification object:notification];
    
    // no, not recursion. we swapped implementations, remember. calling original implementation
    [self customApplication:application didReceiveLocalNotification:notification];
}

- (void) customApplication:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken;
{
    // re-post ( broadcast )
    NSString* token = [[[[deviceToken description]
                         stringByReplacingOccurrencesOfString:@"<" withString:@""]
                        stringByReplacingOccurrencesOfString:@">" withString:@""]
                       stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:CDVRemoteNotification object:token];
    
    // no, not recursion. we swapped implementations, remember. calling original implementation
    [self customApplication:application didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
}

- (void) customApplication:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error;
{
    // re-post ( broadcast )
    [[NSNotificationCenter defaultCenter] postNotificationName:CDVRemoteNotificationError object:error];
    
    // no, not recursion. we swapped implementations, remember. calling original implementation
    [self customApplication:application didFailToRegisterForRemoteNotificationsWithError:error];
}


@end

@implementation CDVNotificationRebroadcast : CDVPlugin


- (void)pluginInitialize
{
    // TODO: listen to the notifications, and send to JavaScript as events?
}

@end
