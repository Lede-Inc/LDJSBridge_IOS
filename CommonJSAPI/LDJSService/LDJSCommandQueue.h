//
//  LDJSCommandQueue.h
//  CommonJSAPI
//
//  Created by 庞辉 on 14-10-13.
//  Copyright (c) 2014年 庞辉. All rights reserved.
//

#import <Foundation/Foundation.h>


@class LDJSInvokedUrlCommand;
@class LDJSService;

/**
 * @class LDJSCommandQueue
 * 用来存储从HTML页面发过来的调用请求命令
 */
@interface LDJSCommandQueue : NSObject {
}

@property (nonatomic, readonly) BOOL currentlyExecuting;  //用于判断当前是否在执行调用请求

/**
 * 初始化和销毁CommandQueue
 */
- (id)initWithService:(LDJSService *)jsService;
- (void)dispose;

/**
 * 从webview截获URL并执行
 */
- (void)excuteCommandsFromUrl:(NSString *)urlStr;

@end
