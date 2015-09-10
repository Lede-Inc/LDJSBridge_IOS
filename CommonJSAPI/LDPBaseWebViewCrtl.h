//
//  LDPBaseWebViewCrtl.h
//  CommonJSAPI
//
//  Created by 庞辉 on 14-10-13.
//  Copyright (c) 2014年 庞辉. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LDPBaseWebViewCrtl : UIViewController {
}

@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *jsCallback;


//初始化右上角的分享按钮
- (void)setNavigationRightBtnWithType:(int)type andTitle:(NSString *)title;

//设置webview菊花的显示、隐藏和颜色；
- (void)showActivityLoading;
- (void)hideActivityLoading;
- (void)setActivityLoadingColor:(UIColor *)color;
@end
