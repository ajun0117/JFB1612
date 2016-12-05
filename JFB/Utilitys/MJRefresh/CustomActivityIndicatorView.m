//
//  CustomActivityIndicatorView.m
//  CustomActivityView
//
//  Created by Victoria on 15/3/16.
//  Copyright (c) 2015年 Somiya. All rights reserved.
//

#import "CustomActivityIndicatorView.h"
@interface CustomActivityIndicatorView (){
    CGFloat angle;
}

@property BOOL isAinmate;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation CustomActivityIndicatorView

@synthesize isAinmate;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.isAinmate = NO;
        CGRect frame1 = frame;
        frame1.origin.x = 0;
        frame1.origin.y = 0;
        self.imageView = [[UIImageView alloc] initWithFrame:frame1];
        self.imageView.image = [UIImage imageNamed:@"indicator.png"];
        self.alpha = 0.0;
        [self addSubview:self.imageView];
    }
    
    return self;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    UIImage *image = [UIImage imageNamed:@"indicator.png"];
    [image drawInRect:rect];
}
*/
-(void)startAnimating{
    self.alpha = 1.0;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.001 target:self selector:@selector(hadleTimer:) userInfo:nil repeats:YES];
    self.isAinmate = YES;
}

-(void) hadleTimer:(NSTimer *)timer{

    angle += 0.01;
    if (angle > 6.283) {
        angle = 0;
    }
    
    CGAffineTransform transform=CGAffineTransformMakeRotation(angle);
    self.imageView.transform = transform;
}
-(void)stopAnimating{
    self.alpha = 0.0;
    angle = 0;
    self.isAinmate = NO;
    [self.timer invalidate];
}

-(BOOL)isAnimating{
    return self.isAinmate;
}
@end
