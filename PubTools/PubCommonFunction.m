//
//  PubCommonFunction.c
//  PubTools
//
//  Created by kyao on 15-2-11.
//  Copyright (c) 2015年 arcsoft. All rights reserved.
//

#include <stdio.h>
#include <math.h>
#include "PubCommonFunction.h"

const double x_pi = 3.14159265358979324 * 3000.0 / 180.0;

void bd_encrypt(double gg_lat, double gg_lon, double *bd_lat, double *bd_lon)//传入火星坐标，传出百度坐标
{
    double x = gg_lon, y = gg_lat;
    double z = sqrt(x * x + y * y) + 0.00002 * sin(y * x_pi);
    double theta = atan2(y, x) + 0.000003 * cos(x * x_pi);
    *bd_lon = z * cos(theta) + 0.0065;
    *bd_lat = z * sin(theta) + 0.006;
}

void bd_decrypt(double bd_lat, double bd_lon, double *gg_lat, double *gg_lon)//传入百度坐标，传出火星坐标
{
    double x = bd_lon - 0.0065, y = bd_lat - 0.006;
    double z = sqrt(x * x + y * y) - 0.00002 * sin(y * x_pi);
    double theta = atan2(y, x) - 0.000003 * cos(x * x_pi);
    *gg_lon = z * cos(theta);
    *gg_lat = z * sin(theta);
}