
#import <UIKit/UIKit.h>
#import "PTBaseViewController.h"
#import "PTTableViewConst.h"

typedef void(^PTTableViewPullRefrshBlock)();

/**
 * 该类会通过TableViewCell的autolayout属性来进行计算高度，
 * 因此不要重写tableView:heightForRowAtIndexPath:方法，重写
 * 该方法会使得自动计算高度失效
 * 使用自动计算高度，必须确保UITableViewCell的contentView的某个子view的
 * bottom layout是设置到contentView上，
 * 注意contentView高度能通过子view来计算
 */
@class PTTableViewCell;
@interface PTTableViewController : PTBaseViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, assign) UITableViewStyle tableViewStyle; // default is UITableViewStylePlain
@property (nonatomic, weak, readonly) UITableView* tableView;
@property (nonatomic, strong) NSMutableArray* dataArray;

//// 通过以下方法进行对TableViewCell的注册
- (void)registerClass:(Class)cellClass;
- (void)registerNibClass:(Class)cellClass;
- (void)registerNib:(NSString*)nibName cellClass:(Class)cellClass;

//////////////////////////////////////////////////////////////////////////////////////////////////
// 首先获取数量会调用getCellCount方法
// 在cellForRowAtIndexPath中调用顺序，getClass:->configCell:indexPath->getEntityByIndexPath:
// 根据需求进行相应函数的重写
/**
 *  返回indexPath对应的TableViewCell的Class
 *
 *  @param indexPath
 *
 *  @return 基类返回最后一次注册的class，如果没有注册过，返回PTTableViewCell
 */
- (Class)getClass:(NSIndexPath*)indexPath;
- (void)configCell:(PTTableViewCell*)cell indexPath:(NSIndexPath*)indexPath;
// 该方法会默认获取dataArray的数量，如果需定制重写该方法
- (NSUInteger)getCellCount:(NSInteger)section;
- (id)getEntityByIndexPath:(NSIndexPath*)indexPath;

//////////////////////////////////////////////////////////////////////////////////////////////////
// 下拉刷新相关方法
#if PT_HAVE_PULL_THIRD
// default is kPTTableViewPullRefreshNone
@property (nonatomic, assign) kPTTableViewPullRefresh pullStyle;
// 用来判断是否需要显示下一页
@property (nonatomic, assign) BOOL stillHaveData;

- (void)forceRefresh;
// 异步操作完成后调用finish的block
// 下拉刷新的时候会调用该方法
- (void)insertTopData:(PTTableViewPullRefrshBlock)finish;
- (void)insertBottomData:(PTTableViewPullRefrshBlock)finish;

- (void)endInsertTopData;
- (void)endInsertBottomDataWith:(BOOL)stillHaveData;

#endif

@end
