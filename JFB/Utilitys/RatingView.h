//
//  RatingView.h
//  RatingViewDemo
//
//  Created by Kevin on 14-8-11.
//  Copyright (c) 2014年 Kevin. All rights reserved.
//

typedef enum kRatingViewStyle
{
    kRatingViewStyleSmall   = 0,
    kRatingViewStyleNormal = 1
}kRatingViewStyle;

#import <UIKit/UIKit.h>

@interface RatingView : UIView
{
@private
    UIView *baseStarView;
    UILabel *ratingMarkLabel;
    
    NSMutableArray *grayStarsViewArray;
    NSMutableArray *yellowStarsViewArray;
}

@property (nonatomic) kRatingViewStyle style;
@property (nonatomic) NSInteger ratingScore;
@end
