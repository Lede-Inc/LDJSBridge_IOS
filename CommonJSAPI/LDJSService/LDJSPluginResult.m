//
//  LDJSService.h
//  CommonJSAPI
//
//  Created by 庞辉 on 14-10-13.
//  Copyright (c) 2014年 庞辉. All rights reserved.
//
#import "LDJSPluginResult.h"
#import "LDJSJSON.h"


@interface LDJSPluginResult (){
    
}

-(LDJSPluginResult*)initWithStatus:(LDJSCommandStatus)statusOrdinal message:(id)theMessage;

@end




@implementation LDJSPluginResult
@synthesize status, message;

#pragma mark - init method
- (LDJSPluginResult*)init{
    return [self initWithStatus:LDJSCommandStatus_NO_RESULT message:nil];
}


- (LDJSPluginResult*)initWithStatus:(LDJSCommandStatus)statusOrdinal message:(id)theMessage{
    self = [super init];
    if (self) {
        status = [NSNumber numberWithInt:statusOrdinal];
        message = theMessage;
    }
    return self;
}


#pragma mark 封装返回数据
+ (LDJSPluginResult*)resultWithStatus:(LDJSCommandStatus)statusOrdinal{
    return [[self alloc] initWithStatus:statusOrdinal message:nil];
}

+ (LDJSPluginResult*)resultWithStatus:(LDJSCommandStatus)statusOrdinal messageAsString:(NSString*)theMessage{
    return [[self alloc] initWithStatus:statusOrdinal message:theMessage];
}

+ (LDJSPluginResult*)resultWithStatus:(LDJSCommandStatus)statusOrdinal messageAsArray:(NSArray*)theMessage{
    return [[self alloc] initWithStatus:statusOrdinal message:theMessage];
}

+ (LDJSPluginResult*)resultWithStatus:(LDJSCommandStatus)statusOrdinal messageAsInt:(int)theMessage{
    return [[self alloc] initWithStatus:statusOrdinal message:[NSNumber numberWithInt:theMessage]];
}

+ (LDJSPluginResult*)resultWithStatus:(LDJSCommandStatus)statusOrdinal messageAsDouble:(double)theMessage{
    return [[self alloc] initWithStatus:statusOrdinal message:[NSNumber numberWithDouble:theMessage]];
}

+ (LDJSPluginResult*)resultWithStatus:(LDJSCommandStatus)statusOrdinal messageAsBool:(BOOL)theMessage{
    return [[self alloc] initWithStatus:statusOrdinal message:[NSNumber numberWithBool:theMessage]];
}

+ (LDJSPluginResult*)resultWithStatus:(LDJSCommandStatus)statusOrdinal messageAsDictionary:(NSDictionary*)theMessage{
    return [[self alloc] initWithStatus:statusOrdinal message:theMessage];
}

+ (LDJSPluginResult*)resultWithStatus:(LDJSCommandStatus)statusOrdinal messageToErrorObject:(int)errorCode{
    NSDictionary* errDict = @{@"code" :[NSNumber numberWithInt:errorCode]};
    return [[self alloc] initWithStatus:statusOrdinal message:errDict];
}


#pragma mark 将返回数据统一转化成JSON
- (NSString*)argumentsAsJSON{
    id arguments = (self.message == nil ? [NSNull null] : self.message);
    
    //通过Array封装成JSON数组，然后去掉两头的括号
    NSArray* argumentsWrappedInArray = [NSArray arrayWithObject:arguments];
    NSString* argumentsJSON = [argumentsWrappedInArray cdv_JSONString];
    argumentsJSON = [argumentsJSON substringWithRange:NSMakeRange(1, [argumentsJSON length] - 2)];
    return argumentsJSON;
}


- (NSString*)toJSONString{
    NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:
        self.status, @"status",
        self.message ? self.message:[NSNull null], @"message",
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
    
    return resultString;
}

#pragma mark - 将处理结果封装成执行字符串
- (NSString*)toJsCallbackString:(NSString*)callbackId{
    NSString* successCB = @"";
    NSString *argumentsAsJSON = [self argumentsAsJSON];
    argumentsAsJSON = [argumentsAsJSON stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    if([callbackId intValue] > 0){
        successCB= [successCB stringByAppendingFormat:@"mapp.execGlobalCallback(%d,'%@');",[callbackId intValue], argumentsAsJSON];
    }else {
        successCB= [successCB stringByAppendingFormat:@"window.%@('%@');",callbackId,  argumentsAsJSON];
    }
    
    return successCB;
}

@end
