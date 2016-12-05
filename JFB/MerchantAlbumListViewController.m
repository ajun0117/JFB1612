//
//  MerchantAlbumListViewController.m
//  JFB
//
//  Created by LYD on 15/9/15.
//  Copyright (c) 2015年 李俊阳. All rights reserved.
//

#import "MerchantAlbumListViewController.h"
#import "HZIndicatorView.h"
#import "AJSegmentedControl.h"
#import "MerchantAlbumCollectionViewCell.h"
#import "HZPhotoBrowser.h"

#define CollectionCelllIdentifier      @"merchantAlbumCollectionCell"

@interface MerchantAlbumListViewController () <HZPhotoBrowserDelegate,AJSegmentedControlDelegate>
{
    MBProgressHUD *_hud;
    MBProgressHUD *_networkConditionHUD;
    
    NSArray *_typesArray;
    NSArray *_imagesArray;
    NSMutableArray *_typeImgsArray;
}

@end

@implementation MerchantAlbumListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"商家相册";
    
    _typeImgsArray = [[NSMutableArray alloc] init];
    
    [self.myCollectionView registerNib:[UINib nibWithNibName:@"MerchantAlbumCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:CollectionCelllIdentifier];
    
    [self requestGetMerchantAlbumList];
    
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

#pragma mark - 自定义segmented
- (void)createSegmentControlWithTitles:(NSArray *)titls
{
    AJSegmentedControl *mySegmentedControl = [[AJSegmentedControl alloc] initWithOriginY:0 Titles:titls delegate:self];
    [self.view addSubview:mySegmentedControl];
}

//
//  根据下标主动切换
//
//- (void)changeIndex
//{
//    NSInteger index = 3;
//    [_mySegmentedControl changeSegmentedControlWithIndex:index];
//}

//
//  AJSegmentedControlDelegate method
//
- (void)ajSegmentedControlSelectAtIndex:(NSInteger)index
{
    NSLog(@"%ld",(long)index);
    if (_typeImgsArray) {
        [_typeImgsArray removeAllObjects];
    }
    NSDictionary *typeDic = _typesArray [index];
    int typeId = [typeDic [@"id"] intValue];
    if (typeId == 0) {  //全部
        [_typeImgsArray addObjectsFromArray:_imagesArray];
    }
    else {
        for (NSDictionary *imgDic in _imagesArray) {
            if ([imgDic[@"album_type_id"] intValue] == typeId) {
                [_typeImgsArray addObject:imgDic];
            }
        }
    }
    
    [self.myCollectionView reloadData];
}


#pragma mark --UICollectionViewDataSource
//定义展示的UICollectionViewCell的个数
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [_typeImgsArray count];
}

//定义展示的Section的个数
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

//每个UICollectionView展示的内容
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dic = _typeImgsArray [indexPath.item];
    MerchantAlbumCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:CollectionCelllIdentifier forIndexPath:indexPath];
//    [cell.AlbumIM sd_setImageWithURL:[NSURL URLWithString:dic[@"original_path"]] placeholderImage:IMG(@"whiteplaceholder")];
    cell.titleL.text = dic [@"album_title"];
    //让图片不变形，以适应按钮宽高，按钮中图片部分内容可能看不到
    cell.AlbumBtn.imageView.contentMode = UIViewContentModeScaleAspectFill;
    cell.AlbumBtn.clipsToBounds = YES;
    
    [cell.AlbumBtn sd_setImageWithURL:[NSURL URLWithString:dic[@"original_path"]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"bg_merchant_photo_placeholder"]];
    cell.AlbumBtn.tag = indexPath.item + 2000;
    
    [cell.AlbumBtn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    
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
    CGSize size = CGSizeMake((SCREEN_WIDTH-75) / 2, (SCREEN_WIDTH-75) / 2);
    return size;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(20, 25, 20, 25);
}


////itemCell间隔
//- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
//{
//    return 10;
//}


- (void)buttonClick:(UIButton *)button
{
    NSDictionary *dic = _typeImgsArray [button.tag - 2000];
    //启动图片浏览器
    HZPhotoBrowser *browserVC = [[HZPhotoBrowser alloc] init];
    browserVC.sourceImagesContainerView = self.myCollectionView; // 原图的父控件
    browserVC.imageCount = _typeImgsArray.count; // 图片总数
    browserVC.currentImageIndex = (int)button.tag - 2000;
    browserVC.currentImageTitle = dic [@"album_title"];
    browserVC.delegate = self;
    [browserVC show];
}

#pragma mark - photobrowser代理方法
- (UIImage *)photoBrowser:(HZPhotoBrowser *)browser placeholderImageForIndex:(NSInteger)index
{
    NSIndexPath *path = [NSIndexPath indexPathForItem:index inSection:0];
    MerchantAlbumCollectionViewCell * cell = (MerchantAlbumCollectionViewCell *)[self.myCollectionView cellForItemAtIndexPath:path];
    return [cell.AlbumBtn currentImage];
}

- (NSURL *)photoBrowser:(HZPhotoBrowser *)browser highQualityImageURLForIndex:(NSInteger)index
{
    NSDictionary *dic = _typeImgsArray [index];
    NSString *urlStr = dic [@"original_path"];
    return [NSURL URLWithString:urlStr];
}

- (NSString *)photoBrowser:(HZPhotoBrowser *)browser titleStringForIndex:(NSInteger)index {
    NSDictionary *dic = _typeImgsArray [index];
    NSString *titleStr = dic [@"album_title"];
    return titleStr;
}


#pragma mark - 发送请求
-(void)requestGetMerchantAlbumList { //获取商户相册
    [_hud show:YES];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:GetMerchantAlbumList object:nil];
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:GetMerchantAlbumList, @"op", nil];
    NSDictionary *pram = [[NSDictionary alloc] initWithObjectsAndKeys:self.merchant_id,@"merchant_id", nil];
    NSLog(@"pram: %@",pram);
    [[DataRequest sharedDataRequest] postDataWithUrl:RequestURL(GetMerchantAlbumList) delegate:nil params:pram info:infoDic];
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
    if ([notification.name isEqualToString:GetMerchantAlbumList]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:GetMerchantAlbumList object:nil];
        if ([responseObject[@"status"] boolValue]) {
            NSDictionary *dic = responseObject [DATA];
            NSLog(@"GetMerchantAlbumList_dic: %@",dic);
            _typesArray = dic [@"types"];
            _imagesArray = dic [@"images"];
            
            [self createSegmentControlWithTitles:_typesArray];
            
            //默认全部
            [_typeImgsArray addObjectsFromArray:_imagesArray];
            
            [self.myCollectionView reloadData];
        
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
