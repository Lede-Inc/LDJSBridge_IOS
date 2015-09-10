//
//  LDPUINavCtrl.m
//  CommonJSAPI
//
//  Created by 庞辉 on 14-10-16.
//  Copyright (c) 2014年 庞辉. All rights reserved.
//

#import "LDPUINavCtrl.h"
#import "LDPBaseWebViewCrtl.h"
#import "JSAboutCtrl.h"

#define ENABLE_VIEWS                                                                               \
    ([NSDictionary dictionaryWithObjects:@[ @"JSAboutCtrl" ] forKeys:@[ @"about" ]])
#define TAG_ALERTVIEW 987000001
#define NOTI_CONFIRMALERT @"LDPlugin_AlertView"


@interface LDPUINavCtrl () <UIAlertViewDelegate, JSAboutCtrlDelegate> {
    LDJSInvokedUrlCommand *_cacheCommand;
}

@end

@implementation LDPUINavCtrl

/*
 *@func  在指定的target打开url页面
 *@param url    指定的url地址
 *@param target 指定打开Webview的方式，0:在当前webview打开（默认）1:在新的webview打开
 *2:在外部浏览器打开
 *@param style  Webview的样式(只对target＝1有效) 0:顶部标题栏（默认）1:顶部标题栏无分享
 *2:加底部工具栏 3:加底部工具栏顶部无分享；
 */
- (void)openLinkInNewWebView:(LDJSInvokedUrlCommand *)command
{
    NSString *url = [command jsonParamForkey:@"url"];
    NSDictionary *dic_options = [command jsonParamForkey:@"options"];
    int target = [[dic_options objectForKey:@"target"] intValue];

    switch (target) {
        //外部js处理
        case 0:
            break;

        //打开新的webview
        case 1: {
            LDPBaseWebViewCrtl *newWebViewCtrl = [[LDPBaseWebViewCrtl alloc] init];
            newWebViewCtrl.url = url;
            [self.viewController.navigationController pushViewController:newWebViewCtrl
                                                                animated:YES];

            //目前只处理0，1的情况；3，4底部加工具栏由具体项目去处理
            int style = [[dic_options objectForKey:@"style"] intValue];
            if (style == 0) {
                [newWebViewCtrl setNavigationRightBtnWithType:0 andTitle:@""];
            } else {
            }
        } break;
        //在浏览器打开
        case 2: {
            NSURL *openURL = [NSURL URLWithString:url];
            [[UIApplication sharedApplication] openURL:openURL];
        } break;
        default:
            break;
    }


    // nothing to callback
}


/*
 *@func  打开指定名字的viewController
 *@param name    view的名字
 *@param options 传递给客户端的启动参数
 *@param onclonse 当打开的viewCtroller关闭后，客户端执行回调，带上数据传回原webview
 */
- (void)openViewController:(LDJSInvokedUrlCommand *)command
{
    NSString *viewCtrlName = [command jsonParamForkey:@"name"];
    NSDictionary *dic_options = [command jsonParamForkey:@"options"];
    ///    NSString *onclose = [command jsonParamForkey:@"onclose"];

    if (viewCtrlName && ![viewCtrlName isEqualToString:@""]) {
        NSString *viewClass = [ENABLE_VIEWS objectForKey:[viewCtrlName lowercaseString]];
        if (viewCtrlName != nil) {
            JSAboutCtrl *viewCtrl = (JSAboutCtrl *)[[NSClassFromString(viewClass) alloc]
                initWithTitle:[dic_options objectForKey:@"title"]];
            viewCtrl.delegate = self;
            UINavigationController *nav =
                [[UINavigationController alloc] initWithRootViewController:viewCtrl];
            [self.viewController presentViewController:nav
                                              animated:YES
                                            completion:^() {
                                                _cacheCommand = command;
                                            }];

            //[self.viewController.navigationController pushViewController:viewCtrl animated:YES];
        }
    }
}


- (void)cancel
{
    if (_cacheCommand != nil) {
        LDJSPluginResult *result =
            [LDJSPluginResult resultWithStatus:LDJSCommandStatus_OK messageAsInt:1];
        [self.commandDelegate sendPluginResult:result callbackId:_cacheCommand.callbackId];
    }
}


/*
 *@func 关闭当前webview
 */
- (void)popBack:(LDJSInvokedUrlCommand *)command
{
    [self.viewController.navigationController popViewControllerAnimated:YES];
}


/*
 *@func  返回到打开该webview的AIO，例如使用openUrl打开了多个Webview之后，
 *调用该函数将立刻返回到打开Webview之前的AIO窗口，而调用popBack只会关闭当前Webview
 */
- (void)returnToAIO:(LDJSInvokedUrlCommand *)command
{
    NSArray *navViewCtrls = self.viewController.navigationController.viewControllers;
    int num = (int)navViewCtrls.count;
    for (int i = num - 1; i >= 0; i--) {
        UIViewController *tmp_ctrl = [navViewCtrls objectAtIndex:i];
        if ([tmp_ctrl isKindOfClass:[LDPBaseWebViewCrtl class]]) {
            continue;
        }
        [self.viewController.navigationController popToViewController:tmp_ctrl animated:YES];
    }
}


/*
 *@func  配置webview右上角按钮的标题、点击回调等；
 *@param title  设置右上角的按钮文字
 *@param hidden 是否隐藏右上角按钮
 *@param iconID 图标的本地资源ID（只支持内置的资源） 1:编辑 2:删除 3:浏览器默认图标 4:分享图标
 *@param callback 点击按钮后的回调
 */
- (void)setActionButton:(LDJSInvokedUrlCommand *)command
{
    NSString *title = [command jsonParamForkey:@"title"];
    int type = -1;
    if (title && ![title isEqualToString:@""]) {
        type = 0;
    } else {
        type = [[command jsonParamForkey:@"iconID"] intValue];
    }

    LDPBaseWebViewCrtl *ctrl = (LDPBaseWebViewCrtl *)self.viewController;
    [ctrl setNavigationRightBtnWithType:type andTitle:(type == 0 ? title : @"")];

    BOOL hidden = [[command jsonParamForkey:@"hidden"] boolValue];
    if (hidden) {
        [ctrl.navigationItem setRightBarButtonItem:nil];
    }

    LDJSPluginResult *result =
        [LDJSPluginResult resultWithStatus:LDJSCommandStatus_OK messageAsBool:YES];
    NSString *jsCallback = [result toJsCallbackString:command.callbackId];
    ctrl.jsCallback = jsCallback;
}

/*
 *@func  配置菊花是否可见和样式
 *@param visible 控制菊花可见度
 *@param color 数组 r,g,b控制菊花颜色
 */
- (void)showLoading:(LDJSInvokedUrlCommand *)command
{
    LDPBaseWebViewCrtl *ctrl = (LDPBaseWebViewCrtl *)self.viewController;
    [ctrl showActivityLoading];
}

- (void)hideLoading:(LDJSInvokedUrlCommand *)command
{
    LDPBaseWebViewCrtl *ctrl = (LDPBaseWebViewCrtl *)self.viewController;
    [ctrl hideActivityLoading];
}

- (void)setLoadingColor:(LDJSInvokedUrlCommand *)command
{
    int r = [[command jsonParamForkey:@"r"] intValue];
    int g = [[command jsonParamForkey:@"g"] intValue];
    int b = [[command jsonParamForkey:@"b"] intValue];
    UIColor *color = [UIColor colorWithRed:r green:g blue:b alpha:1.0f];

    LDPBaseWebViewCrtl *ctrl = (LDPBaseWebViewCrtl *)self.viewController;
    [ctrl setActivityLoadingColor:color];
}


/*
 *@func  弹出一个确认框
 *@param params  确认框的参数，包括title,text,needOkBtn,needCancelBtn
 *@param callback 点击按钮的回调函数
 */
- (void)showDialog:(LDJSInvokedUrlCommand *)command
{
    NSString *title = [command jsonParamForkey:@"title"];
    NSString *text = [command jsonParamForkey:@"text"];
    NSString *okBtnText = [command jsonParamForkey:@"okBtnText"];
    NSString *cancelBtnText = [command jsonParamForkey:@"cancelBtnlText"];
    BOOL needOkBtn = false;
    if ([command jsonParamForkey:@"needOkBtn"] != nil) {
        needOkBtn = [[command jsonParamForkey:@"needOkBtn"] boolValue];
    }

    BOOL needCancelBtn = false;
    if ([command jsonParamForkey:@"needCancelBtn"] != nil) {
        needCancelBtn = [[command jsonParamForkey:@"needCancelBtn"] boolValue];
    }

    UIAlertView *confirmAlert = [[UIAlertView alloc]
            initWithTitle:title
                  message:text
                 delegate:self
        cancelButtonTitle:(needCancelBtn ? (cancelBtnText && cancelBtnText &&
                                                    ![cancelBtnText isEqualToString:@""]
                                                ? cancelBtnText
                                                : @"取消")
                                         : (nil))
        otherButtonTitles:(needOkBtn ? (okBtnText && ![okBtnText isEqualToString:@""] ? okBtnText
                                                                                       : @"确定")
                                     : (nil)),
                          nil];
    [[NSUserDefaults standardUserDefaults] setObject:command.callbackId forKey:NOTI_CONFIRMALERT];
    [[NSUserDefaults standardUserDefaults] synchronize];
    confirmAlert.tag = TAG_ALERTVIEW;
    [confirmAlert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //处理alertview
    if (alertView.tag == TAG_ALERTVIEW) {
        LDJSPluginResult *result = [LDJSPluginResult
               resultWithStatus:LDJSCommandStatus_OK
            messageAsDictionary:
                [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:buttonIndex],
                                                           @"button", nil]];
        NSString *callBackId =
            [[NSUserDefaults standardUserDefaults] objectForKey:NOTI_CONFIRMALERT];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:NOTI_CONFIRMALERT];
        [[NSUserDefaults standardUserDefaults] synchronize];
        if (callBackId && ![callBackId isEqualToString:@""]) {
            [self.commandDelegate sendPluginResult:result callbackId:callBackId];
        }
    }
}


/*
 *@func  刷新客户端显示的网页标题
 */
- (void)refreshTitle:(LDJSInvokedUrlCommand *)command
{
    NSString *title = [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    self.viewController.navigationItem.title = title;
}


@end
