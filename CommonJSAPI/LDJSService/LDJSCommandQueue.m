//
//  LDJSCommandQueue.m
//  CommonJSAPI
//
//  Created by 庞辉 on 14-10-13.
//  Copyright (c) 2014年 庞辉. All rights reserved.
//

#include <objc/message.h>
#import "LDJSJSON.h"
#import "LDJSQueue.h"
#import "LDJSInvokedUrlCommand.h"
#import "LDJSCommandQueue.h"

#import "LDJSPlugin.h"
#import "LDJSService.h"

//启用主线程执行最小command长度
static const NSInteger JSON_SIZE_FOR_MAIN_THREAD = 4 * 1024;
//一次执行命令的最长允许执行时间
static const double MAX_EXECUTION_TIME = .008;  // Half of a 60fps frame.


@interface LDJSCommandQueue () {
    __weak LDJSService *_jsService;
    NSMutableArray *_queue;  // js调用命令存储
    NSTimeInterval _startExecutionTime;  //存储开始执行时间
}
@end


@implementation LDJSCommandQueue


- (id)initWithService:(LDJSService *)jsService
{
    self = [super init];
    if (self != nil) {
        _jsService = jsService;
        _queue = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc
{
    _jsService = nil;
    [_queue removeAllObjects];
    _queue = nil;
}


- (void)dispose
{
    _jsService = nil;
}


- (BOOL)currentlyExecuting
{
    return _startExecutionTime > 0;
}


- (void)excuteCommandsFromUrl:(NSString *)urlstr
{
    NSURL *commandURL = [NSURL URLWithString:urlstr];
    NSString *host = commandURL.host;
    NSString *pathStr = commandURL.path;
    NSString *query = commandURL.query;
    NSString *fragement = commandURL.fragment;

    //获取url回调函数的index
    __block NSString *callIndex = @"";
    if (fragement && ![fragement isEqualToString:@""] && [fragement intValue] > 0) {
        callIndex = fragement;
    }

    //获取调用插件名
    NSString *pluginName = @"";
    if (host && ![host isEqualToString:@""]) {
        pluginName =
            (NSString *)CFBridgingRelease(CFURLCreateStringByReplacingPercentEscapesUsingEncoding(
                NULL, (CFStringRef)host, CFSTR(""), kCFStringEncodingUTF8));
    }

    //获取调用方法名，规定第一个host为方法名
    NSString *methodShowName = @"";
    if (pathStr && ![pathStr isEqualToString:@""]) {
        NSArray *paths = [pathStr componentsSeparatedByString:@"/"];
        if (paths && paths.count >= 2 && [[paths objectAtIndex:0] isEqualToString:@""] &&
            ![[paths objectAtIndex:1] isEqualToString:@""]) {
            methodShowName = (NSString *)CFBridgingRelease(
                CFURLCreateStringByReplacingPercentEscapesUsingEncoding(
                    NULL, (CFStringRef)[paths objectAtIndex:1], CFSTR(""), kCFStringEncodingUTF8));
        }
    }

    //获取通过URL query对象传进来的参数
    NSMutableArray *arr_params = nil;
    if (query && query.length > 0) {
        NSArray *queryParas = [query componentsSeparatedByString:@"&"];
        if (queryParas && queryParas.count > 0) {
            arr_params = [[NSMutableArray alloc] initWithCapacity:4];
            for (NSString *queryObjStr in queryParas) {
                //分割p参数,每一个参数都进行了urlDecode
                NSArray *arr_qualMark = [queryObjStr componentsSeparatedByString:@"="];
                if (arr_qualMark.count == 2) {
                    NSString *value_param = (NSString *)CFBridgingRelease(
                        CFURLCreateStringByReplacingPercentEscapesUsingEncoding(
                            NULL, (CFStringRef)[arr_qualMark objectAtIndex:1], CFSTR(""),
                            kCFStringEncodingUTF8));
                    [arr_params addObject:value_param];
                }  // if
            }  // for
        }
    }


    //遍历参数数组，检查json参数, 记录JSon参数供使用
    NSMutableDictionary *dic_params = nil;
    if (arr_params && arr_params.count > 0) {
        for (NSString *paramStr in arr_params) {
            if ([paramStr cdv_JSONObject] == nil) {
                continue;
            }

            NSDictionary *tmp_dic = (NSDictionary *)[paramStr cdv_JSONObject];
            if (tmp_dic && [tmp_dic allKeys].count > 0 && dic_params == nil) {
                dic_params = [[NSMutableDictionary alloc] initWithCapacity:2];
            }

            //便利JSON参数
            [tmp_dic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                if ([[key lowercaseString] isEqualToString:@"callback"]) {
                    callIndex = obj;
                }

                [dic_params setObject:obj forKey:key];
            }];

            //从param中删除参数
            [arr_params removeObject:paramStr];
        }
    }  // if


    //组装p参数
    NSString *str_comparams = @"";
    if (arr_params && arr_params.count > 0) {
        for (int j = 0; j < arr_params.count; j++) {
            id obj_param = [arr_params objectAtIndex:j];
            if ([obj_param isKindOfClass:[NSArray class]] ||
                [obj_param isKindOfClass:[NSDictionary class]]) {
                obj_param = [obj_param cdv_JSONString];
                obj_param = [obj_param stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                obj_param = [obj_param stringByReplacingOccurrencesOfString:@"\"" withString:@"\'"];
            }
            str_comparams =
                [str_comparams stringByAppendingFormat:@"\"%@\"%@", obj_param,
                                                       (j == arr_params.count - 1 ? @"" : @",")];
        }
    }


    //组装json参数
    NSString *str_jsonparams = @"";
    if (dic_params != nil) {
        str_jsonparams = [dic_params cdv_JSONString];
        str_jsonparams = [str_jsonparams stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    }


    //组装command
    NSString *queuedCommandsJSON =
        [NSString stringWithFormat:@"[[\"%@\",\"%@\",\"%@\",[%@],[%@]]]", callIndex, pluginName,
                                   methodShowName, str_comparams ?: @"", str_jsonparams ?: @""];
    [self enqueueCommandBatch:queuedCommandsJSON];
}


- (void)enqueueCommandBatch:(NSString *)batchJSON
{
    if ([batchJSON length] > 0) {
        NSMutableArray *commandBatchHolder = [[NSMutableArray alloc] init];
        [_queue addObject:commandBatchHolder];
        if ([batchJSON length] < JSON_SIZE_FOR_MAIN_THREAD) {
            [commandBatchHolder addObject:[batchJSON cdv_JSONObject]];
            [self executePending];
        } else {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^() {
                NSMutableArray *result = [batchJSON cdv_JSONObject];
                @synchronized(commandBatchHolder)
                {
                    [commandBatchHolder addObject:result];
                }
                [self performSelectorOnMainThread:@selector(executePending)
                                       withObject:nil
                                    waitUntilDone:NO];
            });
        }
    }
}


- (void)executePending
{
    if (_startExecutionTime > 0) {
        return;
    }
    @try {
        _startExecutionTime = [NSDate timeIntervalSinceReferenceDate];
        while ([_queue count] > 0) {
            NSMutableArray *commandBatchHolder = _queue[0];
            NSMutableArray *commandBatch = nil;
            @synchronized(commandBatchHolder)
            {
                if ([commandBatchHolder count] == 0) {
                    break;
                }
                commandBatch = commandBatchHolder[0];
            }

            while ([commandBatch count] > 0) {
                @autoreleasepool
                {
                    NSArray *jsonEntry = [commandBatch cdv_dequeue];
                    if ([commandBatch count] == 0) {
                        [_queue removeObjectAtIndex:0];
                    }
                    LDJSInvokedUrlCommand *command =
                        [LDJSInvokedUrlCommand commandFromJson:jsonEntry];
                    if (![self execute:command]) {
                        NSLog(@"Exec(%@) failure: Calling %@.%@", command.callbackId,
                              command.pluginName, command.pluginShowMethod);
                    }
                }

                //如果当前有多个命令，当前命令执行太久，不再继续执行命令
                if (([_queue count] > 0) &&
                    ([NSDate timeIntervalSinceReferenceDate] - _startExecutionTime >
                     MAX_EXECUTION_TIME)) {
                    [self performSelector:@selector(executePending) withObject:nil afterDelay:0];
                    return;
                }
            }
        }
    } @finally {
        _startExecutionTime = 0;
    }
}


- (BOOL)execute:(LDJSInvokedUrlCommand *)command
{
    if ((command.pluginName == nil) || (command.pluginShowMethod == nil)) {
        NSLog(@"ERROR: pluginName and/or pluginShowMethod not found for command.");
        return NO;
    }

    //从当前BridgeService中的插件管理器中获取插件实例
    LDJSPlugin *obj = [_jsService getPluginInstance:command.pluginName];
    if (!obj || !([obj isKindOfClass:[LDJSPlugin class]])) {
        NSLog(@"ERROR: Plugin '%@' not found, or is not a LDJSPlugin. Check your plugin mapping in "
              @"PluginConfig.json.",
              command.pluginName);
        return NO;
    }

    BOOL retVal = YES;
    double started = [[NSDate date] timeIntervalSince1970] * 1000.0;
    SEL normalSelector =
        NSSelectorFromString([_jsService realForShowMethod:command.pluginShowMethod]);
    if (normalSelector && [obj respondsToSelector:normalSelector]) {
        ((void (*)(id, SEL, id))objc_msgSend)(obj, normalSelector, command);
    } else {
        NSLog(@"ERROR: Method '%@' not defined in Plugin '%@'", command.pluginShowMethod,
              command.pluginName);
        retVal = NO;
    }
    double elapsed = [[NSDate date] timeIntervalSince1970] * 1000.0 - started;
    if (elapsed > 2 * 1000.0) {
        NSLog(@"THREAD WARNING: ['%@'] took '%f' ms. Plugin should use a background thread.",
              command.pluginName, elapsed);
    }
    return retVal;
}

@end
