//
//  LDPDevice.m
//  CommonJSAPI
//
//  Created by 庞辉 on 14-10-13.
//  Copyright (c) 2014年 庞辉. All rights reserved.
//

#include <sys/types.h>
#include <sys/sysctl.h>
#import "LDJSCDV.h"
#import "LDPDevice.h"

typedef enum {
    NETWORK_TYPE_NONE = 0,
    NETWORK_TYPE_WIFI = 1,
    NETWORK_TYPE_2G = 2,
    NETWORK_TYPE_3G = 3,
    NETWORK_TYPE_4G = 4
}NETWORK_TYPE;

@implementation UIDevice (ModelVersion)

- (NSString*)modelVersion
{
    size_t size;
    
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char* machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString* platform = [NSString stringWithUTF8String:machine];
    free(machine);
    
    return platform;
}

@end

@interface LDPDevice () {}
@end

@implementation LDPDevice

/**
 *@func 获取设备信息
 */
- (void)getDeviceInfo:(LDJSInvokedUrlCommand*)command{
    //读取设备信息
    NSMutableDictionary* deviceProperties = [NSMutableDictionary dictionaryWithCapacity:4];
    
    UIDevice* device = [UIDevice currentDevice];
    [deviceProperties setObject:[device systemName] forKey:@"systemName"];
    [deviceProperties setObject:[device systemVersion] forKey:@"systemVersion"];
    [deviceProperties setObject:[device model] forKey:@"model"];
    [deviceProperties setObject:[device modelVersion] forKey:@"modelVersion"];
    [deviceProperties setObject:[self uniqueAppInstanceIdentifier] forKey:@"identifier"];
    
    LDJSPluginResult* pluginResult = [LDJSPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:[NSDictionary dictionaryWithDictionary:deviceProperties]];
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

/**
 *@func 获取客户端信息
 */
- (void)getClientInfo:(LDJSInvokedUrlCommand*)command{
    NSMutableDictionary *clientInfos = [[NSMutableDictionary alloc] initWithCapacity:4];
    NSDictionary *bundleDic = [[NSBundle mainBundle] infoDictionary];
    
    [clientInfos setObject:[bundleDic objectForKey:@"CFBundleShortVersionString"] forKey:@"appVersion"];
    [clientInfos setObject:[bundleDic objectForKey:@"CFBundleVersion"] forKey:@"appBuild"];
    
    LDJSPluginResult *pluginResult = [LDJSPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:clientInfos];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

/**
 *@func 获取当前网络状况
 */
- (void)getNetworkInfo:(LDJSInvokedUrlCommand*)command{
    UIApplication *app = [UIApplication sharedApplication];
    NSArray *subviews = [[[app valueForKey:@"statusBar"] valueForKey:@"foregroundView"] subviews];
    NSNumber *dataNetworkItemView = nil;
    
    for(id subview in subviews){
        if([subview isKindOfClass:[NSClassFromString(@"UIStatusBarDataNetworkItemView") class]]){
            dataNetworkItemView = subview;
            break;
        }
    }
    
    int netType = NETWORK_TYPE_NONE;
    NSNumber *num = [dataNetworkItemView valueForKey:@"dataNetworkType"];
    if(num == nil){
        netType = NETWORK_TYPE_NONE;
    } else {
        int n = [num intValue];
        if(n == 0){
            netType = NETWORK_TYPE_NONE;
        }
        else if(n == 1){
            netType = NETWORK_TYPE_2G;
        }
        else if(n == 2){
            netType = NETWORK_TYPE_3G;
        }
        else if(n == 3) {
            netType = NETWORK_TYPE_WIFI;
        } else {
            netType = NETWORK_TYPE_4G;
        }
    }
    
    
    
    LDJSPluginResult *pluginResult = [LDJSPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:netType];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

/**
 *@func 获取webview类型
 */
- (void)getWebViewType:(LDJSInvokedUrlCommand*)command {
    LDJSPluginResult *pluginResult = [LDJSPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:1];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}


/**
 *@func 连接wifi
 */
- (void)connectToWiFi:(LDJSInvokedUrlCommand*)command{
    
}


/**
 *@func 设置屏幕是否常亮
 */
- (void)setScreenStatus:(LDJSInvokedUrlCommand*)command{
    NSString *status = [command jsonParamForkey:@"status"];
    if( status == nil){
        return;
    }
    
    //设置不长亮
    if([status intValue] == 0){
        [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    } else if([status intValue] == 1) {
        [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
        //设置常亮时调整亮度
        [[UIScreen mainScreen] setBrightness:0.7f];
    } else {
        //nothing to do
    }
    
    NSMutableDictionary *dic_result = [[NSMutableDictionary alloc] initWithCapacity:2];
    int curStatus = 0;
    if([UIApplication sharedApplication].idleTimerDisabled) curStatus = 1;
    [dic_result setObject:[NSNumber numberWithInt:curStatus] forKey:@"result"];
    [dic_result setObject:(curStatus == 0 ? @"当前屏幕处于不长亮状态":@"当前屏幕处于常亮状态") forKey:@"message"];
    
    LDJSPluginResult* pluginResult = [LDJSPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:[NSDictionary dictionaryWithDictionary:dic_result]];
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}


- (NSString*)uniqueAppInstanceIdentifier
{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    static NSString* UUID_KEY = @"CDVUUID";
    
    NSString* app_uuid = [userDefaults stringForKey:UUID_KEY];
    
    if (app_uuid == nil) {
        CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
        CFStringRef uuidString = CFUUIDCreateString(kCFAllocatorDefault, uuidRef);
        
        app_uuid = [NSString stringWithString:(__bridge NSString*)uuidString];
        [userDefaults setObject:app_uuid forKey:UUID_KEY];
        [userDefaults synchronize];
        
        CFRelease(uuidString);
        CFRelease(uuidRef);
    }
    
    return app_uuid;
}

@end
