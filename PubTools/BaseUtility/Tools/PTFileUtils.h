//
//  PTFileUtils.h
//  PubTools
//
//  Created by kyao on 16/6/27.
//  Copyright © 2016年 arcsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PTFileUtils : NSObject

+ (NSString*)getDocumentPath;
+ (NSString*)getCachePath;
+ (NSString*)getResourcePath; // main bundle
+ (NSString*)getTemporaryPath; // 临时文件夹

+ (NSString*)getFilePathAtDocument:(NSString*)filePath;

+ (NSString*)getUniqueName;

+ (BOOL)createFolderAtPath:(NSString*)filePath;
+ (BOOL)createFileAtPath:(NSString*)filePath;

+ (BOOL)removeFileAtPath:(NSString*)filePath;
+ (BOOL)removeFolderAtPath:(NSString*)filePath;

+ (unsigned long long)fileSize:(NSString*)filePath;
+ (unsigned long long)folderSize:(NSString*)folderPath;

@end
