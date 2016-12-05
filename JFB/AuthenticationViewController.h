//
//  AuthenticationViewController.h
//  JFB
//
//  Created by LYD on 15/8/20.
//  Copyright (c) 2015年 李俊阳. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AuthenticationViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *nameTF;
@property (weak, nonatomic) IBOutlet UITextField *identityCardTF;
@property (weak, nonatomic) IBOutlet UITextField *provCityTF;
@property (weak, nonatomic) IBOutlet UITextField *emailTF;
@property (weak, nonatomic) IBOutlet UIButton *submitBtn;
@property (weak, nonatomic) IBOutlet UIButton *radioBtn;

@property (assign, nonatomic) BOOL isAuthenticated;  //是否已认证
@property (strong, nonatomic) NSString *titleStr;   //已认证时，显示修改邮箱

@end
