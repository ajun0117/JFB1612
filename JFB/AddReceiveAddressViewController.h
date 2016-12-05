//
//  AddReceiveAddressViewController.h
//  JFB
//
//  Created by LYD on 15/8/21.
//  Copyright (c) 2015年 李俊阳. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddReceiveAddressViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *nameTF;
@property (weak, nonatomic) IBOutlet UITextField *mobileTF;
@property (weak, nonatomic) IBOutlet UITextField *telTF;
@property (weak, nonatomic) IBOutlet UITextField *regionTF;
@property (weak, nonatomic) IBOutlet UITextView *detailAddrTV;
@property (weak, nonatomic) IBOutlet UITextField *postcodeTF;
@property (weak, nonatomic) IBOutlet UIButton *markBtn;

@property (strong, nonatomic) NSDictionary *addressDic; //地址信息字典
@property (strong, nonatomic) NSString *titleStr;

@end
