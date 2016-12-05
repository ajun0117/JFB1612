//
//  MyEvaluateViewController.m
//  JFB
//
//  Created by 李俊阳 on 15/8/24.
//  Copyright (c) 2015年 李俊阳. All rights reserved.
//

#import "MyEvaluateViewController.h"
#import "ShopDetailEvaluateCell.h"
#import "MJRefresh.h"

#define EvaluateCell    @"shopDetailEvaluateCell"

@interface MyEvaluateViewController ()
{
    MBProgressHUD *_hud;
    MBProgressHUD *_networkConditionHUD;
    int currentpage;
    NSMutableArray *_reviewDataArray;
}

@end

@implementation MyEvaluateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"我的评价";
    
    currentpage = 1; //默认首页
    _reviewDataArray = [[NSMutableArray alloc] init];
    
    [self.myTableView registerNib:[UINib nibWithNibName:@"ShopDetailEvaluateCell" bundle:nil] forCellReuseIdentifier:EvaluateCell];
    [self.myTableView addHeaderWithTarget:self action:@selector(headerRefreshing)];
    [self.myTableView addFooterWithTarget:self action:@selector(footerLoadData)];
    self.myTableView.tableFooterView = [UIView new];

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
    
    [self.myTableView headerBeginRefreshing]; //自动刷新
}

#pragma mark - 下拉刷新,上拉加载
-(void)headerRefreshing {
    NSLog(@"下拉刷新");
    [self resetAllSets];
    [self requestGetMyReviewList];
}

-(void)footerLoadData {
    NSLog(@"上拉加载数据");
    currentpage ++;
    [self requestGetMyReviewList];
}

-(void)resetAllSets {
    currentpage = 1;
    [_reviewDataArray removeAllObjects];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_reviewDataArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    NSLog(@"%f",cell.bounds.size.height);
    return cell.bounds.size.height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ShopDetailEvaluateCell *cell = (ShopDetailEvaluateCell *)[tableView dequeueReusableCellWithIdentifier:EvaluateCell];
    NSDictionary *dic = _reviewDataArray [indexPath.row];
    NSString *nickName = dic [@"nickname"];
    cell.memberNameL.text = [[GlobalSetting shareGlobalSettingInstance] transformToStarStringWithString:nickName];
    cell.timeL.text = dic [@"review_time"];
    cell.rateView.rate = [dic [@"score"] floatValue];
    cell.scoreL.text = [NSString stringWithFormat:@"%@分",dic [@"score"]];
    cell.contentL.text = dic [@"content"];
    [cell.contentL sizeToFit];
    CGRect rect = cell.bounds;
    rect.size.height = 8 + cell.memberNameL.bounds.size.height + 5 + cell.rateView.bounds.size.height + 5 + cell.contentL.bounds.size.height + 8 + 21;
    cell.bounds = rect;
    return cell;
}


#pragma mark - 发送请求
-(void)requestGetMyReviewList { //获取订单列表
    [_hud show:YES];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:GetReviewListByMember object:nil];
    
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:GetReviewListByMember, @"op", nil];
    NSString *userID = [[GlobalSetting shareGlobalSettingInstance] userID];
    if (userID == nil) {
        userID = @"";
    }
    NSDictionary *pram = [[NSDictionary alloc] initWithObjectsAndKeys:userID,@"member_id",[NSNumber numberWithInt:currentpage],@"pageindex", nil];
    [[DataRequest sharedDataRequest] postDataWithUrl:RequestURL(GetReviewListByMember) delegate:nil params:pram info:infoDic];
}


#pragma mark - 网络请求结果数据
-(void) didFinishedRequestData:(NSNotification *)notification{
    [_hud hide:YES];
    
    [self.myTableView headerEndRefreshing];
    [self.myTableView footerEndRefreshing];
    
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
    if ([notification.name isEqualToString:GetReviewListByMember]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:GetReviewListByMember object:nil];
        
        NSLog(@"GetMerchantList_responseObject: %@",responseObject);
        if ([responseObject[@"status"] boolValue]) {
            [_reviewDataArray addObjectsFromArray:responseObject [DATA] [@"reviewdata"]];
            [self.myTableView reloadData];
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
