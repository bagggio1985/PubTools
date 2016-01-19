//
//  PTMethodAdapter.h
//
//  Created by kyao on 15/12/25.
//  Copyright © 2015年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 用来将source实例的方法调用转移到dest实例，如果dest没有实现，使用source的实现
 */
@interface PTMethodAdapter : NSObject

- (instancetype)initWithSource:(id)source dest:(id)dest;

@property (nonatomic, weak) id source;
@property (nonatomic, weak) id dest;

@end
