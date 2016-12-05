//
//  MyPensionsViewController.m
//  JFB
//
//  Created by 李俊阳 on 15/8/24.
//  Copyright (c) 2015年 李俊阳. All rights reserved.
//

#import "MyPensionsViewController.h"
#import "PNLineChartView.h"
#import "PNPlot.h"
#import "PensionsTableViewCell.h"
#import "MJRefresh.h"
#import "AppDelegate.h"

#define RecordCell    @"pensionsTableViewCell"

#define yAxisInterval   9

@interface MyPensionsViewController ()
{
    MBProgressHUD *_hud;
    MBProgressHUD *_networkConditionHUD;
    UIDatePicker *_startDatePicker;
    UIDatePicker *_overDatePicker;
    NSArray *_chartArray; //七日走势图数据
    int currentpage;
    NSMutableArray *_recordArray;    //记录数组
}

@property (weak, nonatomic) IBOutlet PNLineChartView *lineChartView;
@property (weak, nonatomic) IBOutlet UILabel *pointL;


@end

@implementation MyPensionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"我的消费收益";
    
    NSLog(@"self.pointL.frame.size.width: %f",self.pointL.frame.size.width);
    self.pointL.layer.cornerRadius = 5;     //圆形
    self.pointL.clipsToBounds = YES;
    
    _recordArray = [[NSMutableArray alloc] init];
    
    self.danweiL.transform = CGAffineTransformMakeRotation(M_PI_2*3);
    
//    self.totalIncomeL.text = [NSString stringWithFormat:@"%@元",[[GlobalSetting shareGlobalSettingInstance] pension]];
    
    currentpage = 1;    //明细初始第一页
    
    [self.myTableView registerNib:[UINib nibWithNibName:@"PensionsTableViewCell" bundle:nil] forCellReuseIdentifier:RecordCell];
    [self.myTableView addHeaderWithTarget:self action:@selector(headerRefreshing)];
    [self.myTableView addFooterWithTarget:self action:@selector(footerLoadData)];
    self.myTableView.tableFooterView = [UIView new];
    
    [self requestGetPensionChart];
    
    UIToolbar *keyboardToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 38.0f)];
    keyboardToolbar.barStyle = UIBarStyleBlackTranslucent;
    UIBarButtonItem *spaceBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                  target:nil
                                                                                  action:nil];
    
    UIBarButtonItem *doneBarItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"完成", @"")
                                                                    style:UIBarButtonItemStyleDone
                                                                   target:self
                                                                   action:@selector(resignKeyboard)];
    [keyboardToolbar setItems:[NSArray arrayWithObjects:spaceBarItem,doneBarItem, nil]];
    
    NSDate *maxDate = [NSDate date];
    
    _startDatePicker = [[UIDatePicker alloc] initWithFrame:CGRectZero];
    _startDatePicker.datePickerMode = UIDatePickerModeDate;
    _startDatePicker.maximumDate = maxDate; //默认最大时间是当天
    [_startDatePicker addTarget:self action:@selector(startDateChanged:) forControlEvents:UIControlEventValueChanged];
    self.startDateTF.inputView = _startDatePicker;
    self.startDateTF.inputAccessoryView = keyboardToolbar;
    //获取当前日期一月前的日期
    NSDate *priousDate = [[GlobalSetting shareGlobalSettingInstance] getPriousorLaterDateFromDate:maxDate withMonth:-1];
    _startDatePicker.date = priousDate;     //默认时间为当前日期一个月前的日期
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *locationString = [formatter stringFromDate: priousDate];
    self.startDateTF.text = locationString;
    
    _overDatePicker = [[UIDatePicker alloc] initWithFrame:CGRectZero];
    _overDatePicker.datePickerMode = UIDatePickerModeDate;
    _overDatePicker.date = maxDate;    //默认时间为当前日期
    _overDatePicker.maximumDate = maxDate; //默认最大时间是当天
    [_overDatePicker addTarget:self action:@selector(overDateChanged:) forControlEvents:UIControlEventValueChanged];
    self.endDateTF.inputView = _overDatePicker;
    self.endDateTF.inputAccessoryView = keyboardToolbar;
    NSDateFormatter *formatter2 = [[NSDateFormatter alloc] init];
    [formatter2 setDateFormat:@"yyyy-MM-dd"];
    NSString *locationString2 = [formatter stringFromDate: maxDate];
    self.endDateTF.text = locationString2;
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

-(void)resignKeyboard{ //回收键盘
    [self.startDateTF resignFirstResponder];
    [self.endDateTF resignFirstResponder];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.startDateTF resignFirstResponder];
    [self.endDateTF resignFirstResponder];
}


-(void)initLineChartViewWithValues:(NSArray *)values dates:(NSArray *)dates {
    
    NSArray* plottingDataValues1 = values;
    
    //求出数组中最大的数
    NSNumber *max = [values valueForKeyPath:@"@max.floatValue"];
    NSNumber *min = [values valueForKeyPath:@"@min.floatValue"];
    self.lineChartView.max = [max floatValue] + 2;
    if ([min floatValue] - 2 > 0) {
        self.lineChartView.min = [min floatValue] - 2;
    }
    else {
        self.lineChartView.min = 0;
    }
    
    self.lineChartView.interval = (self.lineChartView.max - self.lineChartView.min)/yAxisInterval;
    
    NSMutableArray* yAxisValues = [@[] mutableCopy];
    for (int i=0; i < yAxisInterval; ++i) {
        NSString* str = [NSString stringWithFormat:@"%.0f", self.lineChartView.min + self.lineChartView.interval*i];
        [yAxisValues addObject:str];
    }
    
    self.lineChartView.xAxisValues = dates;
    self.lineChartView.yAxisValues = yAxisValues;
    self.lineChartView.axisLeftLineWidth = 15;
    
    PNPlot *plot1 = [[PNPlot alloc] init];
    plot1.plottingValues = plottingDataValues1;
    
    plot1.lineColor = [UIColor redColor];
    plot1.lineWidth = 0.5;
    
    [self.lineChartView addPlot:plot1];

}

- (IBAction)totalIncomeAction:(id)sender {
    if (! _totalIncomeBtn.selected) { //当前按钮没有选中时
        _totalIncomeBtn.selected = YES;
        [_totalIncomeView setBackgroundColor:RGBCOLOR(216, 80, 92)];
        self.chartView.hidden = NO;
        self.LookInfoView.hidden = YES;
        
        _infobtn.selected = NO;
        [_infoView setBackgroundColor:[UIColor clearColor]];
    }
}

- (IBAction)infoAction:(id)sender {
    if (! _infobtn.selected) { //当前按钮没有选中时
        _infobtn.selected = YES;
        [_infoView setBackgroundColor:RGBCOLOR(216, 80, 92)];
        self.chartView.hidden = YES;
        self.LookInfoView.hidden = NO;
        
        _totalIncomeBtn.selected = NO;
        [_totalIncomeView setBackgroundColor:[UIColor clearColor]];
    }
}
- (IBAction)searchAction:(id)sender {
    if ([self.startDateTF.text length] > 0 && [self.endDateTF.text length] > 0) {
        [self requestGetPensionDetails];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请先选择日期！" delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil, nil];
        [alert show];
//        if (!_networkConditionHUD) {
//            _networkConditionHUD = [[MBProgressHUD alloc] initWithView:self.view];
//            [self.view addSubview:_networkConditionHUD];
//        }
//        _networkConditionHUD.labelText = @"请先选择日期！";
//        _networkConditionHUD.mode = MBProgressHUDModeText;
//        _networkConditionHUD.yOffset = APP_HEIGHT/2 - HUDBottomH;
//        _networkConditionHUD.margin = HUDMargin;
//        [_networkConditionHUD show:YES];
//        [_networkConditionHUD hide:YES afterDelay:HUDDelay];
    }
}


-(void)startDateChanged:(id)sender{
    UIDatePicker* control = (UIDatePicker*)sender;
    NSDate* date = control.date;
    _overDatePicker.minimumDate = date; //设置结束时间最小为开始时间
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    //    [formatter setDateFormat:@"yyyy-MM-dd EEEE HH:mm:ss a"];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *locationString = [formatter stringFromDate: date];
    self.startDateTF.text = locationString;
}
-(void)overDateChanged:(id)sender{
    UIDatePicker* control = (UIDatePicker*)sender;
    NSDate* date = control.date;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *locationString = [formatter stringFromDate: date];
    self.endDateTF.text = locationString;
}

#pragma mark - 下拉刷新,上拉加载
-(void)headerRefreshing {
    NSLog(@"下拉刷新个人信息");
    [self resetAllSets];
    [self requestGetPensionDetails];
}

-(void)footerLoadData {
    NSLog(@"上拉加载数据");
    currentpage ++;
    [self requestGetPensionDetails];
}

-(void)resetAllSets {
    currentpage = 1;
    [_recordArray removeAllObjects];
}


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_recordArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    PensionsTableViewCell *cell = (PensionsTableViewCell *)[tableView dequeueReusableCellWithIdentifier:RecordCell];
    NSDictionary *dic = _recordArray [indexPath.row];
    
    cell.oNameL.text = dic [@"oName"];
    cell.dealtimeL.text = [NSString stringWithFormat:@"%@",dic [@"dealtime"]];
    float ratio = [dic [@"ratio"] floatValue] * 100;
    cell.ratioL.text = [NSString stringWithFormat:@"%.1f%%",ratio];
    cell.dealMnyL.text = [NSString stringWithFormat:@"%.2f元",[dic [@"dealMny"] floatValue]];
    cell.pointL.text = [NSString stringWithFormat:@"%.2f元",[dic [@"point"] floatValue]];

    return cell;
}

#pragma mark - 发送请求
-(void)requestGetPensionChart { //获取7日走势图
//        [_hud show:YES];
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [MBProgressHUD showHUDAddedTo:app.window animated:YES];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:GetPensionChart object:nil];
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:GetPensionChart, @"op", nil];
    NSString *member_id = [[GlobalSetting shareGlobalSettingInstance] userID];    //用户ID
    if (member_id == nil) {
        member_id = @"";
    }
    
    NSDictionary *pram = [[NSDictionary alloc] initWithObjectsAndKeys:member_id,@"member_id", nil];
    NSLog(@"pram: %@",pram);
    [[DataRequest sharedDataRequest] postDataWithUrl:RequestURL(GetPensionChart) delegate:nil params:pram info:infoDic];
}



-(void)requestGetPensionDetails { //获取养老金明细
    [_hud show:YES];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:GetPensionDetails object:nil];
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:GetPensionDetails, @"op", nil];
    NSString *member_id = [[GlobalSetting shareGlobalSettingInstance] userID];    //用户ID
    if (member_id == nil) {
        member_id = @"";
    }
    
    NSDictionary *pram = [[NSDictionary alloc] initWithObjectsAndKeys:member_id,@"member_id",self.startDateTF.text,@"start_date",self.endDateTF.text,@"end_date",[NSNumber numberWithInt:currentpage],@"page_index", nil];
    NSLog(@"pram: %@",pram);
    [[DataRequest sharedDataRequest] postDataWithUrl:RequestURL(GetPensionDetails) delegate:nil params:pram info:infoDic];
}




#pragma mark - 网络请求结果数据
-(void) didFinishedRequestData:(NSNotification *)notification{
    [_hud hide:YES];
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [MBProgressHUD hideAllHUDsForView:app.window animated:YES];
    [self.myTableView headerEndRefreshing];
    [self.myTableView footerEndRefreshing];
    
    if ([[notification.userInfo valueForKey:@"RespResult"] isEqualToString:ERROR]) {
        _networkConditionHUD.labelText = [notification.userInfo valueForKey:@"ContentResult"];
        [_networkConditionHUD show:YES];
        [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        return;
    }
    NSDictionary *responseObject = [[NSDictionary alloc] initWithDictionary:[notification.userInfo objectForKey:@"RespData"]];
    
    if ([notification.name isEqualToString:GetPensionChart]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:GetPensionChart object:nil];
        if ([responseObject[@"status"] boolValue]) {
            self.totalIncomeL.text = [NSString stringWithFormat:@"%@元",responseObject[DATA][@"total"]];
            
            _chartArray = responseObject [DATA] [DATA];
            NSMutableArray *values = [[NSMutableArray alloc] init];
            NSMutableArray *dates = [[NSMutableArray alloc] init];
            for (NSDictionary *dic in _chartArray) {
//                [values addObject:@"78"];
                [values addObject:dic [@"value"]];
                [dates addObject:dic [@"date"]];
            }
            
            [self initLineChartViewWithValues:values dates:dates];
            
        }
        else {
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:[responseObject objectForKey:MSG] delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil, nil];
//            [alert show];
            
            _networkConditionHUD.labelText = [responseObject objectForKey:MSG];
            [_networkConditionHUD show:YES];
            [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        }
    }
    
    
    if ([notification.name isEqualToString:GetPensionDetails]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:GetPensionDetails object:nil];
        if ([responseObject[@"status"] boolValue]) {

            [_recordArray addObjectsFromArray:responseObject [DATA]];
            [self.myTableView reloadData];
        }
        else {
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:[responseObject objectForKey:MSG] delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil, nil];
//            [alert show];
            
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
