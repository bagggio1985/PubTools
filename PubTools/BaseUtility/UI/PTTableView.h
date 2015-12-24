//
//  PTTableView.h
//  TestTableViewController
//
//  Created by kyao on 15/12/24.
//  Copyright © 2015年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>

#define PT_HAVE_PULL_THIRD 1

#if PT_HAVE_PULL_THIRD
typedef NS_ENUM(NSInteger, kPTTableViewPullRefresh) {
    kPTTableViewPullRefreshNone = 0,
    kPTTableViewPullRefreshTop = 1,
    kPTTableViewPullRefreshBottom = 2,
    kPTTableViewPullRefreshAll = (kPTTableViewPullRefreshTop|kPTTableViewPullRefreshBottom)
};
#endif

@protocol PTTableViewDelegate;

@class PTTableViewCell;

@interface PTTableView : UIView <UITableViewDataSource, UITableViewDelegate>

- (instancetype)initWithTableViewStyle:(UITableViewStyle)style pullStyle:(kPTTableViewPullRefresh)pullStyle;

@property (nonatomic, weak) id<PTTableViewDelegate> delegate;

@property (nonatomic, weak, readonly) UITableView* tableView;
@property (nonatomic, strong) NSMutableArray* dataArray;

//// 通过以下方法进行对TableViewCell的注册
- (void)registerClass:(Class)cellClass;
- (void)registerNibClass:(Class)cellClass;
- (void)registerNib:(NSString*)nibName cellClass:(Class)cellClass;

- (Class)getClass:(NSIndexPath*)indexPath;
- (void)configCell:(PTTableViewCell*)cell indexPath:(NSIndexPath*)indexPath;
// 该方法会默认获取dataArray的数量，如果需定制重写该方法
- (NSUInteger)getCellCount;
- (id)getEntityByIndexPath:(NSIndexPath*)indexPath;

// 用来判断是否需要显示下一页
@property (nonatomic, assign) BOOL stillHaveData;

- (void)insertTopData;
- (void)insertBottomData;
- (void)endInsertTopData;
- (void)endInsertBottomDataWith:(BOOL)stillHaveData;

@end

@protocol PTTableViewDelegate <NSObject>

@end