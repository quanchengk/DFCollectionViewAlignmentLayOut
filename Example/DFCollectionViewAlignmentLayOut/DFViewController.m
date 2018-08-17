//
//  DFViewController.m
//  DFCollectionViewAlignmentLayOut
//
//  Created by acct<blob>=0xE585A8E7A88BE681BA on 12/19/2017.
//  Copyright (c) 2017 acct<blob>=0xE585A8E7A88BE681BA. All rights reserved.
//

#import "DFViewController.h"
#import <DFCollectionViewAlignmentLayOut/DFCollectionViewAlignmentLayOut.h>

@interface DFViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (retain, nonatomic) UICollectionView *collectionView;
@property (retain, nonatomic) NSMutableArray *itemSizes;
@end

@implementation DFViewController

- (UICollectionView *)collectionView {
    
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:[[DFCollectionViewAlignmentLayOut alloc] initWithType:DFCollectViewAlignLeft]];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.alwaysBounceVertical = YES;
        [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"UICollectionViewCell"];
        [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"UICollectionReusableView"];
    }
    return _collectionView;
}

- (NSMutableArray *)itemSizes {
    
    if (!_itemSizes) {
        _itemSizes = [NSMutableArray array];
        for (int i = 0; i < 30; i++) {
            
            CGFloat height = 40;
//            height = arc4random() % 160 + 5;
            CGFloat width = 80;
            width = arc4random() % 120 + 5;
            [self.itemSizes addObject:[NSValue valueWithCGSize:CGSizeMake(width, height)]];
        }
    }
    return _itemSizes;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    // Do any additional setup after loading the view, typically from a nib.self.view.backgroundColor = [UIColor whiteColor];
    for (int i = 0; i < 4; i++) {
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        [btn addTarget:self action:@selector(modifyCount:) forControlEvents:UIControlEventTouchUpInside];
        btn.tag = i;
        btn.frame = CGRectMake(i * 80 + 15, 20, 60, 40);
        
        switch (i) {
            case 0:
                [btn setTitle:@"左" forState:UIControlStateNormal];
                [btn sendActionsForControlEvents:UIControlEventTouchUpInside];
                break;
            case 1:
                [btn setTitle:@"中" forState:UIControlStateNormal];
                break;
            case 2:
                [btn setTitle:@"右" forState:UIControlStateNormal];
                break;
            case 3:
                [btn setTitle:@"上" forState:UIControlStateNormal];
                break;
                
            default:
                break;
        }
        [self.view addSubview:btn];
    }
    
    [self.view addSubview:self.collectionView];
    self.collectionView.frame = CGRectMake(0, 20 + 40, self.view.frame.size.width, self.view.frame.size.height - 20 - 40);
}

- (void)modifyCount:(UIButton *)btn {
    
    [self.view.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if ([obj isKindOfClass:[UIButton class]]) {
            
            ((UIButton *)obj).selected = NO;
        }
    }];
    
    btn.selected = YES;
    
    DFCollectionViewAlignmentLayOut *layout = (DFCollectionViewAlignmentLayOut *)self.collectionView.collectionViewLayout;
    if (!layout || ![layout isKindOfClass:[DFCollectionViewAlignmentLayOut class]]) {
        layout = [[DFCollectionViewAlignmentLayOut alloc] initWithType:DFCollectViewAlignLeft];
        self.collectionView.collectionViewLayout = layout;
    }
    
//    _itemSizes = nil;
    switch (btn.tag) {
        case 0:
            layout.alignType = DFCollectViewAlignLeft;
            break;
        case 1:
            layout.alignType = DFCollectViewAlignMiddle;
            break;
        case 2:
            layout.alignType = DFCollectViewAlignRight;
            break;
        case 3:
            layout.alignType = DFCollectViewAlignTop;
            break;
        default:
            break;
    }
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.itemSizes.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"UICollectionViewCell" forIndexPath:indexPath];
    
    cell.backgroundColor = indexPath.row % 2 ? [UIColor redColor] : [UIColor greenColor];
    UILabel *label = [cell viewWithTag:1];
    if (!label) {
        
        label = [[UILabel alloc] initWithFrame:CGRectMake(15, 8, self.view.frame.size.width - 30, 22)];
        label.tag = 1;
        [cell addSubview:label];
    }
    label.text = [NSString stringWithFormat:@"%ld", (long)indexPath.row];
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        UICollectionReusableView *header = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"UICollectionReusableView" forIndexPath:indexPath];
        UILabel *label = [header viewWithTag:1];
        if (!label) {
            
            label = [[UILabel alloc] initWithFrame:CGRectMake(15, 8, self.view.frame.size.width - 30, 22)];
            label.tag = 1;
            [header addSubview:label];
        }
        label.text = [NSString stringWithFormat:@"section header %ld", (long)indexPath.section];
        return header;
    }
    return nil;
}

#pragma mark -- UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return [self.itemSizes[indexPath.row] CGSizeValue];
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    
    return UIEdgeInsetsMake(15, 15, 15, 15);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(nonnull UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    
    return 10;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(nonnull UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    
    return 5;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    
    return CGSizeMake(self.view.frame.size.width, 0);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
