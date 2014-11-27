//
//  GlobalConfig.m
//  PubTools
//
//  Created by kyao on 14-9-1.
//  Copyright (c) 2014年 arcsoft. All rights reserved.
//

#import "GlobalConfig.h"

static NSString* s_removeKey[] = {
};

static NSString* s_configKey[] = {
    @"GlobalConfigDefault"
};

static GlobalConfig* s_config = nil;

@interface GlobalConfig (){
    NSString* _filePath;
    BOOL _needSave;
    BOOL _autoSave;
}

@property (atomic, retain) NSMutableDictionary *configDict;

@end

@implementation GlobalConfig

+ (GlobalConfig*)sharedConfig {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_config = [[GlobalConfig alloc] init];
    });
    
    return s_config;
}

- (id)init{
    
    if (self = [super init]){
        @autoreleasepool {
            _filePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/GlobalConfig.data"];
            [self open];
            _needSave = NO;
            _autoSave = [[self objectForKey:kGlobalConfigDefault] boolValue];
            
            //Set Default Here
            [self dealRemoveKey];
            
            // 推到后台的时候自动保存
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(forceSynchronize) name:UIApplicationDidEnterBackgroundNotification object:nil];
            
        }
    }
    
    return self;
}

- (void)setDefault:(id)object forKey:(kGlobalConfigKey)key{
    if (nil == [self objectForKey:key]){
        [self setObject:object forKey:key];
    }
}

- (void)dealRemoveKey {
    int size = sizeof(s_removeKey) / sizeof(s_removeKey[0]);
    for (int index = 0; index < size; index++) {
        NSString* key = s_removeKey[index];
        [self.configDict removeObjectForKey:key];
    }
}

- (void)dealloc {
    // 删除后台通知
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [self synchronize];
}

- (id)objectForKey:(kGlobalConfigKey)key {
    if (key >= kGlobalConfigCount)
        return nil;
    
    NSString* keyValue = s_configKey[key];
    return [self.configDict objectForKey:keyValue];
}

- (void)setObject:(id)value forKey:(kGlobalConfigKey)key{
    if (key >= kGlobalConfigCount)
        return ;
    
    NSString* keyValue = s_configKey[key];
    // This method adds value and key to the dictionary using setObject:forKey:, unless value is nil in which case the method instead attempts to remove key using removeObjectForKey:.
    [self.configDict setValue:value forKey:keyValue];
    _needSave = YES;
    
    if (_autoSave){
        [self synchronize];
    }
}

- (void)autoSync:(BOOL)sync{
    if (_autoSave == sync)
        return;
    
    _autoSave = sync;
    [self setObject:[NSNumber numberWithBool:sync] forKey:kGlobalConfigDefault];
}

- (void)synchronize{
    if (!_needSave)
        return ;
    
    [NSKeyedArchiver archiveRootObject:self.configDict toFile:_filePath];
    _needSave = NO;
}

- (void)forceSynchronize {
    [NSKeyedArchiver archiveRootObject:self.configDict toFile:_filePath];
    _needSave = NO;
}

#pragma mark Private

- (void)open{
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    if ([fileMgr fileExistsAtPath:_filePath]){
        self.configDict = [NSKeyedUnarchiver unarchiveObjectWithFile:_filePath];
    }
    else {
        self.configDict = [NSMutableDictionary dictionary];
        [self setObject:[NSNumber numberWithBool:NO] forKey:kGlobalConfigDefault];
    }
}

@end
