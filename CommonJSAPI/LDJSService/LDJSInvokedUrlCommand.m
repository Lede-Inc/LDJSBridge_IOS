//
//  LDJSCommandQueue.h
//  CommonJSAPI
//
//  Created by 庞辉 on 14-10-13.
//  Copyright (c) 2014年 庞辉. All rights reserved.
//

#import "LDJSInvokedUrlCommand.h"
#import "LDJSJSON.h"



@implementation LDJSInvokedUrlCommand
@synthesize jsonParams = _jsonParams;
@synthesize arguments = _arguments;
@synthesize callbackId = _callbackId;
@synthesize pluginName = _pluginName;
@synthesize pluginShowMethod = _pluginShowMethod;

#pragma mark init
+ (LDJSInvokedUrlCommand*)commandFromJson:(NSArray*)jsonEntry{
    return [[LDJSInvokedUrlCommand alloc] initFromJson:jsonEntry];
}


- (id)initFromJson:(NSArray*)jsonEntry{
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
             methodName:(NSString*)methodName{
    self = [super init];
    if (self != nil) {
        _jsonParams = jsonParams;
        _arguments = arguments;
        _callbackId = callbackId;
        _pluginName = className;
        _pluginShowMethod = methodName;
    }
    
    return self;
}

#pragma mark - 获取JSON参数
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


#pragma mark - 获取Array参数
- (id)argumentAtIndex:(NSUInteger)index{
    return [self argumentAtIndex:index withDefault:nil];
}


- (id)argumentAtIndex:(NSUInteger)index withDefault:(id)defaultValue{
    return [self argumentAtIndex:index withDefault:defaultValue andClass:nil];
}


- (id)argumentAtIndex:(NSUInteger)index withDefault:(id)defaultValue andClass:(Class)aClass{
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
