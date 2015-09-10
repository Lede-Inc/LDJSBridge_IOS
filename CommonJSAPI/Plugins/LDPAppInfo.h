//
//  LDPAppInfo.h
//  CommonJSAPI
//
//  Created by 庞辉 on 14-10-15.
//  Copyright (c) 2014年 庞辉. All rights reserved.
//

#import "LDJSPlugin.h"

@class LDJSInvokedUrlCommand;

@interface LDPAppInfo : LDJSPlugin {
}

/**
 *@func 通过scheme判断指定应用是否已经安装
 */
- (void)isAppInstalled:(LDJSInvokedUrlCommand *)command;


/**
 *@func 批量查询应用是否已安装
 */
- (void)isAppInstalledBatch:(LDJSInvokedUrlCommand *)command;


/**
 *@func 使用scheme(ios)或者报名（android）启动第三方应用
 */
- (void)launchApp:(LDJSInvokedUrlCommand *)command;


/**
 *@func 带用户状态的启动第三方应用；
 */
- (void)launchAppWithTokens:(LDJSInvokedUrlCommand *)command;


@end
