
//
//  JJFoldingFanCollectionViewLayout.m
//  CardLayoutDemo
//
//  Created by ljw on 2016/12/22.
//  Copyright © 2016年 ljw. All rights reserved.
//

#import "JJFoldingFanCollectionViewLayout.h"

//用于计算结束角度
static CGFloat const s_Range = M_PI;

JJAngleRange JJMakeAngleRange(CGFloat startAngle, CGFloat angleLength)
{
    return (JJAngleRange){startAngle, angleLength};
}

#pragma mark - ========================= Attributes =========================
@interface JJFoldingFanCollectionViewLayoutAttributes : UICollectionViewLayoutAttributes

/**
 offset为0时排列布局的角度信息
 */
@property (nonatomic, copy) NSNumber *layoutAngle;

@end

@implementation JJFoldingFanCollectionViewLayoutAttributes

@end

#pragma mark - ========================= Layout =========================
@interface JJFoldingFanCollectionViewLayout ()

@property (nonatomic, assign) NSInteger itemCount;

//滚到开始角度的index
@property (nonatomic, assign) NSInteger currentMarkIndex;

/**
 attributes缓存(只会缓存offset为0时排列布局的角度信息)
 */
@property (nonatomic, strong) NSMutableDictionary<NSString *, JJFoldingFanCollectionViewLayoutAttributes *> *attributesCaches;


/**
 可见的第item的index
 */
@property (nonatomic, assign) NSInteger visiableIndex;

@end

@implementation JJFoldingFanCollectionViewLayout

#pragma mark - Setter & Getter
- (void)setCurrentMarkIndex:(NSInteger)currentMarkIndex
{
    if (_currentMarkIndex != currentMarkIndex) {
        if ([self.delegate respondsToSelector:@selector(layout:didCardAtIndexPathScrollToStartAngle:)]) {
            [self.delegate layout:self didCardAtIndexPathScrollToStartAngle:[NSIndexPath indexPathForRow:self.currentMarkIndex inSection:0]];
        }
    }
    _currentMarkIndex = currentMarkIndex;
}

- (NSMutableDictionary<NSString *, JJFoldingFanCollectionViewLayoutAttributes *> *)attributesCaches
{
    if (!_attributesCaches) {
        _attributesCaches = [[NSMutableDictionary<NSString *, JJFoldingFanCollectionViewLayoutAttributes *> alloc] init];
    }
    return _attributesCaches;
}

#pragma mark - Override
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setUp];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self setUp];
    }
    return self;
}

-(CGSize)collectionViewContentSize
{
    if (!self.dynamic) {
        return CGSizeZero;
    }
    if ([self isHorizontal]) {
        CGFloat width = ((self.itemCount - 1) * self.angleDifference + self.startAngle - (s_Range - self.endAngle)) / self.speed + self.collectionView.bounds.size.width;
        width += self.collectionView.contentInset.left + self.collectionView.contentInset.right;
        return CGSizeMake(width, 0.f);
    }
    else
    {
        CGFloat height = ((self.itemCount - 1) * self.angleDifference + self.startAngle - (s_Range - self.endAngle)) / self.speed + self.collectionView.bounds.size.height;
        height += self.collectionView.contentInset.top + self.collectionView.contentInset.bottom;
        return CGSizeMake(0.f, height);
    }
}

- (void)prepareLayout
{
    [super prepareLayout];
    
    if (self.collectionView.showsVerticalScrollIndicator != self.showsScrollIndicator) {
        self.collectionView.showsVerticalScrollIndicator = self.showsScrollIndicator;
    }
    if (self.collectionView.showsHorizontalScrollIndicator != self.showsScrollIndicator) {
        self.collectionView.showsHorizontalScrollIndicator = self.showsScrollIndicator;
    }
    
    //关闭预加载，不关会有奇怪的效果，暂时没想去解决
    if ([self.collectionView respondsToSelector:@selector(isPrefetchingEnabled)] && self.collectionView.prefetchingEnabled) {
        self.collectionView.prefetchingEnabled = NO;
    }
    
    self.itemCount = [self.collectionView numberOfItemsInSection:0];
}

- (nullable NSArray<__kindof UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect
{
    
    NSMutableArray<__kindof UICollectionViewLayoutAttributes *> *attrsList = [[NSMutableArray<__kindof UICollectionViewLayoutAttributes *> alloc] init];
    
    for (NSInteger index = self.visiableIndex == 0 ? 0 : self.visiableIndex - 1; index < self.itemCount; index ++) {
        
        UICollectionViewLayoutAttributes *attrs = [self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
        
        if (!attrs.hidden) {
            [attrsList addObject:attrs];
        }
        else
        {
            if (attrsList.count > 0) {
                self.visiableIndex = attrsList.firstObject.indexPath.row;
                return attrsList;
            }
        }
    
    }
    
    self.visiableIndex = attrsList.firstObject.indexPath.row;
    return attrsList;
}

- (nullable UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    JJFoldingFanCollectionViewLayoutAttributes *attrs = [self cachedAttribuesForIndexPath:indexPath];
    
    if (!attrs) {
        attrs = [JJFoldingFanCollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        [self cacheAttributes:attrs];
    }
    
    //排列角度
    NSNumber *layoutAngle = attrs.layoutAngle;
    if (!layoutAngle) {
        layoutAngle = @([self angleLayoutTrend] * indexPath.row * self.angleDifference + [self angleLayoutTrend] * self.startAngle + [self startAngleOffset]);
        attrs.layoutAngle = layoutAngle;
    }
    
    CGFloat itemAngle = layoutAngle.doubleValue;
    
    //offset
    CGFloat offset = [self isHorizontal] ? self.collectionView.contentOffset.x : self.collectionView.contentOffset.y;
    
    //旋转角度
    CGFloat rotatAngle = offset * self.speed *  - [self angleLayoutTrend];
    
    //显示角度
    itemAngle += rotatAngle;
    
    //位置
    CGFloat itemCenterX = 0.f;
    CGFloat itemCenterY = 0.f;
    
    switch (self.layoutType) {
        case JJFoldingFanCollectionViewLayoutTypeCircle:
        {
            itemCenterX = self.origin.x + self.radius * cos(itemAngle) + ([self isHorizontal] ? self.collectionView.contentOffset.x : 0.f);
            itemCenterY = self.origin.y - self.radius * sin(itemAngle) + (![self isHorizontal] ? self.collectionView.contentOffset.y : 0.f);
        }
            break;
        case JJFoldingFanCollectionViewLayoutTypeOval:
        {
            itemCenterX = self.origin.x + self.a * cos(itemAngle) + ([self isHorizontal] ? self.collectionView.contentOffset.x : 0.f);
            itemCenterY = self.origin.y - self.b * sin(itemAngle) + (![self isHorizontal] ? self.collectionView.contentOffset.y : 0.f);
        }
            break;
            
        default:
            break;
    }
    
    //处理相对于开始角度的坐标偏移
    if ([self.additionalConfiger respondsToSelector:@selector(layout:offsetOfAngleDifferenceForStartAngle:)]) {
        CGFloat angleDifference = [self angleDifferenceForStartAngle:itemAngle];
        CGPoint offset = [self.additionalConfiger layout:self offsetOfAngleDifferenceForStartAngle:angleDifference];
        itemCenterX += offset.x;
        itemCenterY += offset.y;
    }
    else
    {
        if (self.offsetOfPerDegree.x != 0) {
            CGFloat angleDifference = [self angleLayoutTrend] * self.startAngle + [self startAngleOffset] - itemAngle;
            itemCenterX += fabs(angleDifference) * self.offsetOfPerDegree.x * [self angleLayoutTrend];
        }
        if (self.offsetOfPerDegree.y != 0) {
            CGFloat angleDifference = [self angleLayoutTrend] * self.startAngle + [self startAngleOffset] - itemAngle;
            itemCenterY += fabs(angleDifference) * self.offsetOfPerDegree.y * - [self angleLayoutTrend];
        }
    }
    

    attrs.center = CGPointMake(itemCenterX, itemCenterY);
    
    //大小
    attrs.size = self.itemSize;
    
    //是否要与半径同向
    if (self.syntropyToRadius) {
        attrs.transform = CGAffineTransformMakeRotation(M_PI_2 - itemAngle);
    }
    
    //是否显示
    attrs.hidden = ![self angleIsVisible:itemAngle];
    
    //控制层级
    NSInteger zIndex = 0;
    
    CGFloat itemAngle100 = round(itemAngle * 100);
    CGFloat markAngle100 = round(([self angleLayoutTrend] * self.startAngle + [self startAngleOffset]) * 100);
    CGFloat diferenceAngle100 = round(self.angleDifference * 100);
    
    NSInteger zIndexUnit = 1;
    
    switch (self.zIndexVariationTrend) {
        case JJFoldingFanCollectionViewLayoutZIndexVariationTrendAscending:
        {
            zIndexUnit = 1;
        }
            break;
        case JJFoldingFanCollectionViewLayoutZIndexVariationTrendDescending:
        {
            zIndexUnit = -1;
        }
            break;
        case JJFoldingFanCollectionViewLayoutZIndexVariationTrendAscendingBothSide:
        {
            zIndexUnit = itemAngle100 > markAngle100 + 2 ?   [self angleLayoutTrend] : - [self angleLayoutTrend];
        }
            break;
        case JJFoldingFanCollectionViewLayoutZIndexVariationTrendDescendingBothSide:
        {
            zIndexUnit = itemAngle100 > markAngle100 + 2 ?  - [self angleLayoutTrend] : [self angleLayoutTrend];
        }
            break;
            
        default:
            break;
    }
    
    zIndex = zIndexUnit * indexPath.row;
    
    
    if (self.zIndexVariationTrend == JJFoldingFanCollectionViewLayoutZIndexVariationTrendDescendingBothSide
        || self.zIndexVariationTrend == JJFoldingFanCollectionViewLayoutZIndexVariationTrendAscendingBothSide)
    {
        if (itemAngle100 > markAngle100 - diferenceAngle100 * 0.5f && itemAngle100 < markAngle100 + diferenceAngle100 * 0.5f) {
            zIndex = self.zIndexVariationTrend == JJFoldingFanCollectionViewLayoutZIndexVariationTrendDescendingBothSide ? NSIntegerMax : NSIntegerMin;
            self.currentMarkIndex = attrs.indexPath.row;
        }
    }
    
    attrs.zIndex = zIndex;
    
    //附加配置代理
    if ([self.additionalConfiger respondsToSelector:@selector(layout:configForStartAngle:indexDifferToStartAngle:)]) {
        [self.additionalConfiger layout:self configForStartAngle:attrs indexDifferToStartAngle:self.currentMarkIndex - attrs.indexPath.row];
    }
    
    if ([self.additionalConfiger respondsToSelector:@selector(layout:configForAttributes:)]) {
        [self.additionalConfiger layout:self configForAttributes:attrs];
    }
    
    if ([self.additionalConfiger respondsToSelector:@selector(layout:configForAngleDifferenceForStartAngle:attributes:)]) {
        [self.additionalConfiger layout:self configForAngleDifferenceForStartAngle:[self angleDifferenceForStartAngle:itemAngle] attributes:attrs];
    }
    
    return attrs;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return YES;
}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity
{
    if (self.adsorbed) {
        if ([self isHorizontal]) {
            CGFloat unitOffset = self.angleDifference / self.speed;
            
            NSInteger index = lround(proposedContentOffset.x / unitOffset);
            
            return CGPointMake(index * unitOffset, proposedContentOffset.y);
        }
        else
        {
            CGFloat unitOffset = self.angleDifference / self.speed;
            
            NSInteger index = lround(proposedContentOffset.y / unitOffset);
            
            return CGPointMake(proposedContentOffset.x, index * unitOffset);
        }
    }
    else
    {
        return proposedContentOffset;
    }
}

#pragma mark - Private
- (void)setUp
{
    self.visibleAngleRange = JJMakeAngleRange(0.f, M_PI);
    self.layoutType = JJFoldingFanCollectionViewLayoutTypeCircle;
    self.originPosition = JJFoldingFanCollectionViewLayoutOriginPositionBottom;
    self.scrollDirection = JJFoldingFanCollectionViewLayoutScrollDirectionHorizontal;
    self.speed = M_PI / 180.f;
    self.dynamic = YES;
}

- (BOOL)angleIsVisible:(CGFloat)itemAngle
{
    if ([self angleLayoutTrend] > 0) {
        return (itemAngle > - self.angleDifference + [self startAngleOffset] + [self angleLayoutTrend] * self.visibleAngleRange.startAngle && itemAngle < [self startAngleOffset] + self.angleDifference + [self angleLayoutTrend] * (self.visibleAngleRange.startAngle + self.visibleAngleRange.angleLength));
    }
    else
    {
        return (itemAngle < self.angleDifference + [self angleLayoutTrend] * self.visibleAngleRange.startAngle + [self startAngleOffset] && itemAngle > [self angleLayoutTrend] * (self.visibleAngleRange.startAngle + self.visibleAngleRange.angleLength) - self.angleDifference + [self startAngleOffset]);
    }
}

- (CGFloat)startAngleOffset
{
    CGFloat startAngleOffset = 0.f;
    
    switch (self.originPosition) {
        case JJFoldingFanCollectionViewLayoutOriginPositionTop:
        case JJFoldingFanCollectionViewLayoutOriginPositionBottom:

        {
            startAngleOffset = M_PI;
        }
            break;
        case JJFoldingFanCollectionViewLayoutOriginPositionRight:
        case JJFoldingFanCollectionViewLayoutOriginPositionLeft:
        {
            startAngleOffset = M_PI_2;
        }
            
        default:
            break;
    }
    
    return startAngleOffset;
}

- (NSInteger)angleLayoutTrend
{
    return self.originPosition == JJFoldingFanCollectionViewLayoutOriginPositionRight || self.originPosition == JJFoldingFanCollectionViewLayoutOriginPositionTop ? 1 : -1;
}

- (BOOL)isHorizontal
{
    return self.scrollDirection == JJFoldingFanCollectionViewLayoutScrollDirectionHorizontal;
}

- (CGFloat)angleDifferenceForStartAngle:(CGFloat)itemAngle
{
   return [self angleLayoutTrend] * self.startAngle + [self startAngleOffset] - itemAngle;
}

- (JJFoldingFanCollectionViewLayoutAttributes *)cachedAttribuesForIndexPath:(NSIndexPath *)indexPath
{
    if (self.maxmumCachedAttributes != 0) {
        return [self.attributesCaches valueForKey:[@(indexPath.row) stringValue]];
    }
    else
    {
        return nil;
    }
}

- (void)cacheAttributes:(JJFoldingFanCollectionViewLayoutAttributes *)attributes
{
    if (self.maxmumCachedAttributes != 0) {
        if (self.attributesCaches.count == self.maxmumCachedAttributes) {
            [self.attributesCaches removeObjectForKey:self.attributesCaches.allKeys.firstObject];
        }
        [self.attributesCaches setValue:attributes forKey:[@(attributes.indexPath.row) stringValue]];
    }
}

#pragma mark - Public
/**
 处在开始角度的indexPath
 
 @return 处在开始角度的indexPath
 */
- (NSIndexPath *)indexPathOfItemAtStartAngle
{
    return [NSIndexPath indexPathForRow:self.currentMarkIndex inSection:0];
}

@end

#pragma mark - ========================= Category =========================

@implementation UICollectionView (JJFoldingFanCollectionViewLayout)

- (void)JJ_scrollToIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated
{
    JJFoldingFanCollectionViewLayout *layout = [self JJ_foldingFanCollectionViewLayout];
    if (layout) {
        
        CGFloat offsetX = layout.scrollDirection == JJFoldingFanCollectionViewLayoutScrollDirectionHorizontal ? indexPath.row * layout.angleDifference / layout.speed : 0;
        CGFloat offsetY = layout.scrollDirection == JJFoldingFanCollectionViewLayoutScrollDirectionVertical ? indexPath.row * layout.angleDifference / layout.speed : 0;
        [self setContentOffset:CGPointMake(offsetX, offsetY) animated:animated];
        
    }
    else
    {
        [self scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:animated];
    }
}


- (BOOL)JJ_itemAtIndexPathIsAtStartAngle:(NSIndexPath *)indexPath
{
    JJFoldingFanCollectionViewLayout *layout = [self JJ_foldingFanCollectionViewLayout];
    if (layout) {
        return indexPath.row == [layout indexPathOfItemAtStartAngle].row;
    }
    else
    {
        return NO;
    }
}

#pragma mark - Private 
- (JJFoldingFanCollectionViewLayout *)JJ_foldingFanCollectionViewLayout
{
    return [self.collectionViewLayout isKindOfClass:[JJFoldingFanCollectionViewLayout class]] ? (JJFoldingFanCollectionViewLayout *)self.collectionViewLayout : nil;
}

@end
