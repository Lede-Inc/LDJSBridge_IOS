//
//  JSAboutCtrl.m
//  CommonJSAPI
//
//  Created by 庞辉 on 14-10-16.
//  Copyright (c) 2014年 庞辉. All rights reserved.
//

#import "JSAboutCtrl.h"

@implementation JSAboutCtrl

-(id)initWithTitle:(NSString *) title {
    self = [super init];
    if(self){
        self.navigationItem.title = title;
    }
    return self;
}

-(void) viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
}




@end
