//
//  CustomTextField.m
//  mobilely
//
//  Created by Victoria on 15/2/28.
//  Copyright (c) 2015年 ylx. All rights reserved.
//

#import "CustomTextField.h"

@implementation CustomTextField

//-(id)initWithFrame:(CGRect)frame leftView:(NSString *)leftImage placeholder:(NSString *)placeholder{
//    if (self = [super initWithFrame:frame]) {
//        if (leftImage) {
//            self.leftView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:leftImage]];
//            self.leftViewMode = UITextFieldViewModeAlways;
//        }
//        self.placeholder = placeholder;
//        self.font = [UIFont systemFontOfSize:17];
//        self.borderStyle = UITextBorderStyleNone;
//        
//        self.layer.borderColor = [UIColor colorWithWhite:0.756 alpha:1.000].CGColor;
//        self.layer.borderWidth = 1;
//        self.layer.masksToBounds = YES;
//        self.layer.cornerRadius = 5;
//        
//    }
//    return self;
//}

-(void)setLeftView:(NSString *)leftImage placeholder:(NSString *)placeholder {
    if (leftImage) {
        self.leftView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:leftImage]];
        self.leftViewMode = UITextFieldViewModeAlways;
    }
    self.placeholder = placeholder;
    self.font = [UIFont systemFontOfSize:17];
    self.borderStyle = UITextBorderStyleNone;
    
    self.layer.borderColor = [UIColor colorWithWhite:0.756 alpha:1.000].CGColor;
    self.layer.borderWidth = 1;
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = 5;
}

-(CGRect) leftViewRectForBounds:(CGRect)bounds {
    CGRect iconRect = [super leftViewRectForBounds:bounds];
    iconRect.origin.x += 10;// 右偏10
    return iconRect;
}

//控制 placeHolder 的位置，左右缩 20
- (CGRect)textRectForBounds:(CGRect)bounds {
    CGRect iconRect = [super textRectForBounds:bounds];
    iconRect.origin.x += 10;// 右偏10
    return iconRect;
}

// 控制文本的位置
- (CGRect)editingRectForBounds:(CGRect)bounds {
    CGRect iconRect = [super editingRectForBounds:bounds];
    iconRect.origin.x += 10;// 右偏10
    return iconRect;
}

-(CGRect)placeholderRectForBounds:(CGRect)bounds{
    CGRect iconRect = [super textRectForBounds:bounds];
    iconRect.origin.x += 10;// 右偏10
    return iconRect;
}

//-(CGRect)placeholderRectForBounds:(CGRect)bounds{
//    [super placeholderRectForBounds:bounds];
//    CGRect frame = CGRectMake(self.leftView.frame.size.width + 20, 0, bounds.size.width, bounds.size.height);
//    return frame;
//}
//
//-(CGRect)textRectForBounds:(CGRect)bounds{
//    [super textRectForBounds:bounds];
//    CGRect frame = CGRectMake(self.leftView.frame.size.width + 20, 0, bounds.size.width, bounds.size.height);
//    return frame;
//}
//
//
//-(CGRect)editingRectForBounds:(CGRect)bounds{
//    [super editingRectForBounds:bounds];
//    CGRect frame = CGRectMake(self.leftView.frame.size.width + 20, 0, bounds.size.width, bounds.size.height);
//    return frame;
//}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
