//
//  LDJSService.h
//  CommonJSAPI
//
//  Created by 庞辉 on 14-10-13.
//  Copyright (c) 2014年 庞辉. All rights reserved.
//


#import "LDJSQueue.h"

@implementation NSMutableArray (QueueAdditions)


- (id)cdv_queueHead{
    if ([self count] == 0) {
        return nil;
    }

    return [self objectAtIndex:0];
}


- (__autoreleasing id)cdv_dequeue{
    if ([self count] == 0) {
        return nil;
    }

    id head = [self objectAtIndex:0];
    if (head != nil) {
        [self removeObjectAtIndex:0];
    }

    return head;
}


- (id)cdv_pop{
    return [self cdv_dequeue];
}


- (void)cdv_enqueue:(id)object{
    [self addObject:object];
}

@end
