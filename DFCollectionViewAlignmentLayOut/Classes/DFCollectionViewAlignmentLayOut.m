//
//  DFCollectionViewAlignmentLayOut.m
//  DFCollectionViewAlignmentLayOut
//
//  Created by 全程恺 on 17/1/13.
//  Copyright © 2017年 全程恺. All rights reserved.
//

#import "DFCollectionViewAlignmentLayOut.h"

@interface DFCollectionViewAlignmentLayOut ()

// 所有的cell的布局
@property (nonatomic, strong) NSMutableArray<UICollectionViewLayoutAttributes *> *attrs;
// 记录位于最底部的视图rect的容器，即使有一点点在底部也要放进去，用于垂直方向上的布局判断
@property (retain, nonatomic) NSMutableArray *bottomRects;
@end

@implementation DFCollectionViewAlignmentLayOut

- (NSMutableArray *)bottomRects {
    if (!_bottomRects) {
        _bottomRects = [NSMutableArray array];
    }
    return _bottomRects;
}

- (NSMutableArray<UICollectionViewLayoutAttributes *> *)attrs {
    if (!_attrs) {
        _attrs = [NSMutableArray array];
    }
    return _attrs;
}

- (instancetype)initWithType:(DFCollectViewAlignType)type {
    if(self = [super init]) {
        _alignType = type;
    }
    return self;
}

- (void)setAlignType:(DFCollectViewAlignType)alignType {
    
    _alignType = alignType;
    if (self.collectionView) {
        [_bottomRects removeAllObjects];
        [self.collectionView reloadData];
    }
}

#pragma mark - 布局计算
// collectionView 首次布局和之后重新布局的时候会调用
// 并不是每次滑动都调用，只有在数据源变化的时候才调用
- (void)prepareLayout
{
    // 重写必须调用super方法
    [super prepareLayout];
    
    if ((_alignType & DFCollectViewAlignTop) == 0) {
        
    }
    else {
        
        // 遍历所有的cell，计算所有cell的布局
        NSInteger sections = [self evaluatedNumberOfSectionsInCollectionView:self.collectionView];
        if (self.bottomRects.count != sections) {
            [_bottomRects removeAllObjects];
            [_bottomRects addObjectsFromArray:@[[NSMutableArray array], [NSMutableArray array]]];
            [self.attrs removeAllObjects];
        }
        NSInteger numbersCell = 0;
        for (int i = 0; i < sections; i++) {
            numbersCell += [self evaluatedNumberOfItemsInSection:i];
        }
        for (NSInteger i = self.attrs.count; i < numbersCell; i++) {
            
            // 找到当前的section
            NSInteger row = i;
            NSInteger section = 0;
            NSInteger numbers = [self evaluatedNumberOfItemsInSection:section];
            
            // i必须要小于当前section的合集
            while (numbers <= i) {
                row -= numbers;
                numbers += [self evaluatedNumberOfItemsInSection:++section];
            }
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:row inSection:section];
            // 计算布局属性并将结果添加到布局属性数组中
            [self.attrs addObject:[self layoutAttributesForItemAtIndexPath:indexPath]];
        }
    }
}

#pragma mark - UICollectionViewLayout
- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    
    NSArray *layoutAttributes = [super layoutAttributesForElementsInRect:rect];
    NSMutableArray *updatedAttributes = [[NSMutableArray alloc] initWithArray:layoutAttributes copyItems:YES];
    
    NSInteger sections = [self evaluatedNumberOfSectionsInCollectionView:self.collectionView];
    
    if ((_alignType & DFCollectViewAlignTop) == 0) {
        
        for (int i = 0; i < sections; i ++) {
            
            CGFloat space = [self evaluatedMinimumInteritemSpacingForSectionAtIndex:i];
            UIEdgeInsets padding = [self evaluatedSectionInsetForItemAtIndex:i];
            
            // 水平布局，可以整行布局
            [self resizeHorizontalAlignmentAttributes:updatedAttributes edges:padding space:space];
        }
        
        return updatedAttributes;
    }
    else {
        
        // 垂直布局，需要一个个单独布局
        return self.attrs;
    }
}

// 计算水平布局的对齐方式
- (void)resizeHorizontalAlignmentAttributes:(NSMutableArray *)updatedAttributes edges:(UIEdgeInsets)edges space:(CGFloat)space {
    
    //可布局的最大right
    CGFloat maxRight = self.collectionView.frame.size.width - edges.right;
    //划分出来了行以后，就容易依照对齐方式布局
    NSMutableArray *lines = [NSMutableArray array];
    for (int i = 0; i < updatedAttributes.count; i++) {
        
        UICollectionViewLayoutAttributes *currentAttributes = updatedAttributes[i];
        NSMutableArray *line = [lines lastObject];
        if (!line) {
            
            line = [NSMutableArray arrayWithObject:currentAttributes];
            [lines addObject:line];
            continue;
        }
        
        //记录最右点的位置
        __block CGFloat sumWidth = edges.left;
        [line enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            UICollectionViewLayoutAttributes *attributes = obj;
            sumWidth += attributes.frame.size.width;
            
            sumWidth += space;
        }];
        
        /*  sumWidth
         *  | (leftPadding) xxxx (itemSpacing) xxxx (itemSpacing) .... (rightPadding) |
         */
        //判断是否要换行
        if (sumWidth + currentAttributes.frame.size.width <= maxRight &&
            currentAttributes.indexPath.row != 0) {
            
            [line addObject:currentAttributes];
        }
        else {
            
            [lines addObject:[NSMutableArray arrayWithObject:currentAttributes]];
        }
    }
    
    //起点位置
    CGFloat x = .0;
    for (int i = 0; i < lines.count; i++) {
        
        NSMutableArray *line = lines[i];
        
        __block CGFloat sumWidth = .0;
        [line enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            UICollectionViewLayoutAttributes *attributes = obj;
            sumWidth += attributes.frame.size.width;
        }];
        
        for (int j = 0; j < line.count; j++) {
            
            UICollectionViewLayoutAttributes *attributes = line[j];
            
            if (attributes.representedElementKind) {
                //当前不是cell的layout，忽略
                continue;
            }
            if (j == 0) {
                
                switch (_alignType) {
                    case DFCollectViewAlignLeft: {
                        //后续的布局参照第一个的布局，做一些数据初始化
                        x = [self evaluatedSectionInsetForItemAtIndex:[updatedAttributes indexOfObject:attributes]].left;
                    }
                        break;
                    case DFCollectViewAlignRight: {
                        //后续的布局参照第一个的布局，做一些数据初始化
                        x = maxRight - sumWidth - space * (line.count - 1);
                    }
                        break;
                    case DFCollectViewAlignMiddle: {
                        //后续的布局参照第一个的布局，做一些数据初始化
                        x = [self evaluatedSectionInsetForItemAtIndex:[updatedAttributes indexOfObject:attributes]].left;
                        if (line.count > 1) {
                            
                            space = (maxRight - edges.left - sumWidth) / (line.count - 1);
                        }
                    }
                        break;
                    default:
                        break;
                }
            }
            
            CGRect frame = attributes.frame;
            frame.origin.x = x;
            attributes.frame = frame;
            
            //设置下个对象的起始位置
            x += frame.size.width + space;
        }
    }
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes *currentAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    
    CGFloat space = [self evaluatedMinimumInteritemSpacingForSectionAtIndex:indexPath.section];
    UIEdgeInsets padding = [self evaluatedSectionInsetForItemAtIndex:indexPath.section];
    CGSize headerSize = [self evaluatedReferenceSizeForHeaderInSection:indexPath.section];
    
    CGFloat maxRight = self.collectionView.frame.size.width - padding.right;
    
    CGSize itemSize = [self evaluatedCollectionView:self.collectionView layout:self sizeForItemAtIndexPath:indexPath];
    
    if (currentAttributes.representedElementKind) {
        //当前不是cell的layout，忽略
        return currentAttributes;
    }
    
    // 首行铺满后，开始往下计算
    /* 俄罗斯方块的逻辑，找到空隙后插入
     找出底部视图最靠上的视图frame，记录这个frame的x，从bottom+space开始计算，比对宽度是否能够塞下当前的item：
     1、如果宽度超出可显示范围，寻找其次靠上的frame，重新进行比较
     2、如果宽度没超出可显示范围，但是和其他item重叠，则寻找其次靠上的frame，重新进行比较
     以此递归，直到找出空位能同时满足以上两个条件为止
     */
    
    // 排序出x轴的大小关系，从小到大排序
    NSMutableArray *bottomRects = _bottomRects[indexPath.section];
    NSArray *sortXArr = [bottomRects sortedArrayWithOptions:NSSortConcurrent usingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        
        CGRect rect1 = [obj1 CGRectValue];
        CGRect rect2 = [obj2 CGRectValue];
        CGFloat left1 = rect1.origin.x + rect1.size.width;
        CGFloat left2 = rect2.origin.x + rect2.size.width;
        if (left1 < left2) {
            return NSOrderedAscending;
        }
        else if (left1 > left2) {
            return NSOrderedDescending;
        }
        return NSOrderedSame;
    }];
    
    // 排序出y轴的大小关系，从小到大排序
    NSArray *sortYArr = [sortXArr sortedArrayUsingComparator:^NSComparisonResult(NSValue * _Nonnull obj1, NSValue * _Nonnull obj2) {
        
        CGRect rect1 = [obj1 CGRectValue];
        CGRect rect2 = [obj2 CGRectValue];
        CGFloat bottom1 = rect1.origin.y + rect1.size.height;
        CGFloat bottom2 = rect2.origin.y + rect2.size.height;
        if (bottom1 < bottom2) {
            return NSOrderedAscending;
        }
        else if (bottom1 > bottom2) {
            return NSOrderedDescending;
        }
        return NSOrderedSame;
    }];
    
    // link在一起的rect，不包括itemspace
    CGRect targetRect = CGRectZero;
    if (sortXArr.count) {
        CGRect rightRect = [[sortXArr lastObject] CGRectValue];
        if (maxRight - rightRect.origin.x - rightRect.size.width - space >= itemSize.width) {
            targetRect = CGRectMake(rightRect.origin.x + rightRect.size.width + space, padding.top + headerSize.height, itemSize.width, itemSize.height);
        }
    }
    else {
        targetRect = CGRectMake(padding.left, padding.top + headerSize.height, 0, 0);
    }
    if (CGRectEqualToRect(targetRect, CGRectZero)) {
        
        // 从上开始找，找到适合当前size的最宽的空隙
        for (int j = 0; j < sortYArr.count; j++) {
            
            CGRect jRect = [sortYArr[j] CGRectValue];
            targetRect = CGRectMake(jRect.origin.x, jRect.origin.y + jRect.size.height + space, 0, 0);
            
            // 找“附近”联姻宽度
            NSInteger xIndex = [sortXArr indexOfObject:sortYArr[j]];
            
            // 往左开始找顶端
            for (NSInteger z = xIndex - 1; z >= 0; z--) {
                
                CGRect zRect = [sortXArr[z] CGRectValue];
                if (zRect.origin.y + zRect.size.height + space > targetRect.origin.y + targetRect.size.height) {
                    // 如果左边的y比当前的jrect长，说明左侧到顶
                    CGFloat x = zRect.origin.x + zRect.size.width + space;
                    targetRect = CGRectMake(x, targetRect.origin.y, targetRect.origin.x + targetRect.size.width - x, targetRect.size.height);
                    break;
                }
                else if (z == 0) {
                    
                    // 屏幕最左
                    targetRect = CGRectMake(padding.left, targetRect.origin.y, targetRect.origin.x + targetRect.size.width - padding.left, targetRect.size.height);
                }
            }
            
            // 右侧开始找顶端
            if (xIndex == sortXArr.count - 1) {
                
                // 因为本身就是最右，不会进入循环，所以直接判断
                targetRect = CGRectMake(targetRect.origin.x, targetRect.origin.y, maxRight - targetRect.origin.x, targetRect.size.height);
            }
            else {
                
                for (NSInteger z = xIndex + 1; z < sortXArr.count; z++) {
                    
                    CGRect zRect = [sortXArr[z] CGRectValue];
                    if (zRect.origin.y + zRect.size.height + space > targetRect.origin.y + targetRect.size.height) {
                        
                        // 如果右边的y比当前的jrect长，说明右侧到顶
                        targetRect = CGRectMake(targetRect.origin.x, targetRect.origin.y, zRect.origin.x - targetRect.origin.x - space, targetRect.size.height);
                        break;
                    }
                    else if (z == sortXArr.count - 1) {
                        
                        // 屏幕最右
                        targetRect = CGRectMake(targetRect.origin.x, targetRect.origin.y, maxRight - targetRect.origin.x, targetRect.size.height);
                    }
                }
            }
            
            if (targetRect.size.width >= itemSize.width) {
                break;
            }
        }
    }
    
    targetRect.size = itemSize;
    
    // 重新整理bottomViews数组，拆分成一个个零散的view
    NSMutableIndexSet *removeSet = [NSMutableIndexSet indexSet];
    NSMutableArray *tempRects = [NSMutableArray array];
    for (int j = 0; j < bottomRects.count; j++) {
        
        CGRect currentRect = [bottomRects[j] CGRectValue];
        // 如果底部部分可见，就把可见部分单独拆出来
        // 左侧部分可见
        if (currentRect.origin.x < targetRect.origin.x &&
            currentRect.origin.x + currentRect.size.width >= targetRect.origin.x) {
            
            [tempRects addObject:[NSValue valueWithCGRect:CGRectMake(currentRect.origin.x, currentRect.origin.y, targetRect.origin.x - currentRect.origin.x, currentRect.size.height)]];
            [removeSet addIndex:j];
        }
        
        // 右侧部分可见
        if (currentRect.origin.x < targetRect.origin.x + targetRect.size.width &&
            currentRect.origin.x + currentRect.size.width > targetRect.origin.x + targetRect.size.width) {
            
            [tempRects addObject:[NSValue valueWithCGRect:CGRectMake(targetRect.origin.x + targetRect.size.width, currentRect.origin.y, currentRect.origin.x + currentRect.size.width - targetRect.origin.x - targetRect.size.width, currentRect.size.height)]];
            [removeSet addIndex:j];
        }
        
        // 全部不可见，整体移除
        if (currentRect.origin.x >= targetRect.origin.x &&
            currentRect.origin.x + currentRect.size.width <= targetRect.origin.x + targetRect.size.width) {
            [removeSet addIndex:j];
        }
    }
    [bottomRects removeObjectsAtIndexes:removeSet];
    [bottomRects addObjectsFromArray:tempRects];
    
    [bottomRects addObject:[NSValue valueWithCGRect:targetRect]];
    currentAttributes.frame = targetRect;
    
    // 返回计算获取的布局
    return currentAttributes;
}

// 返回collectionView的ContentSize
- (CGSize)collectionViewContentSize
{
    if ((_alignType & DFCollectViewAlignTop) == 0) {
        
        return [super collectionViewContentSize];
    }
    else {
        
        // collectionView的contentSize的高度等于所有列高度中最大的值
        CGFloat maxColumnHeight = 0;
        NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
        for (NSInteger i = 0; i < self.attrs.count; i++) {
            
            if (![indexSet containsIndex:self.attrs[i].indexPath.section]) {
                [indexSet addIndex:self.attrs[i].indexPath.section];
            }
            CGRect frame = self.attrs[i].frame;
            CGFloat bottom = frame.origin.y + frame.size.height;
            
            if (maxColumnHeight < bottom) {
                maxColumnHeight = bottom;
            }
        }
        __block CGFloat edges = 0;
        [indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
            
            CGSize headerSize = [self evaluatedReferenceSizeForHeaderInSection:idx];
            UIEdgeInsets sectionInsets = [self evaluatedSectionInsetForItemAtIndex:idx];
            edges += headerSize.height;
            edges += sectionInsets.top;
            edges += sectionInsets.bottom;
        }];
        return CGSizeMake(0, maxColumnHeight + edges);
    }
}

/**
 预估区块的数量

 @param collectionView 指定的父视图
 @return 指定区块的数量
 */
- (NSInteger)evaluatedNumberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    if ([self.collectionView.delegate respondsToSelector:@selector(numberOfSectionsInCollectionView:)]) {
        return [(id)self.collectionView.delegate numberOfSectionsInCollectionView:collectionView];
    }
    return 1;
}

/**
 预估区块的最小item间距

 @param sectionIndex 预估区块的section 下标
 @return CGFloat item间距
 */
- (CGFloat)evaluatedMinimumInteritemSpacingForSectionAtIndex:(NSInteger)sectionIndex {
    if ([self.collectionView.delegate respondsToSelector:@selector(collectionView:layout:minimumInteritemSpacingForSectionAtIndex:)]) {
        
        return [(id)self.collectionView.delegate collectionView:self.collectionView layout:self minimumInteritemSpacingForSectionAtIndex:sectionIndex];
    } else {
        return self.minimumInteritemSpacing;
    }
}

/**
 预估区块的内边距

 @param index 要预估的section
 @return UIEdgeInsets
 */
- (UIEdgeInsets)evaluatedSectionInsetForItemAtIndex:(NSInteger)index {
    if ([self.collectionView.delegate respondsToSelector:@selector(collectionView:layout:insetForSectionAtIndex:)]) {
        return [(id)self.collectionView.delegate collectionView:self.collectionView layout:self insetForSectionAtIndex:index];
    } else {
        return self.sectionInset;
    }
}

- (CGSize)evaluatedReferenceSizeForHeaderInSection:(NSInteger)section {
    
    if ([self.collectionView.delegate respondsToSelector:@selector(collectionView:layout:referenceSizeForHeaderInSection:)]) {
        return [(id)self.collectionView.delegate collectionView:self.collectionView layout:self referenceSizeForHeaderInSection:section];
    } else {
        return self.headerReferenceSize;
    }
}

- (NSInteger)evaluatedNumberOfItemsInSection:(NSInteger)section {
    
    if ([self.collectionView.delegate respondsToSelector:@selector(collectionView:numberOfItemsInSection:)]) {
        return [(id)self.collectionView.delegate collectionView:self.collectionView numberOfItemsInSection:section];
    } else {
        return 0;
    }
}

/**
 预估区块的最小行间距
 
 @param sectionIndex 预估区块的section 下标
 @return CGFloat 行间距
 */
- (CGFloat)evaluatedMinimumLineSpacingForSectionAtIndex:(NSInteger)sectionIndex {
    if ([self.collectionView.delegate respondsToSelector:@selector(collectionView:layout:minimumLineSpacingForSectionAtIndex:)]) {
        return [(id)self.collectionView.delegate collectionView:self.collectionView layout:self minimumLineSpacingForSectionAtIndex:sectionIndex];
    } else {
        return self.minimumLineSpacing;
    }
}

/**
 item的大小，用于垂直布局时宽高的计算

 @param collectionView 父视图
 @param collectionViewLayout 布局
 @param indexPath indexPath
 @return CGSize
 */
- (CGSize)evaluatedCollectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.collectionView.delegate respondsToSelector:@selector(collectionView:layout:sizeForItemAtIndexPath:)]) {
        return [(id)self.collectionView.delegate collectionView:collectionView layout:collectionViewLayout sizeForItemAtIndexPath:indexPath];
    }
    return self.itemSize;
}

@end
