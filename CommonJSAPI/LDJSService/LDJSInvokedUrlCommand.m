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

#import "LDJSInvokedUrlCommand.h"
#import "LDJSJSON.h"
#import "LDJSDataBase64.h"

@implementation LDJSInvokedUrlCommand

@synthesize jsonParams = _jsonParams;
@synthesize arguments = _arguments;
@synthesize callbackId = _callbackId;
@synthesize className = _className;
@synthesize methodName = _methodName;

+ (LDJSInvokedUrlCommand*)commandFromJson:(NSArray*)jsonEntry
{
    return [[LDJSInvokedUrlCommand alloc] initFromJson:jsonEntry];
}

- (id)initFromJson:(NSArray*)jsonEntry
{
    id tmp = [jsonEntry objectAtIndex:0];
    NSString* callbackId = tmp == [NSNull null] ? nil : tmp;
    NSString* className = [jsonEntry objectAtIndex:1];
    NSString* methodName = [jsonEntry objectAtIndex:2];
    NSMutableArray* arguments = [jsonEntry objectAtIndex:3];
    NSArray* arr_jsonParams = [jsonEntry objectAtIndex:4];
    NSMutableDictionary *jsonParams = nil;
    if(arr_jsonParams && arr_jsonParams.count > 0){
        jsonParams = [arr_jsonParams objectAtIndex:0];
    } else {
        jsonParams = [[NSMutableDictionary alloc] initWithCapacity:2];
    }

    return [self initWithJsonParams:jsonParams
                        Arguments:arguments
                        callbackId:callbackId
                         className:className
                        methodName:methodName];
}

- (id)initWithJsonParams:(NSDictionary*)jsonParams
            Arguments:(NSArray*)arguments
             callbackId:(NSString*)callbackId
              className:(NSString*)className
             methodName:(NSString*)methodName
{
    self = [super init];
    if (self != nil) {
        _jsonParams = jsonParams;
        _arguments = arguments;
        _callbackId = callbackId;
        _className = className;
        _methodName = methodName;
    }
    
    return self;
}

-(id)jsonParamForkey: (NSString *)key {
    return [self jsonParamForkey:key withDefault:nil];
}

-(id)jsonParamForkey:(NSString *)key withDefault:(id)defaultValue{
    return [self jsonParamForkey:key withDefault:defaultValue andClass:nil];
}


-(id)jsonParamForkey:(NSString *)key withDefault:(id)defaultValue andClass:(Class) aClass{
    id jsonvalue = [_jsonParams objectForKey:[key lowercaseString]];
    if(jsonvalue == nil || jsonvalue ==  [NSNull null]) {
        return defaultValue;
    }
    
    if(aClass != nil && ![jsonvalue isKindOfClass:aClass]){
        jsonvalue = defaultValue;
    }
    
    return jsonvalue;
}



- (id)argumentAtIndex:(NSUInteger)index
{
    return [self argumentAtIndex:index withDefault:nil];
}

- (id)argumentAtIndex:(NSUInteger)index withDefault:(id)defaultValue
{
    return [self argumentAtIndex:index withDefault:defaultValue andClass:nil];
}

- (id)argumentAtIndex:(NSUInteger)index withDefault:(id)defaultValue andClass:(Class)aClass
{
    if (index >= [_arguments count]) {
        return defaultValue;
    }
    id ret = [_arguments objectAtIndex:index];
    if (ret == [NSNull null]) {
        ret = defaultValue;
    }
    if ((aClass != nil) && ![ret isKindOfClass:aClass]) {
        ret = defaultValue;
    }
    return ret;
}


@end
