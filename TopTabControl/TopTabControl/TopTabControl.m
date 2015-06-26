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


@interface TopTabControl()<UICollectionViewDataSource, UICollectionViewDelegate>

/** @brief 顶部菜单栏横向滑动的collection view */
@property (nonatomic, strong) UICollectionView *collectionViewTopMenu;
@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayoutTopMenu;
@property (nonatomic, strong) NSString *identifierTopMenu;

/** @brief 顶部菜单栏横向滑动的collection view */
@property (nonatomic, strong) UICollectionView *collectionViewContent;
@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayoutContent;
@property (nonatomic, strong) NSString *identifierContent;

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


- (UICollectionView *)collectionViewContent {
  if (nil == _collectionViewContent) {
    CGFloat left = .0;
    CGFloat top = [self _topMenuHeight];
    CGFloat width = CGRectGetWidth(self.frame);
    CGFloat height = CGRectGetHeight(self.frame) - top;
    CGRect rect = CGRectMake(left, top, width, height);
    _collectionViewContent = [[UICollectionView alloc] initWithFrame:rect collectionViewLayout:self.flowLayoutContent];
    _collectionViewContent.dataSource = self;
    _collectionViewContent.delegate = self;
    _collectionViewContent.pagingEnabled = YES;
    _collectionViewContent.backgroundColor = [UIColor clearColor];
    self.identifierContent = @"identifierContent";
    [_collectionViewContent registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:self.identifierContent];
    [_collectionViewContent setShowsHorizontalScrollIndicator:NO];
    
    [self addSubview:_collectionViewContent];
  }
  return _collectionViewContent;
}

- (UICollectionViewFlowLayout *)flowLayoutContent {
  if (!_flowLayoutContent) {
    _flowLayoutContent = [[UICollectionViewFlowLayout alloc] init];
    _flowLayoutContent.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    _flowLayoutContent.minimumLineSpacing = .0;
    _flowLayoutContent.minimumInteritemSpacing = .0;
    _flowLayoutContent.sectionInset = UIEdgeInsetsZero;
  }
  return _flowLayoutContent;
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
  if (collectionView == self.collectionViewContent) {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:self.identifierContent forIndexPath:indexPath];
    [[cell.contentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    if([self.datasource respondsToSelector:@selector(topTabControl:itemAtIndex:)]) {
      UIView *page = [self.datasource topTabControl:self pageAtIndex:indexPath.item];
      cell.contentView.backgroundColor = [UIColor randomColor];
      [cell.contentView addSubview:page];
    }

    return cell;
  }
  
  UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:self.identifierTopMenu forIndexPath:indexPath];
  [[cell.contentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
  if([self.datasource respondsToSelector:@selector(topTabControl:itemAtIndex:)])
  {
    UIView *item = [self.datasource topTabControl:self itemAtIndex:indexPath.item];
    cell.contentView.backgroundColor = [UIColor randomColor];
    [cell.contentView addSubview:item];
    return cell;
  }
  return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
  if (collectionView == self.collectionViewContent) {
    return;
  }
  
  [self contentTablesSrollToIndexPath:indexPath];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
  if (collectionView == self.collectionViewContent) {
    CGFloat with = CGRectGetWidth(self.frame);
    CGFloat height = CGRectGetHeight(self.frame) - [self _topMenuHeight];
    return CGSizeMake(with, height);
  }
  
  CGFloat width = [self _topMenuWidth];
  CGFloat height = [self _topMenuHeight];
  return CGSizeMake(width, height);
}


#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
  if(scrollView == self.collectionViewContent) {
    NSUInteger currentPage = (self.collectionViewContent.contentOffset.x + 0.5*CGRectGetWidth(self.frame))/CGRectGetWidth(self.frame);
    if(currentPage != self.pageIndex)
      _pageIndex = currentPage;
    [self updateIndicatorPosition];
  }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
  if(scrollView == self.collectionViewContent) {
    [self handleEndScroll];
  }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
  if(scrollView == self.collectionViewContent) {
    if(!decelerate) {
      [self handleEndScroll];
    }
  }
}

#pragma mark - public method
- (void)reloadData {
  [self.collectionViewTopMenu reloadData];
  [self.collectionViewContent reloadData];
}


- (void)setShowIndicatorView:(BOOL)showIndicatorView {
  _showIndicatorView = showIndicatorView;
  if(showIndicatorView) {
    [[self indicatorView] setHidden:NO];;
    [self.collectionViewTopMenu bringSubviewToFront:[self indicatorView]];
  } else {
    [[self indicatorView] setHidden:YES];
  }
  
}

- (void)displayPageAtIndex:(NSUInteger)pageIndex {
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
    
    CGFloat x = self.collectionViewContent.contentOffset.x / self.collectionViewContent.contentSize.width;
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
  UICollectionViewLayoutAttributes *layoutAttributes = [self.collectionViewTopMenu.collectionViewLayout layoutAttributesForItemAtIndexPath:indexPath];
  CGFloat centerX = CGRectGetMidX(layoutAttributes.frame);
  CGFloat x = MAX(centerX - (CGRectGetWidth(self.collectionViewTopMenu.frame) / 2.0), 0);
  CGPoint offset = CGPointMake(x, 0);
  [self.collectionViewTopMenu setContentOffset:offset animated:YES];
}


/**
 *  <#Description#>
 *
 *  @param indexPath <#indexPath description#>
 */
- (void)contentTablesSrollToIndexPath:(NSIndexPath *)indexPath
{
  [self.collectionViewContent scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
  [self performSelector:@selector(handleEndScroll) withObject:nil afterDelay:0.25];
}

@end
