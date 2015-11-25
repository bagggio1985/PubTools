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

@interface PTTableViewController () <PTTableViewCellDelegate>

@property (nonatomic, weak) UITableView* tableView;
@property (nonatomic, strong) Class currentClass;

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
    [self.view addSubview:tableView];
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.mas_topLayoutGuideBottom);
        make.bottom.equalTo(self.mas_bottomLayoutGuideTop);
    }];
    self.tableView = tableView;
    [self registerClass:[PTTableViewCell class]];
    
#ifdef DEBUG
    [tableView setFd_debugLogEnabled:YES];
#endif
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

- (NSUInteger)getCellCount {
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
