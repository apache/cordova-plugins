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

#pragma mark Global Methods

// Return a NSArray<Class> containing all subclasses of a Class
NSArray* ClassGetSubclasses(Class parentClass)
{
    int numClasses = objc_getClassList(nil, 0);
    Class* classes = nil;
    
    classes = (Class*)malloc(sizeof(Class) * numClasses);
    numClasses = objc_getClassList(classes, numClasses);
    
    NSMutableArray* result = [NSMutableArray array];
    for (NSInteger i = 0; i < numClasses; i++) {
        
        Class superClass = classes[i];
        do {
            superClass = class_getSuperclass(superClass);
        }
        while(superClass && superClass != parentClass);
        
        if (superClass == nil) {
            continue;
        }
        
        [result addObject:classes[i]];
    }
    
    free(classes);
    
    return result;
}

// Replace or Exchange method implementations
// Return YES if method was exchanged, NO if replaced
BOOL MethodSwizzle(Class clazz, SEL originalSelector, SEL overrideSelector)
{
    Method originalMethod = class_getInstanceMethod(clazz, originalSelector);
    Method overrideMethod = class_getInstanceMethod(clazz, overrideSelector);
    
    // try to add, if it does not exist, replace
    if (class_addMethod(clazz, originalSelector, method_getImplementation(overrideMethod), method_getTypeEncoding(overrideMethod))) {
        class_replaceMethod(clazz, overrideSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    }
    // add failed, so we exchange
    else {
        method_exchangeImplementations(originalMethod, overrideMethod);
        return YES;
    }
    
    return NO;
}

// Helper to return the Class to swizzle
// We need to swizzle the subclass (if available) of CDVAppDelegate
Class ClassToSwizzle() {
    Class clazz = [CDVAppDelegate class];
    
    NSArray* subClazz = ClassGetSubclasses(clazz);
    if ([subClazz count] > 0) {
        clazz = [subClazz objectAtIndex:0];
    }
    
    return clazz;
}

#pragma mark Global Variables

static BOOL cdvLocalNotifSelExchanged = NO;
static BOOL cdvRemoteNotifSelExchanged = NO;
static BOOL cdvRemoteNotifErrorSelExchanged = NO;

#pragma mark CDVAppDelegate (SwizzledMethods)

@implementation CDVAppDelegate (SwizzledMethods)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class clazz = ClassToSwizzle();
        
    cdvLocalNotifSelExchanged = MethodSwizzle(clazz, @selector(application:didReceiveLocalNotification:), @selector(cdv_notification_rebroadcastApplication:didReceiveLocalNotification:));
    cdvRemoteNotifSelExchanged = MethodSwizzle(clazz, @selector(application:didRegisterForRemoteNotificationsWithDeviceToken:), @selector(cdv_notification_rebroadcastApplication:didRegisterForRemoteNotificationsWithDeviceToken:));
    cdvRemoteNotifErrorSelExchanged = MethodSwizzle(clazz, @selector(application:didFailToRegisterForRemoteNotificationsWithError:), @selector(cdv_notification_rebroadcastApplication:didFailToRegisterForRemoteNotificationsWithError:));
    });
}

- (void) cdv_notification_rebroadcastApplication:(UIApplication*)application didReceiveLocalNotification:(UILocalNotification*)notification
{
    // re-post ( broadcast )
    [[NSNotificationCenter defaultCenter] postNotificationName:CDVLocalNotification object:notification];
    
    // if method was exchanged through method_exchangeImplementations, we call ourselves (no, it's not a recursion)
    if (cdvLocalNotifSelExchanged) {
        [self cdv_notification_rebroadcastApplication:application didReceiveLocalNotification:notification];
    }
}

- (void) cdv_notification_rebroadcastApplication:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken;
{
    // re-post ( broadcast )
    NSString* token = [[[[deviceToken description]
                         stringByReplacingOccurrencesOfString:@"<" withString:@""]
                        stringByReplacingOccurrencesOfString:@">" withString:@""]
                       stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:CDVRemoteNotification object:token];
    
    // if method was exchanged through method_exchangeImplementations, we call ourselves (no, it's not a recursion)
    if (cdvRemoteNotifSelExchanged) {
        [self cdv_notification_rebroadcastApplication:application didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
    }
}

- (void) cdv_notification_rebroadcastApplication:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error;
{
    // re-post ( broadcast )
    [[NSNotificationCenter defaultCenter] postNotificationName:CDVRemoteNotificationError object:error];
    
    // if method was exchanged through method_exchangeImplementations, we call ourselves (no, it's not a recursion)
    if (cdvRemoteNotifErrorSelExchanged) {
        [self cdv_notification_rebroadcastApplication:application didFailToRegisterForRemoteNotificationsWithError:error];
    }
}

@end

#pragma mark UILocalNotification (JSONString)

@implementation UILocalNotification (JSONString)

- (NSString*) cdv_notification_rebroadcastJSONString
{
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    
    if ([self alertAction]) {
        [dict setValue:[self alertAction] forKey:@"alertAction"];
    }
    if ([self alertBody]) {
        [dict setValue:[self alertBody] forKey:@"alertBody"];
    }
    if ([self alertLaunchImage]) {
        [dict setValue:[self alertLaunchImage] forKey:@"alertLaunchImage"];
    }
    if ([self alertTitle]) {
        [dict setValue:[self alertTitle] forKey:@"alertTitle"];
    }
    if ([self userInfo]) {
        [dict setValue:[self userInfo] forKey:@"userInfo"];
    }
    
    NSError* error  = nil;
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
    NSString* val = nil;
    
    if (error == nil) {
        val = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    
    return val;
}

@end

#pragma mark CDVNotificationRebroadcast Plugin

@implementation CDVNotificationRebroadcast : CDVPlugin


- (void)pluginInitialize
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onLocalNotification:) name:CDVLocalNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onRemoteNotification:) name:CDVRemoteNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onRemoteNotificationError:) name:CDVRemoteNotificationError object:nil];
}

 - (void)onLocalNotification:(NSNotification*)notification
{
    UILocalNotification* localNotification = notification.object;
    NSString* jsString = [NSString stringWithFormat:@"cordova.fireDocumentEvent('CDVLocalNotification', %@);", [localNotification cdv_notification_rebroadcastJSONString]];
    
    [self.commandDelegate evalJs:jsString];
}

- (void)onRemoteNotification:(NSNotification*)notification
{
    NSString* token = notification.object;
    NSString* jsString = [NSString stringWithFormat:@"cordova.fireDocumentEvent('CDVRemoteNotification', { 'token': '%@'});", token];

    [self.commandDelegate evalJs:jsString];
}

- (void)onRemoteNotificationError:(NSNotification*)notification
{
    NSError* error = notification.object;
    NSString* desc = [error localizedDescription];
    NSString* jsString = [NSString stringWithFormat:@"cordova.fireDocumentEvent('CDVRemoteNotificationError', { 'error': '%@'});", desc];
    
    [self.commandDelegate evalJs:jsString];
}


@end
