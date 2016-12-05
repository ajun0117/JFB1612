//
//  ReplyViewController.m
//  mobilely
//
//  Created by wp on 15-1-27.
//  Copyright (c) 2015年 ylx. All rights reserved.
//

#import "ReplyViewController.h"
#import "CustomTextView.h"
#import "NSString+Check.h"
@interface ReplyViewController (){
    BOOL isSending;
}
@property(nonatomic,strong) CustomTextView *wordTextView;
@property(nonatomic,strong) MBProgressHUD *hud;
@property (nonatomic, strong) MBProgressHUD *networkConditionHUD;
@end


@implementation ReplyViewController
@synthesize wordTextView;
@synthesize starView;
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"评论";
    self.view.backgroundColor = [UIColor colorWithWhite:0.925 alpha:1.000];
    UIBarButtonItem *rightBarButton=[[UIBarButtonItem alloc]initWithTitle:@"发送" style:UIBarButtonItemStylePlain target:self action:@selector(replyBtnPressed:)];
    self.navigationItem.rightBarButtonItem=rightBarButton;
    
    [self initUI];
    
    isSending = NO;
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (! _hud) {
        _hud = [[MBProgressHUD alloc] initWithView:self.view];
        _hud.labelText = @"正在发送中...";
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

/**
 *  页面初始化布局
 */
-(void)initUI
{
    UIView *topView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, APP_WIDTH, 1)];
    topView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:topView];
    
    wordTextView = [[CustomTextView alloc]initWithFrame:CGRectMake(15, topView.frame.origin.y+20, APP_WIDTH-30, 100) selector:nil delegate:nil title:@"说点什么吧" image:@"people_input.png"];
    [self.view addSubview:wordTextView];
    
    UILabel *selectStarLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, wordTextView.frame.size.height+wordTextView.frame.origin.y+10, APP_WIDTH-30, 21)];
    selectStarLabel.text = @"请选择星级";
    [self.view addSubview:selectStarLabel];
    
    starView = [[RatingView alloc] initWithFrame:CGRectMake(15, selectStarLabel.frame.size.height+selectStarLabel.frame.origin.y+10, 200, 25)];
    starView.style = kRatingViewStyleNormal;
    starView.ratingScore = 0;
    [self.view addSubview:starView];
    
    //初始化mbprogress
    self.hud = [[MBProgressHUD alloc] initWithView:self.view];
    self.hud.labelText = @"正在发送中...";
    [self.view addSubview:self.hud];
    
}
/**
 *  取消评论
 *
 *  @param sender
 */
-(void)cannelReply:(id)sender{
    [self.wordTextView resignFirstResponder];
    [self popoverPresentationController];
    NSLog(@"取消评论");
}
/**
 *  发送按钮触发方法
 */
-(void)replyBtnPressed:(id)sender
{
    
    //先将未到时间执行前的任务取消。
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(todoSomething:) object:sender];
    [self performSelector:@selector(todoSomething:) withObject:sender afterDelay:1.0f];
    
    NSLog(@"您点击了发送按钮");
    NSLog(@"当前星级:%ld",(long)starView.ratingScore);
}

-(void)todoSomething:(id)sender{
    if (isSending) {
        return;
    }
    isSending = YES;
    
    [self.wordTextView resignFirstResponder];
    if (self.wordTextView.text.length > 0) {
        
        if ([self.wordTextView.text length] < 3) {
            
            self.networkConditionHUD.labelText = @"内容不能少于3个字符哟！";
            [self.networkConditionHUD show:YES];
            [self.networkConditionHUD hide:YES afterDelay:HUDDelay];
            isSending = NO;
            return;
        }
        
//        if (![NSString checkStringWithString:self.wordTextView.text]) {
//            
//            self.networkConditionHUD.labelText = @"内容不能是纯数字哟！";
//            [self.networkConditionHUD show:YES];
//            [self.networkConditionHUD hide:YES afterDelay:HUDDelay];
//            isSending = NO;
//            return;
//        }
        
        //        if ([_isReply integerValue]==1 && starView.ratingScore == 0) {
        //
        //            self.networkConditionHUD.labelText = @"给它个星星吧！";
        //            [self.networkConditionHUD show:YES];
        //            [self.networkConditionHUD hide:YES afterDelay:HUDDelay];
        //            return;
        //        }
        
        
//        [self.hud show:YES];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:SubmitReview object:nil];
//        
//        NSString *str = [GetIPAddress getIpAddress];
//        NSLog(@"当前IP:%@",str);
//        NSLog(@"当前问题id:%@",_qid);
//        NSLog(@"评论内容:%@",wordTextView.text);
//        NSLog(@"当前评分:%ld",(long)starView.ratingScore);
//        [[RequestManager sharedRequestManager] pubCommentWithQid:_qid content:wordTextView.text ip:str star:starView.ratingScore];
        
        [self requestSubmitReview];
    } else {
        self.networkConditionHUD.labelText = @"评论内容不能为空哟！";
        [self.networkConditionHUD show:YES];
        [self.networkConditionHUD hide:YES afterDelay:HUDDelay];
        isSending = NO;
    }
}

-(MBProgressHUD *)networkConditionHUD{
    if (!_networkConditionHUD) {
        _networkConditionHUD = [[MBProgressHUD alloc] initWithView:self.view];
        _networkConditionHUD.mode = MBProgressHUDModeText;
        _networkConditionHUD.yOffset = APP_HEIGHT/2 - HUDBottomH;
        _networkConditionHUD.margin = HUDMargin;
        
        [self.view addSubview:_networkConditionHUD];
    }
    
    
    return _networkConditionHUD;
}

/**
 *  收起键盘
 *
 *  @param touches
 *  @param event
 */
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

#pragma mark - 发送请求
-(void)requestSubmitReview { //提交评价
    [_hud show:YES];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:SubmitReview object:nil];
    
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:SubmitReview, @"op", nil];
    NSString *userID = [[GlobalSetting shareGlobalSettingInstance] userID];
    if (userID == nil) {
        userID = @"";
    }
    NSString *memName = [[GlobalSetting shareGlobalSettingInstance] mName];
    if (memName == nil) {
        memName = @"匿名";
    }
    
    NSDictionary *pram = [[NSDictionary alloc] initWithObjectsAndKeys:userID,@"member_id",self.order_no,@"order_no",self.merchant_id,@"merchant_id",self.goods_id,@"goods_id",memName,@"member_name",[NSNumber numberWithInteger:starView.ratingScore],@"score",wordTextView.text,@"content", nil];
    NSLog(@"pram: %@",pram);
    [[DataRequest sharedDataRequest] postDataWithUrl:RequestURL(SubmitReview) delegate:nil params:pram info:infoDic];
}


#pragma mark -
#pragma mark 网络请求数据
-(void) didFinishedRequestData:(NSNotification *)notification{
    [self.hud hide:YES];
    
    if ([[notification.userInfo valueForKey:@"RespResult"] isEqualToString:ERROR]) {
        
        self.networkConditionHUD.labelText = [notification.userInfo valueForKey:@"ContentResult"];
        [self.networkConditionHUD show:YES];
        [self.networkConditionHUD hide:YES afterDelay:HUDDelay];
        isSending = NO;
        return;
    }
    
    NSDictionary *responseObject = [[NSDictionary alloc] initWithDictionary:[notification.userInfo objectForKey:@"RespData"]];
    
    if ([notification.name isEqualToString:SubmitReview]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:SubmitReview object:nil];
        if ([responseObject[@"status"] boolValue]) {
            
            self.networkConditionHUD.labelText = [responseObject objectForKey:MSG];
            [self.networkConditionHUD show:YES];
            [self.networkConditionHUD hide:YES afterDelay:HUDDelay];
            
            
            double delayInSeconds = HUDDelay;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                isSending = NO;
                [self.navigationController popViewControllerAnimated:YES];
            });

        }
        else {
            self.networkConditionHUD.labelText = [responseObject objectForKey:MSG];
            [self.networkConditionHUD show:YES];
            [self.networkConditionHUD hide:YES afterDelay:HUDDelay];
        }
    }
}

@end
