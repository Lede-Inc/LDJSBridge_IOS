//
//  LDJSPluginManager.m
//  CommonJSAPI
//
//  Created by 庞辉 on 1/23/15.
//  Copyright (c) 2015 庞辉. All rights reserved.
//

#import "LDJSPluginManager.h"

@implementation LDJSExportDetail
@end



@implementation LDJSPluginInfo

-(LDJSExportDetail *)getDetailByShowMethod:(NSString *)showMethod;{
    return [self.exports objectForKey:showMethod];
}

@end



@interface LDJSPluginManager ()
@property (strong, nonatomic) NSMutableDictionary *pluginMap;

@end


@implementation LDJSPluginManager

- (id)init {
    self = [super init];
    if(self) {
        _pluginMap = [[NSMutableDictionary alloc] init];
    }
    return self;
}


- (id)initWithConfigFile:(NSString *)file {
    self = [self init];
    if(self) {
        [self resetWithConfigFile:file];
    }
    return self;
}


- (void)resetWithConfigFile:(NSString *)file {
    [_pluginMap removeAllObjects];
    NSString *path = [[NSBundle mainBundle] pathForResource:[file stringByDeletingPathExtension] ofType:[file pathExtension]];
    if(path) {
        NSData *data = [NSData dataWithContentsOfFile:path];
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
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
            if(NSClassFromString(info.pluginClass) != nil) {
                id obj = [[NSClassFromString(info.pluginClass) alloc] init];
                if(obj != nil) {
                    info.instance = obj;
                    [info.instance pluginInitialize];
                } else {
                    NSLog(@"plugin class %@ initial failure", info.pluginClass);
                    
                }
            } else {
                NSLog(@"plugin %@'class %@ does not exist.",info.pluginName, info.pluginClass);
            }
            
            [_pluginMap setObject:info forKey:info.pluginName];
        }
    }
}


-(id)getPluginInstanceByPluginName:(NSString *)pluginName{
    return ((LDJSPluginInfo *)[self.pluginMap objectForKey:pluginName]).instance;
}



-(NSString *)realForShowMethod:(NSString *)showMethod{
    NSString *realMethod = nil;
    //找到包含showMethod的插件信息
    for(NSString *key in _pluginMap.allKeys){
        LDJSPluginInfo *tmp = [_pluginMap objectForKey:key];
        if([tmp getDetailByShowMethod:showMethod]){
            realMethod = [tmp getDetailByShowMethod:showMethod].realMethod;
            break;
        }
    }
    

    if(realMethod == nil){
        realMethod = showMethod;
    }
    
    NSString *selStr = [NSString stringWithFormat:@"%@:", realMethod];
    return selStr;
}

@end
