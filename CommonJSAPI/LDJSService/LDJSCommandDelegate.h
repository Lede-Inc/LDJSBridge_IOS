//
//  LDJSCommandDelegate.h
//  CommonJSAPI
//
//  Created by 庞辉 on 14-10-13.
//  Copyright (c) 2014年 庞辉. All rights reserved.
//


@class LDJSPluginResult;
@class LDJSService;

@protocol LDJSCommandDelegate <NSObject>
/**
 * 将执行native的结果封装并通过callBackId进行JS回调
 */
- (void)sendPluginResult:(LDJSPluginResult *)result callbackId:(NSString *)callbackId;


@end


/**
 * @protocol LDJSCommandDelegate
 * 执行URLCommand的回调
 */
@interface LDJSCommandDelegateImpl : NSObject <LDJSCommandDelegate> {
}

/**
 * 初始化Command回调
 */
- (id)initWithService:(LDJSService *)jsService;

@end
