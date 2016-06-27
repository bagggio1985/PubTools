//
//  PTFileUtils.m
//  PubTools
//
//  Created by kyao on 16/6/27.
//  Copyright © 2016年 arcsoft. All rights reserved.
//

#import "PTFileUtils.h"
#import "NSString+Helper.h"

@implementation PTFileUtils

+ (NSString*)getDocumentPath {
    NSString* filePath = nil;
    @try {
        filePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    }
    @catch (NSException *exception) {
    
    }
    return filePath;
}

+ (NSString*)getCachePath {
    NSString* filePath = nil;
    @try {
        filePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    }
    @catch (NSException *exception) {
        
    }
    return filePath;
}

+ (NSString*)getResourcePath {
    return [[NSBundle mainBundle] resourcePath];
}

+ (NSString*)getTemporaryPath {
    return NSTemporaryDirectory();
}

+ (NSString*)getFilePathAtDocument:(NSString*)filePath {
    return [[self getDocumentPath] stringByAppendingPathComponent:filePath];
}

+ (NSString*)getUniqueName {
    NSTimeInterval interval = [[[NSDate alloc] init] timeIntervalSince1970];
    NSString* fileName = [NSString stringWithFormat:@"%.3f_%@", interval, [[NSUUID UUID] UUIDString]];
    return [fileName md5Encode];
}

+ (BOOL)createFolderAtPath:(NSString*)filePath {
    NSFileManager* fileManager = [NSFileManager defaultManager];
    BOOL isFolder = NO;
    if ([fileManager fileExistsAtPath:filePath isDirectory:&isFolder] && isFolder) {
        return YES;
    }
    
    return [fileManager createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
}

+ (BOOL)createFileAtPath:(NSString*)filePath {
    NSFileManager* fileManager = [NSFileManager defaultManager];
    BOOL isFolder = NO;
    if ([fileManager fileExistsAtPath:filePath isDirectory:&isFolder] && !isFolder) {
        return NO;
    }
    
    // 获取folder目录
    NSString* folderPath = [filePath stringByDeletingLastPathComponent];
    if (![self createFolderAtPath:folderPath]) {
        return NO;
    }
    
    return [fileManager createFileAtPath:filePath contents:nil attributes:nil];
}

+ (BOOL)removeFileAtPath:(NSString*)filePath {
    if ([filePath length] == 0) return NO;
    
    NSFileManager* fileManager = [NSFileManager defaultManager];
    BOOL isDir = NO;
    if ([fileManager fileExistsAtPath:filePath isDirectory:&isDir] && !isDir) {
        return [fileManager removeItemAtPath:filePath error:nil];
    }
    
    return NO;
}

+ (BOOL)removeFolderAtPath:(NSString*)filePath {
    if ([filePath length] == 0) return NO;
    
    NSFileManager* fileManager = [NSFileManager defaultManager];
    BOOL isDir = NO;
    if ([fileManager fileExistsAtPath:filePath isDirectory:&isDir] && isDir) {
        return [fileManager removeItemAtPath:filePath error:nil];
    }
    
    return NO;
}

+ (NSDictionary *)getFileAttributsAtPath:(NSString *)filePath {
    if ([filePath length] == 0) return nil;

    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:filePath] == NO) return nil;

    return [fileManager attributesOfItemAtPath:filePath error:nil];
}

+ (unsigned long long)fileSize:(NSString*)filePath {
    NSDictionary* fileAttr = [self getFileAttributsAtPath:filePath];
    
    if (fileAttr) {
        return [((NSNumber*)[fileAttr objectForKey:NSFileSize]) unsignedLongLongValue];
    }
    
    return 0;
}

+ (unsigned long long)folderSize:(NSString*)folderPath {
    NSFileManager *mgr = [NSFileManager defaultManager];
    NSArray *filesArray = [mgr subpathsOfDirectoryAtPath:folderPath error:nil];
    NSEnumerator *filesEnumerator = [filesArray objectEnumerator];
    NSString *fileName;
    unsigned long long int fileSize = 0;
    
    while (fileName = [filesEnumerator nextObject]) {
        NSDictionary *fileDictionary = [mgr attributesOfItemAtPath:[folderPath stringByAppendingPathComponent:fileName] error:nil];
        fileSize += [fileDictionary fileSize];
    }
    
    return fileSize;
}

@end
