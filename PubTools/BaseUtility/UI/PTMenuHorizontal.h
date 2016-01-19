//
//  PTMenuHorizontal.h
//
//

#import <UIKit/UIKit.h>

@protocol PTMenuHorizontalDelegate;

@interface PTMenuHorizontal : UIView

@property (nonatomic, weak) id<PTMenuHorizontalDelegate> delegate;
@property (nonatomic, strong) UIColor* highlightColor; // default is #11d2a2

- (void)setTitleArray:(NSArray<NSString*> *)titles;
- (NSInteger)getSelectedIndex; // not selected return -1;
- (void)moveToIndex:(NSInteger)index;

@end

@protocol PTMenuHorizontalDelegate <NSObject>

- (void)onMenuClickedAtIndex:(NSInteger)index;

@end
