//
//  ViewController.m
//  JJFoldingFanCollectionViewLayout
//
//  Created by ljw on 2017/1/3.
//  Copyright © 2017年 ljw. All rights reserved.
//

#import "ViewController.h"
#import "JJFoldingFanCollectionViewLayout.h"

@interface ViewController () <JJFoldingFanCollectionViewLayoutAdditionalConfiger, JJFoldingFanCollectionViewLayoutDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;


@property (nonatomic, strong) NSArray<UIColor *> *colorList;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self createColorListWithCount:10];
    
    [self configCollectionView];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private
- (void)configCollectionView
{
    
    JJFoldingFanCollectionViewLayout *layout = (JJFoldingFanCollectionViewLayout *)self.collectionView.collectionViewLayout;
    
    CGFloat boundsWidth = [UIScreen mainScreen].bounds.size.width;
    
    //大小(随便调，和屏幕的宽无关)
    CGSize itemSize = CGSizeMake(boundsWidth / 3.f, boundsWidth / 3.3f * 1.6f);
    
    //半径(随便调，和item的宽无关)
    layout.radius = itemSize.width * 2;
    //每个item的角度差
    layout.angleDifference = M_PI / 10;
    //控制起始和结束位置
    layout.startAngle = M_PI_2;
    layout.endAngle = M_PI_2;
    
    layout.itemSize = itemSize;
    
    //类型为圆时的圆心所在位置
    layout.origin = CGPointMake(boundsWidth / 2, layout.radius + layout.itemSize.height / 2 + 60.f);
    
    //是否一张卡片一张卡片的滚动
    layout.adsorbed = YES;
    
    //卡片的方向是否和卡片中心到圆心的方向水平
    layout.syntropyToRadius = YES;
    
    //卡片层级的变化趋势，这个是开始角度向两边递减
    layout.zIndexVariationTrend = JJFoldingFanCollectionViewLayoutZIndexVariationTrendDescendingBothSide;
    
    //控制滑动的速度，（随便调）
    layout.speed = M_PI / (layout.radius * 6);
    
    //可视角度范围
    layout.visibleAngleRange = JJMakeAngleRange(M_PI / 10 * 3, M_PI / 10 * 7);
    
    //额外配置
    layout.additionalConfiger = self;
    
    //代理
    layout.delegate = self;
}

- (void)createColorListWithCount:(NSInteger)count
{
    NSMutableArray<UIColor *> *colorList = [[NSMutableArray<UIColor *> alloc] init];
    for (NSInteger index = 0; index < count; index++) {
        CGFloat r = arc4random() % 11 / 10.f;
        CGFloat g = arc4random() % 11 / 10.f;
        CGFloat b = arc4random() % 11 / 10.f;
        [colorList addObject:[UIColor colorWithRed:r green:g blue:b alpha:1.f]];
    }
    self.colorList = colorList;
}

#pragma mark - JJFoldingFanCollectionViewLayoutAdditionalConfiger
- (CGPoint)layout:(JJFoldingFanCollectionViewLayout *)layout offsetOfAngleDifferenceForStartAngle:(CGFloat)angleDifference
{
    //调整相对于开始角度的角度差对应的高度差，不实现也行
    return CGPointMake(0.f, fabs(angleDifference * layout.itemSize.width / 6));
}

- (void)layout:(JJFoldingFanCollectionViewLayout *)layout configForAngleDifferenceForStartAngle:(CGFloat)angleDifference attributes:(UICollectionViewLayoutAttributes *)attributes
{
    //透明度效果，不实现也行
    CGFloat markAngle = layout.angleDifference / 2;
    CGFloat markAlpha = 0.85f;
    if (fabs(angleDifference) - markAngle <= 0) {
        attributes.alpha = 1.f - fabs(angleDifference) / markAngle * (1.f - markAlpha);
    }
    else
    {
        attributes.alpha = markAlpha + (fabs(angleDifference) - markAngle) / markAngle * (1.f - markAlpha);
    }
}

#pragma mark - JJFoldingFanCollectionViewLayoutDelegate
/**
 当有新的卡片滚动到开始角度时的回调
 
 @param layout layout
 @param indexPath 卡片对应的indexPath
 */
- (void)layout:(JJFoldingFanCollectionViewLayout *)layout didCardAtIndexPathScrollToStartAngle:(NSIndexPath *)indexPath
{
    NSLog(@"new item scroll to start postion %zd", indexPath.row);
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.colorList.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.backgroundColor = self.colorList[indexPath.row];
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    //选中卡片时，如果卡片不在开始角度就滚到开始角度
    if ([collectionView JJ_itemAtIndexPathIsAtStartAngle:indexPath]) {
        NSLog(@"item is at start postion");
    }
    else
    {
        //禁止快速连续点击切换卡片，防止出现一些奇怪的现象
        collectionView.userInteractionEnabled = NO;
        
        [collectionView JJ_scrollToIndexPath:indexPath animated:YES];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    //禁止快速连续点击切换卡片，防止出现一些奇怪的现象
    scrollView.userInteractionEnabled = YES;
}


@end
