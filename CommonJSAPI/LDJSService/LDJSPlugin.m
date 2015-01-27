//
//  LDJSPlugin.m
//  CommonJSAPI
//
//  Created by 庞辉 on 14-10-13.
//  Copyright (c) 2014年 庞辉. All rights reserved.
//

#import "LDJSPlugin.h"
#import "LDJSService.h"

@implementation LDJSPlugin

// Do not override these methods. Use pluginInitialize instead.
-(id)init{
    self = [super init];
    if(self){
        _bridgeService = nil;
        _isReady = NO;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onConnect:) name:LDJSBridgeConnectNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onClose:) name:LDJSBridgeCloseNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onWebViewFinishLoad:) name:LDJSBridgeWebFinishLoadNotification object:nil];
    }
    return self;
}


- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)pluginInitialize{
    
}


-(void)stopPlugin{
    self.bridgeService = nil;
    self.isReady = NO;
}


- (void)onConnect:(NSNotification *)notification {
    if(!self.bridgeService) self.bridgeService = [notification.userInfo objectForKey:JsBridgeServiceTag];
}


-(UIViewController *)viewController {
    if(self.bridgeService){
        return (UIViewController *)self.bridgeService.viewController;
    } else {
        NSAssert(NO, @"the bridge Service is not connected");
        return nil;
    }
}

-(UIWebView *)webView{
    if(self.bridgeService){
        return (UIWebView *)self.bridgeService.webView;
    } else {
        NSAssert(NO, @"the bridge Service is not connected");
        return nil;
    }
}

-(id<LDJSCommandDelegate>)commandDelegate{
    if(self.bridgeService){
        return self.bridgeService.commandDelegate;
    } else {
        NSAssert(NO, @"the bridge Service is not connected");
        return nil;
    }
}


- (void)onClose:(NSNotification *)notification {
    if(self.bridgeService && self.bridgeService == notification.object) {
        self.bridgeService = nil;
        self.isReady = NO;
        [self stopPlugin];
    }
}

- (void)onWebViewFinishLoad:(NSNotification *)notification {
    if(self.bridgeService && self.bridgeService == notification.object) {
        self.isReady = YES;
    }
}


- (NSString*)writeJavascript:(NSString*)javascript{
    return [self.bridgeService jsMainLoopEval:javascript];
}

@end

