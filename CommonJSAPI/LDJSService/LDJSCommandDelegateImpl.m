//
//  LDJSCommandDelegateImpl.m
//  CommonJSAPI
//
//  Created by 庞辉 on 14-10-13.
//  Copyright (c) 2014年 庞辉. All rights reserved.
//

#import "LDJSCommandDelegateImpl.h"
#import "LDJSCDV.h"

@implementation LDJSCommandDelegateImpl

- (id)initWithService:(LDJSService *)jsService{
    self = [super init];
    if (self != nil) {
        _jsService = jsService;
        _commandQueue = _jsService.commandQueue;
        _callbackIdPattern = nil;
    }
    return self;
}

/**
 *@func 获得jsService中创建的的插件实例
 */
- (id)getCommandInstance:(NSString*)pluginName
{
    return [_jsService getCommandInstance:pluginName];
}


/**
 *@func 重新执行被耽搁的js
 */
- (void)flushCommandQueueWithDelayedJs{
    _delayResponses = YES;
    [_commandQueue executePending];
    _delayResponses = NO;
}


/**
 *@func 验证url传入的回调函数是否合法
 *@param callbackId 回调函数
 */
- (BOOL)isValidCallbackId:(NSString*)callbackId{
    NSError* err = nil;
    
    if (callbackId == nil) {
        return NO;
    }
    
    // Initialize on first use
    if (_callbackIdPattern == nil) {
        // Catch any invalid characters in the callback id.
        _callbackIdPattern = [NSRegularExpression regularExpressionWithPattern:@"[^A-Za-z0-9._-]" options:0 error:&err];
        if (err != nil) {
            // Couldn't initialize Regex; No is safer than Yes.
            return NO;
        }
    }
    // Disallow if too long or if any invalid characters were found.
    if (([callbackId length] > 100) || [_callbackIdPattern firstMatchInString:callbackId options:0 range:NSMakeRange(0, [callbackId length])]) {
        return NO;
    }
    return YES;
}


/**
 *@func 执行完plugin之后通过回调函数返回数据
 *@param callbackId 回调函数
 */
- (void)sendPluginResult:(LDJSPluginResult*)result callbackId:(NSString*)callbackId{
    NSLog(@"Exec(%@): Sending result. Status=%@", callbackId, result.status);
    // This occurs when there is are no win/fail callbacks for the call.
    if ([@"INVALID" isEqualToString : callbackId]) {
        return;
    }
    // This occurs when the callback id is malformed.
    if (![self isValidCallbackId:callbackId]) {
        NSLog(@"Invalid callback id received by sendPluginResult");
        return;
    }
    
    //  int status = [result.status intValue];
    //  BOOL keepCallback = [result.keepCallback boolValue];
    NSString* argumentsAsJSON = [result argumentsAsJSON];
    argumentsAsJSON = [argumentsAsJSON stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    NSString *js = @"";
    
    //如果callbackId 以数字开头, 为回调函数的index
    if([callbackId intValue] > 0){
        js= [js stringByAppendingFormat:@"mapp.execGlobalCallback(%d,'%@');",[callbackId intValue], argumentsAsJSON];
    }
    
    //否则为直接调回调函数
    else {
        js= [js stringByAppendingFormat:@"window.%@('%@');",callbackId,  argumentsAsJSON];
    }
    
    NSLog(@"js>>>>>>>>>%@", js);
    [self evalJsHelper:js];
}


/**
 *@fun 主线程执行js代码
 */
- (void)evalJsHelper:(NSString*)js
{
    // Cycle the run-loop before executing the JS.
    // For _delayResponses -
    //    This ensures that we don't eval JS during the middle of an existing JS
    //    function (possible since UIWebViewDelegate callbacks can be synchronous).
    // For !isMainThread -
    //    It's a hard error to eval on the non-UI thread.
    // For !_commandQueue.currentlyExecuting -
    //     This works around a bug where sometimes alerts() within callbacks can cause
    //     dead-lock.
    //     If the commandQueue is currently executing, then we know that it is safe to
    //     execute the callback immediately.
    // Using    (dispatch_get_main_queue()) does *not* fix deadlocks for some reason,
    // but performSelectorOnMainThread: does.
    
    //如果当前队列正在执行延迟的命令、非主线程或者当前队列并没有在执行过程中，需要在主线程中完成js调用
    if (_delayResponses || ![NSThread isMainThread] || !_commandQueue.currentlyExecuting) {
        [self performSelectorOnMainThread:@selector(evalJsHelper2:) withObject:js waitUntilDone:NO];
    } else {
        [self evalJsHelper2:js];
    }
}

- (void)evalJsHelper2:(NSString*)js
{
    NSLog(@"Exec: evalling: %@", [js substringToIndex:MIN([js length], 160)]);
    NSString* commandsJSON = [_jsService.webView stringByEvaluatingJavaScriptFromString:js];
    if ([commandsJSON length] > 0) {
        NSLog(@"Exec: Retrieved new exec messages by chaining.");
    }
    
    [_commandQueue enqueueCommandBatch:commandsJSON];
    [_commandQueue executePending];
}



/*
 *供插件直接执行js代码
 */
- (void)evalJs:(NSString*)js{
    [self evalJs:js scheduledOnRunLoop:YES];
}

- (void)evalJs:(NSString*)js scheduledOnRunLoop:(BOOL)scheduledOnRunLoop{
    if (scheduledOnRunLoop) {
        [self evalJsHelper:js];
    } else {
        [self evalJsHelper2:js];
    }
}

- (void)runInBackground:(void (^)())block
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block);
}

@end
