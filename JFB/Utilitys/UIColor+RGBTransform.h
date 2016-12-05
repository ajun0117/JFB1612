//
//  UIColor+RGBTransform.h
//  HeaderViewDemo
//
//  Created by Victoria on 15/1/15.
//  Copyright (c) 2015年 Somiya. All rights reserved.
//  根据传入的16进制颜色值转换为RGB颜色值

#import <UIKit/UIKit.h>

@interface UIColor (RGBTransform)
+ (UIColor *)getColor:(NSString *)hexColor;
@end
