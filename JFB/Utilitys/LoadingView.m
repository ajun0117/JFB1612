//
//  LoadingView.m
//  mobilely
//
//  Created by Victoria on 15/2/13.
//  Copyright (c) 2015年 ylx. All rights reserved.
//

#import "LoadingView.h"

@interface LoadingView ()<UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *myScrollView;
@property (nonatomic, strong) UIButton *enterButn;

@property (nonatomic, strong) NSArray *images;
@end

@implementation LoadingView

-(id)initWithFrame:(CGRect)frame withImagesArr:(NSArray *)images{
    if (self = [super initWithFrame:frame]) {
        self.images = images;
        [self initViews];
    }
    return self;
}

#pragma mark -
#pragma self Methods
/**
 *  初始化视图
 */
-(void) initViews{
    //myscrollview
    self.myScrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    self.myScrollView.delegate = self;
    self.myScrollView.pagingEnabled = YES;
    self.myScrollView.showsHorizontalScrollIndicator = NO;
    self.myScrollView.bounces = NO;
    [self addSubview:self.myScrollView];
    
    //enterbutn
//    CGFloat rate = APP_WIDTH/375.0;
//    CGSize butnSize = CGSizeMake(254*rate * 0.7, 82*rate * 0.7);
//    CGFloat rate1 = APP_HEIGHT/667.0;
//    CGFloat bottom = 60 * rate1;
    
    self.enterButn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.enterButn setFrame:CGRectMake(0, SCREEN_HEIGHT - 61, SCREEN_WIDTH, 61)];
    [self.enterButn setImage:[UIImage imageNamed:@"enter"] forState:UIControlStateNormal];
    [self.enterButn addTarget:self action:@selector(enterApp:) forControlEvents:UIControlEventTouchUpInside];
    
    [self initImageViews];
}

/**
 *  初始化loading图片
 */
-(void) initImageViews{
    for (int i =0; i < self.images.count; i ++) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(i * APP_WIDTH, 0, APP_WIDTH, self.bounds.size.height)];
        UIImage *image = [UIImage imageNamed:self.images[i]];
        imageView.image = image;
        CGSize size = image.size;
        //imageView.contentMode = UIViewContentModeScaleAspectFit;
        if ([[self.images lastObject] isEqualToString:self.images[i]]) {
            imageView.userInteractionEnabled = YES;
            [imageView addSubview:self.enterButn];
        }
        [self.myScrollView addSubview:imageView];
    }
    self.myScrollView.contentSize = CGSizeMake((self.images.count + 0) * APP_WIDTH, 0);
}

/**
 *  点击立即体验按钮
 *
 *  @param sender
 */
-(void) enterApp:(id)sender{
    if ([self.delegate respondsToSelector:@selector(didEnterAppWithStyle:)]) {
        [self.delegate didEnterAppWithStyle:1];
    }
}

#pragma mark -
#pragma mark UIScrollViewDelegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView.contentOffset.x == (self.images.count) * APP_WIDTH) {
        if ([self.delegate respondsToSelector:@selector(didEnterAppWithStyle:)]) {
            //[self.delegate didEnterAppWithStyle:2];
        }
    }
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
