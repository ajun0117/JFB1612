//
//  ScanCodeViewController.m
//  JFB
//
//  Created by 李俊阳 on 15/8/24.
//  Copyright (c) 2015年 李俊阳. All rights reserved.
//

#import "ScanCodeViewController.h"
#import "ScanResultViewController.h"
#import "MaskView.h"

@interface ScanCodeViewController () <UIAlertViewDelegate>

@property (nonatomic, strong) MaskView *maskView;//蒙版
@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, strong) MBProgressHUD *networkConditionHUD;
@end

@implementation ScanCodeViewController

#pragma mark -
#pragma mark 初始时的一些方法
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor blackColor];
    
    self.extendedLayoutIncludesOpaqueBars = YES;  //设置导航栏不透明
    
    self.title = @"二维码";
    //导航条左右按钮-请根据具体情况自行设置，左右两侧的按钮也可以是文字，是文字的话自行重写self.navigationItem.rightBarButtonItem
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Right-arrow"] style:UIBarButtonItemStylePlain target:self action:@selector(backButnClicked)];
    
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
    
    self.hud = [[MBProgressHUD alloc] initWithView:self.view];
    self.hud.labelText = @"正在初始化...";
    [self.view addSubview:self.hud];
}

-(void)backButnClicked {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

/**
 *  初始化扫描配置
 *
 *  @param interestFrame
 */
- (void)initScanConfig:(CGRect)interestFrame
{
    _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    NSError *error = nil;
    
    //输入数据配置
    self.input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:&error];
    if (error) {
        
        NSLog(@"你手机不支持二维码扫描!");
        return;
    }
    
    //输出数据配置
    self.output = [[AVCaptureMetadataOutput alloc] init];
    
    [self.output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    //区域的原点在左上方，然后区域是相对于设备的大小的，默认值是CGRectMake(0, 0, 1, 1)，CGRectMake(APP_WIDTH * 0.5 - 100, APP_HEIGHT * 0.5 - 100, 200, 200);
    self.output.rectOfInterest = CGRectMake((124)/APP_HEIGHT,((APP_WIDTH-220)/2)/APP_WIDTH,220/APP_HEIGHT,220/APP_WIDTH);//
    self.session = [[AVCaptureSession alloc]init];
    
    if ([self.session canAddInput:self.input])
    {
        [self.session addInput:self.input];
    }
    
    if ([self.session canAddOutput:self.output])
    {
        [self.session addOutput:self.output];
    }
    
    self.output.metadataObjectTypes = @[AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code, AVMetadataObjectTypeQRCode];
    
    //输出视图图层
    self.preview = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    self.preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
        
    self.preview.frame = CGRectMake(0, 0, APP_WIDTH, APP_HEIGHT + 20);
        
    [self.view.layer addSublayer:self.preview];
    
    if ([UIScreen mainScreen].bounds.size.height == 480)
    {
        [self.session setSessionPreset:AVCaptureSessionPreset640x480];
    }
    else
    {
        [self.session setSessionPreset:AVCaptureSessionPresetHigh];
    }
    
//    [self.session startRunning];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.hud show:YES];
}

-(void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    CGRect frame = CGRectMake((APP_WIDTH-220)/2,60,220, 220);// CGRectMake(APP_WIDTH * 0.5 - 100, APP_HEIGHT * 0.5 - 100, 200, 200);
    [self initScanConfig:frame];
    if (self.maskView.superview == nil) {
        self.maskView = [[MaskView alloc] initWithFrame:self.view.frame];
        [self.view addSubview:self.maskView];
    }
    [self.maskView startAnimation];
    [self.session startRunning];
    [self.hud hide:YES];
}

//检测摄像头是否可用
- (BOOL) isRearCameraAvailable{
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self.maskView stopAnimation];
    [self.maskView removeFromSuperview];
    self.maskView = nil;
    [self.preview removeFromSuperlayer];
    self.session = nil;
    self.output = nil;
    self.device = nil;
    self.input = nil;
}

/**
 *  Informs the delegate that the capture output object emitted new metadata objects.
 *
 *  @param captureOutput
 *  @param metadataObjects
 *  @param connection      
 */
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    [self.session stopRunning];
    
    NSString *val = nil;
    if (metadataObjects.count > 0)
    {
        AVMetadataMachineReadableCodeObject *obj = metadataObjects[0];
        
        val = obj.stringValue;
        
        NSLog(@"val: %@",val);
        if ([val hasPrefix:@"http://wx.jfb315.com/UserCenter/Reg.aspx?uid="]) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(ScanCodeComplete:)]) {
                [self.delegate ScanCodeComplete:val];   //返回代理页并传值
            }
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您扫描的不是发卡组织！" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            alert.tag = 1000;
            [alert show];
        }
        
        
//        ScanResultViewController *scanResultVC = [[ScanResultViewController alloc] init];
//        scanResultVC.resultUrl = val;
//        [self.navigationController pushViewController:scanResultVC animated:YES];
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 1000) {
        [self.session startRunning];
    }
}

/**
 *  customAlertView的自定义视图
 *
 *  @return
 */
-(UIView*)customParentView  {
    UIView *alertView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH - 60, 130)];
    alertView.backgroundColor = RGBCOLOR(242, 242, 242);
//    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 30, 30)];
//    imgView.contentMode = UIViewContentModeScaleAspectFit;
//    imgView.image = IMG(@"my_remind");
//    [alertView addSubview:imgView];
    
    UILabel *showLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, VIEW_W(alertView) - 10, 21)];
    showLabel.text = @"提示";
    showLabel.textColor = [UIColor redColor];
    [alertView addSubview:showLabel];
    
    UIView *whiteView = [[UIView alloc] initWithFrame:CGRectMake(0, VIEW_H(showLabel) + 10, VIEW_W(alertView), VIEW_H(alertView) - 10)];
    whiteView.backgroundColor = [UIColor whiteColor];
    [alertView addSubview:whiteView];
    
    UILabel *show = [[UILabel alloc] initWithFrame:CGRectMake(30, 0, VIEW_W(whiteView) - 30 *2, VIEW_H(whiteView))];
    show.numberOfLines = 5;
    show.text = @"未发现二维码";
    [whiteView addSubview:show];
    
    return alertView;
}

//#pragma mark -
//#pragma mark 网络请求数据
//-(void) didFinishedRequestData:(NSNotification *)notification   {
//    if ([[notification.userInfo valueForKey:@"RespResult"] isEqualToString:ERROR]) {
//        if (!self.networkConditionHUD) {
//            self.networkConditionHUD = [[MBProgressHUD alloc] initWithView:self.view];
//            [self.view addSubview:self.networkConditionHUD];
//        }
//        self.networkConditionHUD.labelText = [notification.userInfo valueForKey:@"ContentResult"];
//        self.networkConditionHUD.mode = MBProgressHUDModeText;
//        self.networkConditionHUD.yOffset = APP_HEIGHT/2 - HUDBottomH;
//        self.networkConditionHUD.margin = HUDMargin;
//        [self.networkConditionHUD show:YES];
//        [self.networkConditionHUD hide:YES afterDelay:HUDDelay];
//        
//        return;
//    }
//    
//    NSDictionary *responseObject = [[NSDictionary alloc] initWithDictionary:[notification.userInfo objectForKey:@"RespData"]];
//    
//}


-(void)clickLeftButton:(id)sender   {
    NSLog(@"点击了导航栏左边的按钮");
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
