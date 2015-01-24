//
//  LDJSService.h
//  CommonJSAPI
//
//  Created by 庞辉 on 14-10-13.
//  Copyright (c) 2014年 庞辉. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

extern NSString *const LDJSBridgeConnectNotification; //Bridge和webview绑定消息
extern NSString *const LDJSBridgeCloseNotification; //Bridge和webView断开消息
extern NSString *const LDJSBridgeWebFinishLoadNotification; //Bridge绑定WebView加载完毕

extern NSString *const JsBridgeServiceTag; //获取Notification的service Tag

/**
 * 用于连接bridgeService的Controller定义是否需要调试
 * 如果是调试模式，客服端输出关于Native的打印信息
 */
@protocol LDJSWebViewBridgeProtocol <NSObject>

@required
- (BOOL)isDebugMode;

@optional
- (NSString *)debugChannel;

@end


/**
 * @class LDJSService
 * JSBridge服务，提供JS和本地Native代码的连接服务
 */
@protocol LDJSCommandDelegate;
@class LDJSCommandQueue;
@interface LDJSService : NSObject <UIWebViewDelegate> {
}

@property (nonatomic, weak) UIWebView* webView;
@property (nonatomic, weak) id viewController;
@property (nonatomic, readonly, strong) LDJSCommandQueue* commandQueue;
@property (nonatomic, readonly, strong) id<LDJSCommandDelegate> commandDelegate;


/**
 * 根据配置文件初始化BridgeService
 */
-(id)initBridgeServiceWithConfig:(NSString *)configFile;


/**
 * 打开将BridgeService和webview以及webview所在Controller绑定
 */
-(void)connect:(UIWebView *) webView Controller:(id)controller;


/**
 * 关闭bridge服务连接
 */
-(void)close;


/**
 * 监测webView是否加载完毕
 */
-(void)webReady;


/**
 * 1.根据pluginName 获取plugin的实例
 * 2.根据pluginShowMethod获取对应的SEL
 */
-(id)getPluginInstance:(NSString*)pluginName;
-(NSString *)realForShowMethod:(NSString *)showMethod;


/**
 * 调用bridge绑定的webview执行JS代码
 */
-(void)jsEval:(NSString *)js;
-(NSString *)jsMainLoopEval:(NSString *)js;


/**
 * 释放JS端监控的事件消息
 */
-(void)triggerEvent:(NSString *)type withDetail:(NSDictionary *)detail;
-(BOOL)webResponsesToEvent:(NSString *)type;


@end
