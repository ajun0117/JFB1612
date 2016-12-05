//
//  MaskView.m
//  JFB
//
//  Created by 李俊阳 on 15/8/24.
//  Copyright (c) 2015年 李俊阳. All rights reserved.
//

#import "MaskView.h"

@interface MaskView ()

/* 是否停止扫描动画 0：停止  1：继续*/
@property (nonatomic, assign) NSInteger isStopAnimation;

@property (nonatomic, strong) UIImageView *lineImageView;

@end

@implementation MaskView

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = RGBACOLOR(0, 0, 0, 0.5);
        [self initViews];
    }
    return self;
}

/**
 *  初始化视图
 */
- (void)initViews
{
    
    CGRect frame =  CGRectMake((APP_WIDTH-220)/2,60+64,220, 220); //CGRectMake(APP_WIDTH * 0.5 - 100, APP_HEIGHT * 0.5 - 100, 200, 200);
    
    //添加扫描区域边框
    self.borderImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"qr_code_bg.9"]];
//    self.borderImageView.layer.borderColor = [UIColor whiteColor].CGColor;
//    self.borderImageView.layer.borderWidth = 0.5;
    self.borderImageView.frame = frame;
    [self addSubview:self.borderImageView];
    
    //添加扫描线
    _lineImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 220, 2)];
    _lineImageView.image = [UIImage imageNamed:@"scan_line"];
    [self.borderImageView addSubview:_lineImageView];
    
    //添加说明
    UILabel *descriLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, VIEW_BY(self.borderImageView) + 5, APP_WIDTH, 30)];
    descriLabel.textColor = [UIColor whiteColor];
    descriLabel.textAlignment = NSTextAlignmentCenter;
    descriLabel.font = [UIFont systemFontOfSize:12];
    descriLabel.text = @"将二维码放入框内即可自动扫描";
    [self addSubview:descriLabel];
}


/**
 *  扫描线运动动画
 */
- (void)animation
{
    if (_isStopAnimation == 1) {
        [UIView animateWithDuration:2 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            
            _lineImageView.frame = CGRectMake(0, 220, 220, 2);
            
        } completion:^(BOOL finished) {
            _lineImageView.frame = CGRectMake(0, 0, 220, 2);
            [self performSelector:@selector(animation) withObject:nil];
        }];
    }
}

/*!
 * @brief  开始扫描动画
 */
-(void)startAnimation{
    _isStopAnimation = 1;
    [self performSelector:@selector(animation) withObject:nil];
}

/*!
 * @brief  停止动画
 */
-(void)stopAnimation
{
    _isStopAnimation=0;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    //1.取得图形上下文对象
    CGContextRef context = UIGraphicsGetCurrentContext();
    
//    //2.创建路径对象
    CGMutablePathRef path = CGPathCreateMutable();
//    CGPathMoveToPoint(path, nil, 20, 50);//移动到指定位置（设置路径起点）
//    CGPathAddLineToPoint(path, nil, 20, 100);//绘制直线（从起始位置开始）
//    CGPathAddLineToPoint(path, nil, 300, 100);//绘制另外一条直线（从上一直线终点开始绘制）
    
    //2.1 创建矩形
    CGRect rectNew = self.borderImageView.frame;
    
    //3.添加路径到图形上下文
//    CGContextAddPath(context, path);
    //3.1 添加矩形到图形上下文
    //CGPathAddRect(path, NULL, rectNew);
    CGContextClearRect(context, rectNew);
    //4.设置图形上下文状态属性
//    CGContextSetRGBStrokeColor(context, 1.0, 0, 0, 1);//设置笔触颜色
//    CGContextSetRGBFillColor(context, 0, 1.0, 0, 1);//设置填充色
//    CGContextSetLineWidth(context, 2.0);//设置线条宽度
//    CGContextSetLineCap(context, kCGLineCapRound);//设置顶点样式,（20,50）和（300,100）是顶点
//    CGContextSetLineJoin(context, kCGLineJoinRound);//设置连接点样式，(20,100)是连接点
    //4.1 设置图形上下文的填充色
    //CGContextSetRGBFillColor(context, 0, 0, 0, 0);
    /*设置线段样式
     phase:虚线开始的位置
     lengths:虚线长度间隔（例如下面的定义说明第一条线段长度8，然后间隔3重新绘制8点的长度线段，当然这个数组可以定义更多元素）
     count:虚线数组元素个数
     */
//    CGFloat lengths[2] = { 18, 9 };
//    CGContextSetLineDash(context, 0, lengths, 2);
    /*设置阴影
     context:图形上下文
     offset:偏移量
     blur:模糊度
     color:阴影颜色
     */
//    CGColorRef color = [UIColor grayColor].CGColor;//颜色转化，由于Quartz 2D跨平台，所以其中不能使用UIKit中的对象，但是UIkit提供了转化方法
//    CGContextSetShadowWithColor(context, CGSizeMake(2, 2), 0.8, color);
    
    //5.绘制图像到指定图形上下文
    /*CGPathDrawingMode是填充方式,枚举类型
     kCGPathFill:只有填充（非零缠绕数填充），不绘制边框
     kCGPathEOFill:奇偶规则填充（多条路径交叉时，奇数交叉填充，偶交叉不填充）
     kCGPathStroke:只有边框
     kCGPathFillStroke：既有边框又有填充
     kCGPathEOFillStroke：奇偶填充并绘制边框
     */
    CGContextDrawPath(context, kCGPathFillStroke);//最后一个参数是填充类型
    
    //6.释放对象
    CGPathRelease(path);
}


@end
