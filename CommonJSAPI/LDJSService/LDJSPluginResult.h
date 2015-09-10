//
//  LDJSService.h
//  CommonJSAPI
//
//  Created by 庞辉 on 14-10-13.
//  Copyright (c) 2014年 庞辉. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    LDJSCommandStatus_NO_RESULT = 0,
    LDJSCommandStatus_OK,
    LDJSCommandStatus_CLASS_NOT_FOUND_EXCEPTION,
    LDJSCommandStatus_ILLEGAL_ACCESS_EXCEPTION,
    LDJSCommandStatus_INSTANTIATION_EXCEPTION,
    LDJSCommandStatus_MALFORMED_URL_EXCEPTION,
    LDJSCommandStatus_IO_EXCEPTION,
    LDJSCommandStatus_INVALID_ACTION,
    LDJSCommandStatus_JSON_EXCEPTION,
    LDJSCommandStatus_ERROR
} LDJSCommandStatus;


/**
 * @class LDJSPluginResult
 * 封装native执行结果
 */
@interface LDJSPluginResult : NSObject {
}
@property (nonatomic, strong, readonly) NSNumber *status;
@property (nonatomic, strong, readonly) id message;

+ (LDJSPluginResult *)resultWithStatus:(LDJSCommandStatus)statusOrdinal;
+ (LDJSPluginResult *)resultWithStatus:(LDJSCommandStatus)statusOrdinal
                       messageAsString:(NSString *)theMessage;
+ (LDJSPluginResult *)resultWithStatus:(LDJSCommandStatus)statusOrdinal
                        messageAsArray:(NSArray *)theMessage;
+ (LDJSPluginResult *)resultWithStatus:(LDJSCommandStatus)statusOrdinal
                          messageAsInt:(int)theMessage;
+ (LDJSPluginResult *)resultWithStatus:(LDJSCommandStatus)statusOrdinal
                       messageAsDouble:(double)theMessage;
+ (LDJSPluginResult *)resultWithStatus:(LDJSCommandStatus)statusOrdinal
                         messageAsBool:(BOOL)theMessage;
+ (LDJSPluginResult *)resultWithStatus:(LDJSCommandStatus)statusOrdinal
                   messageAsDictionary:(NSDictionary *)theMessage;
+ (LDJSPluginResult *)resultWithStatus:(LDJSCommandStatus)statusOrdinal
                  messageToErrorObject:(int)errorCode;


/**
 * 直接封装Native处理结果
 */
- (NSString *)argumentsAsJSON;


/**
 * 将处理状态，和结果一起通过JSON形式封装；
 */
- (NSString *)toJSONString;


/**
 * 将处理结果封装成一个JS执行字符串
 */
- (NSString *)toJsCallbackString:(NSString *)callbackId;

@end
