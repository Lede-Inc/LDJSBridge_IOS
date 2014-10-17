//
//  LDPDevice.h
//  CommonJSAPI
//
//  Created by 庞辉 on 14-10-13.
//  Copyright (c) 2014年 庞辉. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LDJSPlugin.h"

@interface LDPDevice : LDJSPlugin
{}

/**
 *@func 获取设备信息
 */
- (void)getDeviceInfo:(LDJSInvokedUrlCommand*)command;

/**
 *@func 获取客户端信息
 */
- (void)getClientInfo:(LDJSInvokedUrlCommand*)command;

/**
 *@func 获取当前网络状况
 */
- (void)getNetworkInfo:(LDJSInvokedUrlCommand*)command;

/**
 *@func 获取webview类型
 */
- (void)getWebViewType:(LDJSInvokedUrlCommand*)command;



/**
 *@func 连接wifi
 */
- (void)connectToWiFi:(LDJSInvokedUrlCommand*)command;


/**
 *@func 设置屏幕是否常亮
 */
- (void)setScreenStatus:(LDJSInvokedUrlCommand*)command;

@end
