//
//  LDPAppInfo.m
//  CommonJSAPI
//
//  Created by 庞辉 on 14-10-15.
//  Copyright (c) 2014年 庞辉. All rights reserved.
//

#import "LDPAppInfo.h"

@implementation LDPAppInfo

/**
 *@func 通过scheme判断指定应用是否已经安装
 */
- (void)isAppInstalled:(LDJSInvokedUrlCommand*)command{
    NSString *appScheme = [command jsonParamForkey:@"scheme"];
    BOOL isInstalled = [self isAppInstalledWithScheme:appScheme];
    LDJSPluginResult *pluginResult = [LDJSPluginResult resultWithStatus:LDJSCommandStatus_OK messageAsBool:isInstalled];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}


/**
 *@func 批量查询应用是否已安装
 */
- (void)isAppInstalledBatch:(LDJSInvokedUrlCommand*)command{
    NSArray *arr_apps = [command jsonParamForkey:@"schemes"];
    NSMutableArray *arr_result = [[NSMutableArray alloc] initWithCapacity:2];
    for(int i = 0; i < arr_apps.count; i++){
        BOOL isInstalled = [self isAppInstalledWithScheme:[arr_apps objectAtIndex:i]];
        [arr_result addObject:[NSNumber numberWithBool:isInstalled]];
    }
    
    LDJSPluginResult *pluginResult = [LDJSPluginResult resultWithStatus:LDJSCommandStatus_OK messageAsArray:arr_result];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}


/**
 *@func 使用scheme(ios)或者报名（android）启动第三方应用
 */
- (void)launchApp:(LDJSInvokedUrlCommand*)command{
    NSString *appScheme = [command jsonParamForkey:@"name"];
    NSURL *appSchemeURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@://", appScheme]];
    if([[UIApplication sharedApplication] canOpenURL: appSchemeURL]){
        [[UIApplication sharedApplication] openURL:appSchemeURL];
    }
    //nothing to back
}


/**
 *@func 带用户状态的启动第三方应用；
 */
- (void)launchAppWithTokens:(LDJSInvokedUrlCommand*)command{
    NSString *str_jumpurl = [NSString stringWithFormat:@"%@://%@", [command jsonParamForkey:@"appID"],[command jsonParamForkey:@"paramsStr"]];

    NSURL *appSchemeURL = [NSURL URLWithString: str_jumpurl];
    if([[UIApplication sharedApplication] canOpenURL: appSchemeURL]){
        [[UIApplication sharedApplication] openURL:appSchemeURL];
    }
    //nothing to back
}


#pragma mark common API
-(BOOL)isAppInstalledWithScheme:(NSString *) appScheme {
    NSString *appSchemeURL = [NSString stringWithFormat:@"%@://", appScheme];
    BOOL isInstalled = NO;
    if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:appSchemeURL]]){
        isInstalled = YES;
    }
    
    return isInstalled;
}

@end
