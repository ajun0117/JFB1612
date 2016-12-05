//
//  CustomTextView.h
//  SELDemo
//
//  Created by Victoria on 15/1/13.
//  Copyright (c) 2015年 Somiya. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomTextView : UITextView
@property (nonatomic, strong) UIButton *butn;
@property (nonatomic, strong) UIView *tagetView;
//@property (nonatomic, assign) SEL selector;

/**
 *  初始化品论视图
 *
 *  @param frame    评论视图的frame
 *  @param selector <#selector description#>
 *  @param delegate <#delegate description#>
 *  @param title    placeholder的内容
 *
 *  @return <#return value description#>
 */
-(id)initWithFrame:(CGRect)frame selector:(SEL)selector delegate:(id)delegate title:(NSString *)title image:(NSString *)image;
@end
