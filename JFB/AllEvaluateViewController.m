//
//  AllEvaluateViewController.m
//  JFB
//
//  Created by 李俊阳 on 15/9/5.
//  Copyright (c) 2015年 李俊阳. All rights reserved.
//

#import "AllEvaluateViewController.h"
#import "ShopDetailEvaluateCell.h"
#import "MJRefresh.h"

#define EvaluateCell    @"shopDetailEvaluateCell"

@interface AllEvaluateViewController ()
{
    MBProgressHUD *_hud;
    MBProgressHUD *_networkConditionHUD;
    int currentpage;
    NSMutableArray *_evaluateArray;    //评价数组
}

@end

@implementation AllEvaluateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"全部评价";
    
    currentpage = 1; //默认首页
    _evaluateArray = [[NSMutableArray alloc] init];
    
    [self.myTableView registerNib:[UINib nibWithNibName:@"ShopDetailEvaluateCell" bundle:nil] forCellReuseIdentifier:EvaluateCell];
    [self.myTableView addHeaderWithTarget:self action:@selector(headerRefreshing)];
    [self.myTableView addFooterWithTarget:self action:@selector(footerLoadData)];
    self.myTableView.tableFooterView = [UIView new];
    
    [self.myTableView headerBeginRefreshing]; //自动刷新
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

#pragma mark - 下拉刷新,上拉加载
-(void)headerRefreshing {
    NSLog(@"下拉刷新个人信息");
    [self resetAllSets];
    [self requestGetAllEvaluate];
}

-(void)footerLoadData {
    NSLog(@"上拉加载数据");
    currentpage ++;
    [self requestGetAllEvaluate];
}

-(void)resetAllSets {
    currentpage = 1;
    [_evaluateArray removeAllObjects];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_evaluateArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    NSLog(@"%f",cell.bounds.size.height);
    return cell.bounds.size.height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ShopDetailEvaluateCell *cell = (ShopDetailEvaluateCell *)[tableView dequeueReusableCellWithIdentifier:EvaluateCell];
    NSDictionary *dic = _evaluateArray [indexPath.row];
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
-(void)requestGetAllEvaluate { //获取评价列表
    [_hud show:YES];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:GetReviewList object:nil];
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:GetReviewList, @"op", nil];
    NSString *userID = [[GlobalSetting shareGlobalSettingInstance] userID];
    if (userID == nil) {
        userID = @"";
    }
    NSDictionary *pram = [[NSDictionary alloc] initWithObjectsAndKeys:self.merchant_id,@"merchant_id",self.goods_id,@"goods_id",[NSNumber numberWithInt:currentpage],@"pageindex",userID,@"member_id", nil];
    NSLog(@"pram: %@",pram);
    [[DataRequest sharedDataRequest] postDataWithUrl:RequestURL(GetReviewList) delegate:nil params:pram info:infoDic];
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
    
    if ([notification.name isEqualToString:GetReviewList]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:GetReviewList object:nil];
        if ([responseObject[@"status"] boolValue]) {
                [_evaluateArray addObjectsFromArray:responseObject [DATA]];
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
