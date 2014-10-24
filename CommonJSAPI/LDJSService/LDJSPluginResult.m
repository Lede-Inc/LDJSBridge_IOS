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

#import "LDJSPluginResult.h"
#import "LDJSJSON.h"
#import "LDJSDataBase64.h"

@interface LDJSPluginResult ()

- (LDJSPluginResult*)initWithStatus:(CDVCommandStatus)statusOrdinal message:(id)theMessage;

@end

@implementation LDJSPluginResult
@synthesize status, message, keepCallback, associatedObject;

static NSArray* org_apache_cordova_CommandStatusMsgs;

id messageFromArrayBuffer(NSData* data)
{
    return @{
               @"CDVType" : @"ArrayBuffer",
               @"data" :[data cdv_base64EncodedString]
    };
}

id massageMessage(id message)
{
    if ([message isKindOfClass:[NSData class]]) {
        return messageFromArrayBuffer(message);
    }
    return message;
}

id messageFromMultipart(NSArray* theMessages)
{
    NSMutableArray* messages = [NSMutableArray arrayWithArray:theMessages];

    for (NSUInteger i = 0; i < messages.count; ++i) {
        [messages replaceObjectAtIndex:i withObject:massageMessage([messages objectAtIndex:i])];
    }

    return @{
               @"CDVType" : @"MultiPart",
               @"messages" : messages
    };
}

+ (void)initialize
{
    org_apache_cordova_CommandStatusMsgs = [[NSArray alloc] initWithObjects:@"No result",
        @"OK",
        @"Class not found",
        @"Illegal access",
        @"Instantiation error",
        @"Malformed url",
        @"IO error",
        @"Invalid action",
        @"JSON error",
        @"Error",
        nil];
}

- (LDJSPluginResult*)init
{
    return [self initWithStatus:CDVCommandStatus_NO_RESULT message:nil];
}

- (LDJSPluginResult*)initWithStatus:(CDVCommandStatus)statusOrdinal message:(id)theMessage
{
    self = [super init];
    if (self) {
        status = [NSNumber numberWithInt:statusOrdinal];
        message = theMessage;
        keepCallback = [NSNumber numberWithBool:NO];
    }
    return self;
}

+ (LDJSPluginResult*)resultWithStatus:(CDVCommandStatus)statusOrdinal
{
    return [[self alloc] initWithStatus:statusOrdinal message:nil];
}

+ (LDJSPluginResult*)resultWithStatus:(CDVCommandStatus)statusOrdinal messageAsString:(NSString*)theMessage
{
    return [[self alloc] initWithStatus:statusOrdinal message:theMessage];
}

+ (LDJSPluginResult*)resultWithStatus:(CDVCommandStatus)statusOrdinal messageAsArray:(NSArray*)theMessage
{
    return [[self alloc] initWithStatus:statusOrdinal message:theMessage];
}

+ (LDJSPluginResult*)resultWithStatus:(CDVCommandStatus)statusOrdinal messageAsInt:(int)theMessage
{
    return [[self alloc] initWithStatus:statusOrdinal message:[NSNumber numberWithInt:theMessage]];
}

+ (LDJSPluginResult*)resultWithStatus:(CDVCommandStatus)statusOrdinal messageAsDouble:(double)theMessage
{
    return [[self alloc] initWithStatus:statusOrdinal message:[NSNumber numberWithDouble:theMessage]];
}

+ (LDJSPluginResult*)resultWithStatus:(CDVCommandStatus)statusOrdinal messageAsBool:(BOOL)theMessage
{
    return [[self alloc] initWithStatus:statusOrdinal message:[NSNumber numberWithBool:theMessage]];
}

+ (LDJSPluginResult*)resultWithStatus:(CDVCommandStatus)statusOrdinal messageAsDictionary:(NSDictionary*)theMessage
{
    return [[self alloc] initWithStatus:statusOrdinal message:theMessage];
}

+ (LDJSPluginResult*)resultWithStatus:(CDVCommandStatus)statusOrdinal messageAsArrayBuffer:(NSData*)theMessage
{
    return [[self alloc] initWithStatus:statusOrdinal message:messageFromArrayBuffer(theMessage)];
}

+ (LDJSPluginResult*)resultWithStatus:(CDVCommandStatus)statusOrdinal messageAsMultipart:(NSArray*)theMessages
{
    return [[self alloc] initWithStatus:statusOrdinal message:messageFromMultipart(theMessages)];
}

+ (LDJSPluginResult*)resultWithStatus:(CDVCommandStatus)statusOrdinal messageToErrorObject:(int)errorCode
{
    NSDictionary* errDict = @{@"code" :[NSNumber numberWithInt:errorCode]};

    return [[self alloc] initWithStatus:statusOrdinal message:errDict];
}

- (void)setKeepCallbackAsBool:(BOOL)bKeepCallback
{
    [self setKeepCallback:[NSNumber numberWithBool:bKeepCallback]];
}

- (NSString*)argumentsAsJSON
{
    id arguments = (self.message == nil ? [NSNull null] : self.message);
    NSArray* argumentsWrappedInArray = [NSArray arrayWithObject:arguments];

    NSString* argumentsJSON = [argumentsWrappedInArray cdv_JSONString];

    argumentsJSON = [argumentsJSON substringWithRange:NSMakeRange(1, [argumentsJSON length] - 2)];

    return argumentsJSON;
}

// These methods are used by the legacy plugin return result method
- (NSString*)toJSONString
{
    NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:
        self.status, @"status",
        self.message ? self.                                message:[NSNull null], @"message",
        self.keepCallback, @"keepCallback",
        nil];

    NSError* error = nil;
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    NSString* resultString = nil;

    if (error != nil) {
        NSLog(@"toJSONString error: %@", [error localizedDescription]);
    } else {
        resultString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }

    if ([[self class] isVerbose]) {
        NSLog(@"PluginResult:toJSONString - %@", resultString);
    }
    return resultString;
}

- (NSString*)toSuccessCallbackString:(NSString*)callbackId
{

    NSString* successCB = @"";
    //如果callbackId 以数字开头, 为回调函数的index
    NSString *argumentsAsJSON = [self argumentsAsJSON];
    argumentsAsJSON = [argumentsAsJSON stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    if([callbackId intValue] > 0){
        successCB= [successCB stringByAppendingFormat:@"mapp.execGlobalCallback(%d,'%@');",[callbackId intValue], argumentsAsJSON];
    }
    //否则为直接调回调函数
    else {
        successCB= [successCB stringByAppendingFormat:@"window.%@('%@');",callbackId,  argumentsAsJSON];
    }
    
    if ([[self class] isVerbose]) {
        NSLog(@"PluginResult toSuccessCallbackString: %@", successCB);
    }
    return successCB;
}

- (NSString*)toErrorCallbackString:(NSString*)callbackId
{
    NSString* errorCB = @"";
    //如果callbackId 以数字开头, 为回调函数的index
    NSString *argumentsAsJSON = [self argumentsAsJSON];
     argumentsAsJSON = [argumentsAsJSON stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    if([callbackId intValue] > 0){
        errorCB= [errorCB stringByAppendingFormat:@"mapp.execGlobalCallback(%d,'%@');",[callbackId intValue], argumentsAsJSON];
    }
    //否则为直接调回调函数
    else {
        errorCB= [errorCB stringByAppendingFormat:@"window.%@('%@');",callbackId,  argumentsAsJSON];
    }

    if ([[self class] isVerbose]) {
        NSLog(@"PluginResult toErrorCallbackString: %@", errorCB);
    }
    return errorCB;
}

static BOOL gIsVerbose = NO;
+ (void)setVerbose:(BOOL)verbose
{
    gIsVerbose = verbose;
}

+ (BOOL)isVerbose
{
    return gIsVerbose;
}

@end