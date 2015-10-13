//
//  NSString+Helper.h
//  PubTools
//
//  Created by kyao on 14-9-1.
//  Copyright (c) 2014年 arcsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (Helper)

- (NSData *)HMACSHA1WithKey:(NSString *)key;
- (NSString*)md5Encode;

@end

@interface NSString (Helper)

// encode
- (NSString*)md5Encode;
- (NSData *)HMACSHA1WithKey:(NSString *)key;

- (NSString*)subSpace;
- (NSString*)urlEncode;
- (NSString *)urlDecode;
- (NSDictionary*)parseURLParams;
- (BOOL)isEmpty; // 首先去除前后的空格，然后再判断

/// 常用日期格式:
/// yyyy-MM-dd HH:mm:ss.SSS
/// yyyy-MM-dd HH:mm:ss
/// yyyy-MM-dd
/// yyyy年MM月dd
/// MM dd yyyy
- (NSDate*)getDateTimeWithFormat:(NSString*)formatterStr;
- (NSDateComponents*)getComponentWithFormat:(NSString*)formatterStr;


// Must be 0xRRGGBB or #RRGGBB or RRGGBB format
- (UIColor*)getColor;
- (UIColor*)getColorAlpha:(float)alpha;

@end

@interface NSString (PTPath)

+ (instancetype)documentPath;
+ (instancetype)cachePath;

- (NSURL*)toUrl;

@end
