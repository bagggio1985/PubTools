//
//  NSString+Helper.m
//  PubTools
//
//  Created by kyao on 14-9-1.
//  Copyright (c) 2014年 . All rights reserved.
//

#import "NSString+Helper.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>
#import <CommonCrypto/CommonCryptor.h>
#import <sys/xattr.h>

@implementation NSData (Helper)

- (NSString*)md5Encode {
    unsigned char result[CC_MD5_DIGEST_LENGTH];
	CC_MD5([self bytes], (CC_LONG)[self length], result);
	
	return [[NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
             result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],
             result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15]] lowercaseString];
}

- (NSData *)HMACSHA1WithKey:(NSString *)key
{
	NSData *keyData = [key dataUsingEncoding:NSUTF8StringEncoding];
    void *buffer = malloc(CC_SHA1_DIGEST_LENGTH);
    CCHmac(kCCHmacAlgSHA1, [keyData bytes], [keyData length], [self bytes], [self length], buffer);
	
	NSData *encodedData = [NSData dataWithBytesNoCopy:buffer length:CC_SHA1_DIGEST_LENGTH freeWhenDone:YES];
    return encodedData;
}

@end

@implementation NSString (Helper)

- (NSString*)md5Encode{
    NSData* data = [self dataUsingEncoding:NSUTF8StringEncoding];
    
    unsigned char result[CC_MD5_DIGEST_LENGTH];
	CC_MD5([data bytes], (CC_LONG)[data length], result);
	
	return [[NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
             result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],
             result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15]] lowercaseString];
}

- (NSData *)HMACSHA1WithKey:(NSString *)key
{
	return [[self dataUsingEncoding:NSUTF8StringEncoding] HMACSHA1WithKey:key];
}

- (NSString*)subSpace{
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

- (NSString *)subReturnSpace {
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (NSString*)urlEncode
{
	return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)[self mutableCopy], NULL, CFSTR("￼=,!$&'()*+;@?\n\"<>#\t :/"), kCFStringEncodingUTF8));
}

- (NSString *)urlDecode
{
    // bug fix : 将+转换为空格
    NSString *result = [self stringByReplacingOccurrencesOfString:@"+" withString:@"%20"];
    return (NSString *)CFBridgingRelease(CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL, (CFStringRef)[result mutableCopy], CFSTR(""), kCFStringEncodingUTF8));
}

- (NSDictionary*)parseURLParams {
	NSArray *pairs = [self componentsSeparatedByString:@"&"];
	NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
	for (NSString *pair in pairs) {
		NSArray *kv = [pair componentsSeparatedByString:@"="];
        if ([kv count] != 2) continue;
        
		NSString *val =
        [[kv objectAtIndex:1]
         stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
		[params setObject:val forKey:[kv objectAtIndex:0]];
	}
    return params;
}

- (BOOL)isEmpty {
    return ([self subSpace].length == 0);
}

#pragma mark -- 日期时间的转换
/*
 时间格式定义:
 
 yy: 年的后2位
 yyyy: 完整年
 MM: 月，显示为1-12
 MMM: 月，显示为英文月份简写,如 Jan
 MMMM: 月，显示为英文月份全称，如 Janualy
 dd: 日，2位数表示，如02
 d: 日，1-2位显示，如 2
 EEE: 简写星期几，如Sun
 EEEE: 全写星期几，如Sunday
 aa: 上下午，AM/PM
 H: 时，24小时制，0-23
 K：时，12小时制，0-11
 m: 分，1-2位
 mm: 分，2位
 s: 秒，1-2位
 ss: 秒，2位
 S: 毫秒
 
 常用日期格式:
 yyyy-MM-dd HH:mm:ss.SSS
 yyyy-MM-dd HH:mm:ss
 yyyy-MM-dd
 yyyy年MM月dd
 MM dd yyyy
 */
- (NSDate *)getDateTimeWithFormat:(NSString *)formatterStr {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:formatterStr];
    return [dateFormat dateFromString:self];
}

- (NSDateComponents*)getComponentWithFormat:(NSString*)formatterStr {
    NSDate *date = [self getDateTimeWithFormat:formatterStr];
    if (date == nil) return nil;
    
    NSCalendar *calender = [NSCalendar currentCalendar];
    NSDateComponents *component = [calender components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay
                                                   | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond)
                                         fromDate:date];
    [component setCalendar:calender];
    return component;
}

- (UIColor*)getColor {
    return [self getColorAlpha:1.0f];
}

- (UIColor*)getColorAlpha:(float)alpha {
    
    //删除字符串中的空格
    NSString *newString = [[self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    // String should be 6 or 8 characters
    if ([newString length] < 6) return [UIColor clearColor];
    
    // strip 0X if it appears
    //如果是0x开头的，那么截取字符串，字符串从索引为2的位置开始，一直到末尾
    if ([newString hasPrefix:@"0X"]) newString = [newString substringFromIndex:2];
    //如果是#开头的，那么截取字符串，字符串从索引为1的位置开始，一直到末尾
    if ([newString hasPrefix:@"#"]) newString = [newString substringFromIndex:1];
    if ([newString length] != 6) return [UIColor clearColor];
    
    // Separate into r, g, b substrings
    NSRange range = NSMakeRange(0, 2);
    //r
    NSString *rString = [newString substringWithRange:range];
    //g
    range.location = 2;
    NSString *gString = [newString substringWithRange:range];
    //b
    range.location = 4;
    NSString *bString = [newString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float)r / 255.0f) green:((float)g / 255.0f) blue:((float)b / 255.0f) alpha:alpha];
}

- (CGSize)sizeWithBoundSize:(CGSize)size font:(UIFont*)font {
    return [self boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:font} context:nil].size;
}

- (CGSize)sizeWithTextFont:(UIFont*)font {
    return [self sizeWithAttributes:@{NSFontAttributeName:font}];
}

@end

@implementation NSString (Size)

- (CGSize)estimateSizeWithFont:(UIFont*)font {
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 70000
    return [self length] ? [self sizeWithAttributes:@{NSFontAttributeName:font}] : CGSizeZero;
#else
    return [self length] ? [self sizeWithFont:font] : CGSizeZero;
#endif
}

- (CGSize)estimateSizeWithFont:(UIFont *)font forWidth:(CGFloat)width lineBreakMode:(NSLineBreakMode)lineBreakMode {
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 70000
    return [self length] > 0 ? [self boundingRectWithSize:CGSizeMake(width, NSUIntegerMax) options:(NSStringDrawingUsesLineFragmentOrigin) attributes:@{NSFontAttributeName:font} context:nil].size : CGSizeZero;
#else
    return [self length] > 0 ? [self sizeWithFont:font constrainedToSize:CGSizeMake(width, NSUIntegerMax) lineBreakMode:mode] : CGSizeZero;
#endif
}

@end

@implementation NSString (PTPath)

+ (instancetype)documentPath {
    static NSString * path = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)
                 objectAtIndex:0] copy];
    });
    return path;
}

+ (instancetype)cachePath {
    static NSString * path = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)
                 objectAtIndex:0] copy];
    });
    
    return path;
}

- (NSURL*)toUrl {
    return [NSURL URLWithString:self];
}

//+ (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL
//{
//    if (URL==nil) {
//        return NO;
//    }
//    NSString *systemVersion=[[UIDevice currentDevice] systemVersion];
//    float version=[systemVersion floatValue];
//    if (version<5.0) {
//        return YES;
//    }
//    if ( version>=5.1) {
//        assert([[NSFileManager defaultManager] fileExistsAtPath: [URL path]]);
//        
//        NSError *error = nil;
//        BOOL success = [URL setResourceValue: [NSNumber numberWithBool: YES]
//                                      forKey: NSURLIsExcludedFromBackupKey error: &error];
//        if(!success){
//        }
//        return success;
//    }
//    
//    if ([systemVersion isEqual:@"5.0"]) {
//        return NO;
//    }else{
//        assert([[NSFileManager defaultManager] fileExistsAtPath: [URL path]]);
//        
//        const char* filePath = [[URL path] fileSystemRepresentation];
//        
//        const char* attrName = "com.apple.MobileBackup";
//        u_int8_t attrValue = 1;
//        
//        int result = setxattr(filePath, attrName, &attrValue, sizeof(attrValue), 0, 0);
//        return result == 0;
//    }
//    return YES;
//}

@end
