//
//  MyCollectionViewController.m
//  JFB
//
//  Created by 李俊阳 on 15/8/24.
//  Copyright (c) 2015年 李俊阳. All rights reserved.
//

#import "MyCollectionViewController.h"
#import "ShopDetailVoucherCell.h"
#import "HomeShopListCell.h"
#import "ShopDetailViewController.h"
#import "GoodsDetailViewController.h"

#define VoucherCell    @"shopDetailVoucherCell"
#define kTableViewCelllIdentifier      @"HomeShopCell"


@interface MyCollectionViewController ()
{
    MBProgressHUD *_hud;
    MBProgressHUD *_networkConditionHUD;
    NSMutableArray *goodsdata;
    NSMutableArray *merchantdata;
}

@end

@implementation MyCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"我的收藏";
    
    goodsdata = [[NSMutableArray alloc] init];
    merchantdata = [[NSMutableArray alloc] init];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(editTableCell)];
    
    self.myTableView.tableFooterView = [UIView new];
    [self.myTableView registerNib:[UINib nibWithNibName:@"ShopDetailVoucherCell" bundle:nil] forCellReuseIdentifier:VoucherCell];
    [self.myTableView registerNib:[UINib nibWithNibName:@"HomeShopListCell" bundle:nil] forCellReuseIdentifier:kTableViewCelllIdentifier];

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
    
    [self requestGetCollectList];
}

-(void)editTableCell {
    if ([self.navigationItem.rightBarButtonItem.title isEqualToString:@"编辑"]) {
        self.myTableView.editing = YES;
        [self.navigationItem.rightBarButtonItem setTitle:@"完成"];
        return;
    }
    
    self.myTableView.editing = NO;
    [self.navigationItem.rightBarButtonItem setTitle:@"编辑"];
    
}


- (IBAction)goodsAction:(id)sender {
    if (! _goodsBtn.selected) { //当前按钮没有选中时
        _goodsBtn.selected = YES;
        [_goodsView setBackgroundColor:RGBCOLOR(216, 80, 92)];
        
        _shopBtn.selected = NO;
        [_shopView setBackgroundColor:[UIColor clearColor]];
    }
    
    [self.myTableView reloadData];
}

- (IBAction)shopAction:(id)sender {
    if (! _shopBtn.selected) { //当前按钮没有选中时
        _shopBtn.selected = YES;
        [_shopView setBackgroundColor:RGBCOLOR(216, 80, 92)];
        
        _goodsBtn.selected = NO;
        [_goodsView setBackgroundColor:[UIColor clearColor]];
    }
    
    [self.myTableView reloadData];
}

//设置Separator顶头
-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    if ([self.myTableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.myTableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([self.myTableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.myTableView setLayoutMargins:UIEdgeInsetsZero];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.goodsBtn.selected) {
        return [goodsdata count];
    }
    return [merchantdata count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (self.goodsBtn.selected) {
//        return 90;
//    }
    return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.goodsBtn.selected) {
        ShopDetailVoucherCell *cell = (ShopDetailVoucherCell *)[tableView dequeueReusableCellWithIdentifier:VoucherCell];
        
        NSDictionary *dic = goodsdata [indexPath.row];
        
        cell.emptyL.hidden = YES;
        cell.voucherView.hidden = NO;
        [cell.voucherIM sd_setImageWithURL:[NSURL URLWithString:dic [@"cover_Image"]] placeholderImage:IMG(@"bg_merchant_photo_placeholder")];
        cell.nameL.text = dic [@"goods_name"];
        cell.priceL.text = [NSString stringWithFormat:@"%@元",dic[@"sales_price"]];
        cell.costPriceStrikeL.text = [NSString stringWithFormat:@"%@元",dic[@"market_price"]];
        
        cell.collectionSaleL.hidden = NO;
        cell.collectionSaleL.text = [NSString stringWithFormat:@"已售:%@",dic[@"sales"]];
        cell.saleL.hidden = YES;
        
        return cell;
    }
    
    NSDictionary *dic = merchantdata [indexPath.row];
    HomeShopListCell *cell = (HomeShopListCell *)[tableView dequeueReusableCellWithIdentifier:kTableViewCelllIdentifier];
    
    [cell.shopIM sd_setImageWithURL:[NSURL URLWithString:dic[@"merchant_logo"]] placeholderImage:IMG(@"bg_merchant_photo_placeholder")];
    cell.shopNameL.text = dic[@"merchant_name"];
    cell.shopAddressL.text = dic[@"address"];
    cell.rateView.rate = [dic[@"score"] floatValue];
    cell.scoreL.text = [NSString stringWithFormat:@"%@分",dic[@"score"]];
    cell.integralRateL.text = [NSString stringWithFormat:@"%@%%",dic[@"fraction"]];
    
    float dis = [dic[@"distance"] floatValue];
    float convertDis = 0;
    if (dis >= 1000) {
        convertDis = dis / 1000;
        cell.distanceL.text = [NSString stringWithFormat:@"%.1fkm",convertDis];
    }
    else {
        cell.distanceL.text = [NSString stringWithFormat:@"%.1fm",dis];
    }
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if (self.goodsBtn.selected) {
            NSDictionary *dic = goodsdata [indexPath.row];
            [self DeleteCollectionWithCollectionID:dic[@"cid"]];
            [goodsdata removeObjectAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        }
        else {
            NSDictionary *dic = merchantdata [indexPath.row];
            [self DeleteCollectionWithCollectionID:dic[@"cid"]];
            [merchantdata removeObjectAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        }
    }
}

//设置Separator顶头
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}


#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.goodsBtn.selected) {
        NSDictionary *dic = goodsdata [indexPath.row];
        GoodsDetailViewController *goodsDeatilVC = [[GoodsDetailViewController alloc] init];
        goodsDeatilVC.goods_id = dic [@"goods_id"];
        goodsDeatilVC.merchant_id = dic [@"merchant_id"];
        [self.navigationController pushViewController:goodsDeatilVC animated:YES];
    }
    else {
        NSDictionary *dic = merchantdata [indexPath.row];
        ShopDetailViewController *shopDeatilVC = [[ShopDetailViewController alloc] init];
        shopDeatilVC.merchantdataDic = dic;
        [self.navigationController pushViewController:shopDeatilVC animated:YES];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}



#pragma mark - 发送请求
-(void)requestGetCollectList { //获取收藏列表
    [_hud show:YES];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:GetCollectList object:nil];
    
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:GetCollectList, @"op", nil];
    NSDictionary *locationDic = [[GlobalSetting shareGlobalSettingInstance] myLocation];
    NSString *userID = [[GlobalSetting shareGlobalSettingInstance] userID];
    if (userID == nil) {
        userID = @"";
    }
    NSDictionary *pram = [[NSDictionary alloc] initWithObjectsAndKeys:userID,@"member_id",[locationDic objectForKey:@"latitude"],@"latitude",[locationDic objectForKey:@"longitude"],@"longitude", nil];
    [[DataRequest sharedDataRequest] postDataWithUrl:RequestURL(GetCollectList) delegate:nil params:pram info:infoDic];
}


-(void)DeleteCollectionWithCollectionID:(NSString *)collectionId { //删除收藏
    [_hud show:YES];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:DeleteCollect object:nil];
    
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:DeleteCollect, @"op", nil];
//    NSDictionary *locationDic = [[GlobalSetting shareGlobalSettingInstance] myLocation];
    NSString *userID = [[GlobalSetting shareGlobalSettingInstance] userID];
    if (userID == nil) {
        userID = @"";
    }
    NSDictionary *pram = [[NSDictionary alloc] initWithObjectsAndKeys:userID,@"member_id",collectionId,@"id", nil];
    [[DataRequest sharedDataRequest] postDataWithUrl:RequestURL(DeleteCollect) delegate:nil params:pram info:infoDic];
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
    if ([notification.name isEqualToString:GetCollectList]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:GetCollectList object:nil];
        NSLog(@"GetMerchantList_responseObject: %@",responseObject);
        
        [goodsdata removeAllObjects];
        [merchantdata removeAllObjects];
        if ([responseObject[@"status"] boolValue]) {
            NSDictionary *dic = responseObject[DATA];
            if ([dic[@"goodsdata"] isKindOfClass:[NSNull class]]) {
            }
            else {
                [goodsdata addObjectsFromArray:dic[@"goodsdata"]];
            }
            [merchantdata addObjectsFromArray:dic[@"merchantdata"]];
        }
        else {
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:[responseObject objectForKey:MSG] delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil, nil];
//            [alert show];
            _networkConditionHUD.labelText = responseObject [MSG];
            [_networkConditionHUD show:YES];
            [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        }
        
        [self.myTableView reloadData];
    }
    
    
    if ([notification.name isEqualToString:DeleteCollect]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:DeleteCollect object:nil];
        
        NSLog(@"GetMerchantList_responseObject: %@",responseObject);
        if ([responseObject[@"status"] boolValue]) {
//            _networkConditionHUD.labelText = responseObject [MSG];
//            [_networkConditionHUD show:YES];
//            [_networkConditionHUD hide:YES afterDelay:HUDDelay];
            
        }
//        else {
//            _networkConditionHUD.labelText = responseObject [MSG];
//            [_networkConditionHUD show:YES];
//            [_networkConditionHUD hide:YES afterDelay:HUDDelay];
//        }
        _networkConditionHUD.labelText = responseObject [MSG];
        [_networkConditionHUD show:YES];
        [_networkConditionHUD hide:YES afterDelay:HUDDelay];
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
