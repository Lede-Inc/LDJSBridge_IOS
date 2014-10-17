//
//  LDJSPlugin.m
//  CommonJSAPI
//
//  Created by 庞辉 on 14-10-13.
//  Copyright (c) 2014年 庞辉. All rights reserved.
//

#import "LDJSPlugin.h"

NSString* const LDJSPageDidLoadNotification = @"LDJSPageDidLoadNotification";
NSString* const LDJSPluginHandleOpenURLNotification = @"LDJSPluginHandleOpenURLNotification";
NSString* const LDJSPluginResetNotification = @"LDJSPluginResetNotification";
NSString* const LDJSLocalNotification = @"LDJSLocalNotification";
NSString* const LDJSRemoteNotification = @"LDJSRemoteNotification";
NSString* const LDJSRemoteNotificationError = @"LDJSRemoteNotificationError";

@interface LDJSPlugin ()

@property (readwrite, assign) BOOL hasPendingOperation;

@end

@implementation LDJSPlugin
@synthesize webView, viewController, commandDelegate, hasPendingOperation;

// Do not override these methods. Use pluginInitialize instead.
- (LDJSPlugin*)initWithWebView:(UIWebView*)theWebView settings:(NSDictionary*)classSettings
{
    return [self initWithWebView:theWebView];
}

- (LDJSPlugin*)initWithWebView:(UIWebView*)theWebView
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppTerminate) name:UIApplicationWillTerminateNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMemoryWarning) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleOpenURL:) name:LDJSPluginHandleOpenURLNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onReset) name:LDJSPluginResetNotification object:theWebView];
        
        self.webView = theWebView;
    }
    return self;
}

- (void)pluginInitialize
{
    // You can listen to more app notifications, see:
    // http://developer.apple.com/library/ios/#DOCUMENTATION/UIKit/Reference/UIApplication_Class/Reference/Reference.html#//apple_ref/doc/uid/TP40006728-CH3-DontLinkElementID_4
    
    // NOTE: if you want to use these, make sure you uncomment the corresponding notification handler
    
    // [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onPause) name:UIApplicationDidEnterBackgroundNotification object:nil];
    // [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onResume) name:UIApplicationWillEnterForegroundNotification object:nil];
    // [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onOrientationWillChange) name:UIApplicationWillChangeStatusBarOrientationNotification object:nil];
    // [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onOrientationDidChange) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    
    // Added in 2.3.0
    // [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveLocalNotification:) name:LDJSLocalNotification object:nil];
    
    // Added in 2.5.0
    // [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pageDidLoad:) name:LDJSPageDidLoadNotification object:self.webView];
}

- (void)dispose
{
    viewController = nil;
    commandDelegate = nil;
    webView = nil;
}

/*
 // NOTE: for onPause and onResume, calls into JavaScript must not call or trigger any blocking UI, like alerts
 - (void) onPause {}
 - (void) onResume {}
 - (void) onOrientationWillChange {}
 - (void) onOrientationDidChange {}
 */

/* NOTE: calls into JavaScript must not call or trigger any blocking UI, like alerts */
- (void)handleOpenURL:(NSNotification*)notification
{
    // override to handle urls sent to your app
    // register your url schemes in your App-Info.plist
    
    NSURL* url = [notification object];
    
    if ([url isKindOfClass:[NSURL class]]) {
        /* Do your thing! */
    }
}

/* NOTE: calls into JavaScript must not call or trigger any blocking UI, like alerts */
- (void)onAppTerminate
{
    // override this if you need to do any cleanup on app exit
}

- (void)onMemoryWarning
{
    // override to remove caches, etc
}

- (void)onReset
{
    // Override to cancel any long-running requests when the WebView navigates or refreshes.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];   // this will remove all notification unless added using addObserverForName:object:queue:usingBlock:
}

- (id)appDelegate
{
    return [[UIApplication sharedApplication] delegate];
}

- (NSString*)writeJavascript:(NSString*)javascript
{
    return [self.webView stringByEvaluatingJavaScriptFromString:javascript];
}

- (NSString*)success:(LDJSPluginResult*)pluginResult callbackId:(NSString*)callbackId
{
    [self.commandDelegate evalJs:[pluginResult toSuccessCallbackString:callbackId]];
    return @"";
}

- (NSString*)error:(LDJSPluginResult*)pluginResult callbackId:(NSString*)callbackId
{
    [self.commandDelegate evalJs:[pluginResult toErrorCallbackString:callbackId]];
    return @"";
}

// default implementation does nothing, ideally, we are not registered for notification if we aren't going to do anything.
// - (void)didReceiveLocalNotification:(NSNotification *)notification
// {
//    // UILocalNotification* localNotification = [notification object]; // get the payload as a LocalNotification
// }

@end

