//
//  MaskView.h
//  JFB
//
//  Created by 李俊阳 on 15/8/24.
//  Copyright (c) 2015年 李俊阳. All rights reserved.
//

//扫描二维码遮罩层

#import <UIKit/UIKit.h>

@interface MaskView : UIView

@property (nonatomic, strong) UIImageView *borderImageView;

/*!
 * @brief  停止扫描动画
 */
-(void)stopAnimation;

/*!
 * @brief  开始扫描动画
 */
-(void)startAnimation;
@end
