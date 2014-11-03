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

@implementation GCDWebServer (LocalhostOnlyBaseHandler)

- (GCDWebServerResponse*)_responseWithContentsOfDirectory:(NSString*)path {
	NSDirectoryEnumerator* enumerator = [[NSFileManager defaultManager] enumeratorAtPath:path];
	if (enumerator == nil) {
		return nil;
	}
	NSMutableString* html = [NSMutableString string];
	[html appendString:@"<!DOCTYPE html>\n"];
	[html appendString:@"<html><head><meta charset=\"utf-8\"></head><body>\n"];
	[html appendString:@"<ul>\n"];
	for (NSString* file in enumerator) {
		if (![file hasPrefix:@"."]) {
			NSString* type = [[enumerator fileAttributes] objectForKey:NSFileType];
			NSString* escapedFile = [file stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
			GWS_DCHECK(escapedFile);
			if ([type isEqualToString:NSFileTypeRegular]) {
				[html appendFormat:@"<li><a href=\"%@\">%@</a></li>\n", escapedFile, file];
			} else if ([type isEqualToString:NSFileTypeDirectory]) {
				[html appendFormat:@"<li><a href=\"%@/\">%@/</a></li>\n", escapedFile, file];
			}
		}
		[enumerator skipDescendents];
	}
	[html appendString:@"</ul>\n"];
	[html appendString:@"</body></html>\n"];
	return [GCDWebServerDataResponse responseWithHTML:html];
}

- (void)addLocalhostOnlyGETHandlerForBasePath:(NSString*)basePath directoryPath:(NSString*)directoryPath indexFilename:(NSString*)indexFilename cacheAge:(NSUInteger)cacheAge allowRangeRequests:(BOOL)allowRangeRequests {
	if ([basePath hasPrefix:@"/"] && [basePath hasSuffix:@"/"]) {
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
			return response;
			
		}];
	} else {
		GWS_DNOT_REACHED();
	}
}

@end
