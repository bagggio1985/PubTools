
#import <UIKit/UIKit.h>


/**
 * 该类会通过TableViewCell的autolayout属性来进行计算高度，
 * 因此不要重写tableView:heightForRowAtIndexPath:方法，重写
 * 该方法会使得自动计算高度失效
 * 使用自动计算高度，必须确保UITableViewCell的contentView的某个子view的
 * bottom layout是设置到contentView上，
 * 注意contentView高度能通过子view来计算
 */
@class PTTableViewCell;
@interface PTTableViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

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
- (NSUInteger)getCellCount;
- (id)getEntityByIndexPath:(NSIndexPath*)indexPath;

@end
