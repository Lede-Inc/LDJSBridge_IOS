//
//  LDJSService.m
//  CommonJSAPI
//
//  Created by 庞辉 on 14-10-13.
//  Copyright (c) 2014年 庞辉. All rights reserved.
//

#import "LDJSService.h"
#import "LDJSPluginManager.h"
#import "LDJSCommandQueue.h"
#import "LDJSCommandDelegate.h"

NSString *const LDJSBridgeConnectNotification = @"LDJSBridgeConnectNotification";
NSString *const LDJSBridgeCloseNotification = @"LDJSBridgeCloseNotification";
NSString *const LDJSBridgeWebFinishLoadNotification = @"LDJSBridgeWebFinishLoadNotification";

NSString *const JsBridgeServiceTag = @"ldjsbridgeservice";

//在JS端定义字段回收代码
#define JsBridgeScheme @"ldjsbridge"
#define JsBridgeCoreFileName @"LDJSBridge.js" //以text结尾



@interface LDJSService () {
    NSString *_userAgent; //用于记录绑定webview进来的UserAgent
}

@property (weak, nonatomic) id<UIWebViewDelegate> originDelegate; //记录绑定webView的原始delegate
@property (strong, nonatomic) LDJSPluginManager *pluginManager;   //本地插件管理器

@end



@implementation LDJSService

-(id)init {
    NSAssert(NO, @"Bridge Service must init with plugin config file");
    return nil;
}


-(id)initBridgeServiceWithConfig:(NSString *)configFile;{
    self = [super init];
    if(self){
        _webView = nil;
        _viewController = nil;
        _originDelegate = nil;
        _pluginManager = [[LDJSPluginManager alloc] initWithConfigFile:configFile];
        _commandQueue = [[LDJSCommandQueue alloc] initWithService:self];
        _commandDelegate = [[LDJSCommandDelegateImpl alloc] initWithService:self];
        
        //设置当前webview的UserAgent,方便webview注入版本信息
        _userAgent = [[[UIWebView alloc] init] stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
        NSString *appVersion = [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"];
        NSString *customUserAgent = [_userAgent stringByAppendingFormat:@" _MAPP_/%@", appVersion];
        [[NSUserDefaults standardUserDefaults] registerDefaults:@{@"UserAgent":customUserAgent}];
    }
    return self;
}


-(void) dealloc {
    [self close];
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{@"UserAgent":_userAgent}];
    [_commandQueue dispose];
}


-(void)connect:(UIWebView *)webView Controller:(id)controller {
    if(webView == self.webView) return;
    if(self.webView != nil){
        [self close];
    }
    
    self.viewController = controller;
    self.webView = webView;
    self.originDelegate = webView.delegate;
    self.webView.delegate = self;
    
    //注册webViewDelegate的KVO
    [self registerKVO];
    
    //bridge连接成功，通知所有插件获取bridgeService
    [[NSNotificationCenter defaultCenter] postNotificationName:LDJSBridgeConnectNotification object:self userInfo:@{JsBridgeServiceTag:self}];
}


-(void)close {
    [self unregisterKVP];
    if(self.webView == nil) return;

    //bridgeService关闭，通知所有插件断开bridge
    [[NSNotificationCenter defaultCenter] postNotificationName:LDJSBridgeCloseNotification object:self];

    self.webView.delegate = self.originDelegate;
    self.originDelegate = nil;
    self.webView = nil;
    self.viewController = nil;
}


#pragma mark - 执行JS函数
-(void)jsEval:(NSString *)js {
    [self performSelectorOnMainThread:@selector(jsEvalIntrnal:) withObject:js waitUntilDone:YES];
}


//直接在主线程中执行
-(NSString *)jsMainLoopEval:(NSString *)js {
    return [self jsEvalIntrnal:js];
}


-(NSString *)jsEvalIntrnal:(NSString *)js {
    if(self.webView){
        return [self.webView stringByEvaluatingJavaScriptFromString:js];
    } else {
        return nil;
    }
}



#pragma mark - KVO
-(void)registerKVO {
    if(_webView){
        [_webView addObserver:self forKeyPath:@"delegate" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:nil];
    }
}


-(void)unregisterKVP{
    if(_webView){
        [_webView removeObserver:self forKeyPath:@"delegate"];
    }
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    id newDelegate = change[@"new"];
    if(object == self.webView && [keyPath isEqualToString:@"delegate"] && newDelegate != self){
        self.originDelegate = newDelegate;
        self.webView.delegate = self;
    }
}



#pragma mark webViewDelegate monitor
- (void)webViewDidStartLoad:(UIWebView *)webView {
    if(webView != self.webView) return;
    if([self.originDelegate respondsToSelector:@selector(webViewDidStartLoad:)]) {
        [self.originDelegate webViewDidStartLoad:webView];
    }
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    if(webView != self.webView) return;
    //加载本地的框架JS
    NSString *path = [[NSBundle mainBundle] pathForResource:JsBridgeCoreFileName ofType:@"txt"];
    NSString *js = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    [self jsMainLoopEval:js];
    [[NSNotificationCenter defaultCenter] postNotificationName:LDJSBridgeWebFinishLoadNotification object:self];
    
    if([self.originDelegate respondsToSelector:@selector(webViewDidFinishLoad:)]) {
        [self.originDelegate webViewDidFinishLoad:webView];
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if(webView != self.webView) return YES;
    BOOL res = NO;
    NSURL *url = [request URL];
    if([[url scheme] isEqualToString:JsBridgeScheme]){
        [self handleURLFromWebview:[url absoluteString]];
        return NO;
    }
    
    if([self.originDelegate respondsToSelector:@selector(webView:shouldStartLoadWithRequest:navigationType:)]) {
        res |= [self.originDelegate webView:webView shouldStartLoadWithRequest:request navigationType:navigationType];
    } else {
        res = YES;
    }
    
    return res;
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    if(webView != self.webView) return;
    
    if([self.originDelegate respondsToSelector:@selector(webView:didFailLoadWithError:)]) {
        [self.originDelegate webView:webView didFailLoadWithError:error];
    }
}


/*
 *@func 处理从webview发过来的的url调用请求
 */
-(void)handleURLFromWebview:(NSString *) urlstring {
    if([urlstring hasPrefix:JsBridgeScheme] &&  self.webView != nil){
        [_commandQueue excuteCommandsFromUrl:urlstring];
    }
}


- (id)getPluginInstance:(NSString*)pluginName{
    return [_pluginManager getPluginInstanceByPluginName:pluginName];
}


-(NSString *)realForShowMethod:(NSString *)showMethod{
    return [_pluginManager realForShowMethod:showMethod];
}

@end
