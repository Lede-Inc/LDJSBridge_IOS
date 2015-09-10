//
//  JSAboutCtrl.m
//  CommonJSAPI
//
//  Created by 庞辉 on 14-10-16.
//  Copyright (c) 2014年 庞辉. All rights reserved.
//

#import "JSAboutCtrl.h"

@implementation JSAboutCtrl

- (id)initWithTitle:(NSString *)title
{
    self = [super init];
    if (self) {
        self.navigationItem.title = title;
        self.navigationItem.rightBarButtonItem =
            [[UIBarButtonItem alloc] initWithTitle:@"取消"
                                             style:UIBarButtonItemStylePlain
                                            target:self
                                            action:@selector(cancel)];
    }
    return self;
}

- (void)cancel
{
    [self dismissViewControllerAnimated:YES
                             completion:^() {
                                 [self.delegate cancel];
                             }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
}


@end
