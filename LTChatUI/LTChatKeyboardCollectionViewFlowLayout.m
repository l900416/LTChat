//
//  LTChatKeyboardCollectionViewFlowLayout.m
//  LTChatUI
//
//  Created by 梁通 on 2017/11/13.
//  Copyright © 2017年 梁通. All rights reserved.
//

#import "LTChatKeyboardCollectionViewFlowLayout.h"

@implementation LTChatKeyboardCollectionViewFlowLayout

-(instancetype)init{
    self = [super init];
    if(self){
        
    }
    return self;
}

#pragma mark - Pagination
- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity{
    
    CGRect targetRect = CGRectMake(proposedContentOffset.x, 0, self.collectionView.bounds.size.width, self.collectionView.bounds.size.height);
    
    NSArray *array = [[super layoutAttributesForElementsInRect:targetRect] sortedArrayUsingComparator:^NSComparisonResult(UICollectionViewLayoutAttributes* obj1, UICollectionViewLayoutAttributes* obj2) {
                    NSInteger row1 = obj1.indexPath.row;
                    NSInteger row2 = obj2.indexPath.row;
                    if (row1 >= row2) {
                        return NSOrderedDescending;
                    }
                    return NSOrderedAscending;
                }];
    
    UICollectionViewLayoutAttributes* centerObj = [array objectAtIndex:array.count / 2 - 1];
    
    CGFloat offsetX = ((int)(centerObj.frame.origin.x / CGRectGetWidth(self.collectionView.frame))) * CGRectGetWidth(self.collectionView.frame);
    
    CGPoint targetOffset = CGPointMake(offsetX, proposedContentOffset.y);
    
    NSLog(@"velocity:(%.2f,%.2f)",velocity.x,velocity.y);
    NSLog(@"targetOffset:(%.f,%.f)",targetOffset.x,targetOffset.y);
    
    return targetOffset;
}

@end
