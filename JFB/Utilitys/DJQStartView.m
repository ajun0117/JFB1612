//
//  HomeViewController.h
//  JFB
//
//  Created by 李俊阳 on 15/8/18.
//  Copyright (c) 2015年 李俊阳. All rights reserved.
//

#import "DJQStartView.h"

#define th M_PI/180
@implementation DJQStartView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CGFloat x = frame.size.width / 2;
        CGFloat y = frame.size.height / 2;
        self.radius = x < y ? x:y;
        self.value = 1;
        self.startColor = RGBCOLOR(255, 116, 0);
        self.backgroundColor = [UIColor clearColor];
        self.boundsColor = RGBCOLOR(197, 198, 200);
        self.opaque = NO;
    }
    return self;
}
-(void) setFrame:(CGRect)frame
{
    CGFloat x = frame.size.width / 2;
    CGFloat y = frame.size.height / 2;
    self.radius = x < y ? x:y;
    
    [super setFrame:frame];
    [self setNeedsDisplay];
        
}
-(id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        
        CGFloat x = self.frame.size.width / 2;
        CGFloat y = self.frame.size.height / 2;
        self.radius = x < y ? x:y;
        self.value = 1;
        self.startColor = RGBCOLOR(255, 116, 0);
        self.backgroundColor = [UIColor clearColor];
        self.boundsColor = RGBCOLOR(197, 198, 200);
      
    }
    return self;
}


- (void)drawRect:(CGRect)rect
{
    
    
    CGFloat centerX = rect.size.width / 2;
    CGFloat centerY = rect.size.height / 2;
    
    CGFloat r0 = self.radius * sin(18 * th)/cos(36 * th); /*计算小圆半径r0 */
    CGFloat x1[5]={0},y1[5]={0},x2[5]={0},y2[5]={0};
    
    for (int i = 0; i < 5; i ++)
    {
        x1[i] = centerX + self.radius * cos((90 + i * 72) * th); /* 计算出大圆上的五个平均分布点的坐标*/
        y1[i]=centerY - self.radius * sin((90 + i * 72) * th);
        x2[i]=centerX + r0 * cos((54 + i * 72) * th); /* 计算出小圆上的五个平均分布点的坐标*/
        y2[i]=centerY - r0 * sin((54 + i * 72) * th);
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGMutablePathRef startPath = CGPathCreateMutable();
    CGPathMoveToPoint(startPath, NULL, x1[0], y1[0]);
    
    
    for (int i = 1; i < 5; i ++) {
     
        
        CGPathAddLineToPoint(startPath, NULL, x2[i], y2[i]);
        CGPathAddLineToPoint(startPath, NULL, x1[i], y1[i]);
    }

    CGPathAddLineToPoint(startPath, NULL, x2[0], y2[0]);
    CGPathCloseSubpath(startPath);
    

    CGContextAddPath(context, startPath);

    CGContextSetFillColorWithColor(context, self.boundsColor.CGColor);

//    CGContextSetStrokeColorWithColor(context, self.boundsColor.CGColor);
//    CGContextStrokePath(context);
    
    CGRect range1 = CGRectMake(x1[1], 0, (x1[4] - x1[1]) * 5 , y1[2]);
    
    CGContextAddPath(context, startPath);
    CGContextClip(context);
    CGContextFillRect(context, range1);
    
//    CFRelease(startPath);
    
    
    CGContextSetFillColorWithColor(context, self.startColor.CGColor);
    CGRect range = CGRectMake(x1[1], 0, (x1[4] - x1[1]) * self.value , y1[2]);

    CGContextAddPath(context, startPath);
    CGContextClip(context);
    CGContextFillRect(context, range);

    CFRelease(startPath);
    
}

-(void) setValue:(CGFloat)value
{
    if (value < 0) {
        _value = 0;
    }
    else if(value > 1)
    {
        _value = 1;
    }
    else{
        _value = value;
    }
    
    [self setNeedsDisplay];
}

@end
