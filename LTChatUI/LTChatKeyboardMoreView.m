//
//  LTChatKeyboardMoreView.m
//  LTChatUI
//
//  Created by 梁通 on 2017/10/23.
//  Copyright © 2017年 梁通. All rights reserved.
//

#import "LTChatKeyboardMoreView.h"
#import "LTChatKeyboardMoreCollectionViewCell.h"

@interface LTChatKeyboardMoreView()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView* collectionView;

@property (nonatomic, strong) UIPageControl *pageControl;
@end

@implementation LTChatKeyboardMoreView

static NSString* LTChatKeyboardMoreCollectionViewCellIdentifier = @"LTChatKeyboardMoreCollectionViewCellIdentifier";


#pragma mark - initialization
-(instancetype)init{
    self = [super init];
    if (self) {
        [self setupInitialization];
    }
    return self;
}
//-(instancetype)initWithFrame:(CGRect)frame{
//    self = [super initWithFrame:frame];
//    if (self) {
//        [self setupInitialization];
//    }
//    return self;
//}
//-(instancetype)initWithCoder:(NSCoder *)aDecoder{
//    self = [super initWithCoder:aDecoder];
//    if (self) {
//        [self setupInitialization];
//    }
//    return self;
//}

-(void)setupInitialization{
    self.translatesAutoresizingMaskIntoConstraints = NO;
    self.backgroundColor = LTChatKeyboardViewBackgroundColor;
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    self.collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.collectionView];
    [self.collectionView registerNib:[UINib nibWithNibName:@"LTChatKeyboardMoreCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:LTChatKeyboardMoreCollectionViewCellIdentifier];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.showsHorizontalScrollIndicator = NO;
    
    [self pinSubview:self.collectionView toEdge:NSLayoutAttributeTop];//Top
    [self pinSubview:self.collectionView toEdge:NSLayoutAttributeLeading];//Leading
    [self pinSubview:self.collectionView toEdge:NSLayoutAttributeBottom withConstant:LTChatKeyboardPadding * 3];//Bottom
    [self pinSubview:self.collectionView toEdge:NSLayoutAttributeTrailing];//Trailing
    
    _pageControl = [[UIPageControl alloc] init];
    _pageControl.translatesAutoresizingMaskIntoConstraints = NO;
    _pageControl.currentPage = 1;
    _pageControl.numberOfPages = 2;
    [self addSubview:_pageControl];
    [self pinSubview:self.pageControl toEdge:NSLayoutAttributeBottom withConstant:0];//Bottom
    [self pinSubview:self.pageControl toEdge:NSLayoutAttributeCenterX];//Trailing
    _pageControl.currentPageIndicatorTintColor = [UIColor darkGrayColor];
    _pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
}
#pragma mark - UICollectionViewFlowLayoutDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat collectionViewWidth = collectionView.frame.size.width;
    CGFloat cellWidth = collectionViewWidth / kLTKeyboardMoreItem_COL;
    CGFloat cellHeiht = (LTChatKeyboardMoreViewHeight - LTChatKeyboardPadding * 3) / kLTKeyboardMoreItem_ROW;
    return CGSizeMake(cellWidth, cellHeiht);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 0;
}

#pragma mark - UICollectionView data source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section{
    NSInteger number =  [self.delegate numberOfItems];
    _pageControl.numberOfPages = number / (kLTKeyboardMoreItem_COL * kLTKeyboardMoreItem_ROW);
    return number;
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath;{
    LTChatKeyboardMoreCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:LTChatKeyboardMoreCollectionViewCellIdentifier forIndexPath:indexPath];
    NSDictionary* item = [self.delegate itemAtIndex:indexPath.row];
    cell.item = item;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [collectionView deselectItemAtIndexPath:indexPath animated:true];
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectedAtIndex:)]) {
        [self.delegate didSelectedAtIndex:indexPath.row];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    //获取最新的CollectionViewCell
    int page = (int)(scrollView.contentOffset.x / scrollView.frame.size.width + 0.5) % 5;
    self.pageControl.currentPage = page;
    
    NSInteger index = page * kLTKeyboardMoreItem_ROW * kLTKeyboardMoreItem_COL;
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
    });
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (!decelerate) {
        int page = (int)(scrollView.contentOffset.x / scrollView.frame.size.width + 0.5) % 5;
        self.pageControl.currentPage = page;
        
        NSInteger index = page * kLTKeyboardMoreItem_ROW * kLTKeyboardMoreItem_COL;
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
        });
    }
}

@end
