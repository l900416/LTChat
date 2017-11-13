//
//  LTChatKeyboardFaceView.m
//  LTChatUI
//
//  Created by 梁通 on 2017/11/6.
//  Copyright © 2017年 梁通. All rights reserved.
//

#import "LTChatKeyboardFaceView.h"
#import "LTChatKebaordFaceEmojiView.h"
#import "LTChatKeyboardFaceEmojiCollectionViewCell.h"

@interface LTChatKeyboardFaceView()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,LTChatKeyboardFaceEmojiViewDelegate>

@property (nonatomic, strong) NSMutableArray* faceDataSource;

//表情键盘
@property (nonatomic, strong) LTChatKebaordFaceEmojiView* emojiView;
@property (nonatomic, strong) NSDictionary* emojiDic;

//下方滚动工具栏
@property (nonatomic, strong) UICollectionView* collectionView;



@property (nonatomic, assign) NSInteger selectedIndex;

@end

@implementation LTChatKeyboardFaceView

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
    
    //数据源
    [self dataSourceInit];

    //上半部分的表情键盘区域
    self.emojiView = [[LTChatKebaordFaceEmojiView alloc] init];
    self.emojiView.delegate = self;
    [self addSubview:self.emojiView];
    [self pinSubview:self.emojiView toEdge:NSLayoutAttributeTop];//Top
    [self pinSubview:self.emojiView toEdge:NSLayoutAttributeLeading withConstant:-LTChatKeyboardPadding];//Leading
    [self pinSubview:self.emojiView toEdge:NSLayoutAttributeBottom withConstant:LTChatKeyboardPadding + LTChatKeyboardFaceViewToolHeight];//Bottom
    [self pinSubview:self.emojiView toEdge:NSLayoutAttributeTrailing withConstant:LTChatKeyboardPadding];//Trailing
    
    
    //下部分的表情键盘控制区
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    self.collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.collectionView];
    [self.collectionView registerNib:[UINib nibWithNibName:@"LTChatKeyboardFaceEmojiCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:LTChatKeyboardFaceEmojiCollectionViewCellIdentifier];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.showsHorizontalScrollIndicator = NO;
    
    [self pinSubview:self.collectionView toEdge:NSLayoutAttributeLeading];//Leading
    [self pinSubview:self.collectionView toEdge:NSLayoutAttributeBottom];//Bottom
    [self pinSubview:self.collectionView toEdge:NSLayoutAttributeTrailing];//Trailing
    [self pinSubview:self.collectionView withAttribute:NSLayoutAttributeHeight constant:LTChatKeyboardFaceViewToolHeight];//height
    
    _selectedIndex = 0;
    [self.emojiView reloadEmojis];//初始化更新表情键盘
    
}
#pragma mark - UICollectionViewFlowLayoutDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(LTChatKeyboardFaceViewToolHeight * 1.3, LTChatKeyboardFaceViewToolHeight);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 1;
}

#pragma mark - UICollectionView data source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section{
    return [_faceDataSource count];
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath;{
    LTChatKeyboardFaceEmojiCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:LTChatKeyboardFaceEmojiCollectionViewCellIdentifier forIndexPath:indexPath];
    
    if(indexPath.row == 0){
        cell.emojiStr = [_emojiDic objectForKey:@"cover"];
    }else if(indexPath.row == 1){
        cell.emojiStr = @"+";
    }else{
        cell.emojiStr = @"";
    }
    cell.contentView.backgroundColor = [UIColor whiteColor];
    
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [collectionView deselectItemAtIndexPath:indexPath animated:true];
    _selectedIndex = indexPath.row;
    [self.emojiView reloadEmojis];

}

#pragma mark LTChatKeyboardFaceEmojiViewDelegate
-(NSInteger)numberOfEmojis{
    NSInteger allCount = [[_emojiDic objectForKey:@"emoji"] count];
    NSInteger countPerPage = kLTKeyboardFaceEmojiItem_ROW * kLTKeyboardFaceEmojiItem_COL;
    NSInteger number = (allCount / countPerPage + 1) * countPerPage;
    return number;
    
}
-(NSString*)emojiAtIndex:(NSInteger)index{
    
    NSInteger countPerPage = kLTKeyboardFaceEmojiItem_ROW * kLTKeyboardFaceEmojiItem_COL;
    NSInteger page = index / countPerPage;
    
    NSInteger row = index % countPerPage % kLTKeyboardFaceEmojiItem_ROW;
    NSInteger col = index % countPerPage / kLTKeyboardFaceEmojiItem_ROW;
    NSInteger allCount = [[_emojiDic objectForKey:@"emoji"] count];
    NSInteger dIndex = page * countPerPage + (row * kLTKeyboardFaceEmojiItem_COL + col);
    if (dIndex >= allCount) {
        return nil;
    }else{
        return [[_emojiDic objectForKey:@"emoji"] objectAtIndex:dIndex];
    }
}
-(void)didSelectedEmojiAtIndex:(NSInteger)index{
    
}


#pragma mark - Private - DataSource
-(void)dataSourceInit{
    _faceDataSource = [[NSMutableArray alloc] init];
    //表情键盘数据相关
    NSURL *emojiPlistURL = [[NSBundle mainBundle] URLForResource:@"LTChatUI.bundle/LTChatEmoji" withExtension:@"plist"];
    _emojiDic = [NSDictionary dictionaryWithContentsOfURL:emojiPlistURL];
    if(_emojiDic){
        [_faceDataSource addObject:_emojiDic];
    }
    
    //占位符
    [_faceDataSource addObject:@"占位"];
}

@end
