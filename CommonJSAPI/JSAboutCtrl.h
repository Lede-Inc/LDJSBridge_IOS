//
//  JSAboutCtrl.h
//  CommonJSAPI
//
//  Created by 庞辉 on 14-10-16.
//  Copyright (c) 2014年 庞辉. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol JSAboutCtrlDelegate <NSObject>
-(void)cancel;
@end

@interface JSAboutCtrl : UIViewController {
    
}

@property (nonatomic, assign) id<JSAboutCtrlDelegate> delegate;
-(id)initWithTitle:(NSString *) title;


@end
