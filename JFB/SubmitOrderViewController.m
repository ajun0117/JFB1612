//
//  SubmitOrderViewController.m
//  JFB
//
//  Created by 李俊阳 on 15/9/4.
//  Copyright (c) 2015年 李俊阳. All rights reserved.
//

#import "SubmitOrderViewController.h"
#import "PayOrderViewController.h"

@interface SubmitOrderViewController ()
{
    MBProgressHUD *_hud;
    MBProgressHUD *_networkConditionHUD;
}

@end

@implementation SubmitOrderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"提交订单";
    
    if (self.order_no == nil) {
        self.order_no = @"";
    }
    
    [self initViewData];
    
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (! _hud) {
        _hud = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:_hud];
    }
    
    if (!_networkConditionHUD) {
        _networkConditionHUD = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:_networkConditionHUD];
    }
    _networkConditionHUD.mode = MBProgressHUDModeText;
    _networkConditionHUD.yOffset = APP_HEIGHT/2 - HUDBottomH;
    _networkConditionHUD.margin = HUDMargin;
}

//加载视图数据
-(void)initViewData {
    self.goodsNameL.text = self.goodsdataDic [@"goods_name"];
    self.singlePriceL.text = [NSString stringWithFormat:@"%@",self.goodsdataDic [@"sales_price"]];
    if (self.goodsdataDic [@"mobile"] == nil) {  //从商品详情进入
        if ([[GlobalSetting shareGlobalSettingInstance] mMobile] == nil) {
            self.phoneL.text = @"";
        }
        else {
            self.phoneL.text = [NSString stringWithFormat:@"%@",[[GlobalSetting shareGlobalSettingInstance] mMobile]];
        }
    }
    else {  //从订单页进入，含有mobile字段
        self.phoneL.text = [NSString stringWithFormat:@"%@",self.goodsdataDic [@"mobile"]];
    }
    
    if ([self.goodsdataDic [@"qty"] intValue] > 0) {    //从订单页进入，含有qty字段
        float price = [self.goodsdataDic [@"sales_price"] floatValue];
        self.numberTF.text = [NSString stringWithFormat:@"%@",self.goodsdataDic [@"qty"]];
        self.allPriceL.text = [NSString stringWithFormat:@"%.2f",price * [self.goodsdataDic [@"qty"] intValue]];
    }
    else {
        self.numberTF.text = @"1";
        self.allPriceL.text = [NSString stringWithFormat:@"%@",self.goodsdataDic [@"sales_price"]];     //商品详情进入，数量默认为1
    }
    
}

- (IBAction)decAction:(id)sender {
    int currNum = [self.numberTF.text intValue];
    int numInt = currNum - 1;
    self.numberTF.text = [NSString stringWithFormat:@"%d",numInt];
    
    if ([self.numberTF.text isEqualToString:@"1"]) {
        self.decBtn.enabled = NO; 
    }
    
    float price = [self.goodsdataDic [@"sales_price"] floatValue];
    self.allPriceL.text = [NSString stringWithFormat:@"%.2f",price * numInt];
}

- (IBAction)incAction:(id)sender {
    int currNum = [self.numberTF.text intValue];
    if (currNum >= 1) {
        self.decBtn.enabled = YES;
    }
    int numInt = currNum + 1;
    self.numberTF.text = [NSString stringWithFormat:@"%d",numInt];
    
    float price = [self.goodsdataDic [@"sales_price"] floatValue];
    self.allPriceL.text = [NSString stringWithFormat:@"%.2f",price * numInt];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *str = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if ([str integerValue] < 1) {   //当输入的值小于1时，强制修改为为1
        self.numberTF.text = @"1";
        self.decBtn.enabled = NO;
        
        float price = [self.goodsdataDic [@"sales_price"] floatValue];
        self.allPriceL.text = [NSString stringWithFormat:@"%.2f",price * 1];
        
        return NO;
    }
    else if ([str integerValue] > 1) {
        self.decBtn.enabled = YES;
        float price = [self.goodsdataDic [@"sales_price"] floatValue];
        self.allPriceL.text = [NSString stringWithFormat:@"%.2f",price * [str intValue]];
    }
    return YES;
}

- (IBAction)submitAction:(id)sender {
    
    [self  requestSubmitOrder];
}

#pragma mark - 发送请求
-(void)requestSubmitOrder { //提交订单
    [_hud show:YES];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:SubmitOrder object:nil];
//    NSDictionary *locationDic = [[GlobalSetting shareGlobalSettingInstance] myLocation];
    NSString *userID = [[GlobalSetting shareGlobalSettingInstance] userID];
    if (userID == nil) {
        userID = @"";
    }
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:SubmitOrder, @"op", nil];
    NSDictionary *pram = [[NSDictionary alloc] initWithObjectsAndKeys:self.order_no,@"order_no",self.goodsdataDic[@"goods_id"],@"goods_id",self.merchant_id,@"merchant_id",userID,@"member_id",self.goodsNameL.text,@"goods_name",self.phoneL.text,@"mobile",self.singlePriceL.text,@"price",self.numberTF.text,@"qty",self.allPriceL.text,@"payable_amount",self.allPriceL.text,@"order_amount", nil];
    NSLog(@"pram: %@",pram);
    [[DataRequest sharedDataRequest] postDataWithUrl:RequestURL(SubmitOrder) delegate:nil params:pram info:infoDic];
}

#pragma mark - 网络请求结果数据
-(void) didFinishedRequestData:(NSNotification *)notification{
    [_hud hide:YES];
    
    if ([[notification.userInfo valueForKey:@"RespResult"] isEqualToString:ERROR]) {
        if (!_networkConditionHUD) {
            _networkConditionHUD = [[MBProgressHUD alloc] initWithView:self.view];
            [self.view addSubview:_networkConditionHUD];
        }
        _networkConditionHUD.labelText = [notification.userInfo valueForKey:@"ContentResult"];
        _networkConditionHUD.mode = MBProgressHUDModeText;
        _networkConditionHUD.yOffset = APP_HEIGHT/2 - HUDBottomH;
        _networkConditionHUD.margin = HUDMargin;
        [_networkConditionHUD show:YES];
        [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        return;
    }
    NSDictionary *responseObject = [[NSDictionary alloc] initWithDictionary:[notification.userInfo objectForKey:@"RespData"]];
    
    if ([notification.name isEqualToString:SubmitOrder]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:SubmitOrder object:nil];
        NSLog(@"GetMerchantList_responseObject: %@",responseObject);
        
        if ([responseObject[@"status"] boolValue]) {
            PayOrderViewController *payVC = [[PayOrderViewController alloc] init];
            payVC.orderInfoDic = responseObject [DATA];
            payVC.goods_name = self.goodsNameL.text;
            payVC.goods_detail = self.goodsdataDic [@"goods_title"];  //商品描述body
            payVC.amount = self.allPriceL.text;
            payVC.their_type = self.goodsdataDic [@"their_type"];
            payVC.merchant_id = self.merchant_id;
            payVC.qtyStr = self.numberTF.text;
            [self.navigationController pushViewController:payVC animated:YES];
        }
        else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:[responseObject objectForKey:MSG] delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil, nil];
            [alert show];
        }
    }
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
