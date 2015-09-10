//
//  LDJSCommandQueue.h
//  CommonJSAPI
//
//  Created by 庞辉 on 14-10-13.
//  Copyright (c) 2014年 庞辉. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * @class LDJSInvokedUrlCommand
 * 解析URL传进来的Command命令和参数
 */
@interface LDJSInvokedUrlCommand : NSObject {
    NSString *_callbackId;
    NSString *_pluginName;
    NSString *_pluginShowMethod;
    NSArray *_arguments;        //存储通过p传入的参数，按照传入顺序读取
    NSDictionary *_jsonParams;  //用来存储通过json参数对应的key-value值
}

@property (nonatomic, readonly) NSDictionary *jsonParams;
@property (nonatomic, readonly) NSArray *arguments;
@property (nonatomic, readonly) NSString *callbackId;
@property (nonatomic, readonly) NSString *pluginName;
@property (nonatomic, readonly) NSString *pluginShowMethod;


+ (LDJSInvokedUrlCommand *)commandFromJson:(NSArray *)jsonEntry;


/**
 * 存储或者获取通过JSON传进来的参数
 */
- (id)initWithJsonParams:(NSDictionary *)jsonParams
               Arguments:(NSArray *)arguments
              callbackId:(NSString *)callbackId
               className:(NSString *)className
              methodName:(NSString *)methodName;

- (id)jsonParamForkey:(NSString *)key;
- (id)jsonParamForkey:(NSString *)key withDefault:(id)defaultValue;
- (id)jsonParamForkey:(NSString *)key withDefault:(id)defaultValue andClass:(Class)aClass;


/**
 * 存储活着获取通过Array传进来的参数
 */
- (id)argumentAtIndex:(NSUInteger)index;
- (id)argumentAtIndex:(NSUInteger)index withDefault:(id)defaultValue;
- (id)argumentAtIndex:(NSUInteger)index withDefault:(id)defaultValue andClass:(Class)aClass;


@end
