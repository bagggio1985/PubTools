//
//  PTTableViewController.m
//
//  Created by kyao on 15/11/24.
//  Copyright © 2015年 mac. All rights reserved.
//

#import "PTTableViewController.h"
#import "Masonry.h"
#import "PTTableViewCell.h"
#import "UITableView+FDTemplateLayoutCell.h"
#if PT_HAVE_PULL_THIRD
#import "SVPullToRefresh.h"
#endif

@interface PTTableViewController () <PTTableViewCellDelegate>

@property (nonatomic, weak) UITableView* tableView;
@property (nonatomic, strong) Class currentClass;
@property (nonatomic, assign) BOOL isRequesting;

@end

@implementation PTTableViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [self commonInit];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self commonInit];
    }
    
    return self;
}

- (void)commonInit {
    self.dataArray = [NSMutableArray array];
    self.tableViewStyle = UITableViewStylePlain;
    self.isRequesting = NO;
#if PT_HAVE_PULL_THIRD
    self.pullStyle = kPTTableViewPullRefreshNone;
#endif
}

- (void)loadView {
    [super loadView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UITableView* tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:self.tableViewStyle];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.backgroundColor = [UIColor clearColor];
    tableView.showsHorizontalScrollIndicator = NO;
    tableView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:tableView];
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.mas_topLayoutGuideBottom);
        // 如果想使用透明的tabbar，需要修改为mas_bottomLayoutGuideBottom
        make.bottom.equalTo(self.mas_bottomLayoutGuideTop);
    }];
    self.tableView = tableView;
    [self registerClass:[PTTableViewCell class]];
    
#if PT_HAVE_PULL_THIRD
    [self configPullRefresh];
#endif
    
//#ifdef DEBUG
//    [tableView setFd_debugLogEnabled:YES];
//#endif
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    if (self.currentClass) return self.currentClass;
    return [PTTableViewCell class];
}

- (void)configCell:(PTTableViewCell*)cell indexPath:(NSIndexPath*)indexPath {
    
}

- (id)getEntityByIndexPath:(NSIndexPath*)indexPath {
    if (indexPath.row >= self.dataArray.count) return nil;
    
    return [self.dataArray objectAtIndex:indexPath.row];
}

- (NSUInteger)getCellCount:(NSInteger)section {
    return [self.dataArray count];
}

#pragma mark - Private

- (void)innerConfigCell:(PTTableViewCell*)cell indexPath:(NSIndexPath*)indexPath {
    cell.indexPath = indexPath;
    cell.delegate = self;
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;    
    [self configCell:cell indexPath:indexPath];
    [cell configEntity:[self getEntityByIndexPath:indexPath]];
}

- (NSString*)getClassIdentifier:(NSIndexPath*)indexPath {
    return NSStringFromClass([self getClass:indexPath]);
}

#pragma mark - PullRefrsh

#if PT_HAVE_PULL_THIRD
- (void)configPullRefresh {
    __weak PTTableViewController* weakSelf = self;
    if (self.pullStyle & kPTTableViewPullRefreshTop) {
        [self.tableView addPullToRefreshWithActionHandler:^{
            if (weakSelf.isRequesting) {
                [weakSelf endInsertTopData:NO];
                return ;
            }
            weakSelf.isRequesting = YES;
            [weakSelf insertTopData:^{
                [weakSelf endInsertTopData];
            }];
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
            [weakSelf insertBottomData:^{
                [weakSelf endInsertBottomData];
            }];
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

- (void)insertTopData:(PTTableViewPullRefrshBlock)finish {
    if (finish) {
        finish();
    }
}

- (void)insertBottomData:(PTTableViewPullRefrshBlock)finish {
    if (finish) {
        finish();
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
    return [self getCellCount:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    PTTableViewCell* cell = (PTTableViewCell*)[tableView dequeueReusableCellWithIdentifier:[self getClassIdentifier:indexPath] forIndexPath:indexPath];

    [self innerConfigCell:cell indexPath:indexPath];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    __weak PTTableViewController* weakSelf = self;
    // 使用缓存高度来处理
    return [tableView fd_heightForCellWithIdentifier:[self getClassIdentifier:indexPath] cacheByIndexPath:indexPath configuration:^(id cell) {
        __strong PTTableViewController* strongSelf = weakSelf;
        [strongSelf innerConfigCell:cell indexPath:indexPath];
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
