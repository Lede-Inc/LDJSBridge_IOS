//
//  LDJSService.m
//  CommonJSAPI
//
//  Created by 庞辉 on 14-10-13.
//  Copyright (c) 2014年 庞辉. All rights reserved.
//

#import "LDJSService.h"
#import "LDJSCDV.h"

@interface LDJSService () {
    
}
//用来注册用户自定义的插件
@property (nonatomic, readwrite, strong) NSMutableDictionary* pluginsMap;
@property (nonatomic, readwrite, strong) NSMutableDictionary* pluginObjects;
@property (readwrite, assign) BOOL initialized;

@end


@implementation LDJSService
@synthesize webView;
@synthesize pluginObjects, pluginsMap, initialized;
@synthesize commandDelegate = _commandDelegate;

- (void)__init
{
    if ((self != nil) && !self.initialized) {
        _commandQueue = [[LDJSCommandQueue alloc] initWithService:self];
        _commandDelegate = [[LDJSCommandDelegateImpl alloc] initWithService:self];
        self.pluginsMap = [[NSMutableDictionary alloc] initWithCapacity:2];
        self.pluginObjects = [[NSMutableDictionary alloc] initWithCapacity:2];
        self.initialized = YES;
    }
}


/*
 *@func 初始化Webview的service
 *@param theWebView 控制的webview
 */
-(id)initWithWebView:(UIWebView *) theWebView {
    self = [super init];
    if(self) {
        self.webView = theWebView;
        [self __init];
    }
    return self;
}


- (void)dealloc{
    [_commandQueue dispose];
    [[self.pluginObjects allValues] makeObjectsPerformSelector:@selector(dispose)];
    [self unRegisterAllPlugins];
}


#pragma mark Plugins Register
/*
 *@func 处理从webview发过来的的url调用请求
 */
-(void)handleURLFromWebview:(NSString *) urlstring {
    if([urlstring hasPrefix:@"jsbridge://"] &&  self.webView != nil){
        [_commandQueue fetchCommandsFromUrl:urlstring];
        [_commandQueue executePending];
    }
}


/*
 *@func 用户批量注册自定义的plugins
 *@param pluginDic 用户自定义插件列表 key为自定义插件名称，value为具体的插件类名
 */
-(void)registerPlugins:(NSDictionary *) pluginsDic{
    if(self.pluginsMap == nil) {
        self.pluginsMap = [[NSMutableDictionary alloc] initWithCapacity:2];
    }
    
    //检查用户自定义的插件
    NSEnumerator *enumerator = [pluginsDic keyEnumerator];
    NSString *key;
    while(key = [enumerator nextObject]){
        NSString *className = [pluginsDic objectForKey:key];
        [self.pluginsMap setObject:className forKey:[key lowercaseString]];
    }
}


/*
 *@func 用户单个注册自定义的plugin
 *@param pluginName 自定义插件名称(跟js的模块相对应)，
 *@param className  插件类名
 */
-(void)registerPlugin:(NSString *)pluginName withPluginClass:(NSString *)className{
    if(pluginName == nil || className == nil) return;
    
    if(self.pluginsMap == nil) {
        self.pluginsMap = [[NSMutableDictionary alloc] initWithCapacity:2];
    }
    
    [self.pluginsMap setObject:className forKey:[pluginName lowercaseString]];
}


/*
 *@func 用户注销所有自定义插件
 */
-(BOOL)unRegisterAllPlugins {
    //删除所有生成的对象
    [self.pluginObjects removeAllObjects];
    self.pluginObjects = nil;
    
    //删除所有注册的插件
    [self.pluginsMap removeAllObjects];
    self.pluginsMap = nil;
    
    return YES;
}


/*
 *@func 用户单个注销自定义的plugin
 *@param pluginName 自定义插件名称(跟js的模块相对应)，
 *@param className  插件类名
 */
-(void) unRegisterPlugin:(NSString *)pluginName{
    if(pluginName == nil) return;
    
    if(self.pluginsMap){
        NSString *className = [self.pluginsMap objectForKey:[pluginName lowercaseString]];
        //如果插件已注册,先删除实例化的对象，再注销插件；
        if(className != nil && [self removePluginwithClassName:className]){
            [self.pluginsMap removeObjectForKey:[pluginName lowercaseString]];
        }//if
    }//if
}



#pragma mark plugin Instance
/**
 *@func 以pluginName返回用户自定义插件类的对象
 *@param pluginName 插件自定义名称，不一定时类名称
 */
- (id)getCommandInstance:(NSString*)pluginName{
    NSString* className = [self.pluginsMap objectForKey:[pluginName lowercaseString]];
    
    //插件没有注册
    if (className == nil) {
        return nil;
    }
    
    //插件已注册，返回插件实例
    id obj = [self.pluginObjects objectForKey:className];
    if (!obj) {
        obj = [[NSClassFromString(className)alloc] initWithWebView:self.webView];
        
        if (obj != nil) {
            [self addPlugin:obj withClassName:className];
        } else {
            NSLog(@"LDJSPlugin class %@ (pluginName: %@) does not exist.", className, pluginName);
        }
    }
    return obj;
}



/**
 *@func 生成自定义插件的实例对象
 *@param className 自定义插件的类名称
 */
- (BOOL)addPlugin:(LDJSPlugin*)plugin withClassName:(NSString*)className{
    //为plugin设置当前webview所在的ctroller
    if ([plugin respondsToSelector:@selector(setViewController:)]) {
        UIViewController *ctrl = nil;
        if([[self.webView.superview nextResponder] isKindOfClass:[UIViewController class]]){
            ctrl = (UIViewController *)[self.webView.superview nextResponder];
        }
        if(self.webView != nil && ctrl != nil){
            [plugin setViewController:ctrl];
        }
    }
    
    if ([plugin respondsToSelector:@selector(setCommandDelegate:)]) {
        [plugin setCommandDelegate:_commandDelegate];
    }
    
    [self.pluginObjects setObject:plugin forKey:className];
    [plugin pluginInitialize];
    
    return YES;
}


/**
 *@func 注销某个自定义插件
 *@param className 自定义插件的类名称
 */
-(BOOL) removePluginwithClassName:(NSString*)className{
    LDJSPlugin* obj = [self.pluginObjects objectForKey:className];
    if (obj != nil) {
        [self.pluginObjects removeObjectForKey:className];
        [obj setWebView:nil];
        obj = nil;
    }
    return YES;
}
@end
