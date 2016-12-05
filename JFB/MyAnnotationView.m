//
//  MyAnnotationView.m
//  JFB
//
//  Created by LYD on 15/9/6.
//  Copyright (c) 2015年 李俊阳. All rights reserved.
//

#import "MyAnnotationView.h"

@implementation MyAnnotationView

- (id)initWithAnnotation:(id<BMKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        //        [self setBounds:CGRectMake(0.f, 0.f, 30.f, 30.f)];
        [self setBounds:CGRectMake(0.f, 0.f, 23.f, 23.f)];
        
        [self setBackgroundColor:[UIColor clearColor]];
        
        UIImageView *imv = [[UIImageView alloc] initWithFrame:self.bounds];
        imv.image = IMG(@"map_dot");
        imv.contentMode = UIViewContentModeCenter;
        [self addSubview:imv];
    }
    return self;
}

@end
