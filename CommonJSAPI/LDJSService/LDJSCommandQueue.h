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

@interface LDJSCommandQueue : NSObject

@property (nonatomic, readonly) BOOL currentlyExecuting;

- (id)initWithService:(LDJSService*) jsService;
- (void)dispose;

//从识别url中加入参数
-(void) fetchCommandsFromUrl:(NSString *)urlstr;
- (void)enqueueCommandBatch:(NSString*)batchJSON;
- (void)executePending;
- (BOOL)execute:(LDJSInvokedUrlCommand*)command;

@end
