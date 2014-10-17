//
//  LDPUIGlobalCtrl.h
//  CommonJSAPI
//
//  Created by 庞辉 on 14-10-16.
//  Copyright (c) 2014年 庞辉. All rights reserved.
//

#import "LDJSPlugin.h"

@class LDJSInvokedUrlCommand;
@interface LDPUIGlobalCtrl : LDJSPlugin{
    
}

/*
 *@func  弹出ActionSheet
 *@param tilte  ActionSheet标题
 *@param cancel 指定取消按钮的标题
 *@param items  选项里表、字符串
 *
 *@return type 0: 点击普通item 1:取消按钮或空白区域
 *@return index 点击item的下标，从0开始
 */
-(void)showActionSheet:(LDJSInvokedUrlCommand *)command;


/*
 *@func  查询页面的可见性： 当当前可见view不是本页面，或应用退到后台时，返回false
 *
 *@return result bool
 */
-(void)pageVisibility:(LDJSInvokedUrlCommand *)command;


/*
 *@func  设置webview被关闭前的回调，设置回调后将会替代原来的行为
 */
-(void)setOnCloseHandler:(LDJSInvokedUrlCommand *)command;


/*
 *@func  弹出文本的toast提示，2s后消失
 *@param text 提示的文本内容
 */
-(void)showTips:(LDJSInvokedUrlCommand *)command;


/*
 *@func  配置webview的行为
 *@param swipeBack 1支持优化关闭手势；
 *@param actionButton 1显示右上角按钮
 *@param navBgColor navigation背景颜色
 *@param navTextColor navigation文字颜色
 *@param keyboardDisplayRequiresUserAction 设置为true允许js不经用户触发谈起键盘
 */
-(void)setWebViewBehavior:(LDJSInvokedUrlCommand *)command;


/*
 *@func  唤起分享面板
 */
-(void)showShareMenu:(LDJSInvokedUrlCommand *)command;


/*
 *@func  关闭相邻的webview
 *@param mode   关闭模式 0:关闭所有相邻，1:关闭当前webview之上的所有webview 2:关闭当前之下的所有相邻webview
 *@param exclude 是否不关闭当前webview
 */
-(void)closeWebViews:(LDJSInvokedUrlCommand *)command;


@end
