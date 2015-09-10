//
//  LDJSPluginManager.m
//  CommonJSAPI
//
//  Created by 庞辉 on 1/23/15.
//  Copyright (c) 2015 庞辉. All rights reserved.
//

#import "LDJSPluginManager.h"
#define JsBridgeCoreFileName @"LDJSBridge.js.txt"  //核心JS文件默认为这个名字
@implementation LDJSExportDetail
@end


@implementation LDJSPluginInfo

- (LDJSExportDetail *)getDetailByShowMethod:(NSString *)showMethod;
{
    return [self.exports objectForKey:showMethod];
}

@end


@interface LDJSPluginManager () {
    NSString *_updateUrl;
    NSString *_coreBridgeJSFileName;
    BOOL _isUpdate;
}
@property (strong, nonatomic) NSMutableDictionary *pluginMap;

@end


@implementation LDJSPluginManager

#pragma mark - pluginManager initial
- (id)init
{
    self = [super init];
    if (self) {
        _pluginMap = [[NSMutableDictionary alloc] init];
        _isUpdate = NO;
        _updateUrl = nil;
        _coreBridgeJSFileName = nil;
    }
    return self;
}


- (id)initWithConfigFile:(NSString *)file
{
    self = [self init];
    if (self) {
        [self resetWithConfigFile:file];

        //每次resetConfig文件中如果没有检查更新，更新文件
        [NSThread detachNewThreadSelector:@selector(updateCodeBridgeJSCode)
                                 toTarget:self
                               withObject:nil];
    }
    return self;
}


- (void)resetWithConfigFile:(NSString *)file
{
    [_pluginMap removeAllObjects];
    NSString *path = [[NSBundle mainBundle] pathForResource:[file stringByDeletingPathExtension]
                                                     ofType:[file pathExtension]];
    if (path) {
        NSData *data = [NSData dataWithContentsOfFile:path];
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data
                                                             options:NSJSONReadingMutableContainers
                                                               error:nil];
        //以更新url的文件作为核心JS文件的命名
        _updateUrl = [dict objectForKey:@"update"];
        if (_updateUrl != nil && ![_updateUrl isEqualToString:@""]) {
            _coreBridgeJSFileName = [_updateUrl lastPathComponent];
        } else {
            _coreBridgeJSFileName = JsBridgeCoreFileName;
        }

        NSArray *plugins = [dict objectForKey:@"plugins"];
        for (NSDictionary *plugin in plugins) {
            LDJSPluginInfo *info = [[LDJSPluginInfo alloc] init];
            info.pluginName = [plugin objectForKey:@"pluginname"];
            info.pluginClass = [plugin objectForKey:@"pluginclass"];
            NSMutableDictionary *exports = [[NSMutableDictionary alloc] init];
            for (NSDictionary *exportInfo in [plugin objectForKey:@"exports"]) {
                LDJSExportDetail *tmp = [[LDJSExportDetail alloc] init];
                tmp.showMethod = [exportInfo objectForKey:@"showmethod"];
                tmp.realMethod = [exportInfo objectForKey:@"realmethod"];
                [exports setObject:tmp forKey:tmp.showMethod];
            }
            info.exports = exports;
            if (NSClassFromString(info.pluginClass) != nil) {
                id obj = [[NSClassFromString(info.pluginClass) alloc] init];
                if (obj != nil) {
                    info.instance = obj;
                    [info.instance pluginInitialize];
                } else {
                    NSLog(@"plugin class %@ initial failure", info.pluginClass);
                }
            } else {
                NSLog(@"plugin %@'class %@ does not exist.", info.pluginName, info.pluginClass);
            }

            [_pluginMap setObject:info forKey:info.pluginName];
        }
    }
}


- (id)getPluginInstanceByPluginName:(NSString *)pluginName
{
    return ((LDJSPluginInfo *)[self.pluginMap objectForKey:pluginName]).instance;
}


- (NSString *)realForShowMethod:(NSString *)showMethod
{
    NSString *realMethod = nil;
    //找到包含showMethod的插件信息
    for (NSString *key in _pluginMap.allKeys) {
        LDJSPluginInfo *tmp = [_pluginMap objectForKey:key];
        if ([tmp getDetailByShowMethod:showMethod]) {
            realMethod = [tmp getDetailByShowMethod:showMethod].realMethod;
            break;
        }
    }


    if (realMethod == nil) {
        realMethod = showMethod;
    }

    NSString *selStr = [NSString stringWithFormat:@"%@:", realMethod];
    return selStr;
}


#pragma mark - 核心JS文件更新修复
- (NSString *)bridgeCacheDir
{
    NSString *cacheDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask,
                                                              YES) objectAtIndex:0];
    NSString *theBridgeCacheDir = [cacheDir stringByAppendingPathComponent:@"_ldbridge_Cache_"];
    NSLog(@"theBridgeCacheDir>>>>%@", theBridgeCacheDir);
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:theBridgeCacheDir]) {
        BOOL isCreate = [fileManager createDirectoryAtPath:theBridgeCacheDir
                               withIntermediateDirectories:YES
                                                attributes:nil
                                                     error:nil];
        // bundle cache 目录建立不成功，返回不进行拷贝
        if (!isCreate) {
            return @"";
        }
    }

    return theBridgeCacheDir;
}


/**
 * 每次初始化bridgeService时，检查线上文件是否有更新，
 * 如果更新，下载替换本地文件
 */
- (void)updateCodeBridgeJSCode
{
    if (!_isUpdate && _updateUrl) {
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setCachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData];
        [request setURL:[NSURL URLWithString:_updateUrl]];
        [request setHTTPMethod:@"GET"];
        [request setTimeoutInterval:30];

        //获取验证返回码
        NSHTTPURLResponse *urlResponse = nil;
        NSData *responseData = [NSURLConnection sendSynchronousRequest:request
                                                     returningResponse:&urlResponse
                                                                 error:nil];
        if ([urlResponse statusCode] == 200 && responseData != nil) {
            NSString *onlineJSCode =
                [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
            NSString *localJSCode = [self localCoreBridgeJSCode];
            if (onlineJSCode.length != localJSCode.length ||
                ![onlineJSCode isEqualToString:localJSCode]) {
                NSString *cacheBridgeFilePath =
                    [[self bridgeCacheDir] stringByAppendingFormat:@"/%@", _coreBridgeJSFileName];
                NSLog(@"bridgeFilePath:%@", cacheBridgeFilePath);
                [responseData writeToFile:cacheBridgeFilePath atomically:YES];
            }
            _isUpdate = YES;
        }
    }
}


/**
 * 从本地获取核心JS字符串
 */
- (NSString *)localCoreBridgeJSCode
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    NSString *jsBrideCodeStr = @"";

    NSString *cacheBridgeFilePath =
        [[self bridgeCacheDir] stringByAppendingFormat:@"/%@", _coreBridgeJSFileName];
    NSString *bundleBridgeFilePath =
        [[NSBundle mainBundle] pathForResource:_coreBridgeJSFileName ofType:nil];

    //如果配置了在线更新地址，则从更新地址更新JSBridge的核心和插件JS
    if (_updateUrl != nil && ![_updateUrl isEqualToString:@""]) {
// debug状态，始终拷贝修改的JS文件
#ifdef DEBUG
        if (![fileManager removeItemAtPath:cacheBridgeFilePath error:&error]) {
            NSLog(@"delete cache file error: %@", cacheBridgeFilePath);
        }
#endif

        //如果cache无此文件
        if (![fileManager fileExistsAtPath:cacheBridgeFilePath]) {
            if (![fileManager copyItemAtPath:bundleBridgeFilePath
                                      toPath:cacheBridgeFilePath
                                       error:&error]) {
                NSLog(@"copy error: %@", cacheBridgeFilePath);
            }
        }

        jsBrideCodeStr = [NSString stringWithContentsOfFile:cacheBridgeFilePath
                                                   encoding:NSUTF8StringEncoding
                                                      error:nil];
    }

    //如果未配置，则直接从本地读取
    else {
        jsBrideCodeStr = [NSString stringWithContentsOfFile:bundleBridgeFilePath
                                                   encoding:NSUTF8StringEncoding
                                                      error:nil];
    }
    return jsBrideCodeStr;
}


@end
