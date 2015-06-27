//
//  TopTabControl.m
//  TopTabControl
//
//  Created by vousaimer on 14-12-11.
//  Copyright (c) 2014年 va. All rights reserved.
//

#import "TopTabControl.h"

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
- (void)layoutSubviews {
  [super layoutSubviews];
  
  if (CGRectGetWidth(self.collectionViewTopMenu.frame) != CGRectGetWidth(self.frame)) {
    CGRect frame = self.collectionViewTopMenu.frame;
    frame.size.width = CGRectGetWidth(self.frame);
    self.collectionViewTopMenu.frame = frame;
  }
  
  CGFloat wantHeight = MAX(CGRectGetHeight(self.frame) - CGRectGetHeight(self.collectionViewTopMenu.frame), 0);
  if (CGRectGetWidth(self.collectionViewContent.frame) != CGRectGetWidth(self.frame)
      || CGRectGetHeight(self.collectionViewContent.frame) != wantHeight) {
    CGRect frame = self.collectionViewContent.frame;
    frame.size.width = CGRectGetWidth(self.frame);
    frame.size.height = wantHeight;
    self.collectionViewContent.frame = frame;
  }
}



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
  UICollectionViewCell *cell = nil;
  UIView *content = nil;
  if (collectionView == self.collectionViewContent) {
    cell = [collectionView dequeueReusableCellWithReuseIdentifier:self.identifierContent forIndexPath:indexPath];
    if([self.datasource respondsToSelector:@selector(topTabControl:itemAtIndex:)]) {
      UIView *page = [self.datasource topTabControl:self pageAtIndex:indexPath.item];
      content = page;
    }
  } else {
    cell = [collectionView dequeueReusableCellWithReuseIdentifier:self.identifierTopMenu forIndexPath:indexPath];
    if([self.datasource respondsToSelector:@selector(topTabControl:itemAtIndex:)]) {
      UIView *item = [self.datasource topTabControl:self itemAtIndex:indexPath.item];
      content = item;
    }
  }
  
  [self _addContent:content forCell:cell];
  
  /**
   *  @brief  如果是iOS 8.0 以下
   */
  if ([[[UIDevice currentDevice] systemVersion] compare:@"8.0" options:NSNumericSearch] == NSOrderedAscending) {
    [self collectionView:collectionView willDisplayCell:cell forItemAtIndexPath:indexPath];
  }
  
  return cell ?: [UICollectionViewCell new];
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
  if (collectionView == self.collectionViewContent) {
    return;
  }
  
  [self contentTablesSrollToIndexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
  if (collectionView == self.collectionViewContent) {
    if ([self.delegate respondsToSelector:@selector(topTabControl:willDisplayPage:forIndex:)]) {
      [self.delegate topTabControl:self willDisplayPage:[self _contentOfCell:cell] forIndex:indexPath.item];
    }
  }
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
  if (collectionView == self.collectionViewContent) {
    if ([self.delegate respondsToSelector:@selector(topTabControl:didDisplayPage:forIndex:)]) {
      [self.delegate topTabControl:self didDisplayPage:[self _contentOfCell:cell] forIndex:indexPath.item];
    }
  }
}

#pragma mark - UICollectionViewDelegateFlowLayout
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

/**
 *  @brief  获取 cell 中的内容
 *
 *  @param cell 要获取的 cell
 *
 *  @return 视图
 */
- (UIView *)_contentOfCell:(UICollectionViewCell *)cell {
  return [[[cell contentView] subviews] firstObject];
}

/**
 *  @brief   将页面加入到 cell 中
 *
 *  @param content 要加入到 cell 中的内容
 *  @param cell 要加入内容的 cell
 */
- (void)_addContent:(UIView *)content forCell:(UICollectionViewCell *)cell {
  [[[cell contentView] subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
  [[cell contentView] addSubview:content];
}

@end
