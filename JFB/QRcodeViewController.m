//
//  QRcodeViewController.m
//  JFB
//
//  Created by LYD on 15/8/24.
//  Copyright (c) 2015年 李俊阳. All rights reserved.
//

#import "QRcodeViewController.h"
#import "QRCodeGenerator.h"

@interface QRcodeViewController ()

@end

@implementation QRcodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
//    self.title = @"二维码名片";
    self.title = _titleStr;
    
    NSString *userID = [[GlobalSetting shareGlobalSettingInstance] userID];
    if (userID == nil) {
        userID = @"";
    }
//    NSString *midStr = [NSString stringWithFormat:@"%@",userID];
    self.QRimageView.image = [QRCodeGenerator qrImageForString:self.qrString imageSize:self.QRimageView.bounds.size.width];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
