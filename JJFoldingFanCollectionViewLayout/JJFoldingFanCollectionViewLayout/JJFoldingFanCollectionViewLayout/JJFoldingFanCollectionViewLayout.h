//
//  JJFoldingFanCollectionViewLayout.h
//  CardLayoutDemo
//
//  Created by ljw on 2016/12/22.
//  Copyright © 2016年 ljw. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef struct{
    CGFloat startAngle;
    CGFloat angleLength;
} JJAngleRange;

JJAngleRange JJMakeAngleRange(CGFloat startAngle, CGFloat angleLength);

/**
 卡片的层级变化趋势

 - JJFoldingFanCollectionViewLayoutZIndexVariationTrendAscending: index大的卡片会在上面
 - JJFoldingFanCollectionViewLayoutZIndexVariationTrendDescending: index大的卡片会在下面
 - JJFoldingFanCollectionViewLayoutZIndexVariationTrendAscendingBothSide: 从开始位置，两边递增
 - JJFoldingFanCollectionViewLayoutZIndexVariationTrendDescendingBothSide: 从开始位置，两边递减
 */
typedef NS_ENUM(NSInteger, JJFoldingFanCollectionViewLayoutZIndexVariationTrend){
    JJFoldingFanCollectionViewLayoutZIndexVariationTrendAscending,
    JJFoldingFanCollectionViewLayoutZIndexVariationTrendDescending,
    JJFoldingFanCollectionViewLayoutZIndexVariationTrendAscendingBothSide,
    JJFoldingFanCollectionViewLayoutZIndexVariationTrendDescendingBothSide,
};


/**
 滚动方向

 - JJFoldingFanCollectionViewLayoutScrollDirectionVertical: 竖直
 - JJFoldingFanCollectionViewLayoutScrollDirectionHorizontal: 横向
 */
typedef NS_ENUM(NSInteger, JJFoldingFanCollectionViewLayoutScrollDirection)
{
    JJFoldingFanCollectionViewLayoutScrollDirectionVertical,
    JJFoldingFanCollectionViewLayoutScrollDirectionHorizontal,
};


/**
 坐标原点的位置

 - JJFoldingFanCollectionViewLayoutOriginPositionTop: 上
 - JJFoldingFanCollectionViewLayoutOriginPositionLeft: 左
 - JJFoldingFanCollectionViewLayoutOriginPositionBottom: 下
 - JJFoldingFanCollectionViewLayoutOriginPositionRight: 右
 */
typedef NS_ENUM(NSInteger, JJFoldingFanCollectionViewLayoutOriginPosition) {
    JJFoldingFanCollectionViewLayoutOriginPositionTop,
    JJFoldingFanCollectionViewLayoutOriginPositionLeft,
    JJFoldingFanCollectionViewLayoutOriginPositionBottom,
    JJFoldingFanCollectionViewLayoutOriginPositionRight,
};


/**
 布局类型

 - JJFoldingFanCollectionViewLayoutTypeCycle: 圆形
 - JJFoldingFanCollectionViewLayoutTypeElipse: 椭圆
 */
typedef NS_ENUM(NSInteger, JJFoldingFanCollectionViewLayoutType)
{
    JJFoldingFanCollectionViewLayoutTypeCircle,
    JJFoldingFanCollectionViewLayoutTypeOval,
};

#pragma mark - ========================= Layout =========================
@protocol JJFoldingFanCollectionViewLayoutAdditionalConfiger, JJFoldingFanCollectionViewLayoutDelegate;
@interface JJFoldingFanCollectionViewLayout : UICollectionViewLayout

/**
 布局类型，圆形或者椭圆
 */
@property (nonatomic, assign) JJFoldingFanCollectionViewLayoutType layoutType;

/**
 卡片的层级变化趋势，递增的话index大的卡片会在上层
 */
@property (nonatomic, assign) JJFoldingFanCollectionViewLayoutZIndexVariationTrend zIndexVariationTrend;

/**
 坐标原点的位置
 */
@property (nonatomic, assign) JJFoldingFanCollectionViewLayoutOriginPosition originPosition;

/**
 滚动方向
 */
@property (nonatomic, assign) JJFoldingFanCollectionViewLayoutScrollDirection scrollDirection;

/**
 坐标原点（圆心,椭圆的中心在坐标原点上）
 */
@property (nonatomic, assign) CGPoint origin;

/**
 卡片角度差值
 */
@property (nonatomic, assign) CGFloat angleDifference;

/**
 卡片大小
 */
@property (nonatomic, assign) CGSize itemSize;

/**
 开始角度(从左至右算起, 从上至下)
 */
@property (nonatomic, assign) CGFloat startAngle;

/**
 结束角度(同上)
 */
@property (nonatomic, assign) CGFloat endAngle;

/**
 卡片center 到ancho的距离, 类型为圆形时会用到
 */
@property (nonatomic, assign) CGFloat radius;

/**
 场半轴，类型为椭圆时会用到
 */
@property (nonatomic, assign) CGFloat a;

/**
 短半轴，类型为椭圆时会用到
 */
@property (nonatomic, assign) CGFloat b;

/**
 相对于起始角度每一度的坐标差offset
 */
@property (nonatomic, assign) CGPoint offsetOfPerDegree;

/**
 角度相对于位移的比，一个点对应多少度 (默认M_PI/180.f)
 */
@property (nonatomic, assign) CGFloat speed;

/**
 可视角度角度范围（默认为{0,M_PI}）
 */
@property (nonatomic, assign) JJAngleRange visibleAngleRange;

/**
 cell的上方是否和半径同方向
 */
@property (nonatomic, assign) BOOL syntropyToRadius;

/**
 滑动结束时是否吸附至最近的卡片位置，就是以卡片为单位来滑动
 */
@property (nonatomic, assign) BOOL adsorbed;

/**
 是否展示指示条（默认不展示）
 */
@property (nonatomic, assign) BOOL showsScrollIndicator;

/**
 默认为YES设为NO将无法滚动
 */
@property (nonatomic, assign) BOOL dynamic;

/**
 附加配置
 */
@property (nonatomic, weak) id<JJFoldingFanCollectionViewLayoutAdditionalConfiger> additionalConfiger;

/**
 代理
 */
@property (nonatomic, weak) id<JJFoldingFanCollectionViewLayoutDelegate> delegate;


#pragma mark - Public
/**
 处在开始角度的indexPath

 @return 处在开始角度的indexPath
 */
- (NSIndexPath *)indexPathAtStartAngle;

@end

#pragma mark - ========================= Protocol =========================
/**
 附加配置
 */
@protocol JJFoldingFanCollectionViewLayoutAdditionalConfiger <NSObject>

@optional;
/**
 配置attributes，当滚动到与开始角度相差indexDifference个角度差的位置时(请慎重地修改attributes的属性)
 
 @param layout layout
 @param attributes 布局对象
 @param indexDifference 相对于开始角度的index差值
 */
- (void)layout:(JJFoldingFanCollectionViewLayout *)layout configForStartAngle:(UICollectionViewLayoutAttributes *)attributes indexDifferToStartAngle:(NSInteger)indexDifference;


/**
 配置attributes(每一个都会调用，请慎重地修改attributes的属性)
 
 @param layout layout
 @param attributes 布局对象
 */
- (void)layout:(JJFoldingFanCollectionViewLayout *)layout configForAttributes:(UICollectionViewLayoutAttributes *)attributes;

/**
 根据相对于开始角度的角度差，返回相应的坐标偏移

 @param layout layout
 @param angleDifference 相对于开始角度的角度差
 @return 坐标偏移
 */
- (CGPoint)layout:(JJFoldingFanCollectionViewLayout *)layout offsetOfAngleDifferenceForStartAngle:(CGFloat)angleDifference;


/**
 根据相对于开始角度的角度差做相应的配置（请慎重地修改attributes的属性）

 @param layout layout
 @param angleDifference 角度差
 @param attributes 布局对象
 */
- (void)layout:(JJFoldingFanCollectionViewLayout *)layout configForAngleDifferenceForStartAngle:(CGFloat)angleDifference attributes:(UICollectionViewLayoutAttributes *)attributes;

@end

@protocol JJFoldingFanCollectionViewLayoutDelegate <NSObject>


/**
 当有新的卡片滚动到开始角度时的回调

 @param layout layout
 @param indexPath 卡片对应的indexPath
 */
- (void)layout:(JJFoldingFanCollectionViewLayout *)layout didCardAtIndexPathScrollToStartAngle:(NSIndexPath *)indexPath;

@end

#pragma mark - ========================= Category =========================

@interface UICollectionView (JJFoldingFanCollectionViewLayout)


/**
 滚到对应的indexPath

 @param indexPath indexPath
 @param animated 是否动画
 */
- (void)JJ_scrollToIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated;


/**
 indexPath是否在开始角度上
 
 @param indexPath indexPath
 @return indexPath是否在开始角度上
 */
- (BOOL)indexPathIsAtStartAngle:(NSIndexPath *)indexPath;

@end
