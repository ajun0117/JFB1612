//
//  CustomTextView.m
//  SELDemo
//
//  Created by Victoria on 15/1/13.
//  Copyright (c) 2015年 Somiya. All rights reserved.
//

#import "CustomTextView.h"
#import "UIColor+RGBTransform.h"

@interface CustomTextView()<UITextViewDelegate>
@property (nonatomic, strong) NSTimer *timer;
@end
@implementation CustomTextView

-(id)initWithFrame:(CGRect)frame selector:(SEL)selector delegate:(id)delegate title:(NSString *)title image:(NSString *)image{
    if (self = [super initWithFrame:frame]) {
        //self.layer.borderWidth = 1;
        //self.layer.borderColor = [UIColor getColor:@"ababab"].CGColor;
        self.font = [UIFont systemFontOfSize:16];
        self.selectedRange = NSMakeRange(-10, 5);

        UIFont *font = [UIFont systemFontOfSize:15];
        NSDictionary *attributesDic = [[NSDictionary alloc] initWithObjectsAndKeys:font,NSFontAttributeName, nil];
        CGSize size = [title sizeWithAttributes:attributesDic];
        
        self.butn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.butn.frame = CGRectMake(2+1 , 2+1, size.width + 40, 30);
        [self.butn setImage:[UIImage imageNamed:image] forState:UIControlStateNormal];
        [self.butn setContentEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 0)];
        [self.butn setTitle:title forState:UIControlStateNormal];
        self.butn.titleLabel.font = [UIFont systemFontOfSize:15.0];
        [self.butn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        //if (delegate != nil) {
        [self.butn addTarget:self action:@selector(upload:) forControlEvents:UIControlEventTouchUpInside];
        //}
        [self addSubview:self.butn];
        self.delegate = self;
    }
    return self;
}
-(void)isTextNil:(NSTimer *)timer{
    if (self.text.length == 0) {
        self.butn.hidden = NO;
    } else {
        self.butn.hidden = YES;
    }
}

-(void)textViewDidBeginEditing:(UITextView *)textView{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(isTextNil:) userInfo:nil repeats:YES];

}
-(void)textViewDidEndEditing:(UITextView *)textView{
//    NSLog(@"%@",NSStringFromSelector(_cmd));
    
    [self.timer invalidate];
    
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    NSCharacterSet *doneButtonCharacterSet = [NSCharacterSet newlineCharacterSet];
    NSRange replacementTextRange = [text rangeOfCharacterFromSet:doneButtonCharacterSet];
    NSUInteger location = replacementTextRange.location;
    if (location != NSNotFound){
        [textView resignFirstResponder];
        return NO;
    }
    if ([text isEqualToString:@"\n"])
    {
        return YES;
    }
    NSString * toBeString = [textView.text stringByReplacingCharactersInRange:range withString:text];
    
    
    if ([toBeString length] > 250) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"内容不能超过250个字符哟！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        textView.text = [toBeString substringToIndex:250];
        return NO;
    }
    
    
    
    
    return YES;
}
-(void) upload:(id)sender{
    [self becomeFirstResponder];
}


@end
