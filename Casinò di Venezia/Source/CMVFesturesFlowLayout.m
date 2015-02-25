//
//  CMVFesturesFlowLayout.m
//  Casinò di Venezia
//
//  Created by Massimo Moro on 14/12/13.
//  Copyright (c) 2013 Casinò di Venezia SPA. All rights reserved.
//

#import "CMVFesturesFlowLayout.h"

@implementation CMVFesturesFlowLayout

- (BOOL) shouldInvalidateLayoutForBoundsChange: (CGRect) oldBounds
{
    return YES;
}

-(void) prepareLayout
{
    [super prepareLayout];
    
    boundsSize = self.collectionView.bounds.size;
    midX = boundsSize.width / 2.0f;
}

//- (NSArray *) layoutAttributesForElementsInRect: (CGRect) rect
//{
//    NSArray *array = [super layoutAttributesForElementsInRect:rect];
//    
//    for (UICollectionViewLayoutAttributes* attributes in array)
//    {
//        attributes.transform3D = CATransform3DIdentity;
//        if (!CGRectIntersectsRect(attributes.frame, rect)) continue;
//        
//        CGPoint contentOffset = self.collectionView.contentOffset;
//        CGPoint itemCenter = CGPointMake(attributes.center.x - contentOffset.x, attributes.center.y - contentOffset.y);
//        
//        CGFloat distance = ABS(midX - itemCenter.x);
//        CGFloat normalized = distance / midX;
//        normalized = MIN(1.0f, normalized);
//        CGFloat zoom = cos(normalized * M_PI_4);
//        
//        // attributes.zIndex = 1;
//        attributes.transform3D = CATransform3DMakeScale(zoom, zoom, 1.0f);
//    }
//    
//    return array;
//}

- (CGPoint) targetContentOffsetForProposedContentOffset: (CGPoint) proposedContentOffset withScrollingVelocity: (CGPoint) velocity
{
    CGFloat offsetAdjustment = MAXFLOAT;
    
    // Retrieve all onscreen items at the proposed starting point
    CGRect targetRect = CGRectMake(proposedContentOffset.x, 0.0, boundsSize.width, boundsSize.height);
    NSArray *array = [super layoutAttributesForElementsInRect:targetRect];
    
    // Determine the proposed center x-coordinate
    CGFloat proposedCenterX = proposedContentOffset.x + midX;
    
    // Search for the minimum offset adjustment
    for (UICollectionViewLayoutAttributes* layoutAttributes in array)
    {
        CGFloat distance = layoutAttributes.center.x - proposedCenterX;
        if (ABS(distance) < ABS(offsetAdjustment))
            offsetAdjustment = distance;
    }
    
    CGPoint desiredPoint = CGPointMake(proposedContentOffset.x + offsetAdjustment, proposedContentOffset.y);
    
    if ((proposedContentOffset.x == 0) || (proposedContentOffset.x >= (self.collectionViewContentSize.width - boundsSize.width)))
    {
        NSNotification *note = [NSNotification notificationWithName:@"PleaseRecenter" object:[NSValue valueWithCGPoint:desiredPoint]];
        [[NSNotificationCenter defaultCenter] postNotification:note];
        return proposedContentOffset;
    }
    
    // Offset the content by the minimal centering
    return desiredPoint;
}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset {
    CGFloat offsetAdjustment = MAXFLOAT;
    
    // Retrieve all onscreen items at the proposed starting point
    CGRect targetRect = CGRectMake(proposedContentOffset.x, 0.0, boundsSize.width, boundsSize.height);
    NSArray *array = [super layoutAttributesForElementsInRect:targetRect];
    
    // Determine the proposed center x-coordinate
    CGFloat proposedCenterX = proposedContentOffset.x + midX;
    
    // Search for the minimum offset adjustment
    for (UICollectionViewLayoutAttributes* layoutAttributes in array)
    {
        CGFloat distance = layoutAttributes.center.x - proposedCenterX;
        if (ABS(distance) < ABS(offsetAdjustment))
            offsetAdjustment = distance;
    }
    
    CGPoint desiredPoint = CGPointMake(proposedContentOffset.x + offsetAdjustment, proposedContentOffset.y);
    
    if ((proposedContentOffset.x == 0) || (proposedContentOffset.x >= (self.collectionViewContentSize.width - boundsSize.width)))
    {
        NSNotification *note = [NSNotification notificationWithName:@"PleaseRecenter" object:[NSValue valueWithCGPoint:desiredPoint]];
        [[NSNotificationCenter defaultCenter] postNotification:note];
        return proposedContentOffset;
    }
    
    // Offset the content by the minimal centering
    return desiredPoint;
}

@end
