//
//  PTTableView.m
//
//  Created by kyao on 15/12/24.
//  Copyright © 2015年 mac. All rights reserved.
//

#import <objc/runtime.h>
#import "Masonry.h"
#import "PTMethodAdapter.h"
#import "PTTableView.h"
#import "PTTableViewCell.h"
#import "UITableView+FDTemplateLayoutCell.h"
#if PT_HAVE_PULL_THIRD
#import "SVPullToRefresh.h"
#endif

@interface PTTableView () <PTTableViewCellDelegate> {
    __weak id<PTTableViewDelegate> _delegate;
}

@property (nonatomic, assign) UITableViewStyle tableViewStyle; // default is UITableViewStylePlain
@property (nonatomic, weak) UITableView* tableView;
@property (nonatomic, strong) Class currentClass;
@property (nonatomic, assign) BOOL isRequesting;
@property (nonatomic, assign) kPTTableViewPullRefresh pullStyle;
@property (nonatomic, strong) PTMethodAdapter* adapter;

@end

@implementation PTTableView

- (instancetype)initWithTableViewStyle:(UITableViewStyle)style pullStyle:(kPTTableViewPullRefresh)pullStyle {
    if (self = [super init]) {
        self.tableViewStyle = style;
        self.pullStyle = pullStyle;
        [self commonInit];
    }
    
    return self;
}

- (void)commonInit {
    self.dataArray = [NSMutableArray array];
    self.tableViewStyle = UITableViewStylePlain;
    self.isRequesting = NO;
    self.adapter = [[PTMethodAdapter alloc] initWithSource:self dest:self.delegate];
    
    UITableView* tableView = [[UITableView alloc] initWithFrame:self.bounds style:self.tableViewStyle];
    tableView.delegate = (id<UITableViewDelegate>)self.adapter;
    tableView.dataSource = (id<UITableViewDataSource>)self.adapter;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.backgroundColor = [UIColor clearColor];
    tableView.showsHorizontalScrollIndicator = NO;
    tableView.showsVerticalScrollIndicator = NO;
    [self addSubview:tableView];
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    self.tableView = tableView;
    [self registerClass:[PTTableViewCell class]];
    
#if PT_HAVE_PULL_THIRD
    [self configPullRefresh];
#endif

}

- (void)setDelegate:(id<PTTableViewDelegate>)delegate {
     _delegate = delegate;
    
    self.adapter.dest = delegate;
}

- (void)registerClass:(Class)cellClass {
    [self.tableView registerClass:cellClass forCellReuseIdentifier:NSStringFromClass(cellClass)];
    self.currentClass = cellClass;
}

- (void)registerNibClass:(Class)cellClass {
    [self registerNib:NSStringFromClass(cellClass) cellClass:cellClass];
}

- (void)registerNib:(NSString*)nibName cellClass:(Class)cellClass {
    UINib* nib = [[[NSBundle mainBundle] loadNibNamed:nibName owner:self options:nil] objectAtIndex:0];
    [self.tableView registerNib:nib forCellReuseIdentifier:NSStringFromClass(cellClass)];
    self.currentClass = cellClass;
}

- (Class)getClass:(NSIndexPath*)indexPath {
    if ([self.delegate respondsToSelector:@selector(getCellClass:indexPath:)])
        return [self.delegate getCellClass:self indexPath:indexPath];
    
    if (self.currentClass) return self.currentClass;
    return [PTTableViewCell class];
}

- (void)configCell:(PTTableViewCell*)cell indexPath:(NSIndexPath*)indexPath {
    if ([self.delegate respondsToSelector:@selector(configTableView:cell:indexPath:)])
        [self.delegate configTableView:self cell:cell indexPath:indexPath];
}

- (id)getEntityByIndexPath:(NSIndexPath*)indexPath {
    if ([self.delegate respondsToSelector:@selector(getEntity:indexPath:)])
        return [self.delegate getEntity:self indexPath:indexPath];
    
    if (indexPath.row >= self.dataArray.count) return nil;
    
    return [self.dataArray objectAtIndex:indexPath.row];
}

- (NSUInteger)getCellCount {
    if ([self.delegate respondsToSelector:@selector(getCellCount:)])
        return [self.delegate getCellCount:self];
    return [self.dataArray count];
}

#pragma mark - Private

- (void)innerConfigCell:(PTTableViewCell*)cell indexPath:(NSIndexPath*)indexPath {
    [self configCell:cell indexPath:indexPath];
    [cell configEntity:[self getEntityByIndexPath:indexPath]];
}

- (NSString*)getClassIdentifier:(NSIndexPath*)indexPath {
    return NSStringFromClass([self getClass:indexPath]);
}

#pragma mark - PullRefrsh

#if PT_HAVE_PULL_THIRD
- (void)configPullRefresh {
    __weak PTTableView* weakSelf = self;
    if (self.pullStyle & kPTTableViewPullRefreshTop) {
        [self.tableView addPullToRefreshWithActionHandler:^{
            if (weakSelf.isRequesting) {
                [weakSelf endInsertTopData:NO];
                return ;
            }
            weakSelf.isRequesting = YES;
            [weakSelf insertTopData];
             
        }];
        [self setLastUpdateDate];
    }
    
    if (self.pullStyle & kPTTableViewPullRefreshBottom) {
        [self.tableView addInfiniteScrollingWithActionHandler:^{
            if (weakSelf.isRequesting) {
                [weakSelf endInsertBottomData:NO];
                return ;
            }
            weakSelf.isRequesting = YES;
            [weakSelf insertBottomData];
        }];
        self.tableView.showsInfiniteScrolling = NO;
    }
    
    [self setupPullCustomization];
}

// 自定义下拉刷新的view
- (void)setupPullCustomization {
    if (self.pullStyle & kPTTableViewPullRefreshTop) {
        
    }
    
    if (self.pullStyle & kPTTableViewPullRefreshBottom) {
        
    }
}

- (void)forceRefresh {
    // 过滤掉正在请求的下拉刷新
    if (self.isRequesting && self.tableView.pullToRefreshView.state == SVPullToRefreshStateLoading) return ;
    
    [self.tableView setContentOffset:CGPointMake(0, 0)];
    [self.tableView triggerPullToRefresh];
}

- (void)insertTopData {
    if ([self.delegate respondsToSelector:@selector(insertTopData:)]) {
        [self.delegate insertTopData:self];
    }
}

- (void)insertBottomData {
    if ([self.delegate respondsToSelector:@selector(insertBottomData:)]) {
        [self.delegate insertBottomData:self];
    }
}

- (void)endInsertTopData {
    [self endInsertTopData:YES];
}

- (void)endInsertBottomData {
    [self endInsertBottomData:YES];
}

- (void)endInsertBottomDataWith:(BOOL)stillHaveData {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self endInsertBottomData:YES];
        self.stillHaveData = stillHaveData;
    });
}

- (void)endInsertTopData:(BOOL)endReq {
    [self.tableView.pullToRefreshView stopAnimating];
    if (endReq) {
        [self setLastUpdateDate];
        self.isRequesting = NO;
    }
}

- (void)endInsertBottomData:(BOOL)endReq {
    [self.tableView.infiniteScrollingView stopAnimating];
    if (endReq) {
        self.isRequesting = NO;
    }
}

- (void)setLastUpdateDate {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    NSString* lastDate = [NSString stringWithFormat:NSLocalizedString(@"Update: %@", nil), [formatter stringFromDate:[NSDate date]]];
    [self.tableView.pullToRefreshView setSubtitle:lastDate forState:SVPullToRefreshStateAll];
}

- (void)setStillHaveData:(BOOL)stillHaveData {
    _stillHaveData = stillHaveData;
    
    if (!(self.pullStyle & kPTTableViewPullRefreshBottom)) return ;
    
    if (stillHaveData) {
        self.tableView.showsInfiniteScrolling = YES;
    }
    else {
        [self.tableView.infiniteScrollingView stopAnimating];
        self.tableView.showsInfiniteScrolling = NO;
    }
}

#endif

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self getCellCount];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   
    PTTableViewCell* cell = (PTTableViewCell*)[tableView dequeueReusableCellWithIdentifier:[self getClassIdentifier:indexPath] forIndexPath:indexPath];
    
    cell.indexPath = indexPath;
    cell.delegate = self;
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [self innerConfigCell:cell indexPath:indexPath];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    __weak PTTableView* weakSelf = self;
    // 使用缓存高度来处理
    return [tableView fd_heightForCellWithIdentifier:[self getClassIdentifier:indexPath] cacheByIndexPath:indexPath configuration:^(id cell) {
        __strong PTTableView* strongSelf = weakSelf;
        [strongSelf innerConfigCell:cell indexPath:indexPath];
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
