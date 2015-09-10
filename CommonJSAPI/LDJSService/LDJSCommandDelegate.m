//
//  LDJSCommandDelegateImpl.m
//  CommonJSAPI
//
//  Created by 庞辉 on 14-10-13.
//  Copyright (c) 2014年 庞辉. All rights reserved.
//

#import "LDJSCommandDelegate.h"
#import "LDJSPluginResult.h"

#import "LDJSCommandQueue.h"
#import "LDJSService.h"

@interface LDJSCommandDelegateImpl () {
  @private
    __weak LDJSService *_bridgeService;
    NSRegularExpression *_callbackIdPattern;
}

@end


@implementation LDJSCommandDelegateImpl

- (id)initWithService:(LDJSService *)jsService
{
    self = [super init];
    if (self != nil) {
        _bridgeService = jsService;
        _callbackIdPattern = nil;
    }
    return self;
}


/**
 * 验证url传入的回调函数是否合法
 * 只允许有大小字母、数字、下划线、中划线、小数点组成的callbackID有效
 * @param callbackId 回调函数
 */
- (BOOL)isValidCallbackId:(NSString *)callbackId
{
    NSError *err = nil;
    if (callbackId == nil) {
        return NO;
    }

    //回调函数的合法pattern
    if (_callbackIdPattern == nil) {
        _callbackIdPattern = [NSRegularExpression regularExpressionWithPattern:@"[^A-Za-z0-9._-]"
                                                                       options:0
                                                                         error:&err];
        if (err != nil) {
            return NO;
        }
    }

    // Disallow if too long or if any invalid characters were found.
    if (([callbackId length] > 100) ||
        [_callbackIdPattern firstMatchInString:callbackId
                                       options:0
                                         range:NSMakeRange(0, [callbackId length])]) {
        return NO;
    }
    return YES;
}


/**
 *@func 执行完plugin之后通过回调函数返回数据
 *@param callbackId 回调函数
 */
- (void)sendPluginResult:(LDJSPluginResult *)result callbackId:(NSString *)callbackId
{
    if (![self isValidCallbackId:callbackId]) {
        NSLog(@"Invalid callback id received by sendPluginResult");
        return;
    }

    //将结果转化成json字符串
    NSString *argumentsAsJSON = [result argumentsAsJSON];
    argumentsAsJSON = [argumentsAsJSON stringByReplacingOccurrencesOfString:@"\n" withString:@""];

    NSString *js = @"";
    //如果callbackId 以数字开头, 为回调函数的index
    if ([callbackId intValue] > 0) {
        js = [js stringByAppendingFormat:@"mapp.execGlobalCallback(%d,'%@');",
                                         [callbackId intValue], argumentsAsJSON];
    }

    //否则为直接调回调函数
    else {
        js = [js stringByAppendingFormat:@"window.%@('%@');", callbackId, argumentsAsJSON];
    }

    [_bridgeService jsEval:js];
}

@end
