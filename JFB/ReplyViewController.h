//
//  ReplyViewController.h
//  mobilely
//
//  Created by wp on 15-1-27.
//  Copyright (c) 2015年 ylx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RatingView.h"

//@protocol ReplyViewControllerDelegate <NSObject>
//
//-(void) replyDidCommit;
//
//@end

@interface ReplyViewController : UIViewController<UITextViewDelegate>

@property(strong,nonatomic)RatingView *starView;

@property(strong,nonatomic)NSString *order_no;
@property(strong,nonatomic)NSString *merchant_id;
@property(strong,nonatomic)NSString *goods_id;

@end
