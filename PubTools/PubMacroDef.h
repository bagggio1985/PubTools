//
//  PubMacroDef.h
//  PubTools
//
//  Created by kyao on 14-11-27.
//  Copyright (c) 2014年 arcsoft. All rights reserved.
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

#endif
