//
//  LDJSPluginManager.h
//  CommonJSAPI
//
//  Created by 庞辉 on 1/23/15.
//  Copyright (c) 2015 庞辉. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LDJSPlugin.h"

/**
 * @class LDJSExportDetail
 * 对插件对外开放JSAPI调用接口和插件native方法的对应
 */
@interface LDJSExportDetail : NSObject{}
@property (strong, nonatomic) NSString *showMethod; //JSAPI调用方法名
@property (strong, nonatomic) NSString *realMethod; //插件method名

@end



/**
 * @class LDJSPluginInfo
 * 插件的详细配置描述
 */
@interface LDJSPluginInfo : NSObject{}
@property (strong, nonatomic) NSString *pluginName;
@property (strong, nonatomic) NSString *pluginClass;
@property (strong, nonatomic) NSMutableDictionary *exports;
@property (strong, nonatomic) LDJSPlugin *instance;

/**
 *根据JSAPI调用方法名获取实际的selector method方法；
 */
-(LDJSExportDetail *)getDetailByShowMethod:(NSString *)showMethod;

@end



/**
 * @class LDJSPluginManager
 * 对本地实现所有Plugin的管理器
 */
@interface LDJSPluginManager : NSObject {}
/**
 *根据配置文件初始化一个插件管理器
 */
-(id)initWithConfigFile:(NSString *)file;
-(void)resetWithConfigFile:(NSString *)path;


/**
 * 根据PluginName获取该插件的实例对象
 */
-(id)getPluginInstanceByPluginName:(NSString *)pluginName;


/**
 * 根据plugin的showMethod获取Native对应的SEL
 */
-(NSString *)realForShowMethod:(NSString *)showMethod;

@end
