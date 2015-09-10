//
//  LDPUINavCtrl.h
//  CommonJSAPI
//
//  Created by 庞辉 on 14-10-16.
//  Copyright (c) 2014年 庞辉. All rights reserved.
//

#import "LDJSPlugin.h"

@class LDJSInvokedUrlCommand;
@interface LDPUINavCtrl : LDJSPlugin {
}

/*
 *@func  在指定的target打开url页面
 *@param url    指定的url地址
 *@param target 指定打开Webview的方式，0:在当前webview打开（默认）1:在新的webview打开
 *2:在外部浏览器打开
 *@param style  Webview的样式 0:顶部标题栏（默认）1:顶部标题栏无分享 2:加底部工具栏
 *3:加底部工具栏顶部无分享；
 */
- (void)openLinkInNewWebView:(LDJSInvokedUrlCommand *)command;


/*
 *@func  打开指定名字的viewController
 *@param name    view的名字
 *@param options 传递给客户端的启动参数
 *@param onclonse 当打开的viewCtroller关闭后，客户端执行回调，带上数据传回原webview
 */
- (void)openViewController:(LDJSInvokedUrlCommand *)command;


/*
 *@func 关闭当前webview
 */
- (void)popBack:(LDJSInvokedUrlCommand *)command;


/*
 *@func  返回到打开该webview的AIO，例如使用openUrl打开了多个Webview之后，
 *调用该函数将立刻返回到打开Webview之前的AIO窗口，而调用popBack只会关闭当前Webview
 */
- (void)returnToAIO:(LDJSInvokedUrlCommand *)command;


/*
 *@func  配置webview右上角按钮的标题、点击回调等；
 *@param title  设置右上角的按钮文字
 *@param hidden 是否隐藏右上角按钮
 *@param iconID 图标的本地资源ID（只支持内置的资源） 1:编辑 2:删除 3:浏览器默认图标 4:分享图标
 *@param callback 点击按钮后的回调
 */
- (void)setActionButton:(LDJSInvokedUrlCommand *)command;

/*
 *@func  配置菊花是否可见和样式
 *@param visible 控制菊花可见度
 *@param color 数组 r,g,b控制菊花颜色
 */
- (void)showLoading:(LDJSInvokedUrlCommand *)command;
- (void)hideLoading:(LDJSInvokedUrlCommand *)command;
- (void)setLoadingColor:(LDJSInvokedUrlCommand *)command;


/*
 *@func  弹出一个确认框
 *@param params  确认框的参数，包括title,text,needOkBtn,needCancelBtn
 *@param callback 点击按钮的回调函数
 */
- (void)showDialog:(LDJSInvokedUrlCommand *)command;


/*
 *@func  刷新客户端显示的网页标题
 */
- (void)refreshTitle:(LDJSInvokedUrlCommand *)command;

@end
