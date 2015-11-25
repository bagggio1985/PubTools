//
//  PTMacroDef.h
//  PubTools
//
//  Created by kyao on 14-11-27.
//  Copyright (c) 2014年 . All rights reserved.
//

#ifndef PubTools_PubMacroDef_h
#define PubTools_PubMacroDef_h

#ifdef DEBUG
#define DEBUG_NSLog(format, ...) NSLog(format, ##__VA_ARGS__)
#define DEBUG_NSAssert(codition, ...) NSAssert(codition, @"", ##__VA_ARGS__)
#else
#define DEBUG_NSLog(format, ...)
#define DEBUG_NSAssert(codition, ...)
#endif

#define DEBUG_LOG_FUNCTION  DEBUG_NSLog(@"%s", __func__)
#define NSLogRect(rect) NSLog(@"%s x:%.4f, y:%.4f, w:%.4f, h:%.4f", #rect, rect.origin.x, rect.origin.y, rect.size.width, rect.size.height)
#define NSLogSize(size) NSLog(@"%s w:%.4f, h:%.4f", #size, size.width, size.height)
#define NSLogPoint(point) NSLog(@"%s x:%.4f, y:%.4f", #point, point.x, point.y)

#define PT_Rect_X(frame, xx) { CGRect frame___ = (frame); if (frame___.origin.x != (xx)) { frame___.origin.x = (xx); (frame) = frame___; } }
#define PT_Rect_Y(frame, yy) { CGRect frame___ = (frame); if (frame___.origin.y != (yy)) { frame___.origin.y = (yy); (frame) = frame___; } }
#define PT_Rect_Width(frame, ww) { CGRect frame___ = (frame); if (frame___.size.width != (ww)) { frame___.size.width = (ww); (frame) = frame___; } }
#define PT_Rect_Height(frame, hh) { CGRect frame___ = (frame); if (frame___.size.height != (hh)) { frame___.size.height = (hh); (frame) = frame___; } }

#define RGBFromHexadecimal(value) [UIColor colorWithRed:((float)((value & 0xFF0000) >> 16))/255.0 green:((float)((value & 0xFF00) >> 8))/255.0 blue:((float)(value & 0xFF))/255.0 alpha:1.0]

#define BLOCK_SAFE_RUN(block, ...) block ? block(__VA_ARGS__) : nil;

#endif
