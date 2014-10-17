//
//  LDJSPlugin.h
//  CommonJSAPI
//
//  Created by 庞辉 on 14-10-13.
//  Copyright (c) 2014年 庞辉. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "LDJSPluginResult.h"
#import "LDJSQueue.h"
#import "LDJSCommandDelegate.h"

extern NSString* const LDJSPageDidLoadNotification;
extern NSString* const LDJSPluginHandleOpenURLNotification;
extern NSString* const LDJSPluginResetNotification;
extern NSString* const LDJSLocalNotification;
extern NSString* const LDJSRemoteNotification;
extern NSString* const LDJSRemoteNotificationError;

@interface LDJSPlugin : NSObject {}

@property (nonatomic, weak) UIWebView* webView;
@property (nonatomic, weak) UIViewController* viewController;
@property (nonatomic, weak) id <LDJSCommandDelegate> commandDelegate;

@property (readonly, assign) BOOL hasPendingOperation;

- (LDJSPlugin*)initWithWebView:(UIWebView*)theWebView;
- (void)pluginInitialize;

- (void)handleOpenURL:(NSNotification*)notification;
- (void)onAppTerminate;
- (void)onMemoryWarning;
- (void)onReset;
- (void)dispose;

/*
 // see initWithWebView implementation
 - (void) onPause {}
 - (void) onResume {}
 - (void) onOrientationWillChange {}
 - (void) onOrientationDidChange {}
 - (void)didReceiveLocalNotification:(NSNotification *)notification;
 */

- (id)appDelegate;

- (NSString*)writeJavascript:(NSString*)javascript;

- (NSString*)success:(LDJSPluginResult*)pluginResult callbackId:(NSString*)callbackId;

- (NSString*)error:(LDJSPluginResult*)pluginResult callbackId:(NSString*)callbackId;

@end
