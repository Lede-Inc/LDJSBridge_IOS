//
//  LDPBaseWebViewCrtl.m
//  CommonJSAPI
//
//  Created by 庞辉 on 14-10-13.
//  Copyright (c) 2014年 庞辉. All rights reserved.
//

#import "LDPBaseWebViewCrtl.h"
#import "LDJSService.h"

#define ARR_PLUGINS_CLASS @[@"LDPDevice"]
#define ARR_PLUGINS_KEY @[@"device"]

@interface LDPBaseWebViewCrtl ()<UIWebViewDelegate> {
    UIWebView* _webview;
    UIActivityIndicatorView *_activityView;
    LDJSService* _bridgeService;
    int _shareType;
}

@end

@implementation LDPBaseWebViewCrtl
@synthesize url = _url;
@synthesize jsCallback = _jsCallback;

-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self){
        UIBarButtonItem *refreshItem = [[UIBarButtonItem alloc] initWithTitle:@"刷新" style:UIBarButtonItemStylePlain target:self action:@selector(refresh)];
        UIBarButtonItem *forwardItem = [[UIBarButtonItem alloc] initWithTitle:@"前进" style:UIBarButtonItemStylePlain target:self action:@selector(forward)];
        UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@"后退" style:UIBarButtonItemStylePlain target:self action:@selector(back)];
        self.navigationItem.rightBarButtonItems = @[backItem, forwardItem, refreshItem];
    }
    return self;
}


-(void) refresh{
    if(_webview){
        [_webview reload];
    }
}

-(void) forward{
    if([_webview canGoForward]){
        [_webview goForward];
    }
}

-(void) back {
    if([_webview canGoBack]){
        [_webview goBack];
    }
}


#pragma mark navigationItem-Control
-(void)setNavigationRightBtnWithType:(int)type andTitle:(NSString *)title{
    _shareType = type;
    switch (type) {
        case 1:
        {
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(rightBtnAction)];
        }
            break;
        case 2:
        {
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(rightBtnAction)];
        }

            break;
        case 3:
        {
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks target:self action:@selector(rightBtnAction)];
        }
            break;
        case 4:
        {
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(rightBtnAction)];
        }
            break;
        default:
        {
            if([title isEqualToString:@""]) title = @"分享";
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStylePlain target:self action:@selector(rightBtnAction)];
        }
            break;
    }
}


-(void)rightBtnAction{
    if(_jsCallback && ![_jsCallback isEqualToString:@""]){
        [_webview stringByEvaluatingJavaScriptFromString:_jsCallback];
        
    } else {
        NSLog(@"nothing to do");
    }
}


-(void) viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Mobile JS Service";
    
    //创建webview
    [self createGapView];
    
    _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _activityView.center = CGPointMake(self.view.frame.size.width/2.0f, self.view.frame.size.height/2.0f);
    [self.view addSubview:_activityView];
    
    
    //注册插件Service
    if(_bridgeService == nil){
        _bridgeService = [[LDJSService alloc] initBridgeServiceWithConfig:@"PluginConfig.json"];
    }
    [_bridgeService connect:_webview Controller:self];
    
    
    //加载请求
    if(self.url && ![self.url isEqualToString:@""]){
        NSURL *url = [NSURL URLWithString:self.url];
        NSURLRequest* appReq = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:20.0];
        [_webview loadRequest:appReq];
    }
}

-(void) dealloc {
    [_bridgeService close];
    _bridgeService = nil;
    _webview = nil;
}


#pragma mark activity-style
/**
 *控制webview菊花的显示、隐藏和颜色
 */
-(void)showActivityLoading {
    _activityView.hidden = NO;
    [_activityView startAnimating];
}

-(void)hideActivityLoading {
    _activityView.hidden = YES;
    [_activityView stopAnimating];
}

-(void)setActivityLoadingColor: (UIColor *)color {
    _activityView.color = color;
}


/**
 * 创建webview
 *
 * @param bounds
 */
- (void)createGapView{
    CGRect webViewBounds = self.view.bounds;
    webViewBounds.origin = self.view.bounds.origin;
    
    _webview = [self newCordovaViewWithFrame:webViewBounds];
    _webview.delegate = self;
    _webview.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    
    [self.view addSubview:_webview];
    [self.view sendSubviewToBack:_webview];
}

- (UIWebView*)newCordovaViewWithFrame:(CGRect)bounds{
    return [[UIWebView alloc] initWithFrame:bounds];
}



#pragma mark UIWebViewDelegate
/**
 When web application loads Add stuff to the DOM, mainly the user-defined settings from the Settings.plist file, and
 the device's data such as device ID, platform version, etc.
 */
- (void)webViewDidStartLoad:(UIWebView*)theWebView{
    NSLog(@"Resetting plugins due to page load.");
}

/**
 Called when the webview finishes loading.  This stops the activity view.
 */
- (void)webViewDidFinishLoad:(UIWebView*)theWebView{
    NSLog(@"Finished load of: %@", theWebView.request.URL);
    //当webview finish load之后，发event事件通知前端JSBridgeService已经就绪
    //监听事件由各个产品自行决定
    [_bridgeService readyWithEvent:@"LDJSBridgeServiceReady"];
}

- (void)webView:(UIWebView*)theWebView didFailLoadWithError:(NSError*)error{
    NSLog(@"Failed to load webpage with error: %@", [error localizedDescription]);
}

- (BOOL)webView:(UIWebView*)theWebView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSURL* url = [request URL];
    NSLog(@"url:::::%@", [url absoluteString]);
    return YES;
}







@end
