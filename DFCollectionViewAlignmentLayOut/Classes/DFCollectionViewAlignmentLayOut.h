/*!
 @header DFCollectionViewAlignmentLayOut.h
 @abstract Collection View 对齐类
 @author Created by 全程恺 on 2017/1/22
 @version 0.2.3
 Copyright © 2018年 danfort. All rights reserved.
 */

#import <UIKit/UIKit.h>

/*!
 @brief 定义对齐样式的枚举，仅支持垂直、水平交差的同时传递，目前仅支持上下滚动的布局
 */
typedef NS_ENUM(NSInteger, DFCollectViewAlignType) {
    /*! 居左对齐 */
    DFCollectViewAlignLeft = 1 << 0,
    /*! 居中对齐 */
    DFCollectViewAlignMiddle = 1 << 1,
    /*! 居右对齐 */
    DFCollectViewAlignRight = 1 << 2,
    /*! 居上对齐、流水布局，要求section必须为1，且只能垂直滑动，不支持header/footer */
    DFCollectViewAlignTop = 1 << 3,
};

/*!
 @abstract 由于原生控件的对齐方式不尽人意，只有居左的对齐样式，并且当多行时，最后一行居左，其余行居中，经常被测试人员当做bug反馈，所以提供了这个定义对齐方式的类，来填补系统控件的不足
 */
@interface DFCollectionViewAlignmentLayOut : UICollectionViewFlowLayout

/*!
 @abstract 当前的对齐样式，可读写
 
 @code
 
 DFCollectionViewAlignmentLayOut *layout = self.collectionView.collectionViewLayout;
 
 if (!layout || ![layout isKindOfClass:[DFCollectionViewAlignmentLayOut class]]) {
 layout = [[DFCollectionViewAlignmentLayOut alloc] initWithType:DFCollectViewAlignLeft];
 self.collectionView.collectionViewLayout = layout;
 }
 layout.alignType = DFCollectViewAlignLeft;
 @endcode
 */
@property (nonatomic, assign) DFCollectViewAlignType alignType;

/*!
 @abstract 初始化
 @discussion 定义CollectionView的布局样式，目前提供左、中、右三种方式，默认居左
 @param type 样式，参考枚举定义
 @result 当前的实例，可直接赋值给collectionView.collectionViewLayout
 @code
 collectionView.collectionViewLayout = [[DFCollectionViewAlignmentLayOut alloc] initWithType:DFCollectViewAlignLeft | DFCollectViewAlignTop];
 @endcode
 */
- (instancetype)initWithType:(DFCollectViewAlignType)type;

@end
