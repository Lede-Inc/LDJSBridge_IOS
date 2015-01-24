//
//  LDJSService.h
//  CommonJSAPI
//
//  Created by 庞辉 on 14-10-13.
//  Copyright (c) 2014年 庞辉. All rights reserved.
//


@interface NSArray (LDJSBridgeJSONSerializing)
- (NSString*)cdv_JSONString;
@end

@interface NSDictionary (LDJSBridgeJSONSerializing)
- (NSString*)cdv_JSONString;
@end

@interface NSString (LDJSBridgeJSONSerializing)
- (id)cdv_JSONObject;
@end
