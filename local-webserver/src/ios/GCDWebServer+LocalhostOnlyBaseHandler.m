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

#import "GCDWebServer+LocalhostOnlyBaseHandler.h"
#import "GCDWebServerPrivate.h"

@interface GCDWebServer()
- (GCDWebServerResponse*)_responseWithContentsOfDirectory:(NSString*)path;
@end

@implementation GCDWebServer (LocalhostOnlyBaseHandler)

NSString* _authTokenKV = nil;

- (void)addLocalhostOnlyGETHandlerForBasePath:(NSString*)basePath directoryPath:(NSString*)directoryPath indexFilename:(NSString*)indexFilename cacheAge:(NSUInteger)cacheAge allowRangeRequests:(BOOL)allowRangeRequests authToken:(NSString *)authToken {
	if ([basePath hasPrefix:@"/"] && [basePath hasSuffix:@"/"]) {
		_authTokenKV = authToken;
		GCDWebServer* __unsafe_unretained server = self;
		[self addHandlerWithMatchBlock:^GCDWebServerRequest *(NSString* requestMethod, NSURL* requestURL, NSDictionary* requestHeaders, NSString* urlPath, NSDictionary* urlQuery) {
			
			if (![requestMethod isEqualToString:@"GET"]) {
				return nil;
			}
			if (![urlPath hasPrefix:basePath]) {
				return nil;
			}
			return [[GCDWebServerRequest alloc] initWithMethod:requestMethod url:requestURL headers:requestHeaders path:urlPath query:urlQuery];
			
		} processBlock:^GCDWebServerResponse *(GCDWebServerRequest* request) {
			
			//check if it is a request from localhost
			NSString *host = [request.headers objectForKey:@"Host"];
			if (host==nil || [host hasPrefix:@"localhost"] == NO ) {
				return [GCDWebServerErrorResponse responseWithClientError:kGCDWebServerHTTPStatusCode_Forbidden message:@"FORBIDDEN"];
			}
			
			//check if the querystring or the cookie has the token
			BOOL hasToken = (request.URL.query && [request.URL.query containsString:_authTokenKV]);
			NSString *cookie = [request.headers objectForKey:@"Cookie"];
			BOOL hasCookie = (cookie && [cookie containsString:_authTokenKV]);
			if (!hasToken && !hasCookie) {
				return [GCDWebServerErrorResponse responseWithClientError:kGCDWebServerHTTPStatusCode_Forbidden message:@"FORBIDDEN"];
			}
			
			GCDWebServerResponse* response = nil;
			NSString* filePath = [directoryPath stringByAppendingPathComponent:[request.path substringFromIndex:basePath.length]];
			NSString* fileType = [[[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:NULL] fileType];
			if (fileType) {
				if ([fileType isEqualToString:NSFileTypeDirectory]) {
					if (indexFilename) {
						NSString* indexPath = [filePath stringByAppendingPathComponent:indexFilename];
						NSString* indexType = [[[NSFileManager defaultManager] attributesOfItemAtPath:indexPath error:NULL] fileType];
						if ([indexType isEqualToString:NSFileTypeRegular]) {
							return [GCDWebServerFileResponse responseWithFile:indexPath];
						}
					}
					response = [server _responseWithContentsOfDirectory:filePath];
				} else if ([fileType isEqualToString:NSFileTypeRegular]) {
					if (allowRangeRequests) {
						response = [GCDWebServerFileResponse responseWithFile:filePath byteRange:request.byteRange];
						[response setValue:@"bytes" forAdditionalHeader:@"Accept-Ranges"];
					} else {
						response = [GCDWebServerFileResponse responseWithFile:filePath];
					}
				}
			}
			if (response) {
				response.cacheControlMaxAge = cacheAge;
			} else {
				response = [GCDWebServerResponse responseWithStatusCode:kGCDWebServerHTTPStatusCode_NotFound];
			}
			
			if (hasToken && !hasCookie) {
				//set cookie
				[response setValue:_authTokenKV forAdditionalHeader:@"Set-Cookie"];
			}
			
			return response;
			
		}];
	} else {
		GWS_DNOT_REACHED();
	}
}

@end
