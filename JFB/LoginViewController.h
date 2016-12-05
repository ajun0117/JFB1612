//
//  LoginViewController.h
//  JFB
//
//  Created by 李俊阳 on 15/8/21.
//  Copyright (c) 2015年 李俊阳. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomTextField.h"

@interface LoginViewController : UIViewController

@property (weak, nonatomic) IBOutlet CustomTextField *phoneTF;
@property (weak, nonatomic) IBOutlet CustomTextField *passwordTF;

@end
