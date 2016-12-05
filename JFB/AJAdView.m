//
//  AJAdView.m
//  JFB
//
//  Created by LYD on 15/9/14.
//  Copyright (c) 2015年 李俊阳. All rights reserved.
//

#import "AJAdView.h"

@interface AJAdView()<UIScrollViewDelegate>
{
    UILabel *_titleL;
}

@property (nonatomic, assign) CGFloat height;

@property (nonatomic, assign) CGFloat width;
@end

@implementation AJAdView

- (CGFloat)height{
    return self.frame.size.height;
}

- (CGFloat)width{
    return self.frame.size.width;
}

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self initSubViews];
        
    }
    return self;
}

- (void)reloadData{
    int num =(int)[self.delegate numberInAdView:self];
    if (num) {
        _sIndex = 0;
        
        if (num != 1) {
            self.pageControl.frame = CGRectMake(self.width - 15*num - 10, self.height - 30, 15*num, 30);
            self.pageControl.numberOfPages = num;
            [self.scrollView setContentSize:CGSizeMake(self.width*3, self.height)];
            [NSTimer scheduledTimerWithTimeInterval:DefineAdTime target:self selector:@selector(cycleClick:) userInfo:nil repeats:YES];
            
        }
        [self initScrollViewSubViewsWithSelectNum:1];
        
    }
}

- (void)cycleClick:(id)sender{
    [self.scrollView setContentOffset:CGPointMake(self.width*2, 0) animated:YES];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self initScrollViewSubViewsWithSelectNum:2];
    });
}

- (void)initSubViews{
    
    self.bgImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.width, self.height)];
    [self addSubview:self.bgImageView];
    self.bgImageView.image = [UIImage imageNamed:DefineAdImage];
    
    self.scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.width, self.height)];
    self.scrollView.delegate = self;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.bounces = NO;
    [self addSubview:self.scrollView];
    
    for (int i = 0 ; i<3; i++) {
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(i*self.width, 0, self.width, self.height)];
        [self.scrollView addSubview:imageView];
//        imageView.clipsToBounds = YES;
//        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.tag = i+10;
        imageView.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(touchClick:)];
        [imageView addGestureRecognizer:tapGesture];
    }
    
    UIView *titleBgView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 30, self.frame.size.width, 30)];
    titleBgView.backgroundColor = [UIColor blackColor];
    titleBgView.alpha = 0.4;
    [self addSubview:titleBgView];
    
    _titleL = [[UILabel alloc] initWithFrame:CGRectMake(10, self.frame.size.height - 25, self.frame.size.width - 100, 21)];
    _titleL.textColor = [UIColor whiteColor];
    _titleL.font = [UIFont systemFontOfSize:15];
    _titleL.text = _titleL.text = [self.delegate titleStringInAdView:self index:0];
    _titleL.backgroundColor = [UIColor clearColor];
    [self addSubview:_titleL];
    
    self.pageControl = [[UIPageControl alloc]init];
    self.pageControl.userInteractionEnabled = NO;
    [self addSubview:self.pageControl];
    
}


- (void)touchClick:(UITapGestureRecognizer *)gesture {
    
    if ([self.delegate respondsToSelector:@selector(adView:didSelectIndex:)]) {
        [self.delegate adView:self didSelectIndex:_sIndex];
    }
}


- (void)initScrollViewSubViewsWithSelectNum:(NSInteger)num{
    if (num == 2) {
        _sIndex++;
    }
    else if (num == 0){
        _sIndex--;
    }
    [self index2calculate];
    UIImageView *v1 = (UIImageView *)[self.scrollView viewWithTag:10];
    UIImageView *v2 = (UIImageView *)[self.scrollView viewWithTag:11];
    UIImageView *v3 = (UIImageView *)[self.scrollView viewWithTag:12];
    int nexttag  = (_sIndex+1)>([self.delegate numberInAdView:self]-1) ? 0 : (_sIndex+1);
    int lasttag  = (_sIndex-1)<0 ? (int)([self.delegate numberInAdView:self] -1) : (_sIndex-1);
    
    [v2 sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",[self.delegate imageUrlInAdView:self index:_sIndex]]] placeholderImage:[UIImage imageNamed:DefineAdImage]];
    [v1 sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",[self.delegate imageUrlInAdView:self index:lasttag]]] placeholderImage:[UIImage imageNamed:DefineAdImage]];
    [v3 sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",[self.delegate imageUrlInAdView:self index:nexttag]]] placeholderImage:[UIImage imageNamed:DefineAdImage]];
    
    self.pageControl.currentPage = _sIndex;
    _titleL.text = [self.delegate titleStringInAdView:self index:_sIndex];
    [self.scrollView setContentOffset:CGPointMake(self.width, 0)];
}

- (void)index2calculate{
    if (_sIndex>([self.delegate numberInAdView:self] - 1)) {
        _sIndex = 0;
    }
    else if (_sIndex<0) {
        _sIndex = (int)[self.delegate numberInAdView:self]-1;
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    int index = scrollView.contentOffset.x / scrollView.frame.size.width;
    
    [self initScrollViewSubViewsWithSelectNum:index];
}




- (void)willMoveToSuperview:(UIView *)newSuperview{
    [super willMoveToSuperview:newSuperview];
    [self reloadData];
}




@end
