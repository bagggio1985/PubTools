//
//  PubLocation.m
//  PubTools
//
//  Created by kyao on 15-1-20.
//  Copyright (c) 2015年 . All rights reserved.
//

#import "PubLocation.h"
#import <MapKit/MapKit.h>

#define Compile_For_IOS8    (__IPHONE_OS_VERSION_MAX_ALLOWED >= 80000)

static PubLocation* s_locationMgr = nil;

@implementation PubLocationResult

- (NSString *)description {
    NSString* progress = nil;
    switch (self.progress) {
        case kPubLocationProgressFailed:
            progress = @"kPubLocationProgressFailed";
            break;
        case kPubLocationProgressReady:
            progress = @"kPubLocationProgressReady";
            break;
        case kPubLocationProgressCityReversed:
            progress = @"kPubLocationProgressCityReversed";
            break;
        case kPubLocationProgressCityReversing:
            progress = @"kPubLocationProgressCityReversing";
            break;
        case kPubLocationProgressGPSDone:
            progress = @"kPubLocationProgressGPSDone";
            break;
        case kPubLocationProgressLocating:
            progress = @"kPubLocationProgressLocating";
            break;
        default:
            break;
    }
    
    NSString* status = nil;
    switch (self.locationStatus) {
        case kPubLocationAuthorized:
            status = @"kPubLocationAuthorized";
            break;
        case kPubLocationDisabled:
            status = @"kPubLocationDisabled";
            break;
        case kPubLocationNotDetermined:
            status = @"kPubLocationNotDetermined";
            break;
        case kPubLocationUserDenied:
            status = @"kPubLocationUserDenied";
            break;
            
        default:
            break;
    }
    
    return [NSString stringWithFormat:@"progress is %@ and status is %@ --> %.2f--%.2f--%@--%@-%@",
            progress, status,self.longitude, self.latitude, self.province, self.city, self.district, nil];
}

@end

@interface PubLocation () <CLLocationManagerDelegate, MKMapViewDelegate>

@property (nonatomic, strong) NSMutableArray* delegateAry;
@property (nonatomic, assign) kPubLocationProgress locateProgress;
@property (nonatomic, strong) CLLocationManager* locationManager;

@property (nonatomic, strong) MKMapView* mapView;
@property (nonatomic, strong) CLGeocoder *geocoder;

@end

@implementation PubLocation

+ (instancetype)sharedLocation {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_locationMgr = [[PubLocation alloc] init];
    });
    
    return s_locationMgr;
}

+ (kPubLocationStatus)systemLocationStatus {
    kPubLocationStatus status = kPubLocationNotDetermined;
    switch ([CLLocationManager authorizationStatus]) {
        case kCLAuthorizationStatusNotDetermined:
            status = kPubLocationNotDetermined;
            break;
        
#if Compile_For_IOS8
        case kCLAuthorizationStatusAuthorizedAlways:
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            status = kPubLocationAuthorized;
            break;
#else
        case kCLAuthorizationStatusAuthorized:
            status = kPubLocationAuthorized;
            break;
#endif
        case kCLAuthorizationStatusDenied:
            if (![CLLocationManager locationServicesEnabled])
                status = kPubLocationDisabled;
            else
                status = kPubLocationUserDenied;
            break;
        case kCLAuthorizationStatusRestricted:
            status = kPubLocationUserDenied;
            break;
        default:
            break;
    }
    
    return status;
}

- (id)init {
    
    if (self = [super init]) {
        self.locateProgress = kPubLocationProgressReady;
        self.delegateAry = [NSMutableArray array];
    }
    
    return self;
}

- (void)initLocationManager {
    if (self.locationManager) return ;
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    [self.locationManager startUpdatingLocation];
}

- (void)cleanResource {
#if DEBUG
    NSLog(@"%s", __func__);
#endif
    
    [self stopTimeout];
    
    self.locateProgress = kPubLocationProgressReady;

    [self.delegateAry removeAllObjects];
    
    [self.locationManager stopUpdatingLocation];
    self.locationManager.delegate = nil;
    self.locationManager = nil;
    
    [self.mapView removeFromSuperview];
    self.mapView.showsUserLocation = NO;
    self.mapView.delegate = nil;
    self.mapView = nil;
    
    [self.geocoder cancelGeocode];
    self.geocoder = nil;
}

- (void)startLocation:(id<PubLocationDelegate>)delegate {
    if (delegate && [self.delegateAry indexOfObject:delegate] == NSNotFound) {
        [self.delegateAry addObject:delegate];
    }
    
    if (self.locateProgress == kPubLocationProgressReady) {
        [self initLocationManager];
    }
}

- (void)stopLocation:(id<PubLocationDelegate>)delegate {
    if (nil == delegate) {
        [self cleanResource];
    }
    else {
        [self.delegateAry removeObject:delegate];
        if ([self.delegateAry count] == 0) {
            [self cleanResource];
        }
    }
}

#pragma mark CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    
    switch (status) {
    
#if Compile_For_IOS8
        case kCLAuthorizationStatusAuthorizedAlways:
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            [self beginMapLocate];
            break;
#else
        case kCLAuthorizationStatusAuthorized:
            [self beginMapLocate];
            break;
#endif
        case kCLAuthorizationStatusDenied:
        case kCLAuthorizationStatusRestricted:
        {
            self.locateProgress = kPubLocationProgressFailed;
            PubLocationResult* result = [PubLocationResult new];
            result.locationStatus = [PubLocation systemLocationStatus];
            result.progress = self.locateProgress;
            
            [self notifyAll:result clean:YES];
            [self cleanResource];
        }
            break;
        case kCLAuthorizationStatusNotDetermined:
#if Compile_For_IOS8
            if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
                [self.locationManager requestWhenInUseAuthorization];
            }
#endif
            break;
        default:
            break;
    }
}

#pragma mark MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    
    if (nil == userLocation) return ;
    
    self.locateProgress = kPubLocationProgressGPSDone;
    
    CLLocation *location = userLocation.location;
    PubLocationResult* lastLocation = [PubLocationResult new];
    lastLocation.locationStatus = kPubLocationAuthorized;
    lastLocation.progress = kPubLocationProgressGPSDone;
    lastLocation.longitude = location.coordinate.longitude;
    lastLocation.latitude = location.coordinate.latitude;
    
    if ([self haveCityInvoke]) {
        self.geocoder = [CLGeocoder new];
        [self.geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
            
            /// 首先通知只需要GPS信息的delegate，如果是在获取城市信息之前通知的话，会造成在获取城市信息同时添加的delegate收不到GPS回调
            [self notifyAll:lastLocation clean:NO];
            [self removeDelegateWithoutCityInvoke];
            
            self.locateProgress = kPubLocationProgressCityReversed;
            lastLocation.progress = self.locateProgress;
            
            if (! error && [placemarks count]) {
                
                CLPlacemark *place = (CLPlacemark *)[placemarks objectAtIndex:0];
                
                lastLocation.addressMark = place;
                lastLocation.province = place.administrativeArea;
                lastLocation.city = place.locality;
                lastLocation.district = place.subLocality;
                if (! lastLocation.city) {//城市名为空，用省的名字代替
                    lastLocation.city = place.administrativeArea;
                }
                if (! lastLocation.province) {//省名字为空，用城市名代替
                    lastLocation.province = place.locality;
                }
                
                NSString *language = [[NSLocale preferredLanguages] objectAtIndex:0];
                if ([language isEqualToString:@"zh-Hans"]) {//把省和城市名称中的“省”"市"去掉
                    if ([lastLocation.province length] > 1) {
                        lastLocation.province = [lastLocation.province substringToIndex:[lastLocation.province length] - 1];
                    }
                    if ([lastLocation.city length] > 1) {
                        lastLocation.city = [lastLocation.city substringToIndex:[lastLocation.city length] - 1];
                    }
                }
            }
            
#if DEBUG
            NSLog(@"reverseLocation error is %@", error);
#endif
            
            [self notifyAll:lastLocation clean:YES];
            [self cleanResource];
            
        }];
    }
    else {
        [self notifyAll:lastLocation clean:NO];
        [self removeDelegateWithoutCityInvoke];
        [self cleanResource];
    }
    
    
}

- (void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error
{
    PubLocationResult* lastLocation = [PubLocationResult new];
    lastLocation.locationStatus = kPubLocationAuthorized;
    lastLocation.progress = kPubLocationProgressFailed;
    
    [self notifyAll:lastLocation clean:YES];
    [self cleanResource];
    
}

#pragma mark Private

- (void)beginMapLocate {
    
    if (nil == self.mapView) {
        self.mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0.f, 0.f, 1.f, 1.f)];
        self.mapView.delegate = self;
        self.mapView.showsUserLocation = YES;
        [[UIApplication sharedApplication].keyWindow insertSubview:self.mapView atIndex:0];
        [self startTimeout];
    }
    
    self.locateProgress = kPubLocationProgressLocating;
}

- (void)notifyAll:(PubLocationResult*)result clean:(BOOL)clean {
    for (id<PubLocationDelegate> delegate in self.delegateAry) {
        [delegate pubLocation:self result:result];
    }
#if DEBUG
    NSLog(@"%@", result);
#endif
    if (clean) {
        [self.delegateAry removeAllObjects];
    }
}

- (void)removeDelegateWithoutCityInvoke {
    
    NSMutableIndexSet* indexSet = [NSMutableIndexSet indexSet];
    for (int index = 0; index < [self.delegateAry count]; index++) {
        id<PubLocationDelegate> delegate = [self.delegateAry objectAtIndex:index];
        
        if ([delegate respondsToSelector:@selector(shouldGetCity)]) {
            BOOL shouldGet = [delegate shouldGetCity];
            
            if (!shouldGet) {
                [indexSet addIndex:index];
            }
        }
        else {
            [indexSet addIndex:index];
        }
    }
    
    [self.delegateAry removeObjectsAtIndexes:indexSet];
    
}

- (BOOL)haveCityInvoke {
    BOOL haveCityInvoke = NO;
    for (id<PubLocationDelegate> delegate in self.delegateAry) {
        if ([delegate respondsToSelector:@selector(shouldGetCity)]) {
            if ([delegate shouldGetCity]) {
                haveCityInvoke = YES;
                break;
            }
        }
    }
    
    return haveCityInvoke;
    
}

- (void)startTimeout {
    [self performSelector:@selector(dealTimeout) withObject:nil afterDelay:15];
}

- (void)stopTimeout {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(dealTimeout) object:nil];
}

- (void)dealTimeout {
#if DEBUG
    NSLog(@"%s", __func__);
#endif
    
    PubLocationResult* lastLocation = [PubLocationResult new];
    lastLocation.locationStatus = kPubLocationAuthorized;
    lastLocation.progress = kPubLocationProgressFailed;
    
    [self notifyAll:lastLocation clean:YES];
    [self cleanResource];
}

@end
