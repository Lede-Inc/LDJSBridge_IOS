//
//  LDJSService.h
//  CommonJSAPI
//
//  Created by 庞辉 on 14-10-13.
//  Copyright (c) 2014年 庞辉. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol LDJSCommandDelegate;
@class LDJSCommandQueue;
@interface LDJSService : NSObject {
    @protected
        id <LDJSCommandDelegate> _commandDelegate;
    @protected
        LDJSCommandQueue* _commandQueue;

}

//用来定义当前Service操作的webview和delegate
@property (nonatomic, strong) IBOutlet UIWebView* webView;
@property (nonatomic, readonly, strong) id <LDJSCommandDelegate> commandDelegate;
@property (nonatomic, readonly, strong) LDJSCommandQueue* commandQueue;

//用来存储用户注册的自定义的plugin
@property (nonatomic, readonly, strong) NSMutableDictionary* pluginObjects;
@property (nonatomic, readonly, strong) NSMutableDictionary* pluginsMap;


/*
 *@func 初始化Webview的service
 *@param theWebView 控制的webview
 */
-(id)initWithWebView:(UIWebView *) theWebView;


/*
 *@func 处理从webview发过来的的url调用请求
 */
-(void)handleURLFromWebview:(NSString *) urlstring;


/*
 *@func 用户批量注册自定义的plugins
 *@param pluginDic 用户自定义插件列表 key为自定义插件名称，value为具体的插件类名
 */
-(void)registerPlugins:(NSDictionary *) pluginsDic;


/*
 *@func 用户单个注册自定义的plugin
 *@param pluginName 自定义插件名称(跟js的模块相对应)，
 *@param className  插件类名
 */
-(void)registerPlugin:(NSString *)pluginName withPluginClass:(NSString *)className;


/*
 *@func 用户注销所有自定义插件
 */
-(BOOL)unRegisterAllPlugins;

/*
 *@func 用户单个注销自定义的plugin
 *@param pluginName 自定义插件名称(跟js的模块相对应)，
 *@param className  插件类名
 */
-(void) unRegisterPlugin:(NSString *)pluginName;


/**
 *@func 以pluginName返回用户自定义插件类的对象
 *@param pluginName 插件自定义名称，不一定时类名称
 */
- (id)getCommandInstance:(NSString*)pluginName;



@end
