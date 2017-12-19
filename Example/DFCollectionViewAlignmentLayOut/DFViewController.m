//
//  DFViewController.m
//  DFCollectionViewAlignmentLayOut
//
//  Created by acct<blob>=0xE585A8E7A88BE681BA on 12/19/2017.
//  Copyright (c) 2017 acct<blob>=0xE585A8E7A88BE681BA. All rights reserved.
//

#import "DFViewController.h"
#import <DFCollectionViewAlignmentLayOut/DFCollectionViewAlignmentLayOut.h>

@interface DFViewController () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (retain, nonatomic) UICollectionView *collectionView;

@end

@implementation DFViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.self.view.backgroundColor = [UIColor whiteColor];
    for (int i = 0; i < 3; i++) {
        
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
    
    switch (btn.tag) {
            case 0:
            self.collectionView.collectionViewLayout = [[DFCollectionViewAlignmentLayOut alloc] initWithType:DFCollectViewAlignLeft];
            break;
            case 1:
            self.collectionView.collectionViewLayout = [[DFCollectionViewAlignmentLayOut alloc] initWithType:DFCollectViewAlignMiddle];
            break;
            case 2:
            self.collectionView.collectionViewLayout = [[DFCollectionViewAlignmentLayOut alloc] initWithType:DFCollectViewAlignRight];
            break;
        default:
            break;
    }
    
    [self.collectionView reloadData];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return 30;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"UICollectionViewCell" forIndexPath:indexPath];
    
    cell.backgroundColor = indexPath.row % 2 ? [UIColor redColor] : [UIColor greenColor];
    return cell;
}

#pragma mark -- UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(arc4random() % 160 + 5, 40);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    
    return UIEdgeInsetsMake(15, 15, 15, 15);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(nonnull UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    
    return 30;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(nonnull UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    
    return 5;
}

- (UICollectionView *)collectionView {
    
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:[[DFCollectionViewAlignmentLayOut alloc] initWithType:DFCollectViewAlignLeft]];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.alwaysBounceVertical = YES;
        [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"UICollectionViewCell"];
    }
    return _collectionView;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
