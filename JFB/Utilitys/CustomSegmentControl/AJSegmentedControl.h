//
//  AJSegmentedControl.h
//  JFB
//
//  Created by LYD on 15/9/16.
//  Copyright (c) 2015年 李俊阳. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AJSegmentedControlDelegate <NSObject>

@required
//代理函数 获取当前下标
- (void)ajSegmentedControlSelectAtIndex:(NSInteger)index;

@end

@interface AJSegmentedControl : UIView

@property (assign, nonatomic) id<AJSegmentedControlDelegate>delegate;
//初始化函数
- (id)initWithOriginY:(CGFloat)y Titles:(NSArray *)titles delegate:(id)delegate;
//提供方法改变 index
- (void)changeSegmentedControlWithIndex:(NSInteger)index;


@end
