//
//  PubLocation.h
//  PubTools
//
//  Created by kyao on 15-1-20.
//  Copyright (c) 2015年 arcsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

typedef enum {
    kPubLocationNotDetermined = 0,
    kPubLocationDisabled,
    kPubLocationUserDenied,
    kPubLocationAuthorized
} kPubLocationStatus;

@class PubLocation;

typedef enum {
    kPubLocationProgressReady = 0,
    kPubLocationProgressLocating,   // 获取GPS信息中
    kPubLocationProgressGPSDone,    // 获取GPS结束
    kPubLocationProgressCityReversing,  // 解析城市名称中
    kPubLocationProgressCityReversed,    // 解析城市名称结束
    kPubLocationProgressFailed
} kPubLocationProgress;

@interface PubLocationResult : NSObject

@property (nonatomic, assign) kPubLocationProgress progress;
@property (nonatomic, assign) kPubLocationStatus locationStatus; //

@property (nonatomic, assign) CLLocationDegrees latitude;
@property (nonatomic, assign) CLLocationDegrees longitude;

@property (nonatomic, strong) NSString *province;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *district;
@property (nonatomic, strong) CLPlacemark *addressMark;

@end


@protocol PubLocationDelegate <NSObject>

/// 会在result.progress为kPubLocationProgressCityReversed，kPubLocationProgressGPSDone，kPubLocationProgressFailed时调用该函数
- (void)pubLocation:(PubLocation*)location result:(PubLocationResult*)result;

@optional
/// 在进行GPS定位置之后，会调用该接口来进行查询是否需要解析城市名称
- (BOOL)shouldGetCity;

@end


/// ios8 should add NSLocationWhenInUseUsageDescription into PLIST
/// add MapKit and CoreLocation framework
@interface PubLocation : NSObject

+ (instancetype)sharedLocation;
+ (kPubLocationStatus)systemLocationStatus;

/// 开始定位功能，如果之前的定位正在进行中，那么只是添加一个delegate，定位成功或者失败后为调用delegate
- (void)startLocation:(id<PubLocationDelegate>)delegate;
/// 如果delegate==nil，那么会强制取消定位，并且不会收到失败的回调
- (void)stopLocation:(id<PubLocationDelegate>)delegate;

@end
