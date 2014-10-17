//
//  LDJSCommandDelegate.h
//  CommonJSAPI
//
//  Created by 庞辉 on 14-10-13.
//  Copyright (c) 2014年 庞辉. All rights reserved.
//

@class LDJSPluginResult;

@protocol LDJSCommandDelegate <NSObject>
- (id)getCommandInstance:(NSString*)pluginName;

// Sends a plugin result to the JS. This is thread-safe.
- (void)sendPluginResult:(LDJSPluginResult*)result callbackId:(NSString*)callbackId;

/*
 *供插件直接执行js代码
 */
// Evaluates the given JS. This is thread-safe.
- (void)evalJs:(NSString*)js;
// Can be used to evaluate JS right away instead of scheduling it on the run-loop.
// This is required for dispatch resign and pause events, but should not be used
// without reason. Without the run-loop delay, alerts used in JS callbacks may result
// in dead-lock. This method must be called from the UI thread.
- (void)evalJs:(NSString*)js scheduledOnRunLoop:(BOOL)scheduledOnRunLoop;
// Runs the given block on a background thread using a shared thread-pool.
- (void)runInBackground:(void (^)())block;

@end
