//
//  PubCommonFunction.h
//  PubTools
//
//  Created by kyao on 15-2-11.
//  Copyright (c) 2015年 . All rights reserved.
//

#ifndef PubTools_PubCommonFunction_h
#define PubTools_PubCommonFunction_h

#import <Foundation/Foundation.h>

#define fequal(a,b) (fabs((a) - (b)) < FLT_EPSILON)
#define fequalzero(a) (fabs(a) < FLT_EPSILON)

void bd_encrypt(double gg_lat, double gg_lon, double *bd_lat, double *bd_lon);//传入火星坐标，传出百度坐标
void bd_decrypt(double bd_lat, double bd_lon, double *gg_lat, double *gg_lon);//传入百度坐标，传出火星坐标

#endif
