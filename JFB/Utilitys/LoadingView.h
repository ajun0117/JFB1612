//
//  LoadingView.h
//  mobilely
//
//  Created by Victoria on 15/2/13.
//  Copyright (c) 2015年 ylx. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LoadingViewDelegate <NSObject>

/**
 *  进入到应用中的方式 1点击进入 2滑动进入
 *
 *  @param style 
 */
-(void) didEnterAppWithStyle:(NSInteger)style;

@end

@interface LoadingView : UIView
@property (nonatomic, strong) id<LoadingViewDelegate>delegate;
-(id)initWithFrame:(CGRect)frame withImagesArr:(NSArray *)images;
@end
