//
//  DFCollectionViewAlignmentLayOut.m
//  DFCollectionViewAlignmentLayOut
//
//  Created by 全程恺 on 17/1/13.
//  Copyright © 2017年 全程恺. All rights reserved.
//

#import "DFCollectionViewAlignmentLayOut.h"

@implementation DFCollectionViewAlignmentLayOut

- (instancetype)initWithType:(DFCollectViewAlignType)type {
    if(self = [super init]) {
        _alignType = type;
    }
    return self;
}

#pragma mark - UICollectionViewLayout
- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    
    NSArray *layoutAttributes = [super layoutAttributesForElementsInRect:rect];
    NSMutableArray *updatedAttributes = [[NSMutableArray alloc] initWithArray:layoutAttributes copyItems:YES];
    
    CGFloat space = [self evaluatedMinimumInteritemSpacingForSectionAtIndex:0];
    CGFloat leftPadding = [self evaluatedSectionInsetForItemAtIndex:0].left;
    CGFloat rightPadding = [self evaluatedSectionInsetForItemAtIndex:0].right;
    //可布局的最大right
    CGFloat maxRight = self.collectionView.frame.size.width - rightPadding;
    //把布局拆分到行
    NSMutableArray *lines = [self seperatorToLines:updatedAttributes edges:[self evaluatedSectionInsetForItemAtIndex:0] space:space maxWidth:maxRight];
    
    //起点位置
    CGFloat x = .0;
    CGFloat y = .0;
    //划分出来了行以后，就容易依照对齐方式布局
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
                            
                            space = (maxRight - leftPadding - sumWidth) / (line.count - 1);
                        }
                    }
                        break;
                    default:
                        break;
                }
                //首行的起始位置
                if (i == 0) {
                    y = attributes.frame.origin.y;
                }
            }
            
            CGRect frame = attributes.frame;
            frame.origin.x = x;
            frame.origin.y = y;
            attributes.frame = frame;
            
            //设置下个对象的起始位置
            x += frame.size.width + space;
            if (j == line.count - 1) {
                
                y = attributes.frame.origin.y + attributes.size.height + [self evaluatedMinimumLineSpacingForSectionAtIndex:[updatedAttributes indexOfObject:attributes]];
            }
        }
    }
    
    return updatedAttributes;
}

- (NSMutableArray *)seperatorToLines:(NSMutableArray *)attributes edges:(UIEdgeInsets)edges space:(CGFloat)space maxWidth:(CGFloat)maxRight {
    
    NSMutableArray *lines = [NSMutableArray array];
    for (int i = 0; i < attributes.count; i++) {
        
        UICollectionViewLayoutAttributes *currentAttributes = attributes[i];
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
        if (sumWidth + currentAttributes.frame.size.width <= maxRight) {
            
            [line addObject:currentAttributes];
        }
        else {
            
            [lines addObject:[NSMutableArray arrayWithObject:currentAttributes]];
        }
    }
    return lines;
}

- (CGFloat)evaluatedMinimumInteritemSpacingForSectionAtIndex:(NSInteger)sectionIndex {
    if ([self.collectionView.delegate respondsToSelector:@selector(collectionView:layout:minimumInteritemSpacingForSectionAtIndex:)]) {
        
        return [(id)self.collectionView.delegate collectionView:self.collectionView layout:self minimumInteritemSpacingForSectionAtIndex:sectionIndex];
    } else {
        return self.minimumInteritemSpacing;
    }
}

- (CGFloat)evaluatedMinimumLineSpacingForSectionAtIndex:(NSInteger)sectionIndex {
    if ([self.collectionView.delegate respondsToSelector:@selector(collectionView:layout:minimumLineSpacingForSectionAtIndex:)]) {
        
        return [(id)self.collectionView.delegate collectionView:self.collectionView layout:self minimumLineSpacingForSectionAtIndex:sectionIndex];
    } else {
        return self.minimumLineSpacing;
    }
}

- (UIEdgeInsets)evaluatedSectionInsetForItemAtIndex:(NSInteger)index {
    if ([self.collectionView.delegate respondsToSelector:@selector(collectionView:layout:insetForSectionAtIndex:)]) {
        
        return [(id)self.collectionView.delegate collectionView:self.collectionView layout:self insetForSectionAtIndex:index];
    } else {
        return self.sectionInset;
    }
}

@end
