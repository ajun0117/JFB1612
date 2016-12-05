//
//  OrderRefundViewController.m
//  JFB
//
//  Created by LYD on 15/9/25.
//  Copyright © 2015年 李俊阳. All rights reserved.
//

#import "OrderRefundViewController.h"
#import "OrderRefundSuccessViewController.h"

@interface OrderRefundViewController ()
{
    MBProgressHUD *_hud;
    MBProgressHUD *_networkConditionHUD;
    NSMutableArray *_selectCouponAry;  //勾选的代金券数组
    NSMutableArray *_selectReasomAry;
    NSString *_selectReasonString;
}

@end

@implementation OrderRefundViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"申请退款";
    
    self.myTableView.tableFooterView = [UIView new];
    
    _selectCouponAry = [[NSMutableArray alloc] init];
    
    for (NSDictionary *dic in _couponArray) {
        NSDictionary *dicc = [NSDictionary dictionaryWithObjectsAndKeys:dic,@"couponDic",@"1",@"isSelected", nil];  //默认选中
        [_selectCouponAry addObject:dicc];
    }
    NSLog(@"_selectCouponAry: %@",_selectCouponAry);
    
    _selectReasomAry = [NSMutableArray arrayWithArray:@[@{@"isSelected":@"0",@"reasonString":@"商家停业/装修/转让"},@{@"isSelected":@"0",@"reasonString":@"去过了，不太满意"},@{@"isSelected":@"0",@"reasonString":@"买多了/买错了"},@{@"isSelected":@"0",@"reasonString":@"计划有变，没时间消费"},@{@"isSelected":@"0",@"reasonString":@"其他"}]];
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

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {     //代金券个数
        return [_couponArray count];
    }
    else if (section == 3) {    //退款原因
        return [_selectReasomAry count];
    }
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    switch (indexPath.section) {
        case 0: {
            NSDictionary *dic = _couponArray [indexPath.row];
            
            UILabel *noticeL = [[UILabel alloc] initWithFrame:CGRectMake(8, 0, 60, 44)];
            noticeL.textColor = [UIColor grayColor];
            noticeL.text = @"券码：";
            [cell.contentView addSubview:noticeL];
            
            UILabel *codeL = [[UILabel alloc] initWithFrame:CGRectMake(8 + 65, 0, 200, 44)];
            codeL.textColor = [UIColor grayColor];
            codeL.text = dic [@"consume_code"];
            [cell.contentView addSubview:codeL];
            
            UIButton *selectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            selectBtn.frame = CGRectMake(SCREEN_WIDTH - 8 - 25, 10, 24, 24);
            selectBtn.tag = indexPath.row + 1000;
            [selectBtn setImage:IMG(@"address_check_box_unselect") forState:UIControlStateNormal];
            [selectBtn setImage:IMG(@"address_check_box_select") forState:UIControlStateSelected];
            [selectBtn addTarget:self action:@selector(selectCoupon:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:selectBtn];
            
            NSDictionary *chongzuDic = _selectCouponAry [indexPath.row];
            BOOL isSelected = [chongzuDic [@"isSelected"] boolValue];
            if (isSelected) {
                selectBtn.selected = YES;
            }
            else {
                selectBtn.selected = NO;
            }
            
        }
            break;
            
            
        case 1: {
            UILabel *noticeL = [[UILabel alloc] initWithFrame:CGRectMake(8, 0, 60, 44)];
            noticeL.textColor = [UIColor grayColor];
            noticeL.text = @"现金：";
            [cell.contentView addSubview:noticeL];
            
            UILabel *codeL = [[UILabel alloc] initWithFrame:CGRectMake(8 + 65, 0, 200, 44)];
            codeL.textColor = Red_BtnColor;
            codeL.text = [NSString stringWithFormat:@"%@",_refund_amount];
            [cell.contentView addSubview:codeL];
        }
            break;
            
            
        case 2: {
            UILabel *noticeL = [[UILabel alloc] initWithFrame:CGRectMake(8, 0, 70, 44)];
            noticeL.textColor = [UIColor grayColor];
            noticeL.text = @"原路退回";
            [cell.contentView addSubview:noticeL];
            
            UILabel *codeL = [[UILabel alloc] initWithFrame:CGRectMake(8 + 75, 0, SCREEN_WIDTH - 8 - 75, 44)];
            codeL.textColor = Red_BtnColor;
            codeL.font = [UIFont systemFontOfSize:15];
            codeL.text = @"(3到10个工作日退还到原支付方)";
            [cell.contentView addSubview:codeL];
        }
            break;
            
        case 3: {
            NSDictionary *dic = _selectReasomAry [indexPath.row];
            UILabel *noticeL = [[UILabel alloc] initWithFrame:CGRectMake(8, 0, 200, 44)];
            noticeL.textColor = [UIColor grayColor];
            noticeL.text = dic [@"reasonString"];
            [cell.contentView addSubview:noticeL];
            
            UIButton *selectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            selectBtn.frame = CGRectMake(SCREEN_WIDTH - 8 - 25, 10, 24, 24);
            selectBtn.tag = indexPath.row + 2000;
            [selectBtn setImage:IMG(@"checked_false") forState:UIControlStateNormal];
            [selectBtn setImage:IMG(@"checked_true") forState:UIControlStateSelected];
            [selectBtn addTarget:self action:@selector(selectReason:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:selectBtn];
            
            BOOL isSelected = [dic [@"isSelected"] boolValue];
            if (isSelected) {
                selectBtn.selected = YES;
            }
            else {
                selectBtn.selected = NO;
            }
        }
            break;
            
        default:
            break;
    }

    
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == 3) {
        return 60;    //上下留10像素边
    }
    return 0;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0: {
            UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
            headView.backgroundColor = [UIColor clearColor];
            UILabel *noticeL = [[UILabel alloc] initWithFrame:CGRectMake(8, 0, SCREEN_WIDTH - 16, 44)];
            noticeL.textColor = [UIColor blackColor];
            noticeL.text = @"代金券(可多选)";
            [headView addSubview:noticeL];
            return headView;
        }
            break;
            
        case 1: {
            UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
            headView.backgroundColor = [UIColor clearColor];
            UILabel *noticeL = [[UILabel alloc] initWithFrame:CGRectMake(8, 0, SCREEN_WIDTH - 16, 44)];
            noticeL.textColor = [UIColor blackColor];
            noticeL.text = @"退还内容:";
            [headView addSubview:noticeL];
            return headView;
        }
            break;
            
        case 2: {
            UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
            headView.backgroundColor = [UIColor clearColor];
            UILabel *noticeL = [[UILabel alloc] initWithFrame:CGRectMake(8, 0, SCREEN_WIDTH - 16, 44)];
            noticeL.textColor = [UIColor blackColor];
            noticeL.text = @"现金退还方式:";
            [headView addSubview:noticeL];
            return headView;
        }
            break;
            
        case 3: {
            UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
            headView.backgroundColor = [UIColor clearColor];
            UILabel *noticeL = [[UILabel alloc] initWithFrame:CGRectMake(8, 0, SCREEN_WIDTH - 16, 44)];
            noticeL.textColor = [UIColor blackColor];
            noticeL.text = @"退款原因(选择一项)";
            [headView addSubview:noticeL];
            return headView;
        }
            break;
            
        default:
            break;
    }
    
    
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (section == 3) {
        UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 60)];
        headView.backgroundColor = [UIColor clearColor];

        UIButton *payBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        payBtn.frame = CGRectMake(8, 10, SCREEN_WIDTH - 16, 40);
        [payBtn setTitle:@"申请退款" forState:UIControlStateNormal];
        payBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        payBtn.backgroundColor = RGBCOLOR(229, 24, 35);
        [payBtn addTarget:self action:@selector(refundAction) forControlEvents:UIControlEventTouchUpInside];
        [headView addSubview:payBtn];
        
        return headView;
    }
    return nil;
}




-(void)selectCoupon:(UIButton *)sender {
    sender.selected = ! sender.selected;
    int row = (int)sender.tag - 1000;
    NSMutableDictionary *muDic = [_selectCouponAry [row] mutableCopy];
    if (sender.selected) {
        [muDic setObject:@"1" forKey:@"isSelected"];    //重新置真
    }
    else {
        [muDic setObject:@"0" forKey:@"isSelected"];    //重新置否
    }
    [_selectCouponAry replaceObjectAtIndex:row withObject:muDic];
    
    NSLog(@"_selectCouponAry:  %@",_selectCouponAry);
}


-(void)selectReason:(UIButton *)sender {
    
    for (int i = 0; i < [_selectReasomAry count]; ++i) {
        NSMutableDictionary *muDic = [_selectReasomAry [i] mutableCopy];
        NSIndexPath *path = [NSIndexPath indexPathForRow:i inSection:3];    //第三个section为退款原因
        UITableViewCell *cell = [self.myTableView cellForRowAtIndexPath:path];
        for (UIView *view in cell.contentView.subviews) {
            if ([view isKindOfClass:[UIButton class]]) {
                UIButton *btn = (UIButton *)view;
                btn.selected = NO;
                [muDic setObject:@"0" forKey:@"isSelected"];    //重新置否
            }
        }
        [_selectReasomAry replaceObjectAtIndex:i withObject:muDic];
    }
    
    sender.selected = YES;
    
    int row = (int)sender.tag - 2000;
    NSMutableDictionary *muDic = [_selectReasomAry [row] mutableCopy];
    [muDic setObject:@"1" forKey:@"isSelected"];    //重新置真
    _selectReasonString = _selectReasomAry [row] [@"reasonString"];
    [_selectReasomAry replaceObjectAtIndex:row withObject:muDic];   //更新数组，存储选择的位置
     NSLog(@"_selectReasonString:  %@",_selectReasonString);
    NSLog(@"_selectReasomAry:  %@",_selectReasomAry);
}

-(void)refundAction {
    
    [self requestRefund];
}

#pragma mark - 发送请求
-(void)requestRefund { //退款
    
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:Refund object:nil];
    
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:Refund, @"op", nil];
    NSString *userID = [[GlobalSetting shareGlobalSettingInstance] userID];
    if (userID == nil) {
        userID = @"";
    }
    NSString *memberName = [[GlobalSetting shareGlobalSettingInstance] mName];
    if (memberName == nil) {
        memberName = @"匿名";
    }
    NSMutableString *couponNoString = [[NSMutableString alloc] init];
    for (NSDictionary *dic in _selectCouponAry) {
        BOOL isSelected = [dic [@"isSelected"] boolValue];
        if (isSelected) {
            if ([couponNoString length] == 0) {
                [couponNoString appendString:[NSString stringWithFormat:@"%@",dic[@"couponDic"][@"coupon_no"]]];
            }
            else {
                [couponNoString appendString:[NSString stringWithFormat:@",%@",dic[@"couponDic"][@"coupon_no"]]];
            }
        }
    }
    if ([couponNoString isEqualToString:@""]) {
        _networkConditionHUD.labelText = @"请至少选择一张代金券！";
        [_networkConditionHUD show:YES];
        [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        return;
    }
    if (_selectReasonString == nil) {
        _networkConditionHUD.labelText = @"请选择退款原因！";
        [_networkConditionHUD show:YES];
        [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        return;
    }
    
    [_hud show:YES];
    NSDictionary *pram = [[NSDictionary alloc] initWithObjectsAndKeys:_goodsDic[@"merchant_id"],@"merchant_id",_order_no,@"order_no",userID,@"member_id",couponNoString,@"coupon_no",_refund_amount,@"refund_amount",memberName,@"member_name",_selectReasonString,@"remark", nil];
    NSLog(@"pram: %@",pram);
    
    [[DataRequest sharedDataRequest] postDataWithUrl:RequestURL(Refund) delegate:nil params:pram info:infoDic];
}

#pragma mark - 网络请求结果数据
-(void) didFinishedRequestData:(NSNotification *)notification{
    [_hud hide:YES];
    
    if ([[notification.userInfo valueForKey:@"RespResult"] isEqualToString:ERROR]) {
        _networkConditionHUD.labelText = [notification.userInfo valueForKey:@"ContentResult"];
        [_networkConditionHUD show:YES];
        [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        return;
    }
    NSDictionary *responseObject = [[NSDictionary alloc] initWithDictionary:[notification.userInfo objectForKey:@"RespData"]];
    if ([notification.name isEqualToString:Refund]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:Refund object:nil];
        
        NSLog(@"GetMerchantList_responseObject: %@",responseObject);
        if ([responseObject[@"status"] boolValue]) {
            _networkConditionHUD.labelText = [responseObject objectForKey:MSG];
            [_networkConditionHUD show:YES];
            [_networkConditionHUD hide:YES afterDelay:HUDDelay];
            
            OrderRefundSuccessViewController *successVC = [[OrderRefundSuccessViewController alloc] init];
            [self.navigationController pushViewController:successVC animated:YES];
        }
        else {
            _networkConditionHUD.labelText = [responseObject objectForKey:MSG];
            [_networkConditionHUD show:YES];
            [_networkConditionHUD hide:YES afterDelay:HUDDelay];
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
