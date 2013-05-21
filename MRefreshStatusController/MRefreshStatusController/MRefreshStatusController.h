//
//  MReloadWithStatusControlle.h
//  pairs
//
//  Created by Muukii on 2013/05/02.
//  Copyright (c) 2013年 Muukii. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol MRefreshStatusViewDelegate;
@interface MRefreshStatusController : UIControl<UIScrollViewDelegate>
typedef void(^refresh)(MRefreshStatusController *refreshStatusView);

@property(assign,nonatomic) id<MRefreshStatusViewDelegate> delegate;
@property(retain,nonatomic) UILabel *statusLabel,*refreshLabel;
-(void)setTableView:(UITableView*)tableView;
-(void)setTableView:(UITableView*)tableView refresh:(refresh)refresh;
-(void)setRefresh:(refresh)refresh;
-(void)endRefreshing;
-(void)setStatusMessgae:(NSString*)messgae;
@end
@protocol MRefreshStatusViewDelegate <NSObject>
@optional
-(void)refreshControlDidBeginRefreshing:(MRefreshStatusController*)refreshStatus;
@end
