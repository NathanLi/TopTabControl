//
//  TopTabControl.m
//  TopTabControl
//
//  Created by vousaimer on 14-12-11.
//  Copyright (c) 2014年 va. All rights reserved.
//

#import "TopTabControl.h"
#import "UIColor+RandomColor.h"

/** @brief 顶部菜单栏默认的高度 */
static int const kTopTabControl_Default_TopMenuHeight = 20;
static int const kTopTabControl_Default_TopMenuWidth  = 60;
static int const kTopTabControl_Default_IndicatorHeight = 2;


@interface TopTabControl()<UITableViewDataSource,UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate>

/** @brief 顶部菜单栏横向滑动的collection view */
@property (nonatomic, strong) UICollectionView *collectionViewTopMenu;
@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayoutTopMenu;
@property (nonatomic, strong) NSString *identifierTopMenu;

/** @brief 菜单下面横向滑动内容的table */
@property (nonatomic, strong) UITableView *contentTableView;

/** @brief 顶部菜单栏横向滑动的collection view */
@property (nonatomic, strong) UICollectionView *clvContent;

/** @brief 指示器view */
@property (nonatomic, strong) UIView *indicatorView;

@end


@implementation TopTabControl

- (instancetype)initWithFrame:(CGRect)frame
{
  if(self = [super initWithFrame:frame])
  {
    
  }
  return self;
}


- (void)dealloc
{
  [NSObject cancelPreviousPerformRequestsWithTarget:self
                                           selector:@selector(handleEndScroll)
                                             object:nil];
}

#pragma mark - UIKIT




#pragma mark - override
- (UICollectionView *)collectionViewTopMenu {
  if (nil == _collectionViewTopMenu) {
    CGRect rectTopMenu = CGRectMake(0, 0, CGRectGetWidth(self.bounds), [self _topMenuHeight]);
    _collectionViewTopMenu = [[UICollectionView alloc] initWithFrame:rectTopMenu collectionViewLayout:self.flowLayoutTopMenu];
    _collectionViewTopMenu.dataSource = self;
    _collectionViewTopMenu.delegate = self;
    _collectionViewTopMenu.backgroundColor = [UIColor clearColor];
    self.identifierTopMenu = @"identifierTopMenu";
    [_collectionViewTopMenu registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:self.identifierTopMenu];
    [_collectionViewTopMenu setShowsHorizontalScrollIndicator:NO];
    
    [self addSubview:_collectionViewTopMenu];
  }
  return _collectionViewTopMenu;
}

- (UICollectionViewFlowLayout *)flowLayoutTopMenu {
  if (!_flowLayoutTopMenu) {
    _flowLayoutTopMenu = [[UICollectionViewFlowLayout alloc] init];
    _flowLayoutTopMenu.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    _flowLayoutTopMenu.minimumLineSpacing = .0;
    _flowLayoutTopMenu.minimumInteritemSpacing = .0;
    _flowLayoutTopMenu.sectionInset = UIEdgeInsetsZero;
  }
  return _flowLayoutTopMenu;
}


- (UITableView *)contentTableView {
  if(nil == _contentTableView) {
    CGFloat contentHeight = CGRectGetWidth(self.frame);
    CGFloat contentWidth  = CGRectGetHeight(self.frame) - [self _topMenuHeight];
    CGFloat x = CGRectGetWidth(self.frame)/2 - contentWidth/2;
    CGFloat y = (CGRectGetHeight(self.frame) - [self _topMenuHeight])/2 - contentHeight/2 + ([self _topMenuHeight]);
    CGRect contentRect = CGRectMake(x, y, contentWidth, contentHeight);
    _contentTableView = [[UITableView alloc] initWithFrame:contentRect
                                                     style:UITableViewStylePlain];
    [self addSubview:_contentTableView];
    
    _contentTableView.backgroundColor = [UIColor randomColor];
    _contentTableView.dataSource = self;
    _contentTableView.delegate = self;
    _contentTableView.showsVerticalScrollIndicator = NO;
    _contentTableView.pagingEnabled = YES;
    _contentTableView.transform = CGAffineTransformMakeRotation(-M_PI / 2);
  }
  
  return _contentTableView;
}

- (UIView *)indicatorView
{
  if(nil == _indicatorView)
  {
    CGFloat width = [self _topMenuWidth];
    CGFloat height  = kTopTabControl_Default_IndicatorHeight;
    CGFloat y = [self _topMenuHeight] - kTopTabControl_Default_IndicatorHeight;
    CGRect  rect = CGRectMake(0, y, width, height);
    _indicatorView = [[UIView alloc] initWithFrame:rect];
    _indicatorView.backgroundColor = [UIColor yellowColor];
    [self.collectionViewTopMenu addSubview:_indicatorView];
  }
  return _indicatorView;
}


#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
  if([self.datasource respondsToSelector:@selector(topTabMenuCount:)]) {
    return [self.datasource topTabMenuCount:self];
  }
  return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
  UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:self.identifierTopMenu forIndexPath:indexPath];
  [[cell.contentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
  if([self.datasource respondsToSelector:@selector(topTabControl:itemAtIndex:)])
  {
    TopTabMenuItem *item = [self.datasource topTabControl:self itemAtIndex:indexPath.item];
    cell.contentView.backgroundColor = [UIColor randomColor];
    [cell.contentView addSubview:item];
    return cell;
  }
  return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
  [self contentTablesSrollToIndexPath:indexPath];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
  CGFloat width = [self _topMenuWidth];
  CGFloat height = [self _topMenuHeight];
  return CGSizeMake(width, height);
}

#pragma mark - UITableView Datasource

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
  if([self.datasource respondsToSelector:@selector(topTabMenuCount:)])
  {
    return [self.datasource topTabMenuCount:self];
  }
  return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  if(tableView == _contentTableView)
  {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ContentPageCell"];
    if(cell == nil)
    {
      cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                    reuseIdentifier:@"ContentPageCell"];
      cell.frame = CGRectMake(0,
                              0,
                              CGRectGetHeight(self.frame) - [self _topMenuHeight],
                              CGRectGetWidth(self.frame));
    }
    [[cell.contentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)
                                                 withObject:nil];
    if([self.datasource respondsToSelector:@selector(topTabControl:itemAtIndex:)])
    {
      TopTabPage *page = [self.datasource topTabControl:self
                                            pageAtIndex:indexPath.row];
      cell.contentView.backgroundColor = [UIColor randomColor];
      [cell.contentView addSubview:page];
      CGFloat x = (CGRectGetWidth(cell.frame) - CGRectGetWidth(page.frame))/2;
      CGFloat y = (CGRectGetHeight(cell.frame) - CGRectGetHeight(page.frame))/2;
      page.frame = CGRectMake(x,
                              y,
                              CGRectGetWidth(page.frame),
                              CGRectGetHeight(page.frame));
      page.transform = CGAffineTransformMakeRotation(M_PI / 2);
    }
    return cell;
    
  }
  
  return [[UITableViewCell alloc] initWithFrame:CGRectZero];
}


- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  if(tableView == self.collectionViewTopMenu)
  {
    return [self _topMenuWidth];
  }
  
  if (tableView == self.contentTableView) {
    return CGRectGetWidth(self.frame);
  }
  return 0;
}



#pragma mark - UItableView Delegate


- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
  if(scrollView == self.contentTableView)
  {
    NSUInteger tempPage = (self.contentTableView.contentOffset.y + 0.5*CGRectGetWidth(self.frame))/CGRectGetWidth(self.frame);
    if(tempPage != self.pageIndex)
      _pageIndex = tempPage;
    [self updateIndicatorPosition];
  }
}



- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
  if(scrollView == self.contentTableView)
  {
    [self handleEndScroll];
  }
  
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
  if(scrollView == self.contentTableView)
  {
    if(!decelerate)
    {
      [self handleEndScroll];
    }
  }
}

#pragma mark - public method

- (void)reloadData
{
  [self.collectionViewTopMenu reloadData];
  [self.contentTableView reloadData];
}


- (void)setShowIndicatorView:(BOOL)showIndicatorView
{
  _showIndicatorView = showIndicatorView;
  if(showIndicatorView)
  {
    [[self indicatorView] setHidden:NO];;
    [self.collectionViewTopMenu bringSubviewToFront:[self indicatorView]];
  }
  else
  {
    [[self indicatorView] setHidden:YES];
  }
  
}


- (void)displayPageAtIndex:(NSUInteger)pageIndex
{
  [self contentTablesSrollToIndexPath:[NSIndexPath indexPathForRow:pageIndex inSection:0]];
}

#pragma mark - private method

/**
 *  @brief  得到顶部菜单栏的高度
 *
 *  @return 高度
 */
- (CGFloat)_topMenuHeight {
  CGFloat topMenuHeight = kTopTabControl_Default_TopMenuHeight;
  if([self.datasource respondsToSelector:@selector(topTabHeight:)]) {
    topMenuHeight = [self.datasource topTabHeight:self];
  }
  return topMenuHeight;
}

/**
 *  得到顶部菜单栏单个菜单的宽度
 *
 *  @return 宽度
 */
- (CGFloat)_topMenuWidth {
  if([self.datasource respondsToSelector:@selector(topTabWidth:)]) {
    return [self.datasource topTabWidth:self];
  }
  
  return kTopTabControl_Default_TopMenuWidth;
}

/**
 *  刷新指示器的位置
 */
- (void)updateIndicatorPosition
{
  if(self.showIndicatorView)
  {
    
    CGFloat x = self.contentTableView.contentOffset.y / self.contentTableView.contentSize.height;
    CGFloat height = kTopTabControl_Default_IndicatorHeight;
    CGFloat y = [self _topMenuHeight] - height;
    CGFloat widht = [self _topMenuWidth];
    self.indicatorView.frame = CGRectMake(x * self.collectionViewTopMenu.contentSize.width, y, widht, height);
  }
}


/**
 *  page table 停止滚动的时候
 */
- (void)handleEndScroll
{
  NSIndexPath *indexPath = [NSIndexPath indexPathForItem:self.pageIndex inSection:0];
  [self.collectionViewTopMenu scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
}


/**
 *  <#Description#>
 *
 *  @param indexPath <#indexPath description#>
 */
- (void)contentTablesSrollToIndexPath:(NSIndexPath *)indexPath
{
  //    if(indexPath.row >= max)
  //    {
  //
  //    }
  [self.contentTableView scrollToRowAtIndexPath:indexPath
                               atScrollPosition:UITableViewScrollPositionMiddle
                                       animated:NO];
  [self performSelector:@selector(handleEndScroll) withObject:nil afterDelay:0.25];
}

@end
