//
//  LDJSService.h
//  CommonJSAPI
//
//  Created by 庞辉 on 14-10-13.
//  Copyright (c) 2014年 庞辉. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (QueueAdditions)
- (id)cdv_pop;
- (id)cdv_queueHead;
- (id)cdv_dequeue;
- (void)cdv_enqueue:(id)obj;
@end
