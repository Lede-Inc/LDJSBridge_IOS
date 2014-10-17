//
//  LDJSCommandDelegateImpl.h
//  CommonJSAPI
//
//  Created by 庞辉 on 14-10-13.
//  Copyright (c) 2014年 庞辉. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LDJSCommandDelegate.h"

@class LDJSService;
@class LDJSCommandQueue;

@interface LDJSCommandDelegateImpl : NSObject <LDJSCommandDelegate>{
@private
    __weak LDJSService* _jsService;
    NSRegularExpression* _callbackIdPattern;
@protected
    __weak LDJSCommandQueue* _commandQueue;
    BOOL _delayResponses;
}
- (id)initWithService:(LDJSService*)jsService;
- (void)flushCommandQueueWithDelayedJs;
@end
