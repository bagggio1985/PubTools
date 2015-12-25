//
//  PTTableViewConst.h
//  PubTools
//
//  Created by kyao on 15/12/25.
//

#ifndef PTTableViewConst_h
#define PTTableViewConst_h

#define PT_HAVE_PULL_THIRD 1

#if PT_HAVE_PULL_THIRD
typedef NS_ENUM(NSInteger, kPTTableViewPullRefresh) {
    kPTTableViewPullRefreshNone = 0,
    kPTTableViewPullRefreshTop = 1,
    kPTTableViewPullRefreshBottom = 2,
    kPTTableViewPullRefreshAll = (kPTTableViewPullRefreshTop|kPTTableViewPullRefreshBottom)
};
#endif

#endif /* PTTableViewConst_h */
