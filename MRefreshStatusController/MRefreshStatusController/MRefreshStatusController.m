//
//  MReloadWithStatusController.m
//  pairs
//
//  Created by Muukii on 2013/05/02.
//  Copyright (c) 2013年 Muukii. All rights reserved.
//

#import "MRefreshStatusController.h"
#define STATUSBAR_HEIGHT 36
#define VIEWHEIGHT 504
#define REFRESH_POINT 60
@implementation MRefreshStatusController
{
	refresh _refresh;
	UIImageView *_arrowImageView;
	UITableView *_tableView;
	UIScrollView *_scrollView;
	UIActivityIndicatorView *activityIndicatorView;
	BOOL refreshing;
	BOOL startRefresh;
	CGFloat hideHeight;
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		[self setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"grayBg"]]];

			//status Label init
		_statusLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 320, 36)];
		[_statusLabel setCenter:CGPointMake(320/2,VIEWHEIGHT-_statusLabel.frame.size.height/2)];
		[_statusLabel setTextAlignment:NSTextAlignmentCenter];
		[_statusLabel setFont:[UIFont systemFontOfSize:12]];
		[_statusLabel setTextColor:[UIColor colorWithRed:0.471 green:0.502 blue:0.525 alpha:1.000]];
		[_statusLabel setBackgroundColor:[UIColor clearColor]];
		[_statusLabel setShadowColor:[UIColor whiteColor]];
		[_statusLabel setShadowOffset:CGSizeMake(0.5, 0.5)];
			//refresh Label init
		_refreshLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 320, 36)];
		[_refreshLabel setCenter:CGPointMake(320/2,VIEWHEIGHT-_statusLabel.frame.size.height/2 - 40)];
		[_refreshLabel setTextAlignment:NSTextAlignmentCenter];
		[_refreshLabel setFont:[UIFont boldSystemFontOfSize:12]];
		[_refreshLabel setTextColor:[UIColor colorWithWhite:0.589 alpha:1.000]];
		[_refreshLabel setBackgroundColor:[UIColor clearColor]];
		[_refreshLabel setShadowColor:[UIColor whiteColor]];
		[_refreshLabel setShadowOffset:CGSizeMake(0.5, 0.5)];
			//arrowImageView init
		_arrowImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"refreshArrow"]];
		[_arrowImageView setCenter:CGPointMake(80, _refreshLabel.center.y)];
//		_arrowImageView.transform = CGAffineTransformMakeRotation(0);


		activityIndicatorView = [[UIActivityIndicatorView alloc]init];
		[activityIndicatorView setCenter:CGPointMake(320/2,VIEWHEIGHT-_statusLabel.frame.size.height/2 - 40)];
		[activityIndicatorView setColor:[UIColor darkGrayColor]];
		activityIndicatorView.hidden = YES;
		[self addSubview:_statusLabel];
		[self addSubview:activityIndicatorView];
		[self addSubview:_refreshLabel];
		[self addSubview:_arrowImageView];


		hideHeight = VIEWHEIGHT - STATUSBAR_HEIGHT;
    }
    return self;
}
-(id)init{
	return [self initWithFrame:CGRectMake(0, 0, 320, VIEWHEIGHT)];
}
-(void)setStatusMessgae:(NSString *)messgae{
		_statusLabel.text = messgae;
//	DLog(@"メッセージ変更%@",messgae);
}
-(void)setTableView:(UITableView*)tableView{
	refreshing = NO;
	_tableView = tableView;
	_scrollView = self.scrollView;
	[tableView setTableHeaderView:self];
//	[tableView addSubview:self];
//	DLog("%@",self.superview);
	[tableView setContentInset:UIEdgeInsetsMake(-hideHeight, 0, 0, 0)];

	[self.scrollView addObserver:self
				   forKeyPath:@"contentOffset"
					  options:NSKeyValueObservingOptionNew
					  context:NULL];
}
-(void)setTableView:(UITableView *)tableView refresh:(refresh)refresh{
	_refresh = refresh;
	[self setTableView:tableView];
}
-(void)setRefresh:(refresh)refresh{
	_refresh = refresh;
}
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
	if([keyPath isEqualToString:@"contentOffset"]){
		UIScrollView *scrollView = (UIScrollView *)object;
		if(scrollView.dragging){
			[self scrollViewDidScroll:scrollView];
		}else{
			[self scrollViewDidEndDragging:scrollView willDecelerate:NO];
		}
		return;
	}
}

- (UIScrollView *)scrollView
{
    UIScrollView *scrollView = (UIScrollView *)self.superview;

    if(![scrollView isKindOfClass:[UIScrollView class]])
        scrollView = nil;

    return scrollView;
}

-(void)beginRefreshing{
	refreshing = YES;

	[UIView animateWithDuration:0.2 animations:^{
		[_tableView setContentInset:UIEdgeInsetsMake(-(hideHeight-REFRESH_POINT), 0, 0, 0)];
	}];
	if(_refresh)	_refresh(self);
	
	[self.delegate refreshControlDidBeginRefreshing:self];
	_refreshLabel.hidden = YES;
	_arrowImageView.hidden = YES;
	activityIndicatorView.hidden = NO;
	[activityIndicatorView startAnimating];
	_refreshLabel.text = @"検索中";
}

-(void)endRefreshing{
	refreshing = NO;
	[UIView animateWithDuration:0.2 animations:^{
		[_tableView setContentInset:UIEdgeInsetsMake(-(self.frame.size.height - STATUSBAR_HEIGHT), 0, 0, 0)];
	}completion:^(BOOL finished) {
		_arrowImageView.transform = CGAffineTransformMakeRotation(0);
		_refreshLabel.hidden = NO;
		_arrowImageView.hidden = NO;
		activityIndicatorView.hidden = YES;
		[activityIndicatorView stopAnimating];
	}];

	
}
#pragma mark - UIScrollViewDelegate (Detected by observing value changes)

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	if(scrollView.contentOffset.y <= hideHeight-REFRESH_POINT){
		_refreshLabel.text = @"Release to refresh";
		[UIView animateWithDuration:0.2 animations:^{
			_arrowImageView.transform = CGAffineTransformMakeRotation(-M_PI);
		}];
		startRefresh = YES;
	}else{
		startRefresh = NO;
		[UIView animateWithDuration:0.2 animations:^{
			_arrowImageView.transform = CGAffineTransformMakeRotation(0);
		}];
		_refreshLabel.text = @"Pull down to refresh";
	}
	
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{

	if(startRefresh) {
		if(!refreshing){
			[self beginRefreshing];
			startRefresh = NO;
		}
	}

}


@end
