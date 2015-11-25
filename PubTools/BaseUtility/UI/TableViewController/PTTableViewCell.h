//
//  PBTableViewCell.h
//
//  Created by kyao on 15/11/24.
//  Copyright © 2015年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PTTableViewCellDelegate <NSObject>

@end

@interface PTTableViewCell : UITableViewCell

/**
 *  在类初始化的时候调用，用于初始化cell
 */
- (void)commonInit;
/**
 *  子类重写该方法，在更新cell的时候会调用该方法，如果需要保存entity，需要调用[super configEntity:];
 *
 *  @param entity 用于更新cell的数据类
 */
- (void)configEntity:(id)entity;

@property (nonatomic, strong, readonly) id entity;
@property (nonatomic, weak) id<PTTableViewCellDelegate> delegate;
@property (nonatomic, strong) NSIndexPath* indexPath;

@end
