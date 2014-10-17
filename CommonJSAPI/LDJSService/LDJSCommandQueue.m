//
//  LDJSCommandQueue.m
//  CommonJSAPI
//
//  Created by 庞辉 on 14-10-13.
//  Copyright (c) 2014年 庞辉. All rights reserved.
//

#include <objc/message.h>
#import "LDJSCommandQueue.h"
#import "LDJSCDV.h"

// Parse JS on the main thread if it's shorter than this.
static const NSInteger JSON_SIZE_FOR_MAIN_THREAD = 4 * 1024; // Chosen arbitrarily.
// Execute multiple commands in one go until this many seconds have passed.
static const double MAX_EXECUTION_TIME = .008; // Half of a 60fps frame.

@interface LDJSCommandQueue () {
    __weak LDJSService* _jsService;
    NSMutableArray* _queue;
    NSTimeInterval _startExecutionTime;
}
@end

@implementation LDJSCommandQueue

- (BOOL)currentlyExecuting
{
    return _startExecutionTime > 0;
}

- (id)initWithService:(LDJSService *)jsService
{
    self = [super init];
    if (self != nil) {
        _jsService = jsService;
        _queue = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dispose
{
    // TODO(agrieve): Make this a zeroing weak ref once we drop support for 4.3.
    _jsService = nil;
}

//参数构成：[["Device590967717","Device","getDeviceInfo",[]]]
/*
 * urlstr构成：
 * 1.调用普通接口：
 *   mapp.invoke("ns","method"),
 *   jsbridge://device/getNetworkInfo#7
 *
 * 2.调用有返回值的接口：
 *   mapp.invoke("ns","method",function(){}),
 *
 * 3.调用有异步回调的接口：
 *   mapp.invoke("ns","method",{})
 *   jsbridge://device/setScreenStatus?p={"status":"1","callback":"__MQQ_CALLBACK_12"}#13
 *
 * 4.有多个参数的调用：
 */
//从识别url中加入参数
-(void) fetchCommandsFromUrl:(NSString *)urlstr{
    //去掉scheme
    NSString *queuedCommandsJSON = @"";
    NSRange rg = [urlstr rangeOfString:@"://"];
    urlstr = [urlstr substringFromIndex:(rg.location + rg.length)];
    
    //去掉＃
    NSArray *arr_headAndfoot = [urlstr componentsSeparatedByString:@"#"];
    NSString *callIndex = @"";
    if(arr_headAndfoot.count >= 2) {
        callIndex = [arr_headAndfoot objectAtIndex:1];
    }
    NSString *mcontent = [arr_headAndfoot objectAtIndex:0];
    NSArray *arr_qmark = [mcontent componentsSeparatedByString:@"?"];
    
    //切割类和方法, class和method在js中作了urlencode
    NSString *str_classAndmethod = [arr_qmark objectAtIndex:0];
    NSArray *arr_classAndmethod = [str_classAndmethod componentsSeparatedByString:@"/"];
    NSString *className = (NSString *)CFBridgingRelease(CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL, (CFStringRef) [arr_classAndmethod objectAtIndex:0], CFSTR(""), kCFStringEncodingUTF8));
    NSString *methodName = (NSString *)CFBridgingRelease(CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL, (CFStringRef) [arr_classAndmethod objectAtIndex:1], CFSTR(""), kCFStringEncodingUTF8));
    
    
    //如果url有参数，切割传入的参数
    NSMutableArray *arr_params = nil;
    NSMutableDictionary *dic_params = nil;
    if(arr_qmark.count >= 2){
        NSString *str_param = [arr_qmark objectAtIndex:1];
        NSLog(@"%@", str_param);
        
        //分割&参数
        NSArray *arr_andMark = [str_param componentsSeparatedByString:@"&"];
        if(arr_andMark.count > 0){
            arr_params = [[NSMutableArray alloc] initWithCapacity:4];
            for(NSString *str_param in arr_andMark){
                //分割p参数,每一个参数都进行了urlDecode
                NSArray *arr_qualMark = [str_param componentsSeparatedByString:@"="];
                if(arr_qualMark.count == 2){
                    NSString *value_param = (NSString *)CFBridgingRelease(CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL, (CFStringRef) [arr_qualMark objectAtIndex:1], CFSTR(""), kCFStringEncodingUTF8));
                    [arr_params addObject:value_param];
                }//if
            }//for
        }
        
        
        //遍历参数数组，检查json参数，作二级分析
        if(arr_params.count > 0){
            NSEnumerator *iterator = [arr_params objectEnumerator];
            id tmpObj;
            while (tmpObj = [iterator nextObject]) {
                if([tmpObj cdv_JSONObject] == nil){
                    continue;
                }
                
                NSDictionary *tmp_dic =(NSDictionary *)[tmpObj cdv_JSONObject];
                NSArray *keys = [tmp_dic allKeys];
                if(keys.count > 0 && dic_params == nil){
                    dic_params = [[NSMutableDictionary alloc] initWithCapacity:2];
                }
                
                //拷贝key和对应的value
                for(int j = 0; j < [keys count]; j++){
                    NSString *key = [keys objectAtIndex:j];
                    if([[key lowercaseString] isEqualToString:@"callback"]){
                        callIndex = [tmp_dic objectForKey:key];
                    } else {
                        [dic_params setObject:[tmp_dic objectForKey:key] forKey:[key lowercaseString]];
                    }
                }
                
                //处理完删除该参数
                [arr_params removeObject:tmpObj];
            }
        }
        
    }//if
    
    
    
    
    //组装p参数
    NSString *str_comparams = @"[";
    if(arr_params && arr_params.count > 0){
        for(int j=0; j< arr_params.count; j++){
            id obj_param = [arr_params objectAtIndex:j];
            if([obj_param isKindOfClass:[NSArray class]] || [obj_param isKindOfClass:[NSDictionary class]]){
                obj_param = [obj_param cdv_JSONString];
                obj_param = [obj_param stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                obj_param = [obj_param stringByReplacingOccurrencesOfString:@"\"" withString:@"\'"];
            }
            str_comparams = [str_comparams stringByAppendingFormat:@"\"%@\"%@", obj_param,(j==arr_params.count-1?@"":@",")];
        }
    }
    str_comparams = [str_comparams stringByAppendingString:@"]"];
    
    
    //组装json参数
    NSString *str_jsonparams = @"";
    if(dic_params != nil) {
        str_jsonparams = [dic_params cdv_JSONString];
        str_jsonparams = [str_jsonparams stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    }
    
    
    //组装command
    queuedCommandsJSON = [queuedCommandsJSON stringByAppendingFormat:@"[[\"%@\", \"%@\", \"%@\",%@,[%@]]]", callIndex,className,methodName, str_comparams, str_jsonparams];
    [self enqueueCommandBatch:queuedCommandsJSON];
}


- (void)enqueueCommandBatch:(NSString*)batchJSON
{
    if ([batchJSON length] > 0) {
        NSMutableArray* commandBatchHolder = [[NSMutableArray alloc] init];
        [_queue addObject:commandBatchHolder];
        if ([batchJSON length] < JSON_SIZE_FOR_MAIN_THREAD) {
            NSLog(@"%@", batchJSON);
            [commandBatchHolder addObject:[batchJSON cdv_JSONObject]];
        } else {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^() {
                NSMutableArray* result = [batchJSON cdv_JSONObject];
                @synchronized(commandBatchHolder) {
                    [commandBatchHolder addObject:result];
                }
                [self performSelectorOnMainThread:@selector(executePending) withObject:nil waitUntilDone:NO];
            });
        }
    }
}



- (void)executePending
{
    // Make us re-entrant-safe.
    if (_startExecutionTime > 0) {
        return;
    }
    @try {
        _startExecutionTime = [NSDate timeIntervalSinceReferenceDate];
        
        while ([_queue count] > 0) {
            NSMutableArray* commandBatchHolder = _queue[0];
            NSMutableArray* commandBatch = nil;
            @synchronized(commandBatchHolder) {
                // If the next-up command is still being decoded, wait for it.
                if ([commandBatchHolder count] == 0) {
                    break;
                }
                commandBatch = commandBatchHolder[0];
            }
            
            while ([commandBatch count] > 0) {
                @autoreleasepool {
                    // Execute the commands one-at-a-time.
                    NSArray* jsonEntry = [commandBatch cdv_dequeue];
                    if ([commandBatch count] == 0) {
                        [_queue removeObjectAtIndex:0];
                    }
                    LDJSInvokedUrlCommand* command = [LDJSInvokedUrlCommand commandFromJson:jsonEntry];
                    NSLog(@"Exec(%@): Calling %@.%@", command.callbackId, command.className, command.methodName);
                    
                    if (![self execute:command]) {
#ifdef DEBUG
                        NSString* commandJson = [jsonEntry cdv_JSONString];
                        static NSUInteger maxLogLength = 1024;
                        NSString* commandString = ([commandJson length] > maxLogLength) ?
                        [NSString stringWithFormat:@"%@[...]", [commandJson substringToIndex:maxLogLength]] :
                        commandJson;
                        
                        NSLog(@"FAILED pluginJSON = %@", commandString);
#endif
                    }
                }
                
                // Yield if we're taking too long.
                if (([_queue count] > 0) && ([NSDate timeIntervalSinceReferenceDate] - _startExecutionTime > MAX_EXECUTION_TIME)) {
                    [self performSelector:@selector(executePending) withObject:nil afterDelay:0];
                    return;
                }
            }
        }
    } @finally
    {
        _startExecutionTime = 0;
    }
}

- (BOOL)execute:(LDJSInvokedUrlCommand*)command
{
    if ((command.className == nil) || (command.methodName == nil)) {
        NSLog(@"ERROR: Classname and/or methodName not found for command.");
        return NO;
    }
    
    // Fetch an instance of this class
    LDJSPlugin* obj = [_jsService.commandDelegate getCommandInstance:command.className];
    
    if (!([obj isKindOfClass:[LDJSPlugin class]])) {
        NSLog(@"ERROR: Plugin '%@' not found, or is not a LDJSPlugin. Check your plugin mapping in config.xml.", command.className);
        return NO;
    }
    BOOL retVal = YES;
    double started = [[NSDate date] timeIntervalSince1970] * 1000.0;
    // Find the proper selector to call.
    NSString* methodName = [NSString stringWithFormat:@"%@:", command.methodName];
    SEL normalSelector = NSSelectorFromString(methodName);
    if ([obj respondsToSelector:normalSelector]) {
        // [obj performSelector:normalSelector withObject:command];
        ((void (*)(id, SEL, id))objc_msgSend)(obj, normalSelector, command);
    } else {
        // There's no method to call, so throw an error.
        NSLog(@"ERROR: Method '%@' not defined in Plugin '%@'", methodName, command.className);
        retVal = NO;
    }
    double elapsed = [[NSDate date] timeIntervalSince1970] * 1000.0 - started;
    if (elapsed > 10) {
        NSLog(@"THREAD WARNING: ['%@'] took '%f' ms. Plugin should use a background thread.", command.className, elapsed);
    }
    return retVal;
}

@end
