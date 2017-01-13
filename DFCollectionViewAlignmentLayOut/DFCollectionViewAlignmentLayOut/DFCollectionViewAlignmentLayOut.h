//
//  DFCollectionViewAlignmentLayOut.h
//  DFCollectionViewAlignmentLayOut
//
//  Created by 全程恺 on 17/1/13.
//  Copyright © 2017年 全程恺. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, DFCollectViewAlignType) {
    DFCollectViewAlignLeft,
    DFCollectViewAlignMiddle,
    DFCollectViewAlignRight,
};

@interface DFCollectionViewAlignmentLayOut : UICollectionViewFlowLayout

@property (nonatomic, readonly) DFCollectViewAlignType alignType;

- (instancetype)initWithType:(DFCollectViewAlignType)type;

@end
