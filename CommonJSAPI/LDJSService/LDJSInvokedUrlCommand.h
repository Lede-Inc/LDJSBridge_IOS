/*
 Licensed to the Apache Software Foundation (ASF) under one
 or more contributor license agreements.  See the NOTICE file
 distributed with this work for additional information
 regarding copyright ownership.  The ASF licenses this file
 to you under the Apache License, Version 2.0 (the
 "License"); you may not use this file except in compliance
 with the License.  You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing,
 software distributed under the License is distributed on an
 "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 KIND, either express or implied.  See the License for the
 specific language governing permissions and limitations
 under the License.
 */

#import <Foundation/Foundation.h>

@interface LDJSInvokedUrlCommand : NSObject {
    NSString* _callbackId;
    NSString* _className;
    NSString* _methodName;
    NSArray* _arguments; //存储通过p传入的参数，按照传入顺序读取
    NSDictionary * _jsonParams; //用来存储通过json参数对应的key-value值
}

@property (nonatomic, readonly) NSDictionary* jsonParams;
@property (nonatomic, readonly) NSArray* arguments;
@property (nonatomic, readonly) NSString* callbackId;
@property (nonatomic, readonly) NSString* className;
@property (nonatomic, readonly) NSString* methodName;


+ (LDJSInvokedUrlCommand*)commandFromJson:(NSArray*)jsonEntry;
- (id)initFromJson:(NSArray*)jsonEntry;


#pragma mark jsonParams
-(id) initWithJsonParams:(NSDictionary *)jsonParams
              Arguments:(NSArray *)arguments
             callbackId:(NSString *)callbackId
              className:(NSString *)className
              methodName:(NSString *)methodName;

-(id)jsonParamForkey: (NSString *)key;
-(id)jsonParamForkey:(NSString *)key withDefault:(id)defaultValue;
-(id)jsonParamForkey:(NSString *)key withDefault:(id)defaultValue andClass:(Class) aClass;


// Returns the argument at the given index.
// If index >= the number of arguments, returns nil.
// If the argument at the given index is NSNull, returns nil.
- (id)argumentAtIndex:(NSUInteger)index;
// Same as above, but returns defaultValue instead of nil.
- (id)argumentAtIndex:(NSUInteger)index withDefault:(id)defaultValue;
// Same as above, but returns defaultValue instead of nil, and if the argument is not of the expected class, returns defaultValue
- (id)argumentAtIndex:(NSUInteger)index withDefault:(id)defaultValue andClass:(Class)aClass;



@end
