//
//  AppDelegate.m
//  CommonJSAPI
//
//  Created by 庞辉 on 14-10-10.
//  Copyright (c) 2014年 庞辉. All rights reserved.
//

#import "AppDelegate.h"
#import "LDPBaseWebViewCrtl.h"

@interface MainViewController : UIViewController {
}

@end

@implementation MainViewController

- (void)viewDidLoad
{
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"主界面";
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake((self.view.frame.size.width - 200.0f) / 2.0f,
                           (self.view.frame.size.height - 100.0f) / 2.0f, 200.0f, 100.0f);
    btn.layer.cornerRadius = 5.0f;
    btn.layer.masksToBounds = YES;
    [btn setBackgroundColor:[UIColor lightGrayColor]];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [btn.titleLabel setNumberOfLines:2];
    [btn setTitle:@"click\n打开一个webview" forState:UIControlStateNormal];
    [btn addTarget:self
                  action:@selector(openWebViewCtroller)
        forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}

- (void)openWebViewCtroller
{
    LDPBaseWebViewCrtl *webviewCtrl = [[LDPBaseWebViewCrtl alloc] init];
    NSString *demohtmlPath =
        [[NSBundle mainBundle] pathForResource:@"LDJSBridge_JS/api.htm" ofType:nil];
    if ([[NSFileManager defaultManager] fileExistsAtPath:demohtmlPath]) {
        webviewCtrl.url = demohtmlPath;
    } else {
        webviewCtrl.url = @"http://10.232.0.201/LDJSBridge_JS/api.htm";
    }
    [self.navigationController pushViewController:webviewCtrl animated:YES];
}


@end


@interface AppDelegate ()

@end

@implementation AppDelegate

- (id)init
{
    /** If you need to do any extra app-specific initialization, you can do it here
     *  -jm
     **/

    //设置UIWebview的共享缓存区；
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];

    [cookieStorage setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];

    int cacheSizeMemory = 8 * 1024 * 1024;  // 8MB
    int cacheSizeDisk = 32 * 1024 * 1024;   // 32MB
#if __has_feature(objc_arc)
    NSURLCache *sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:cacheSizeMemory
                                                            diskCapacity:cacheSizeDisk
                                                                diskPath:@"nsurlcache"];
#else
    NSURLCache *sharedCache =
        [[[NSURLCache alloc] initWithMemoryCapacity:cacheSizeMemory
                                       diskCapacity:cacheSizeDisk
                                           diskPath:@"nsurlcache"] autorelease];
#endif
    [NSURLCache setSharedURLCache:sharedCache];

    self = [super init];
    return self;
}

#pragma mark UIApplicationDelegate implementation
- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    NSString *patchInfoPath =
        [[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/www"];
    NSLog(@"bundlePath: %@", patchInfoPath);
    if ([[NSFileManager defaultManager] fileExistsAtPath:patchInfoPath]) {
        NSLog(@"bundlePath: exitst");
    }
    CGRect screenBounds = [[UIScreen mainScreen] bounds];

#if __has_feature(objc_arc)
    self.window = [[UIWindow alloc] initWithFrame:screenBounds];
#else
    self.window = [[[UIWindow alloc] initWithFrame:screenBounds] autorelease];
#endif
    self.window.autoresizesSubviews = YES;

    // Set your app's start page by setting the <content src='foo.html' /> tag in config.xml.
    // If necessary, uncomment the line below to override it.
    // self.viewController.startPage = @"index.html";

    // NOTE: To customize the view's frame size (which defaults to full screen), override
    // [self.viewController viewWillAppear:] in your view controller.
    UINavigationController *nav = [[UINavigationController alloc]
        initWithRootViewController:[[MainViewController alloc] init]];
    self.window.rootViewController = nav;
    [self.window makeKeyAndVisible];
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for
    // certain types of temporary interruptions (such as an incoming phone call or SMS message) or
    // when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame
    // rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store
    // enough application state information to restore your application to its current state in case
    // it is terminated later.
    // If your application supports background execution, this method is called instead of
    // applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo
    // many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive.
    // If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also
    // applicationDidEnterBackground:.
}

- (NSUInteger)application:(UIApplication *)application
    supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    // iPhone doesn't support upside down by default, while the iPad does.  Override to allow all
    // orientations always, and let the root view controller decide what's allowed (the supported
    // orientations mask gets intersected).
    NSUInteger supportedInterfaceOrientations = (1 << UIInterfaceOrientationPortrait) |
                                                (1 << UIInterfaceOrientationLandscapeLeft) |
                                                (1 << UIInterfaceOrientationLandscapeRight) |
                                                (1 << UIInterfaceOrientationPortraitUpsideDown);

    return supportedInterfaceOrientations;
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}


@end
