//
//  LDJSPlugin.h
//  CommonJSAPI
//
//  Created by 庞辉 on 14-10-13.
//  Copyright (c) 2014年 庞辉. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "LDJSInvokedUrlCommand.h"
#import "LDJSPluginResult.h"
#import "LDJSQueue.h"
#import "LDJSCommandDelegate.h"


/**
 * @class LDJSPlugin
 * 所有本地插件继承的基类
 */
@class LDJSService;
@interface LDJSPlugin : NSObject {
    
}
@property (weak, nonatomic) LDJSService *bridgeService; //在bridgeService中提供对webview和controller的访问
@property (assign, nonatomic) UIViewController *viewController;
@property (assign, nonatomic) UIWebView *webView;
@property (assign, nonatomic) id<LDJSCommandDelegate> commandDelegate;
@property (assign, nonatomic) BOOL isReady;

/**
 * 插件不自己初始化，如果需要初始化插件内容，调用此方法
 */
-(void)pluginInitialize;

/**
 * 停止插件使用
 */
-(void)stopPlugin;

/**
 * 监听Bridge服务开启
 */
-(void)onConnect:(NSNotification *)notification;

/**
 * 监听Bridge服务关闭
 */
-(void)onClose:(NSNotification *)notification;

/**
 * 监听Bridge绑定的webview加载完毕事件
 */
-(void)onWebViewFinishLoad:(NSNotification *)notification;


/**
 *直接在插件中向webView发送JS执行代码
 */
- (NSString*)writeJavascript:(NSString*)javascript;

@end
