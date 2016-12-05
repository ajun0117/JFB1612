//
//  CustomActivityIndicatorView.h
//  CustomActivityView
//
//  Created by Victoria on 15/3/16.
//  Copyright (c) 2015年 Somiya. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomActivityIndicatorView : UIView

- (void)startAnimating;
- (void)stopAnimating;
- (BOOL)isAnimating;

@end
