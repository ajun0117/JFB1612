//
//  AJSegmentedControl.m
//  JFB
//
//  Created by LYD on 15/9/16.
//  Copyright (c) 2015年 李俊阳. All rights reserved.
//

#import "AJSegmentedControl.h"

#define AJSegmentedControl_Height 44.0
#define AJSegmentedControl_Width ([UIScreen mainScreen].bounds.size.width)
#define Min_Width_4_Button 80.0

#define Define_Tag_add 1000

@interface AJSegmentedControl()

@property (strong, nonatomic)UIScrollView *scrollView;
@property (strong, nonatomic)NSMutableArray *array4Btn;
@property (strong, nonatomic)UIView *bottomLineView;

@end

@implementation AJSegmentedControl

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithOriginY:(CGFloat)y Titles:(NSArray *)titles delegate:(id)delegate
{
    CGRect rect4View = CGRectMake(.0f, y, AJSegmentedControl_Width, AJSegmentedControl_Height);
    if (self = [super initWithFrame:rect4View]) {
        
        self.backgroundColor = [UIColor whiteColor];
        [self setUserInteractionEnabled:YES];
        
        self.delegate = delegate;
        
        //
        //  array4btn
        //
        _array4Btn = [[NSMutableArray alloc] initWithCapacity:[titles count]];
        
        //
        //  set button
        //
        CGFloat width4btn = rect4View.size.width/[titles count];
        if (width4btn < Min_Width_4_Button) {
            width4btn = Min_Width_4_Button;
        }
        
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _scrollView.backgroundColor = self.backgroundColor;
        _scrollView.userInteractionEnabled = YES;
        _scrollView.contentSize = CGSizeMake([titles count]*width4btn, AJSegmentedControl_Height);
        _scrollView.showsHorizontalScrollIndicator = NO;
        
        for (int i = 0; i<[titles count]; i++) {
            
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.frame = CGRectMake(i*width4btn, .0f, width4btn, AJSegmentedControl_Height);
            [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            btn.titleLabel.font = [UIFont systemFontOfSize:15];
            [btn setTitleColor:Red_BtnColor forState:UIControlStateSelected];
            NSDictionary *titleDic = titles [i];
            [btn setTitle:titleDic[@"type_name"] forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(segmentedControlChange:) forControlEvents:UIControlEventTouchUpInside];
            btn.tag = Define_Tag_add + i;
            [_scrollView addSubview:btn];
            [_array4Btn addObject:btn];
            
            if (i == 0) {
                btn.selected = YES;
            }
        }
        
        //
        //  lineView
        //
        CGFloat height4Line = AJSegmentedControl_Height/2.0f;
        CGFloat originY = (AJSegmentedControl_Height - height4Line)/2;
        for (int i = 1; i<[titles count]; i++) {
            UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(i*width4btn-1.0f, originY, 1.0f, height4Line)];
            lineView.backgroundColor = Cell_sepLineColor;
            [_scrollView addSubview:lineView];
        }
        
        //
        //  bottom lineView
        //
        
//        UILabel *lineL = [[UILabel alloc] initWithFrame:CGRectMake(0, AJSegmentedControl_Height-1, AJSegmentedControl_Width, 1)];
//        lineL.backgroundColor = Cell_sepLineColor;
//        [_scrollView addSubview:lineL];
        
        UIImageView *lineIM = [[UIImageView alloc] initWithImage:IMG(@"dot_line.png")];
        lineIM.frame = CGRectMake(0, AJSegmentedControl_Height-1, _scrollView.contentSize.width, 1);
        [_scrollView addSubview:lineIM];
        
        _bottomLineView = [[UIView alloc] initWithFrame:CGRectMake(.0f, AJSegmentedControl_Height-2, width4btn, 2.0f)];
        _bottomLineView.backgroundColor = Red_BtnColor;
        [_scrollView addSubview:_bottomLineView];
        
        
        
        [self addSubview:_scrollView];
    }
    return self;
}

//
//  btn clicked
//
- (void)segmentedControlChange:(UIButton *)btn
{
    btn.selected = YES;
    for (UIButton *subBtn in self.array4Btn) {
        if (subBtn != btn) {
            subBtn.selected = NO;
        }
    }
    
    CGRect rect4boottomLine = self.bottomLineView.frame;
    rect4boottomLine.origin.x = btn.frame.origin.x;
    
    CGPoint pt = CGPointZero;
    BOOL canScrolle = NO;
    if ((btn.tag - Define_Tag_add) >= 2 && [_array4Btn count] > 4 && [_array4Btn count] > (btn.tag - Define_Tag_add + 2)) {
        pt.x = btn.frame.origin.x - Min_Width_4_Button*2.0f;
        canScrolle = YES;
    }else if ([_array4Btn count] > 4 && (btn.tag - Define_Tag_add + 2) >= [_array4Btn count]){
//        pt.x = (_array4Btn.count - 5) * Min_Width_4_Button;
        pt.x = _scrollView.contentSize.width - AJSegmentedControl_Width;
        canScrolle = YES;
    }else if (_array4Btn.count > 4 && (btn.tag - Define_Tag_add) < 2){
        pt.x = 0;
        canScrolle = YES;
    }
    
    if (canScrolle) {
        [UIView animateWithDuration:0.3 animations:^{
            _scrollView.contentOffset = pt;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.2 animations:^{
                self.bottomLineView.frame = rect4boottomLine;
            }];
        }];
    }else{
        [UIView animateWithDuration:0.2 animations:^{
            self.bottomLineView.frame = rect4boottomLine;
        }];
    }
    
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(ajSegmentedControlSelectAtIndex:)]) {
        [self.delegate ajSegmentedControlSelectAtIndex:btn.tag - 1000];
    }
}


#warning ////// index 从 0 开始
// delegete method
- (void)changeSegmentedControlWithIndex:(NSInteger)index
{
    if (index > [_array4Btn count]-1) {
        NSLog(@"index 超出范围");
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"index 超出范围" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"ok", nil];
        [alertView show];
        return;
    }
    
    UIButton *btn = [_array4Btn objectAtIndex:index];
    [self segmentedControlChange:btn];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
