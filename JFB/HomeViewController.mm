//
//  HomeViewController.m
//  JFB
//
//  Created by 李俊阳 on 15/8/14.
//  Copyright (c) 2015年 李俊阳. All rights reserved.
//

#import "HomeViewController.h"
#import "HomeShopListCell.h"
#import "HomeCityCollectionViewCell.h"
//#import "CityObject.h"
//#import "CountysObject.h"
#import "CitySelectViewController.h"
#import "ShopSearchViewController.h"
#import "ShopMapViewController.h"
#import "ShopDetailViewController.h"
#import "ShopListVC.h"
#import "LoadingView.h"
#import "AJAdView.h"
#import "WebViewController.h"
#import "CityDistrictsCoreObject.h"
#import "AppDelegate.h"
#import "LoginViewController.h"
#import <MobClick.h>

#define Head_View_Height            402     //广告图 + 分类菜单 + 活动
#define Head_ScrollView_Height      180
#define Head_PageControl_Width     80
#define Head_PageControl_Height     30
#define Head_button_Width           40
#define Head_button_Height          60
#define Access_interval_Width        2 //箭头和文字的间隔
#define LeftBtn_MaxWidth            140  //导航左侧按钮最大宽度
#define kTableViewCelllIdentifier      @"HomeShopCell"
#define kCollectionCelllIdentifier      @"HomeCityCollectionCell"

@interface HomeViewController () <AlreadySelectCityDelegate,LoadingViewDelegate,AJAdViewDelegate,UIAlertViewDelegate>
{
    AppDelegate *app;
    MBProgressHUD *_hud;
    MBProgressHUD *_cityHud;
    MBProgressHUD *_firstHud;
    MBProgressHUD *_networkConditionHUD; 
    NSArray *merchantTypeArray;
    BMKLocationService* _locService;
    BMKGeoCodeSearch *_searcher;
    CityDistrictsCoreObject *cityObject;
    NSArray *countysArray;  //区县数组
    NSInteger selectItem; //被选中item的下标
    NSArray *recommendArray; //推荐商户列表数据
    NSString *cityName; //城市名称
    NSString *cityID;   //城市ID
    NSString *current_city_code;
    NSString *countyName; //区县名称
    NSString *countyID;  //区县ID
    NSString *current_county_code;
    NSMutableDictionary *mutabDic; //可变字典用于收集已选参数
    BOOL isChangeToMinCity; //是否显示切换到当前城市
    NSString *locationCityName; //定位城市名
    AJAdView *_adView;
    NSArray *_adArray;   //广告图数组
    NSDictionary *_dazhuanpanDic;    //大转盘
    NSDictionary *_zajindanDic;      //砸金蛋
    UILabel *_textL1;
    UILabel *_detailL1;
    UIImageView *_imgV1;
    UILabel *_textL2;
    UILabel *_detailL2;
    UIImageView *_imgV2;
    BOOL hasLottery;   //抽奖是否有数据
    
    NSString *cityDistricts_Version; //城市区域服务端版本号
    NSString *merchantTypeList_Version; //商户类型服务端版本号
//    BOOL isOpen; //定位城市是否已开通
}
@property (nonatomic, strong) LoadingView *loadingView;//引导视图
@property (nonatomic, strong) UIScrollView *typeScrollView;
@property (nonatomic, strong) UIPageControl *typePageControl;
@property (nonatomic, strong) UIButton *leftButn;
@property (nonatomic, strong) UISearchBar *search;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.navigationBar.translucent = NO;
    self.automaticallyAdjustsScrollViewInsets = NO
    ;
    self.title = @"首页";
    
    _leftButn = [UIButton buttonWithType:UIButtonTypeCustom];
    _leftButn.frame = CGRectMake(0, 9, 100, 26);
    _leftButn.titleLabel.font = [UIFont systemFontOfSize:15];
    [_leftButn setImage:[UIImage imageNamed:@"subject_expand_n"] forState:UIControlStateNormal];
    [_leftButn setImage:[UIImage imageNamed:@"subject_collapse_n"] forState:UIControlStateSelected];
    [_leftButn setTitleEdgeInsets:UIEdgeInsetsMake(0, -12 - Access_interval_Width, 0, 12 + Access_interval_Width)];
    [_leftButn addTarget:self action:@selector(toSelectCity:) forControlEvents:UIControlEventTouchUpInside];
    
    [self adjustLeftBtnFrameWithTitle:@"全部"];
    
//    cityDistricts_Version = [[GlobalSetting shareGlobalSettingInstance] cityDistricts_Version];
//    if (cityDistricts_Version == nil) {
//        cityDistricts_Version = @"1";
//        [[GlobalSetting shareGlobalSettingInstance] setCityDistricts_Version:@"1"];
//    }
    
    merchantTypeList_Version = [[GlobalSetting shareGlobalSettingInstance] merchantTypeList_Version];
    if (merchantTypeList_Version == nil) {
        merchantTypeList_Version = @"1";
        [[GlobalSetting shareGlobalSettingInstance] setMerchantTypeList_Version:@"1"];
    }
    
    
    _search = [[UISearchBar alloc] initWithFrame:CGRectMake( 0, 7, 200, 30)];
    _search.barTintColor = Red_BtnColor;
    _search.tintColor = [UIColor clearColor];
    _search.backgroundColor = [UIColor clearColor];
    _search.delegate = self;
    _search.placeholder = @"输入商家搜索";
    self.navigationItem.titleView = _search;
    
    UIButton *rightButn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightButn.frame = CGRectMake(0, 0, 24, 24);
    rightButn.contentMode = UIViewContentModeScaleAspectFit;
    [rightButn setImage:[UIImage imageNamed:@"pd_sendto"] forState:UIControlStateNormal];
    [rightButn addTarget:self action:@selector(toMapView) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBarButn = [[UIBarButtonItem alloc] initWithCustomView:rightButn];
    self.navigationItem.rightBarButtonItem = rightBarButn;
    
    /**********************/
    app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    [self requestGetLottery];   //因为抽奖视图会变动，所以首先请求
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *appVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];  //上架版本号
    NSString *locationAppVersion = [[GlobalSetting shareGlobalSettingInstance] appVersion];
    
    if (! [[GlobalSetting shareGlobalSettingInstance] isNotFirst] || ! [locationAppVersion isEqual:appVersion]) {   //第一次进入应用
    }
    else {
        [self performSelector:@selector(requestGetCityDistricts) withObject:nil afterDelay:0.1];    //延迟0.1秒
    }
    
    /**********************/
    
    _locService = [[BMKLocationService alloc]init];
    //            初始化检索对象
    _searcher = [[BMKGeoCodeSearch alloc]init];
    
    self.changeCityView.layer.borderColor = Cell_sepLineColor.CGColor;
    self.changeCityView.layer.borderWidth = 1;
    
    //重置tableView的frame，重要！！
    self.myTableView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 49);
    
    [self.myTableView registerNib:[UINib nibWithNibName:@"HomeShopListCell" bundle:nil] forCellReuseIdentifier:kTableViewCelllIdentifier];
    [self.cityCollectionView registerNib:[UINib nibWithNibName:@"HomeCityCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:kCollectionCelllIdentifier];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelSelectCity)];
    [self.citySelectBgView addGestureRecognizer:tap];
    
    mutabDic = [[NSMutableDictionary alloc] init];
    selectItem = 0;
    cityID = @"";
    cityName = @"";
    countyID = @"";
    countyName = @"";
    current_city_code = @"";
    current_county_code = @"";
    isChangeToMinCity = YES;    //是否弹框显示定位城市
    
    NSMutableDictionary *dic = [[GlobalSetting shareGlobalSettingInstance] homeSelectedDic];
    NSLog(@"dic: %@",dic);
    if (dic != nil) {
        selectItem = [dic[@"selectItem"] integerValue];
        cityID = dic[@"cityID"];
        current_city_code = dic [@"current_city_code"];
        cityName = dic [@"areaName"];
        countyID = dic[@"countyID"];
        current_county_code = dic [@"current_county_code"];
        countyName = dic[@"countName"];
        
        if (! [dic[@"countName"] isEqualToString:@""]) {
            countyName = [NSString stringWithFormat:@"--%@",dic[@"countName"]];     //增加“--”分隔符
        }
        
        self.currentCityL.text = cityName;
        
        [self adjustLeftBtnFrameWithTitle:[NSString stringWithFormat:@"%@%@",cityName,countyName]];
        
        CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
        if (kCLAuthorizationStatusDenied == status || kCLAuthorizationStatusRestricted == status) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请到设置-隐私-定位服务中打开定位权限！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
        }
//        [_locService startUserLocationService];     //本地存在省市数据的情况下发起定位
        
        //加载用户选择的数据后直接请求数据
        [self requestGetRecommendShopListWithLocationDic:[[GlobalSetting shareGlobalSettingInstance] myLocation]];
    }
    

}

-(void) initTableViewHeadView {
    if (hasLottery) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, Head_View_Height)];
        view.backgroundColor = RGBCOLOR(235, 235, 241);
        self.myTableView.tableHeaderView = view;
        
//        CGFloat leftOffset;
//        if (isIOS8Later) {  //iOS8.0以上版本
//            leftOffset = 0;
//        }
//        else {               //iOS7.0+
//            leftOffset = 8;
//        }
        
        _adView = [[AJAdView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 120)];
        _adView.delegate = self;
        [view addSubview:_adView];
        
        UILabel *lineL1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 120, SCREEN_WIDTH, 0.5)];
        lineL1.backgroundColor = Cell_sepLineColor;
        [view addSubview:lineL1];
        
        
        UILabel *lineL2 = [[UILabel alloc] initWithFrame:CGRectMake(0, 131 - 0.5, SCREEN_WIDTH, 0.5)];
        lineL2.backgroundColor = Cell_sepLineColor;
        [view addSubview:lineL2];
        
        self.typeScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 131, SCREEN_WIDTH, Head_ScrollView_Height)];
        self.typeScrollView.backgroundColor = [UIColor whiteColor];
        self.typeScrollView.pagingEnabled = YES;
        self.typeScrollView.showsHorizontalScrollIndicator = NO;
        self.typeScrollView.delegate = self;
        [view addSubview:self.typeScrollView];
        
        self.typePageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, 131 + Head_ScrollView_Height - 30, SCREEN_WIDTH, 30)];
        self.typePageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
        self.typePageControl.currentPageIndicatorTintColor = RGBCOLOR(229, 24, 35);
        [view addSubview:self.typePageControl];
        
        UILabel *lineL3 = [[UILabel alloc] initWithFrame:CGRectMake(0, 131 + Head_ScrollView_Height, SCREEN_WIDTH, 0.5)];
        lineL3.backgroundColor = Cell_sepLineColor;
        [view addSubview:lineL3];

        UIView *activityView = [[UIView alloc] initWithFrame:CGRectMake(0, 132 + Head_ScrollView_Height + 10, SCREEN_WIDTH, 80)];
        activityView.backgroundColor = [UIColor whiteColor];
        
        UILabel *lineL4 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0.5)];
        lineL4.backgroundColor = Cell_sepLineColor;
        [activityView addSubview:lineL4];
        
        UILabel *textL1 = [[UILabel alloc] initWithFrame:CGRectMake(10, 15, SCREEN_WIDTH / 2 - 68, 21)];
        textL1.font = [UIFont systemFontOfSize:15];
        _textL1 = textL1;
        [activityView addSubview:_textL1];
        UILabel *detailL1 = [[UILabel alloc] initWithFrame:CGRectMake(10, 35, SCREEN_WIDTH / 2 - 68, 42)];
        detailL1.font = [UIFont systemFontOfSize:14];
        detailL1.numberOfLines = 2;
        _detailL1 = detailL1;
        [activityView addSubview:_detailL1];
        UIImageView *imgV1 = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH / 2 - 60, 15, 50, 50)];
        _imgV1 = imgV1;
        [activityView addSubview:_imgV1];
        
        UIButton *button1 = [UIButton buttonWithType:UIButtonTypeCustom];
        button1.frame = CGRectMake(0, 0, SCREEN_WIDTH / 2, 80);
        [button1 addTarget:self action:@selector(choujiang) forControlEvents:UIControlEventTouchUpInside];
        [activityView addSubview:button1];
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH / 2, 0, 0.5, 80)];
        lineView.backgroundColor = Cell_sepLineColor;
        [activityView addSubview:lineView];
        
        UILabel *textL2 = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH / 2 + 10, 15, SCREEN_WIDTH / 2 - 68, 21)];
        textL2.font = [UIFont systemFontOfSize:15];
        _textL2 = textL2;
        [activityView addSubview:_textL2];
        UILabel *detailL2 = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH / 2 + 10, 35, SCREEN_WIDTH / 2 - 68, 42)];
        detailL2.font = [UIFont systemFontOfSize:14];
        detailL2.numberOfLines = 2;
        _detailL2 = detailL2;
        [activityView addSubview:_detailL2];
        UIImageView *imgV2 = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 60, 15, 50, 50)];
        _imgV2 = imgV2;
        [activityView addSubview:_imgV2];
        
        UIButton *button2 = [UIButton buttonWithType:UIButtonTypeCustom];
        button2.frame = CGRectMake(SCREEN_WIDTH / 2, 0, SCREEN_WIDTH / 2, 80);
        [button2 addTarget:self action:@selector(zajindan) forControlEvents:UIControlEventTouchUpInside];
        [activityView addSubview:button2];
        
        UILabel *lineL5 = [[UILabel alloc] initWithFrame:CGRectMake(0, activityView.frame.size.height - 0.5, SCREEN_WIDTH, 0.5)];
        lineL5.backgroundColor = Cell_sepLineColor;
        [activityView addSubview:lineL5];
        
        [view addSubview:activityView];
    }
    else {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 131 + Head_ScrollView_Height)];
        view.backgroundColor = RGBCOLOR(235, 235, 241);
        self.myTableView.tableHeaderView = view;
        
//        CGFloat leftOffset;
//        if (isIOS8Later) {  //iOS8.0以上版本
//            leftOffset = 0;
//        }
//        else {               //iOS7.0+
//            leftOffset = 8;
//        }
        
        _adView = [[AJAdView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 120)];
        _adView.delegate = self;
        [view addSubview:_adView];
        
        UILabel *lineL1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 120, SCREEN_WIDTH, 0.5)];
        lineL1.backgroundColor = Cell_sepLineColor;
        [view addSubview:lineL1];
        
        
        UILabel *lineL2 = [[UILabel alloc] initWithFrame:CGRectMake(0, 131 - 0.5, SCREEN_WIDTH, 0.5)];
        lineL2.backgroundColor = Cell_sepLineColor;
        [view addSubview:lineL2];
        
        self.typeScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 131, SCREEN_WIDTH, Head_ScrollView_Height)];
        self.typeScrollView.backgroundColor = [UIColor whiteColor];
        self.typeScrollView.pagingEnabled = YES;
        self.typeScrollView.showsHorizontalScrollIndicator = NO;
        self.typeScrollView.delegate = self;
        [view addSubview:self.typeScrollView];
        
        self.typePageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, 131 + Head_ScrollView_Height - 30, SCREEN_WIDTH, 30)];
        self.typePageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
        self.typePageControl.currentPageIndicatorTintColor = RGBCOLOR(229, 24, 35);
        [view addSubview:self.typePageControl];
        
        UILabel *lineL3 = [[UILabel alloc] initWithFrame:CGRectMake(0, 131 + Head_ScrollView_Height, SCREEN_WIDTH, 0.5)];
        lineL3.backgroundColor = Cell_sepLineColor;
        [view addSubview:lineL3];
    }
    
    //在这之后再进行首页tableView头视图的数据加载
    NSDictionary *typeDic = [[GlobalSetting shareGlobalSettingInstance] merchantTypeList];
    NSLog(@"typeDic: %@",typeDic);
    if (typeDic != nil) {   //本地存在，直接加载，并发起版本号校验
        merchantTypeArray = typeDic [DATA];
        NSLog(@"merchantTypeArray:%@",merchantTypeArray);
        [self initHeadScrollViewWithArray:merchantTypeArray];
        
        //发起商户类型版本号校验
        [self requestGetMerchantTypeList_Version];
    }
    else {
        [self requestGetMerchantTypeList];
    }
    
    if (! [cityName isEqualToString:@""]) {
        cityObject = [app selectDataWithName:cityName];    //获取对应城市对象
        NSString *parentID = cityObject.areaId;
        countysArray = [app selectDataWithParentID:parentID];   //获取对应区县数组对象
        [self.cityCollectionView reloadData];   //刷新区县列表
    }

    [self requestGetBanner];
}

-(void)adjustLeftBtnFrameWithTitle:(NSString *)str {
    NSDictionary *attributes = @{NSFontAttributeName : _leftButn.titleLabel.font};
    CGSize size = [str sizeWithAttributes:attributes];
    NSLog(@"size: %@",NSStringFromCGSize(size));
    if (size.width <= LeftBtn_MaxWidth) {
        _leftButn.frame = CGRectMake(0, 9, size.width + 12 + Access_interval_Width, size.height);
    }
    else {
        _leftButn.frame = CGRectMake(0, 9, LeftBtn_MaxWidth + 12 + Access_interval_Width, size.height);
    }
    
    [_leftButn setImageEdgeInsets:UIEdgeInsetsMake(0, _leftButn.frame.size.width - 12, 0, 0)];
    [_leftButn setTitle:str forState:UIControlStateNormal];
    UIBarButtonItem *leftBarBtn = [[UIBarButtonItem alloc] initWithCustomView:_leftButn];
    self.navigationItem.leftBarButtonItem = leftBarBtn;
}

#pragma mark - AJAdViewDelegate
- (NSInteger)numberInAdView:(AJAdView *)adView{
    return [_adArray count];
}

- (NSString *)imageUrlInAdView:(AJAdView *)adView index:(NSInteger)index{
    return _adArray[index] [@"img_url"];
}

- (NSString *)titleStringInAdView:(AJAdView *)adView index:(NSInteger)index {
    return _adArray[index] [@"title"];
}

- (void)adView:(AJAdView *)adView didSelectIndex:(NSInteger)index{
    NSLog(@"--%ld--",(long)index);
    NSDictionary *dic = _adArray [index];
    WebViewController *web = [[WebViewController alloc] init];
    web.webUrlStr = dic [@"link_url"];
    web.titleStr = dic [@"title"];
    web.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:web animated:YES];
}

#pragma mark - 活动actions
-(void)choujiang {  //大转盘
    BOOL isLogined = [[GlobalSetting shareGlobalSettingInstance] isLogined];
    
    if (isLogined) {    //已登录
        WebViewController *web = [[WebViewController alloc] init];
        NSString *urlStr = [NSString stringWithFormat:@"%@?m=%@&mobile=%@",_dazhuanpanDic [@"UrlPath"],[[GlobalSetting shareGlobalSettingInstance] userID],[[GlobalSetting shareGlobalSettingInstance] mMobile]];
        web.webUrlStr = urlStr;
        web.titleStr = _dazhuanpanDic [@"Title"];
        web.canShare = YES; //设置可分享
        web.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:web animated:YES];
    }
    else {  //未登录
//        if (!_networkConditionHUD) {
//            _networkConditionHUD = [[MBProgressHUD alloc] initWithView:self.view];
//            [self.view addSubview:_networkConditionHUD];
//        }
//        _networkConditionHUD.labelText = @"请先登录";
//        _networkConditionHUD.mode = MBProgressHUDModeText;
//        _networkConditionHUD.yOffset = APP_HEIGHT/2 - HUDBottomH;
//        _networkConditionHUD.margin = HUDMargin;
//        [_networkConditionHUD show:YES];
//        [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您还没有登录，请先登录！" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alert.tag = 4040;
        [alert show];
    }
}

-(void)zajindan {   //砸金蛋
    BOOL isLogined = [[GlobalSetting shareGlobalSettingInstance] isLogined];
    
    if (isLogined) {    //已登录
        WebViewController *web = [[WebViewController alloc] init];
        NSString *urlStr = [NSString stringWithFormat:@"%@?m=%@&mobile=%@",_zajindanDic [@"UrlPath"],[[GlobalSetting shareGlobalSettingInstance] userID],[[GlobalSetting shareGlobalSettingInstance] mMobile]];
        web.webUrlStr = urlStr;
        web.titleStr = _zajindanDic [@"Title"];
        web.canShare = YES; //设置可分享
        web.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:web animated:YES];
    }
    else {  //未登录
//        if (!_networkConditionHUD) {
//            _networkConditionHUD = [[MBProgressHUD alloc] initWithView:self.view];
//            [self.view addSubview:_networkConditionHUD];
//        }
//        _networkConditionHUD.labelText = @"请先登录";
//        _networkConditionHUD.mode = MBProgressHUDModeText;
//        _networkConditionHUD.yOffset = APP_HEIGHT/2 - HUDBottomH;
//        _networkConditionHUD.margin = HUDMargin;
//        [_networkConditionHUD show:YES];
//        [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您还没有登录，请先登录！" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alert.tag = 4040;
        [alert show];
    }
}

#pragma mark - UISearchBarDelegate
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    NSLog(@"推出搜索页");
    ShopSearchViewController *searchVC = [[ShopSearchViewController alloc] init];
    searchVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:searchVC animated:YES];
    return NO;
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if (! _hud) {
        _hud = [[MBProgressHUD alloc] initWithView:app.window];
        [app.window addSubview:_hud];
    }
    
    if (!_networkConditionHUD) {
        _networkConditionHUD = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:_networkConditionHUD];
    }
    _networkConditionHUD.mode = MBProgressHUDModeText;
    _networkConditionHUD.yOffset = APP_HEIGHT/2 - HUDBottomH;
    _networkConditionHUD.margin = HUDMargin;
    
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *appVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];  //上架版本号
    NSString *locationAppVersion = [[GlobalSetting shareGlobalSettingInstance] appVersion];
    if (! [[GlobalSetting shareGlobalSettingInstance] isNotFirst] || ! [locationAppVersion isEqual:appVersion]) {   //第一次进入应用
    
//        if (! _firstHud) {
//            _firstHud = [[MBProgressHUD alloc] initWithWindow:app.window];
//            _firstHud.labelText = @"正在更新城市数据...";
//            [app.window addSubview:_firstHud];
//        }
//        [_firstHud show:YES];
//        
////        dispatch_async(dispatch_get_global_queue(0, 0), ^{
//    
//            NSError* err = nil;
//            NSString* dataPath = [[NSBundle mainBundle] pathForResource:@"CityDistricts" ofType:@"json"];
//            NSArray* cityDistricts = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:dataPath] options:kNilOptions error:&err];
//            //        NSLog(@"Importd cityDistricts: %@", cityDistricts);
////            if ([[app selectAllCoreObject] count] == 0) {
//            [app deleteAllObjects];
//                for (NSDictionary *dic in cityDistricts) {
//                    [app insertCoreDataWithObjectItem:dic];
//                }
////            }
//            
////            dispatch_async(dispatch_get_main_queue(), ^{
////                    //（需要放在主线程中执行UI更新）
//////                [_firstHud hide:YES];
////            });
////        });

    
//        //复制本地数据库文件到安装目录-------------------------------------------------------------------//
        NSString *docs = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        //CoreData是建立在SQLite之上的，数据库名称需与Xcdatamodel文件同名
        NSURL *storeUrl = [NSURL fileURLWithPath:[docs stringByAppendingPathComponent:@"JFB.sqlite"]];
        NSURL *storeUrl1 = [NSURL fileURLWithPath:[docs stringByAppendingPathComponent:@"JFB.sqlite-shm"]];
        NSURL *storeUrl2 = [NSURL fileURLWithPath:[docs stringByAppendingPathComponent:@"JFB.sqlite-wal"]];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:[storeUrl path]]) {
            NSURL *preloadURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"JFB" ofType:@"sqlite"]];
            NSError* err = nil;
            if (![[NSFileManager defaultManager] copyItemAtURL:preloadURL toURL:storeUrl error:&err]) {
                NSLog(@"Oops, could copy preloaded data");
            }
            
            NSURL *preloadURL1 = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"JFB" ofType:@"sqlite-shm"]];
            if (![[NSFileManager defaultManager] copyItemAtURL:preloadURL1 toURL:storeUrl1 error:&err]) {
                NSLog(@"Oops, could copy preloaded data");
            }
            
            NSURL *preloadURL2 = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"JFB" ofType:@"sqlite-wal"]];
            if (![[NSFileManager defaultManager] copyItemAtURL:preloadURL2 toURL:storeUrl2 error:&err]) {
                NSLog(@"Oops, could copy preloaded data");
            }
        }
//----------------------------------------------------------------------------------//

    }
    
    //注册通知，当城市列表数据下载完成后调用
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didAlreadyDownLoadCityCountys:) name:@"CityCountysAlreadyDownLoad" object:nil];
}

-(void)viewWillAppear:(BOOL)animated {
    _locService.delegate = self;
    _searcher.delegate = self;
    [MobClick beginLogPageView:@"JFB_HomePage"];
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *appVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];  //上架版本号
    NSString *locationAppVersion = [[GlobalSetting shareGlobalSettingInstance] appVersion];
    
    if (! [[GlobalSetting shareGlobalSettingInstance] isNotFirst] || ! [locationAppVersion isEqual:appVersion]) {
        NSArray *imageArr = nil;//@[@"guide1.png",@"guide2.png",@"guide3.png"];
        imageArr = @[@"guide1",@"guide2",@"guide3"];
        
        self.loadingView = [[LoadingView alloc] initWithFrame:CGRectMake(0, 0, APP_WIDTH, APP_HEIGHT + 20) withImagesArr:imageArr];
        
        self.loadingView.delegate = self;
        
        app = (AppDelegate *)[UIApplication sharedApplication].delegate;
        
        [app.window addSubview:self.loadingView];
        
//        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
//        NSString *appVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];  //上架版本号
//        [[GlobalSetting shareGlobalSettingInstance] setAppVersion:appVersion];
//        [[GlobalSetting shareGlobalSettingInstance] setIsNotFirst:YES];
//        
//        [self requestGetCityDistricts];
    }
}

-(void)viewWillDisappear:(BOOL)animated {
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"CityCountysAlreadyDownLoad" object:nil];
    _locService.delegate = nil;
    _searcher.delegate = nil;
    [MobClick endLogPageView:@"JFB_HomePage"];
}


//#pragma mark -省市数据下载完成后调用通知
//-(void)didAlreadyDownLoadCityCountys:(NSNotification *)notification {
//    if ([notification.name isEqualToString:@"CityCountysAlreadyDownLoad"]) {
//        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"CityCountysAlreadyDownLoad" object:nil];
//        
//        CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
//        if (kCLAuthorizationStatusDenied == status || kCLAuthorizationStatusRestricted == status) {
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请到设置-隐私-定位服务中打开定位权限！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//            [alert show];
//        }
//        
//        [_locService startUserLocationService];
//    }
//}

#pragma mark -
#pragma mark LoadingViewDelegate
//引导页消失的方式
-(void)didEnterAppWithStyle:(NSInteger)style{
    if (style == 1) {
        [self loadingViewDisappearAnimation];
    }
    else {
        [self.loadingView removeFromSuperview];
        self.loadingView = nil;
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        NSString *appVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];  //上架版本号
        [[GlobalSetting shareGlobalSettingInstance] setAppVersion:appVersion];
        [[GlobalSetting shareGlobalSettingInstance] setIsNotFirst:YES];
        
        [self requestGetCityDistricts];
    }
}

//引导页消失的动画
-(void) loadingViewDisappearAnimation{
    [UIView animateWithDuration:1 animations:^{
        self.loadingView.transform = CGAffineTransformMakeScale(2, 2);
        self.loadingView.alpha = 0;
    } completion:^(BOOL finished) {
        if (finished) {
            self.loadingView.transform = CGAffineTransformIdentity;
            [self.loadingView removeFromSuperview];
            self.loadingView = nil;
            NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
            NSString *appVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];  //上架版本号
            [[GlobalSetting shareGlobalSettingInstance] setAppVersion:appVersion];
            [[GlobalSetting shareGlobalSettingInstance] setIsNotFirst:YES];
            
            [self requestGetCityDistricts];
        }
    }];
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


#pragma mark - 定位代理
//实现相关delegate 处理位置信息更新
//处理方向变更信息
//- (void)didUpdateUserHeading:(BMKUserLocation *)userLocation
//{
//    NSLog(@"heading is %@",userLocation.heading);
//}

- (void)didFailToLocateUserWithError:(NSError *)error {
    [_locService stopUserLocationService];
    
    /************  定位失败，赋初值 *************/
    NSDictionary *locationDic = [NSDictionary dictionaryWithObjectsAndKeys:Latitude,@"latitude",Longitude,@"longitude", nil];
    //存储当前位置坐标
    [[GlobalSetting shareGlobalSettingInstance] setMyLocationWithDic:locationDic];
    NSLog(@"error is %@",[error description]);
    
    if ([cityName isEqualToString:@""] || cityName == nil) { //如果用户还没有选择过城市，那么默认显示定位城市名
        NSString *msgStr = [NSString stringWithFormat:@"获取位置信息失败！将为您展示默认城市的商家信息"];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:msgStr delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        alert.tag = 555;
        [alert show];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"定位失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }
}

//处理位置坐标更新
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
    NSLog(@"didUpdateUserLocation lat %f,long %f",userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude);
    if (userLocation) {
        [_locService stopUserLocationService];
        
        
        NSString *locationCoordinateStr = [NSString stringWithFormat:@"{\"latitude\":%f,\"longitude\":%f}",userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude];
        NSLog(@"locationCoordinateStr: %@",locationCoordinateStr);
        
        NSString *lat = [NSString stringWithFormat:@"%f",userLocation.location.coordinate.latitude];
        NSString *lon = [NSString stringWithFormat:@"%f",userLocation.location.coordinate.longitude];
        NSDictionary *locationDic = [NSDictionary dictionaryWithObjectsAndKeys:lat,@"latitude",lon,@"longitude", nil];
        //存储当前位置坐标
        [[GlobalSetting shareGlobalSettingInstance] setMyLocationWithDic:locationDic];

        [self getReverseGeoCodeWithLocation:userLocation];
    }
}

-(void)getReverseGeoCodeWithLocation:(BMKUserLocation *)userLocation
{
//    CLLocationCoordinate2D coor;
//    coor.latitude = [@"45" doubleValue];
//    coor.longitude = [@"75" doubleValue];
    
    //            发起反向地理编码检索
    CLLocationCoordinate2D pt = userLocation.location.coordinate;
    NSLog(@"%lf,%lf",pt.latitude,pt.longitude);
    BMKReverseGeoCodeOption *reverseGeoCodeSearchOption = [[
                                                            BMKReverseGeoCodeOption alloc]init];
    reverseGeoCodeSearchOption.reverseGeoPoint = pt;
    BOOL flag = [_searcher reverseGeoCode:reverseGeoCodeSearchOption];
    if(flag)
    {
        NSLog(@"反geo检索发送成功");
    }
    else
    {
        NSLog(@"反geo检索发送失败");
    }
}

//接收反向地理编码结果
-(void) onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:
(BMKReverseGeoCodeResult *)result
                        errorCode:(BMKSearchErrorCode)error{
    if (error == BMK_SEARCH_NO_ERROR) {
        //      在此处理正常结果
        NSLog(@"result.addressDetail.city: %@,result.addressDetail.streetName: %@,result.address: %@",result.addressDetail.city,result.addressDetail.streetName,result.address);
        NSString *cityNameStr = result.addressDetail.city;
            if ([cityName isEqualToString:@""] || cityName == nil) { //如果用户还没有选择过城市，那么默认显示定位城市名
                if ([cityNameStr length] > 0) {
                    locationCityName = cityNameStr;
                    self.currentCityL.text = locationCityName;
                    if ([[app selectAllCoreObject] count]) {
                        CityDistrictsCoreObject *cityInfo = [app selectDataWithName:locationCityName];
                        
                     if (! [cityInfo.isopen boolValue]) {
                            NSString *msgStr = [NSString stringWithFormat:@"您当前定位的城市为【%@】暂未开通！请选择一个城市！",locationCityName];
                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:msgStr delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
                            alert.tag = 888;
                            [alert show];
                        }
                        cityObject = cityInfo;
                        NSString *parentID = cityObject.areaId;
                        countysArray = [app selectDataWithParentID:parentID];   //获取对应区县数组对象
                        cityID = cityInfo.areaId;
                        current_city_code = cityInfo.current_code;
                        cityName = cityInfo.areaName;
                        countyID = @"";
                        countyName = @"";
                        current_county_code = @"";
                        
                        [mutabDic setObject:[NSNumber numberWithInteger:0] forKey:@"selectItem"];  //更新字典中selectItem的值
                        [mutabDic setObject:cityID forKey:@"cityID"];
                        [mutabDic setObject:cityName forKey:@"areaName"];
                        [mutabDic setObject:countyID forKey:@"countyID"];
                        [mutabDic setObject:countyName forKey:@"countName"];
                        [mutabDic setObject:current_city_code forKey:@"current_city_code"];
                        [mutabDic setObject:current_county_code forKey:@"current_county_code"];
                        NSLog(@"mutabDic: %@",mutabDic);
                        [[GlobalSetting shareGlobalSettingInstance] setHomeSelectedDic:mutabDic];
                        
                        [self.cityCollectionView reloadData];   //刷新地址
                        
                        [self adjustLeftBtnFrameWithTitle:locationCityName];
                        
                        //定位成功并赋值成功后刷新推荐商户数据
                        [self requestGetRecommendShopListWithLocationDic:[[GlobalSetting shareGlobalSettingInstance] myLocation]];
                    }
                    else {
                        NSString *msgStr = [NSString stringWithFormat:@"全国省市区县数据未下载成功，请点击确定按钮重新下载！"];
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:msgStr delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                        alert.tag = 111;
                        [alert show];
                    }
                }
                else {
                    NSString *msgStr = [NSString stringWithFormat:@"获取位置信息失败！将为您展示默认城市的商家信息"];
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:msgStr delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                    alert.tag = 555;
                    [alert show];
                }
            }
            else if (cityName != nil) {
                if ([cityNameStr length] > 0) {
                    CityDistrictsCoreObject *cityInfo = [app selectDataWithName:locationCityName];
                    if (! [cityName isEqualToString:locationCityName] && isChangeToMinCity && [cityInfo.isopen boolValue]) {  //定位城市与本地存储的城市民不一致，则提示用户
                        NSString *msgStr = [NSString stringWithFormat:@"您当前定位的城市为【%@】是否需要切换到该城市？",locationCityName];
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:msgStr delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                        alert.tag = 666;
                        [alert show];
                    }
                }
                else {
                    
                }
            }
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"获取城市信息失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }
}



#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 555) {
        self.currentCityL.text = @"衡阳市";
        NSLog(@"count: %lu",(unsigned long)[[app selectAllCoreObject] count]);
        if ([[app selectAllCoreObject] count]) {
            CityDistrictsCoreObject *cityInfo = [app selectDataWithName:@"衡阳市"];
            cityObject = cityInfo;
            NSString *parentID = cityObject.areaId;
            countysArray = [app selectDataWithParentID:parentID];   //获取对应区县数组对象
            cityID = cityInfo.areaId;
            current_city_code = cityInfo.current_code;
            cityName = cityInfo.areaName;
            countyID = @"";
            countyName = @"";
            current_county_code = @"";
            
            [mutabDic setObject:[NSNumber numberWithInteger:0] forKey:@"selectItem"];  //更新字典中selectItem的值
            [mutabDic setObject:cityID forKey:@"cityID"];
            [mutabDic setObject:cityName forKey:@"areaName"];
            [mutabDic setObject:countyID forKey:@"countyID"];
            [mutabDic setObject:countyName forKey:@"countName"];
            [mutabDic setObject:current_city_code forKey:@"current_city_code"];
            [mutabDic setObject:current_county_code forKey:@"current_county_code"];
            NSLog(@"mutabDic: %@",mutabDic);
            [[GlobalSetting shareGlobalSettingInstance] setHomeSelectedDic:mutabDic];
            
            [self.cityCollectionView reloadData];   //刷新地址
            
            [self adjustLeftBtnFrameWithTitle:@"衡阳市"];
            
            //定位成功并赋值成功后刷新推荐商户数据
            [self requestGetRecommendShopListWithLocationDic:[[GlobalSetting shareGlobalSettingInstance] myLocation]];
        }
        else {
            NSString *msgStr = [NSString stringWithFormat:@"全国省市区县数据未下载成功，请点击确定按钮重新下载！"];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:msgStr delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            alert.tag = 111;
            [alert show];
        }
    }
    else if (alertView.tag == 666) {
        isChangeToMinCity = NO;
        if (buttonIndex == 1) {
            //切换回当前定位城市
            self.currentCityL.text = locationCityName;
    
            CityDistrictsCoreObject *cityInfo = [app selectDataWithName:locationCityName];
            cityObject = cityInfo;
            NSString *parentID = cityObject.areaId;
            countysArray = [app selectDataWithParentID:parentID];   //获取对应区县数组对象
            cityID = cityInfo.areaId;
            cityName = cityInfo.areaName;
            countyID = @"";
            countyName = @"";
            current_city_code = cityInfo.current_code;
            current_county_code = @"";

        
            [mutabDic setObject:[NSNumber numberWithInteger:0] forKey:@"selectItem"];  //更新字典中selectItem的值
            [mutabDic setObject:cityID forKey:@"cityID"];
            [mutabDic setObject:cityName forKey:@"areaName"];
            [mutabDic setObject:countyID forKey:@"countyID"];
            [mutabDic setObject:countyName forKey:@"countName"];
            [mutabDic setObject:current_city_code forKey:@"current_city_code"];
            [mutabDic setObject:current_county_code forKey:@"current_county_code"];
            NSLog(@"mutabDic: %@",mutabDic);
            [[GlobalSetting shareGlobalSettingInstance] setHomeSelectedDic:mutabDic];
            
            [self.cityCollectionView reloadData];   //刷新地址
            
            [self adjustLeftBtnFrameWithTitle:locationCityName];
            
            //定位成功并赋值成功后刷新推荐商户数据
            [self requestGetRecommendShopListWithLocationDic:[[GlobalSetting shareGlobalSettingInstance] myLocation]];
        }
    }
    else if (alertView.tag == 888) {
        CitySelectViewController *selectVC = [[CitySelectViewController alloc] init];
//        selectVC.citysDic = chongzuDic;
        selectVC.selectDelegate = self;
        selectVC.isMustSelect = YES;
        selectVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:selectVC animated:YES];
    }
    else if (alertView.tag == 4040) {
        if (buttonIndex == 1) {
            LoginViewController *loginVC = [[LoginViewController alloc] init];
            loginVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:loginVC animated:YES];
        }
    }
    else if (alertView.tag == 111) {
        [self requestGetCityDistricts];     //重新下载省市数据
    }
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [recommendArray count] + 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0 || indexPath.row == [recommendArray count] +1) {
        return 44;
    }
    return 100;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        cell.textLabel.text = @"附近商家";
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    else if (indexPath.row == [recommendArray count] +1) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.text = @"查看所有商家";
        return cell;
    }
    else {
        NSDictionary *dic = recommendArray[indexPath.row -1];
        
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
    if (indexPath.row == 0) {
        
    }
    else if (indexPath.row == [recommendArray count] + 1) {
        NSLog(@"查看全部商家");
        ShopListVC *listVC = [[ShopListVC alloc] init];
        listVC.menu_subtitle = @"全部分类";
        listVC.menu_code = @"";
        listVC.typeID = @"";
        [listVC.typeBtn setTitle:@"全部分类" forState:UIControlStateNormal];
        listVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:listVC animated:YES];
    }
    else {
        NSDictionary *dic = recommendArray [indexPath.row - 1];
        ShopDetailViewController *detailVC = [[ShopDetailViewController alloc] init];
        detailVC.merchantdataDic = dic;
        detailVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:detailVC animated:YES];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark - 顶部商家类型视图
-(void)initHeadScrollViewWithArray:(NSArray *)dataArray {
    
    int page = (int)  (([dataArray count] - 1) / 8 + 1); //总页数
    if (page > 1) {
        self.typePageControl.hidden = NO;
    }
    else {
        self.typePageControl.hidden = YES;
    }
    self.typePageControl.numberOfPages = page;
    
    self.typeScrollView.contentSize = CGSizeMake(page * SCREEN_WIDTH, Head_ScrollView_Height);
    
    int margin = (SCREEN_WIDTH - Head_button_Width * 4 - 15 * 2) / 3; //按钮列间距
    int rowMargin = Head_ScrollView_Height - Head_PageControl_Height - Head_button_Height * 2 - 15; //按钮行间距
    
    int p = 0;
    for (int a = 0; a < page; ++ a) {
        for (int m = 0; m < 2; ++ m) {
            for (int n = 0; n < 4; ++ n) {
                if (p < [dataArray count]) {
                    NSDictionary *dic = [dataArray objectAtIndex:p];
                    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                    button.frame = CGRectMake(15 + n * (40 + margin) + a * SCREEN_WIDTH , 10 + m * (60 + rowMargin), Head_button_Width, Head_button_Height);
                    button.imageEdgeInsets = UIEdgeInsetsMake(0, 0, Head_button_Height - Head_button_Width, 0);
                    button.tag = p + 1000;
                    [button sd_setImageWithURL:[NSURL URLWithString:[dic objectForKey:@"icon_url"]] forState:UIControlStateNormal placeholderImage:IMG(@"bg_merchant_photo_placeholder")];
                    
                    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                    UILabel *subtitleL = [[UILabel alloc] initWithFrame:CGRectMake(-10, 40, 60, 20)];
                    subtitleL.textAlignment = NSTextAlignmentCenter;
                    subtitleL.font = [UIFont systemFontOfSize:13];
                    subtitleL.text = [dic objectForKey:@"menu_subtitle"];
                    [button addSubview:subtitleL];
                    
                    [button addTarget:self action:@selector(buttontouchAction:) forControlEvents:UIControlEventTouchUpInside];
                    
                    [self.typeScrollView addSubview:button];
                }
                p ++;
            }
        }
    }
}


-(void)buttontouchAction:(UIButton *)sender {
    NSLog(@"sender.tag: %ld",(long)sender.tag);
    NSDictionary *dic = [merchantTypeArray objectAtIndex:sender.tag - 1000];
//    NSLog(@"sender.icon_url: %@",[dic objectForKey:@"icon_url"]);
    NSLog(@"menu_code: %@",[dic objectForKey:@"menu_code"]);
    
//    self.tabBarController.selectedIndex = 1;
//    UINavigationController *nav = (UINavigationController *)self.tabBarController.selectedViewController;
//    ShopListViewController *listVC = (ShopListViewController *)nav.visibleViewController;
//    listVC.menu_subtitle = [dic objectForKey:@"menu_subtitle"];
//    listVC.menu_code = [dic objectForKey:@"menu_code"];
//    listVC.typeID = dic [@"menu_code"];
//    [listVC.typeBtn setTitle:[dic objectForKey:@"menu_subtitle"] forState:UIControlStateNormal];
    
    ShopListVC *listVC = [[ShopListVC alloc] init];
    listVC.menu_subtitle = [dic objectForKey:@"menu_subtitle"];
    listVC.menu_code = [dic objectForKey:@"menu_code"];
    listVC.typeID = dic [@"menu_code"];
    [listVC.typeBtn setTitle:[dic objectForKey:@"menu_subtitle"] forState:UIControlStateNormal];
    listVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:listVC animated:YES];
    
}

#pragma mark --UICollectionViewDataSource
//定义展示的UICollectionViewCell的个数
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [countysArray count] + 1; //增加“全部”区县
}

//定义展示的Section的个数
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

//每个UICollectionView展示的内容
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    HomeCityCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCollectionCelllIdentifier forIndexPath:indexPath];
    [cell.cityBtn addTarget:self action:@selector(selectCityAction:) forControlEvents:UIControlEventTouchUpInside];
    cell.cityBtn.tag = indexPath.item + 3000;
    
    if (indexPath.item == 0) {
        [cell.cityBtn setTitle:@"全部" forState:UIControlStateNormal];
    }
    else {
//        CountysObject *county = (CountysObject *)countysArray[indexPath.item - 1];
//        [cell.cityBtn setTitle:county.countName forState:UIControlStateNormal];
        
        CityDistrictsCoreObject *county = (CityDistrictsCoreObject *)countysArray[indexPath.item - 1];
        [cell.cityBtn setTitle:county.areaName forState:UIControlStateNormal];
    }
     
    if (indexPath.item == selectItem) {
        cell.cityBtn.selected = YES;
    }
    else {
        cell.cityBtn.selected = NO;
    }
    
    return cell;
}

#pragma mark --UICollectionViewDelegate

//-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
//    NSLog(@"您选中了----%ld",(long)indexPath.row);
//    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
//}



#pragma mark --UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize size = CGSizeMake(80, 30);
    return size;
}


//itemCell间隔
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 10;
}


#pragma mark - cell上按钮方法
-(void)selectCityAction:(UIButton *)sender {
    
    NSInteger rowInt = sender.tag - 3000;
    NSLog(@"rowInt: %ld",(long)rowInt);
    selectItem = rowInt;
    
    if (rowInt == 0) {  //选择全部
        countyID = @"";
        countyName = @"";
        current_county_code = @"";
        [mutabDic setObject:[NSNumber numberWithInteger:selectItem] forKey:@"selectItem"];  //更新字典中selectItem的值
        [mutabDic setObject:cityID forKey:@"cityID"];
        [mutabDic setObject:cityName forKey:@"areaName"];
        [mutabDic setObject:countyID forKey:@"countyID"];
        [mutabDic setObject:countyName forKey:@"countName"];
        [mutabDic setObject:current_city_code forKey:@"current_city_code"];
        [mutabDic setObject:current_county_code forKey:@"current_county_code"];
        NSLog(@"mutabDic: %@",mutabDic);
        [[GlobalSetting shareGlobalSettingInstance] setHomeSelectedDic:mutabDic];
        [self adjustLeftBtnFrameWithTitle:[NSString stringWithFormat:@"%@",cityName]];
    }
    
    else {
        CityDistrictsCoreObject *county = (CityDistrictsCoreObject *)countysArray[rowInt -1];
    //    [[GlobalSetting shareGlobalSettingInstance] setCountyObject:county];    //存储选中的County对象
        [mutabDic setObject:[NSNumber numberWithInteger:selectItem] forKey:@"selectItem"];  //更新字典中selectItem的值
        NSLog(@"cityID: %@",cityID);
        [mutabDic setObject:cityID forKey:@"cityID"];
        [mutabDic setObject:cityName forKey:@"areaName"];
        [mutabDic setObject:county.areaId forKey:@"countyID"];
        [mutabDic setObject:county.areaName forKey:@"countName"];
        [mutabDic setObject:current_city_code forKey:@"current_city_code"];
        [mutabDic setObject:county.current_code forKey:@"current_county_code"];
        NSLog(@"county.current_code: %@",county.current_code);
        NSLog(@"mutabDic: %@",mutabDic);
        [[GlobalSetting shareGlobalSettingInstance] setHomeSelectedDic:mutabDic];
        NSLog(@"HomeSelectedDic: %@",[[GlobalSetting shareGlobalSettingInstance] homeSelectedDic]);
        countyID = county.areaId;  //区县赋值ID
        countyName = county.areaName;   //区县名称
        current_county_code = county.current_code;
        [self adjustLeftBtnFrameWithTitle:[NSString stringWithFormat:@"%@--%@",cityName,county.areaName]];
    }
    
    [self.cityCollectionView reloadData];
    
    //选择完后刷新推荐商户数据
    [self requestGetRecommendShopListWithLocationDic:[[GlobalSetting shareGlobalSettingInstance] myLocation]];
    
    [self appearOrDismissCityView:YES]; //hidden
    _leftButn.selected = NO;
}

-(void)cancelSelectCity {
    [self appearOrDismissCityView:YES];
    _leftButn.selected = NO;
}


#pragma mark - scrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    self.typePageControl.currentPage = scrollView.contentOffset.x / scrollView.frame.size.width;
}

- (IBAction)changeCityAction:(id)sender {
    NSLog(@"切换城市！");
    _leftButn.selected = NO;
    [self appearOrDismissCityView:YES];
    
    CitySelectViewController *selectVC = [[CitySelectViewController alloc] init];
//    selectVC.citysDic = chongzuDic;
    selectVC.selectDelegate = self;
    selectVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:selectVC animated:YES];
}

-(void)toSelectCity:(UIButton *)sender {
    NSLog(@"选择城市！");
    sender.selected = ! sender.selected;
    if (sender.selected) {
        [self appearOrDismissCityView:NO];
    }
    else {
        [self appearOrDismissCityView:YES];
    }
}

//-(void)animationWithViewAlph:(int)alph {
//    [UIView animateWithDuration:0.5 animations:^{
//        self.citySelectView.alpha = alph;
//    }];
//}

-(void)appearOrDismissCityView:(BOOL)hidden {
    self.citySelectBgView.hidden = hidden;
    self.citySelectView.hidden = hidden;
}

-(void)toMapView {
    ShopMapViewController *mapVC = [[ShopMapViewController alloc] init];
    mapVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:mapVC animated:YES];
}

//-(void)chongzuDictionaryWithDic:(NSDictionary *)dic {
//    NSArray *cityArr = dic[DATA];
//    
//    NSMutableSet *set = [NSMutableSet set];
//    NSMutableArray *mutableArray = [NSMutableArray array];
//    for (NSDictionary *dic in cityArr) {
//        //检索到定位城市名，赋值cityID。
//        
//        CityObject *city = [[CityObject alloc] init];
//        city.areaId = dic[@"areaId"];
//        city.areaName = dic[@"areaName"];
//        city.pyName = dic[@"pyName"];
//        
//        //重组字典
//        NSString *coding = [[city.pyName substringToIndex:1] uppercaseString];
//        [set addObject:coding];
//        //
//        
//        city.countysArray = [NSMutableArray array];
//        for (NSDictionary *dicc in dic[@"countys"]) {
//            CountysObject *countys = [[CountysObject alloc] init];
//            countys.countId = dicc[@"countId"];
//            countys.countName = dicc[@"countName"];
//            countys.countPyName = dicc[@"countPyName"];
//            [city.countysArray addObject:countys];
//        }
//        [mutableArray addObject:city];
//    }
//    //重组字典
//    NSArray *arr = [[set allObjects] sortedArrayUsingSelector:@selector(compare:)];
//    
//    chongzuDic = [NSMutableDictionary dictionary];
//    for (NSString *key in arr) {
//        NSMutableArray *newArray = [NSMutableArray array];
//        for (CityObject *city in mutableArray) {
//            NSString *coding = [[city.pyName substringToIndex:1] uppercaseString];
//            
//            if ([coding isEqualToString:key]) {
//                [newArray addObject:city];
//            }
//        }
//        [chongzuDic setObject:newArray forKey:key];
//    }
//    NSLog(@"chongzuDic: %@",chongzuDic);
//    
//    //存入本地Document文件夹
//    NSString *plistPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"CityDic.plist"];
//    NSData *archiveData = [NSKeyedArchiver archivedDataWithRootObject:chongzuDic];
//    if (archiveData) {
//        [archiveData writeToFile:plistPath options:NSDataWritingAtomic error:nil];
//        
//        //城市县区数据存储成功后，调起定位功能，更新定位城市
//        [_locService startUserLocationService];
//    }
//
//}


#pragma mark - AlreadySelectCityDelegate
-(void)alreadySelectCity:(CityDistrictsCoreObject *)city {
    [self adjustLeftBtnFrameWithTitle:city.areaName];
    cityID = city.areaId;   //城市赋值ID
    selectItem = 0;  //默认选中“全部”
    
    isChangeToMinCity = NO;
    
    cityObject = city;
    cityName = city.areaName;
    
    countyID = @"";
    countyName = @"";
    current_city_code = city.current_code;
    current_county_code = @"";
    
    self.currentCityL.text = cityName;
//    [[GlobalSetting shareGlobalSettingInstance] setCityObject:city];    //存储选中的City对象
    [mutabDic setObject:[NSNumber numberWithInteger:0] forKey:@"selectItem"];  //更新字典中selectItem的值
    [mutabDic setObject:cityID forKey:@"cityID"];
    [mutabDic setObject:cityName forKey:@"areaName"];
    [mutabDic setObject:countyID forKey:@"countyID"];
    [mutabDic setObject:countyName forKey:@"countName"];
    [mutabDic setObject:current_city_code forKey:@"current_city_code"];
    [mutabDic setObject:current_county_code forKey:@"current_county_code"];
    
    [[GlobalSetting shareGlobalSettingInstance] setHomeSelectedDic:mutabDic];
    
    NSString *parentID = cityObject.areaId;
    countysArray = [app selectDataWithParentID:parentID];   //获取对应区县数组对象
    NSLog(@"areaName: %@,countysArray: %@",city.areaName,countysArray);
    [self.cityCollectionView reloadData];
    
    //选择完后刷新推荐商户数据
    [self requestGetRecommendShopListWithLocationDic:[[GlobalSetting shareGlobalSettingInstance] myLocation]];
}


#pragma mark - 网路请求
-(void)requestGetLottery {
    [_hud show:YES];
    
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:GetLottery object:nil];
    
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:GetLottery, @"op", nil];
    [[DataRequest sharedDataRequest] postDataWithUrl:RequestURL(GetLottery) delegate:nil params:nil info:infoDic];
}


-(void)requestGetBanner {
    [_hud show:YES];
    
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:GetBanner object:nil];
    NSDictionary *pram = [[NSDictionary alloc] initWithObjectsAndKeys:@"-1",@"version", nil]; //版本号
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:GetBanner, @"op", nil];
    [[DataRequest sharedDataRequest] postDataWithUrl:RequestURL(GetBanner) delegate:nil params:pram info:infoDic];
}



/********* 获取城市区县接口版本号，存入本地，当本地版本号和服务器版本号不一致时，重新请求接口，并更新本地版本号 *********/
-(void)requestGetCityDistricts_Version {
    [_hud show:YES];
    
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:@"GetCityDistricts_Version" object:nil];
    
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:@"GetCityDistricts_Version", @"op", nil];
    NSDictionary *pram = [[NSDictionary alloc] initWithObjectsAndKeys:GetCityDistricts,@"function", nil];
    [[DataRequest sharedDataRequest] postDataWithUrl:RequestURL(GetVersion) delegate:nil params:pram info:infoDic];
}

/********* 获取商户类型接口版本号，存入本地，当本地版本号和服务器版本号不一致时，重新请求接口，并更新本地版本号 *********/
-(void)requestGetMerchantTypeList_Version {
    [_hud show:YES];
    
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:@"GetMerchantTypeList_Version" object:nil];
    
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:@"GetMerchantTypeList_Version", @"op", nil];
    NSDictionary *pram = [[NSDictionary alloc] initWithObjectsAndKeys:GetMerchantTypeList,@"function", nil];
    [[DataRequest sharedDataRequest] postDataWithUrl:RequestURL(GetVersion) delegate:nil params:pram info:infoDic];
}
/***********************************************************/


-(void)requestGetMerchantTypeList {
    [_hud show:YES];
    
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:GetMerchantTypeList object:nil];
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:GetMerchantTypeList, @"op", nil];
        NSDictionary *pram = [[NSDictionary alloc] initWithObjectsAndKeys:merchantTypeList_Version,@"version", nil]; //版本号
    [[DataRequest sharedDataRequest] postDataWithUrl:RequestURL(GetMerchantTypeList) delegate:nil params:pram info:infoDic];
}

-(void)requestGetCityDistricts { //获取市和县区
    app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if (! _cityHud) {
        _cityHud = [[MBProgressHUD alloc] initWithView:app.window];
        [app.window addSubview:_cityHud];
    }
    [_cityHud show:YES];

    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:GetCityDistricts object:nil];
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:GetCityDistricts, @"op", nil];
    NSString *locaVersion = [[GlobalSetting shareGlobalSettingInstance] cityDistricts_Version];
    if (locaVersion == nil) {
        locaVersion = @"13";    //版本号从13开始
    }
    NSDictionary *pram = [[NSDictionary alloc] initWithObjectsAndKeys:locaVersion,@"version", nil]; //版本号
    [[DataRequest sharedDataRequest] postDataWithUrl:RequestURL(GetCityDistricts) delegate:nil params:pram info:infoDic];
}

-(void)requestGetRecommendShopListWithLocationDic:(NSDictionary *)dic { //获取推荐商户列表
    [_hud show:YES];
    
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:GetMerchantList object:nil];
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:GetMerchantList, @"op", nil];
    NSString *userID = [[GlobalSetting shareGlobalSettingInstance] userID];
    if (userID == nil) {
        userID = @"";
    }
    NSDictionary *pram = [[NSDictionary alloc] initWithObjectsAndKeys:current_city_code,@"current_city_code",current_county_code,@"current_county_code",cityID,@"city",countyID,@"county",@"",@"business_type",@"2",@"sort",@"1",@"pageindex",[dic objectForKey:@"latitude"],@"latitude",[dic objectForKey:@"longitude"],@"longitude",@"",@"key",userID,@"member_id", nil];
    NSLog(@"RecommendShopList: %@",pram);
    [[DataRequest sharedDataRequest] postDataWithUrl:RequestURL(GetMerchantList) delegate:nil params:pram info:infoDic];
}


#pragma mark - 网络请求结果数据
-(void) didFinishedRequestData:(NSNotification *)notification{
    [_hud hide:YES];
    if ([[notification.userInfo valueForKey:@"RespResult"] isEqualToString:ERROR]) {
        [_cityHud hide:YES];
        
        _networkConditionHUD.labelText = [notification.userInfo valueForKey:@"ContentResult"];
        [_networkConditionHUD show:YES];
        [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        return;
    }
    NSDictionary *responseObject = [[NSDictionary alloc] initWithDictionary:[notification.userInfo objectForKey:@"RespData"]];
    if ([notification.name isEqualToString:GetLottery]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:GetLottery object:nil];
        
        NSLog(@"GetLottery_responseObject: %@",responseObject);
        
        if ([responseObject[@"status"] boolValue]) {
            if ([responseObject[DATA] count] == 2) {
                hasLottery = YES;
                [self initTableViewHeadView];
                
                _dazhuanpanDic = responseObject [DATA] [0];
                _zajindanDic = responseObject [DATA] [1];
                
                _textL1.text = _dazhuanpanDic [@"Title"];
                _detailL1.text = _dazhuanpanDic [@"KeyWord"];
                _imgV1.contentMode = UIViewContentModeScaleAspectFit;
                [_imgV1 sd_setImageWithURL:[NSURL URLWithString:_dazhuanpanDic [@"ImgPath"]] placeholderImage:IMG(@"bg_merchant_photo_placeholder")];
//                _imgV1.image = IMG(@"zpbg.png");
                
                _textL2.text = _zajindanDic [@"Title"];
                _detailL2.text = _zajindanDic [@"KeyWord"];
                _imgV2.contentMode = UIViewContentModeScaleAspectFit;
                [_imgV2 sd_setImageWithURL:[NSURL URLWithString:_zajindanDic [@"ImgPath"]] placeholderImage:IMG(@"bg_merchant_photo_placeholder")];
//                _imgV2.image = IMG(@"eg2.png");
            }
        }
        else {
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:[responseObject objectForKey:MSG] delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil, nil];
//            [alert show];
            hasLottery = NO;
            
            [self initTableViewHeadView];
        }
        
    }
    
    else if ([notification.name isEqualToString:GetBanner]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:GetBanner object:nil];
        
        NSLog(@"GetBanner_responseObject: %@",responseObject);
        
        if ([responseObject[@"status"] boolValue]) {
            _adArray = responseObject [DATA] [@"result"];
            [_adView reloadData];
        }
        else {
            _networkConditionHUD.labelText = [responseObject objectForKey:MSG];
            [_networkConditionHUD show:YES];
            [_networkConditionHUD hide:YES afterDelay:HUDDelay];
            
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:[responseObject objectForKey:MSG] delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil, nil];
//            [alert show];
        }
    }
    
    else if ([notification.name isEqualToString:GetMerchantTypeList]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:GetMerchantTypeList object:nil];
        NSLog(@"GetMerchantTypeList_responseObject: %@",responseObject);
        
        if ([responseObject[@"status"] boolValue]) {
            
            [[GlobalSetting shareGlobalSettingInstance] setMerchantTypeList:responseObject];
            merchantTypeArray = responseObject[DATA];
            
            [self initHeadScrollViewWithArray:merchantTypeArray];
            
        }
        else {
            _networkConditionHUD.labelText = [responseObject objectForKey:MSG];
            [_networkConditionHUD show:YES];
            [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        }
        
    }
    else if ([notification.name isEqualToString:@"GetCityDistricts_Version"]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"GetCityDistricts_Version" object:nil];
        NSLog(@"CityDistricts_Version_responseObject: %@",responseObject);
        
        cityDistricts_Version = responseObject [MSG];
        NSString *locaVersion = [[GlobalSetting shareGlobalSettingInstance] cityDistricts_Version];
        if ( [cityDistricts_Version intValue] > [locaVersion intValue] ) {
            //请求新数据
            [self requestGetCityDistricts];
            
            //获取城市区县接口版本号，比较后存入本地
            [[GlobalSetting shareGlobalSettingInstance] setCityDistricts_Version:cityDistricts_Version];
        }
    }
    else if ([notification.name isEqualToString:@"GetMerchantTypeList_Version"]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"GetMerchantTypeList_Version" object:nil];
        NSLog(@"MerchantTypeList_Version_responseObject: %@",responseObject);
        
        merchantTypeList_Version = responseObject [MSG];
        NSLog(@"%@",merchantTypeList_Version);
        NSString *locaVersion = [[GlobalSetting shareGlobalSettingInstance] merchantTypeList_Version];
        NSLog(@"locaVersion: %@",locaVersion);
        if ( [merchantTypeList_Version intValue] > [locaVersion intValue] ) {
            
            //请求新数据
            [self requestGetMerchantTypeList];
            
            //获取商户类型接口版本号，比较后存入本地
            [[GlobalSetting shareGlobalSettingInstance] setMerchantTypeList_Version:merchantTypeList_Version];
        }
    }
    
    
//    else if ([notification.name isEqualToString:GetCityDistricts]) {
//        [[NSNotificationCenter defaultCenter] removeObserver:self name:GetCityDistricts object:nil];
//        NSLog(@"GetCityDistricts_responseObject: %@",responseObject);
//        [self chongzuDictionaryWithDic:responseObject];  //数据结构重组
//    }
    
    else if ([notification.name isEqualToString:GetCityDistricts]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:GetCityDistricts object:nil];
        //        NSLog(@"GetCityDistricts_responseObject: %@",responseObject);
        NSArray *cityAry = responseObject [@"data"];
        if ([cityAry count] > 0) { //返回的有数据时，更新数据库
            NSString *serviceVersion = responseObject [MSG];
            [app deleteAllObjects];
            for (NSDictionary *dic in cityAry) {
                [app insertCoreDataWithObjectItem:dic];
            }
            [[GlobalSetting shareGlobalSettingInstance] setCityDistricts_Version:serviceVersion];   //本地更新版本号放在数据库存数完毕之后
            [_cityHud hide:YES];    //下载并写入数据库成功后，再关闭hud
            
            CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
            if (kCLAuthorizationStatusDenied == status || kCLAuthorizationStatusRestricted == status) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请到设置-隐私-定位服务中打开定位权限！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alert show];
            }
            
            [_locService startUserLocationService];
            
        }
        else {
            NSString *serviceVersion = responseObject [MSG];
            [[GlobalSetting shareGlobalSettingInstance] setCityDistricts_Version:serviceVersion];   //本地更新版本号放在数据库存数完毕之后
            [_cityHud hide:YES];    //没有数据更新，直接关闭hud
            
            [_locService startUserLocationService];
        }
    }
    
    else if ([notification.name isEqualToString:GetMerchantList]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:GetMerchantList object:nil];
        NSLog(@"GetMerchantList_responseObject: %@",responseObject);
        recommendArray = @[]; //置空数组
        
        if ([responseObject[@"status"] boolValue]) {
            recommendArray = responseObject[DATA];
        }
        else {
            _networkConditionHUD.labelText = [responseObject objectForKey:MSG];
            [_networkConditionHUD show:YES];
            [_networkConditionHUD hide:YES afterDelay:HUDDelay];
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
