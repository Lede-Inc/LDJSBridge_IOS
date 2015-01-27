//
//  LDPUIGlobalCtrl.m
//  CommonJSAPI
//
//  Created by 庞辉 on 14-10-16.
//  Copyright (c) 2014年 庞辉. All rights reserved.
//

#import "LDPUIGlobalCtrl.h"
#import "LDPBaseWebViewCrtl.h"

#define TAG_ACTIONSHEET 987000002
#define NOTI_ACTIONSHEET @"LDPlugin_ActionSheet"

@interface LDPUIGlobalCtrl () <UIActionSheetDelegate>{
    
}

@end

@implementation LDPUIGlobalCtrl

/*
 *@func  弹出ActionSheet
 *@param tilte  ActionSheet标题
 *@param cancel 指定取消按钮的标题
 *@param items  选项里表、字符串
 *
 *@return type 0: 点击普通item 1:取消按钮或空白区域
 *@return index 点击item的下标，从0开始
 */
-(void)showActionSheet:(LDJSInvokedUrlCommand *)command{
    NSString *title = [command jsonParamForkey:@"title"];
    NSString *cancel = [command jsonParamForkey:@"cancel"];
    NSString *close = [command jsonParamForkey:@"close"];
    NSString *onclick =  [command jsonParamForkey:@"onclick"];
    NSArray *items = [command jsonParamForkey:@"items"];
    
    //设置回调函数并存储
    NSString *callbackID = command.callbackId;
    if(onclick && ![onclick isEqualToString:@""]){
        callbackID = onclick;
    }
    [[NSUserDefaults standardUserDefaults] setObject:callbackID forKey:NOTI_ACTIONSHEET];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    

    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:(cancel && ![cancel isEqualToString:@""]?cancel:@"取消") destructiveButtonTitle:(close && ![close isEqualToString:@""] ? close:@"确定") otherButtonTitles:nil, nil];
    if(items && items.count > 0){
        for(int i = 0; i < items.count; i++){
            [actionSheet addButtonWithTitle:[items objectAtIndex:i]];
        }
    }
    actionSheet.tag = TAG_ACTIONSHEET;
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [actionSheet showInView:self.viewController.view];
}

// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(actionSheet.tag == TAG_ACTIONSHEET){
        int type = buttonIndex <= 1?0:1;
        long index = buttonIndex <= 1?-1:buttonIndex-2;
        NSString *callBackId = [[NSUserDefaults standardUserDefaults] objectForKey:NOTI_ACTIONSHEET];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:NOTI_ACTIONSHEET];
        [[NSUserDefaults standardUserDefaults] synchronize];
        LDJSPluginResult *result = [LDJSPluginResult resultWithStatus:LDJSCommandStatus_OK messageAsDictionary:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:type],@"type",[NSNumber numberWithLong:index],@"index", nil]];
        if(callBackId && ![callBackId isEqualToString:@""]){
            [self.commandDelegate sendPluginResult:result callbackId:callBackId];
        }
    }
}


/*
 *@func  查询页面的可见性： 当当前可见view不是本页面，或应用退到后台时，返回false
 *
 *@return result bool
 */
-(void)pageVisibility:(LDJSInvokedUrlCommand *)command{
    BOOL hidden = self.viewController.view.hidden;
    LDJSPluginResult *result = [LDJSPluginResult resultWithStatus:LDJSCommandStatus_OK messageAsBool:hidden?NO:YES];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}


/*
 *@func  设置webview被关闭前的回调，设置回调后将会替代原来的行为
 */
-(void)setOnCloseHandler:(LDJSInvokedUrlCommand *)command{
    [self.viewController.navigationController popViewControllerAnimated:YES];
}


/*
 *@func  弹出文本的toast提示，2s后消失
 *@param text 提示的文本内容
 */
-(void)showTips:(LDJSInvokedUrlCommand *)command{
    
}


/*
 *@func  配置webview的行为
 *@param swipeBack 1支持优化关闭手势；
 *@param actionButton 1显示右上角按钮
 *@param navBgColor navigation背景颜色
 *@param navTextColor navigation文字颜色
 *@param keyboardDisplayRequiresUserAction 设置为true允许js不经用户触发谈起键盘
 */
-(void)setWebViewBehavior:(LDJSInvokedUrlCommand *)command{
    
}


/*
 *@func  唤起分享面板
 */
-(void)showShareMenu:(LDJSInvokedUrlCommand *)command{
    
}


/*
 *@func  关闭相邻的webview
 *@param mode   关闭模式 0:关闭所有相邻，1:关闭当前webview之上的所有webview 2:关闭当前之下的所有相邻webview
 *@param exclude 是否不关闭当前webview
 */
-(void)closeWebViews:(LDJSInvokedUrlCommand *)command{
    //BOOL exclude = [[command jsonParamForkey:@"exclude"] boolValue];
    //int mode = [[command jsonParamForkey:@"mode"] intValue];
    while (self.webView.canGoBack) {
        [self.webView goBack];
    }
}





@end
