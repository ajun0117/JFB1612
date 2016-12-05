//
//  ShopSearchViewController.m
//  JFB
//
//  Created by 李俊阳 on 15/8/29.
//  Copyright (c) 2015年 李俊阳. All rights reserved.
//

#import "ShopSearchViewController.h"
#import "ShopDetailViewController.h"
#import "HomeShopListCell.h"
#import "MJRefresh.h"

#define SearchTableViewCelllIdentifier      @"HomeShopCell"

@interface ShopSearchViewController () <UISearchBarDelegate>
{
    MBProgressHUD *_hud;
    MBProgressHUD *_networkConditionHUD;
    UISearchBar *_search;
    int currentpage;
    NSMutableArray *shopArray; //搜索结果数组
    NSString *currentKey;
    NSMutableArray *keysArray; //搜索关键字历史记录数组

    NSString *cityID;   //城市
    NSString *countyID;    //区县
    NSString *countyName;   //区县名称
    NSString *sortID;   //排序
    NSString *current_city_code;
    NSString *current_county_code;
}

@end

@implementation ShopSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    _search = [[UISearchBar alloc] initWithFrame:CGRectMake( 0, 7, 200, 30)];
    _search.barTintColor = Red_BtnColor;
    _search.tintColor = [UIColor clearColor];
    _search.backgroundColor = [UIColor clearColor];
    _search.delegate = self;
    _search.placeholder = @"输入商家搜索";
    self.navigationItem.titleView = _search;
    
    if (! keysArray && [[GlobalSetting shareGlobalSettingInstance] historys]) {
        keysArray = [NSMutableArray arrayWithArray:[[GlobalSetting shareGlobalSettingInstance] historys]];
    }
    else {
        keysArray = [[NSMutableArray alloc] init];
    }
    
    UIButton *rightButn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightButn.frame = CGRectMake(0, 0, 40, 24);
    rightButn.titleLabel.font = [UIFont systemFontOfSize:15];
    rightButn.contentMode = UIViewContentModeScaleAspectFit;
    [rightButn setTitle:@"搜索" forState:UIControlStateNormal];
    [rightButn addTarget:self action:@selector(toSearch) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBarButn = [[UIBarButtonItem alloc] initWithCustomView:rightButn];
    self.navigationItem.rightBarButtonItem = rightBarButn;
    
    currentpage = 1; //默认首页
    shopArray = [[NSMutableArray alloc] init];
    
    [self.myTableView registerNib:[UINib nibWithNibName:@"HomeShopListCell" bundle:nil] forCellReuseIdentifier:SearchTableViewCelllIdentifier];
    [self.myTableView addHeaderWithTarget:self action:@selector(headerRefreshing)];
    [self.myTableView addFooterWithTarget:self action:@selector(footerLoadData)];
    self.myTableView.tableFooterView = [UIView new];
    
    self.historyTableView.tableFooterView = [UIView new];
    
    
    NSMutableDictionary *dic = [[GlobalSetting shareGlobalSettingInstance] homeSelectedDic];
    NSLog(@"dic:  %@",dic);
    if (dic != nil) {
        cityID = dic[@"cityID"];
//        cityName = dic [@"areaName"];
        countyID = dic[@"countyID"];
        countyName = dic[@"countName"];
        current_city_code = dic[@"current_city_code"];
        current_county_code = dic[@"current_county_code"];
    }
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
//    [_search becomeFirstResponder];     //自动弹出键盘
    
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

#pragma mark - 下拉刷新,上拉加载
-(void)headerRefreshing {
    NSLog(@"下拉刷新个人信息");
    currentpage = 1;
    [self requestGetRecommendShopListWithKey];
}

-(void)footerLoadData {
    NSLog(@"上拉加载数据");
    currentpage ++;
    [self requestGetRecommendShopListWithKey];
}

-(void)toSearch {
    NSLog(@"去搜索");
    self.historyTableView.hidden = YES; //隐藏历史记录
    [_search resignFirstResponder];
    currentKey = _search.text;
    [self requestGetRecommendShopListWithKey];
    
    [self saveSearchHistoryKeys];
}

#pragma mark - UISearchBarDelegate
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    self.historyTableView.hidden = NO; //显示历史记录
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    NSLog(@"去搜索");
    self.historyTableView.hidden = YES; //隐藏历史记录
    [_search resignFirstResponder];
    currentKey = _search.text;
    [self requestGetRecommendShopListWithKey];
    
    [self saveSearchHistoryKeys];
}

//判断并保存新的搜索key
-(void)saveSearchHistoryKeys {
    //如果没有重复，则加入数组
    if ([keysArray count] > 0) {
        BOOL isRepeat = NO;
        for (NSString *key in keysArray) {
            if ([key isEqualToString:_search.text]) {
                isRepeat = YES;
            }
        }
        if (! isRepeat) {
            [keysArray addObject:_search.text];
            [[GlobalSetting shareGlobalSettingInstance] setSearchHistory:keysArray];
        }
    }
    else {
        [keysArray addObject:_search.text];
        [[GlobalSetting shareGlobalSettingInstance] setSearchHistory:keysArray];
    }
    [self.historyTableView reloadData]; //刷新历史记录
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
    if (tableView == self.myTableView) {
        return [shopArray count];
    }
    return [keysArray count] + 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.myTableView) {
        return 100;
    }
    return 44;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (tableView == self.myTableView) {
        return 10;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == self.myTableView) {
        NSDictionary *dic = shopArray [indexPath.row];
        
        HomeShopListCell *cell = (HomeShopListCell *)[tableView dequeueReusableCellWithIdentifier:SearchTableViewCelllIdentifier];
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
    
    else {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        if (indexPath.row == [keysArray count]) {
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            cell.textLabel.text = @"清除搜索历史";
        }
        else {
            cell.textLabel.text = keysArray [indexPath.row];
        }
        return cell;
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
    if (tableView == self.myTableView) {
        NSDictionary *dic = shopArray [indexPath.row];
        ShopDetailViewController *detailVC = [[ShopDetailViewController alloc] init];
        detailVC.merchantdataDic = dic;
        [self.navigationController pushViewController:detailVC animated:YES];
    }
    else {
        if (indexPath.row == [keysArray count]) {
            _search.text = @"";
            [keysArray removeAllObjects]; //置空搜索记录数组
            [[GlobalSetting shareGlobalSettingInstance] setSearchHistory:keysArray]; //同步清空本地记录数据
            [self.historyTableView reloadData];
            
            _networkConditionHUD.labelText = @"清除成功！";
            [_networkConditionHUD show:YES];
            [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        }
        else {
            [_search resignFirstResponder];
            self.historyTableView.hidden = YES;
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            _search.text = cell.textLabel.text;
            currentKey = cell.textLabel.text;
            [self requestGetRecommendShopListWithKey];
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - 发送请求
-(void)requestGetRecommendShopListWithKey { //获取推荐商户列表
    [_hud show:YES];
    
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:GetMerchantList object:nil];
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:GetMerchantList, @"op", nil];
    NSDictionary *locationDic = [[GlobalSetting shareGlobalSettingInstance] myLocation];
    NSString *userID = [[GlobalSetting shareGlobalSettingInstance] userID];
    if (userID == nil) {
        userID = @"";
    }
    NSDictionary *pram = [[NSDictionary alloc] initWithObjectsAndKeys:current_city_code,@"current_city_code",@"",@"current_county_code",cityID,@"city",@"",@"county",@"",@"business_type",@"2",@"sort",[NSNumber numberWithInt:currentpage],@"pageindex",[locationDic objectForKey:@"latitude"],@"latitude",[locationDic objectForKey:@"longitude"],@"longitude",currentKey,@"key",userID,@"member_id", nil];
    NSLog(@"pram: %@",pram);
    [[DataRequest sharedDataRequest] postDataWithUrl:RequestURL(GetMerchantList) delegate:nil params:pram info:infoDic];
}

#pragma mark - 网络请求结果数据
-(void) didFinishedRequestData:(NSNotification *)notification{
    [_hud hide:YES];
    
    [self.myTableView headerEndRefreshing];
    [self.myTableView footerEndRefreshing];
    if ([[notification.userInfo valueForKey:@"RespResult"] isEqualToString:ERROR]) {
        _networkConditionHUD.labelText = [notification.userInfo valueForKey:@"ContentResult"];
        [_networkConditionHUD show:YES];
        [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        return;
    }
    NSDictionary *responseObject = [[NSDictionary alloc] initWithDictionary:[notification.userInfo objectForKey:@"RespData"]];
    if ([notification.name isEqualToString:GetMerchantList]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:GetMerchantList object:nil];
        NSLog(@"GetMerchantList_responseObject: %@",responseObject);
        
//        if ([responseObject[@"status"] boolValue]) {
//            shopArray = responseObject[DATA];
//            [self.myTableView reloadData];
//        }
//        else {
//            _networkConditionHUD.labelText = [responseObject objectForKey:MSG];
//            [_networkConditionHUD show:YES];
//            [_networkConditionHUD hide:YES afterDelay:HUDDelay];
//            
//        }
        if ([responseObject[@"status"] boolValue]) {
            if (currentpage == 1) { //如果是第一页
                [shopArray removeAllObjects];
            }
            if ([responseObject[DATA] isKindOfClass:[NSArray class]]) {
                [shopArray addObjectsFromArray:responseObject[DATA]];
            }
        }
        else {
            _networkConditionHUD.labelText = [responseObject objectForKey:MSG];
            [_networkConditionHUD show:YES];
            [_networkConditionHUD hide:YES afterDelay:HUDDelay];
            
            if (currentpage == 1) { //如果是第一页
                [shopArray removeAllObjects];
            }
        }
        [self.myTableView reloadData];
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
