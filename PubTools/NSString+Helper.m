//
//  NSString+Helper.m
//  PubTools
//
//  Created by kyao on 14-9-1.
//  Copyright (c) 2014年 arcsoft. All rights reserved.
//

#import "NSString+Helper.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>
#import <CommonCrypto/CommonCryptor.h>

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

@end
