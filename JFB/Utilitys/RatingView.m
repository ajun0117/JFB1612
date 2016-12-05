//
//  RatingView.m
//  RatingViewDemo
//
//  Created by Kevin on 14-8-11.
//  Copyright (c) 2014年 Kevin. All rights reserved.
//

#define kStyleSmallHeight   14                                                   //小星星高度
#define kStyleSmallWidth    15                                                   //小星星宽度

#define kStyleNormalHeight  25                                                  //大星星高度
#define kStyleNormalWidth   25                                                  //大星星宽度

#define kNumberOfStars        5                                                  //星星个数
#define kFullMarkScore          5                                                  //评级满分
#define kAverageStarScore   kFullMarkScore/kNumberOfStars      //一个星星的分数

#import "RatingView.h"
#import "UITapTagGestureRecognizer.h"

@implementation RatingView

@synthesize style;
@synthesize ratingScore;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initializeGrayStarView];
        [self initializeYellowStarView];
        [self initializeRatingLabel];
    }
    return self;
}

#pragma mark -
#pragma mark - UserInterface initialization

/**
 *  初始化灰色星星
 */
- (void)initializeGrayStarView
{
    grayStarsViewArray = [[NSMutableArray alloc] initWithCapacity:kNumberOfStars];
    
    for (int index = 0; index < kNumberOfStars; index++)
    {
        UIImageView *grayStarView = [[UIImageView alloc] initWithFrame:CGRectZero];
      
        UITapTagGestureRecognizer *singleTap = [[UITapTagGestureRecognizer alloc] initWithTarget:self action:@selector(yellowOrGrayStarViewTapped:)];
        
        singleTap.tag = index;
        
        grayStarView.image = [UIImage imageNamed:@"people_star_03"];
        [grayStarView setUserInteractionEnabled:YES];
        [grayStarView addGestureRecognizer:singleTap];
        
        [self addSubview:grayStarView];
        
        [grayStarsViewArray addObject:grayStarView];
    }
}

/**
 *  初始化黄色星星
 */
- (void)initializeYellowStarView
{
    baseStarView = [[UIView alloc] initWithFrame:CGRectZero];
    baseStarView.clipsToBounds = YES;
    
    yellowStarsViewArray = [[NSMutableArray alloc] initWithCapacity:kNumberOfStars];

    for (int index = 0; index < kNumberOfStars; index ++)
    {
        UIImageView *yellowStarView = [[UIImageView alloc] initWithFrame:CGRectZero];
       
        UITapTagGestureRecognizer *singleTap = [[UITapTagGestureRecognizer alloc] initWithTarget:self action:@selector(yellowOrGrayStarViewTapped:)];
        
        singleTap.tag = index;
        
        yellowStarView.image = [UIImage imageNamed:@"people_star"];
        [yellowStarView setUserInteractionEnabled:YES];
        [yellowStarView addGestureRecognizer:singleTap];
        
        [baseStarView addSubview:yellowStarView];
        
        [yellowStarsViewArray addObject:yellowStarView];
    }

    [self addSubview:baseStarView];
}

/**
 *  初始化评分Label
 */
- (void)initializeRatingLabel
{
    ratingMarkLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    
    ratingMarkLabel.backgroundColor = [UIColor clearColor];
    //不添加label，不在后面显示当前星级
//    [self addSubview:ratingMarkLabel];
}

#pragma mark -
#pragma mark - Trigger Method

/**
 *  改变评级分数
 *
 *  @param sender 事件发起者
 */
- (void)yellowOrGrayStarViewTapped:(UITapTagGestureRecognizer *)sender
{
    switch (sender.tag)
    {
        case 0:
            self.ratingScore = (sender.tag + 1) * kAverageStarScore;
            break;
        case 1:
            self.ratingScore = 2;
            break;
        case 2:
            self.ratingScore = 3;
            break;
        case 3:
            self.ratingScore = 4;
            break;
        case 4:
            self.ratingScore = 5;
            break;
        default:
            break;
    }
    [self layoutSubviews];
}

#pragma mark -
#pragma mark - UserInterface Layout

/**
 *  界面布局定制
 */
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat baseViewWidth = 0;
    CGFloat baseViewHeight = 0;
    CGFloat widthX = 0;
        
    if (self.style == kRatingViewStyleSmall)
    {
        for (int index = 0; index < kNumberOfStars; index ++)
        {
            UIView *garyStar = grayStarsViewArray[index];
            UIView *yellowStar = yellowStarsViewArray[index];
        
            garyStar.frame = CGRectMake(widthX, 0, kStyleSmallWidth, kStyleSmallHeight);
            yellowStar.frame = CGRectMake(widthX, 0, kStyleSmallWidth, kStyleSmallHeight);
        
            widthX += kStyleSmallWidth;
        }
        
        baseViewHeight = kStyleSmallHeight;
        baseViewWidth = kStyleSmallWidth * ratingScore / 2;
        
        ratingMarkLabel.frame = CGRectMake(widthX+2, -1, 0, kStyleSmallHeight);
        ratingMarkLabel.text = [NSString stringWithFormat:@"%ld",(long)ratingScore];
        

        ratingMarkLabel.font = [UIFont boldSystemFontOfSize:14];
        [ratingMarkLabel sizeToFit];
    }
    else
    {
        for (int index = 0; index < kNumberOfStars; index ++)
        {
            UIView *garyStar = grayStarsViewArray[index];
            UIView *yellowStar = yellowStarsViewArray[index];
            
            garyStar.frame = CGRectMake(widthX, 0, kStyleNormalWidth, kStyleNormalHeight);
            yellowStar.frame = CGRectMake(widthX, 0, kStyleNormalWidth, kStyleNormalHeight);
            
            widthX += kStyleNormalWidth;
        }
    
        baseViewHeight = kStyleNormalHeight;
        baseViewWidth = kStyleNormalWidth * ratingScore;
        
        ratingMarkLabel.frame = CGRectMake(widthX+2, 3, 0, kStyleNormalHeight);
        ratingMarkLabel.text = [NSString stringWithFormat:@"%ld",(long)ratingScore];

        ratingMarkLabel.font = [UIFont boldSystemFontOfSize:22];
        [ratingMarkLabel sizeToFit];
    }
    
    baseStarView.frame = CGRectMake(0, 0, baseViewWidth, baseViewHeight);
}

@end
