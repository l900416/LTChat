//
//  LTChatKebaordFaceEmojiView.m
//  LTChatUI
//
//  Created by 梁通 on 2017/11/6.
//  Copyright © 2017年 梁通. All rights reserved.
//

#import "LTChatKebaordFaceEmojiView.h"
#import "LTChatKeyboardCollectionViewFlowLayout.h"
#import "LTChatKeyboardFaceEmojiCollectionViewCell.h"

@interface LTChatKebaordFaceEmojiView()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView* collectionView;
@property (nonatomic, strong) UIPageControl *pageControl;

@end
@implementation LTChatKebaordFaceEmojiView

static NSString* LTChatKeyboardFaceEmojiCollectionViewCellIdentifier = @"LTChatKeyboardFaceEmojiCollectionViewCellIdentifier";

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
    
    LTChatKeyboardCollectionViewFlowLayout *layout = [[LTChatKeyboardCollectionViewFlowLayout alloc] init];
    [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    self.collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.collectionView];
    [self.collectionView registerNib:[UINib nibWithNibName:@"LTChatKeyboardFaceEmojiCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:LTChatKeyboardFaceEmojiCollectionViewCellIdentifier];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.backgroundColor = LTChatKeyboardViewBackgroundColor;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    
    [self pinSubview:self.collectionView toEdge:NSLayoutAttributeTop withConstant:-2 * LTChatKeyboardPadding];//Top
    [self pinSubview:self.collectionView toEdge:NSLayoutAttributeLeading];//Leading
    [self pinSubview:self.collectionView toEdge:NSLayoutAttributeBottom withConstant:LTChatKeyboardPadding];//Bottom
    [self pinSubview:self.collectionView toEdge:NSLayoutAttributeTrailing];//Trailing
    
    _pageControl = [[UIPageControl alloc] init];
    _pageControl.translatesAutoresizingMaskIntoConstraints = NO;
    _pageControl.currentPage = 0;
    _pageControl.numberOfPages = 0;
    [self addSubview:_pageControl];
    [self pinSubview:self.pageControl toEdge:NSLayoutAttributeBottom withConstant:-2 * LTChatKeyboardPadding];//Bottom
    [self pinSubview:self.pageControl toEdge:NSLayoutAttributeCenterX];//Trailing
    _pageControl.currentPageIndicatorTintColor = [UIColor darkGrayColor];
    _pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    
//    _pageControl.hidden = YES;
}
#pragma mark - UICollectionViewFlowLayoutDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat collectionViewHeight = collectionView.frame.size.height;
    CGFloat cellHeiht = (collectionViewHeight) / kLTKeyboardFaceEmojiItem_ROW;
    CGFloat cellWidth = CGRectGetWidth(collectionView.frame) / kLTKeyboardFaceEmojiItem_COL;
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
    if ([self.delegate respondsToSelector:@selector(numberOfEmojis)]) {
        NSInteger count = [self.delegate numberOfEmojis];
        return count;
    }else{
        return 0;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath;{
    LTChatKeyboardFaceEmojiCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:LTChatKeyboardFaceEmojiCollectionViewCellIdentifier forIndexPath:indexPath];
    if ([self.delegate respondsToSelector:@selector(emojiAtIndex:)]) {
        cell.emojiStr = [self.delegate emojiAtIndex:indexPath.row];
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [collectionView deselectItemAtIndexPath:indexPath animated:true];
    if ([self.delegate respondsToSelector:@selector(didSelectedEmojiAtIndex:)]) {
        [self.delegate didSelectedEmojiAtIndex:indexPath.row];
    }
}

//- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
//    NSArray* visibleCells = [self.collectionView.indexPathsForVisibleItems sortedArrayUsingComparator:^NSComparisonResult(NSIndexPath* obj1, NSIndexPath* obj2) {
//        NSInteger row1 = obj1.row;
//        NSInteger row2 = obj2.row;
//        if (row1 >= row2) {
//            return NSOrderedDescending;
//        }
//        return NSOrderedAscending;
//    }];
//    NSInteger firstVisibleIndex =((NSIndexPath*)(visibleCells.firstObject)).row;
//    NSInteger countPerPage = kLTKeyboardFaceEmojiItem_ROW * kLTKeyboardFaceEmojiItem_COL;
//    NSInteger page = firstVisibleIndex / countPerPage;
//    self.pageControl.currentPage = page;
//
//    NSInteger index = page * countPerPage;
//    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:index inSection:0];
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
//    });
//}
//
//- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
//    if (!decelerate) {
//        NSArray* visibleCells = [self.collectionView.indexPathsForVisibleItems sortedArrayUsingComparator:^NSComparisonResult(NSIndexPath* obj1, NSIndexPath* obj2) {
//            NSInteger row1 = obj1.row;
//            NSInteger row2 = obj2.row;
//            if (row1 >= row2) {
//                return NSOrderedDescending;
//            }
//            return NSOrderedAscending;
//        }];
//        
//        NSInteger firstVisibleIndex =((NSIndexPath*)(visibleCells.firstObject)).row;
//        NSInteger countPerPage = kLTKeyboardFaceEmojiItem_ROW * kLTKeyboardFaceEmojiItem_COL;
//        NSInteger page = firstVisibleIndex / countPerPage;
//        self.pageControl.currentPage = page;
//        
//        NSInteger index = page * countPerPage;
//        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:index inSection:0];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
//        });
//    }
//}

#pragma mark - Action
-(void)reloadEmojis{
    NSInteger count = [self.delegate numberOfEmojis];
    self.pageControl.numberOfPages = count / (kLTKeyboardFaceEmojiItem_ROW * kLTKeyboardFaceEmojiItem_COL);
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
    [self.collectionView reloadData];
}
@end
