//
//  Definition.h
//  JFB
//
//  Created by 李俊阳 on 15/8/13.
//  Copyright (c) 2015年 李俊阳. All rights reserved.
//

#ifndef JFB_Definition_h
#define JFB_Definition_h

//网络请求参数
#define ERROR               @"error"
#define SUCCESS             @"success"
#define MSG             @"msg"
#define DATA             @"data"

//MBProgressHUD 网络情况提示设置
#define HUDBottomH 100
#define HUDDelay 1
#define HUDMargin   10

//定位失败时的默认衡阳市经纬度
#define Latitude     @"26.8994600367"
#define Longitude     @"112.5784483174"


#pragma mark ---- color functions
#define RGBCOLOR(r,g,b) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]
#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:(a)]

#define Gray_BtnColor          RGBCOLOR(170, 170, 170)
#define Red_BtnColor           RGBCOLOR(229, 24, 35)
#define Cell_sepLineColor       RGBCOLOR(200, 199, 204)     //tablecell间隔线颜色

#define isIOS8Later ([[UIDevice currentDevice].systemVersion doubleValue] >= 8.0)

#define STRING(str)         (str==[NSNull null])?@"":str

#define SCREEN_HEIGHT [[UIScreen mainScreen]bounds].size.height
#define SCREEN_WIDTH [[UIScreen mainScreen]bounds].size.width

#define APP_HEIGHT [[UIScreen mainScreen] applicationFrame].size.height
#define APP_WIDTH [[UIScreen mainScreen]applicationFrame].size.width

//get the left top origin's x,y of a view
#define VIEW_TX(view) (view.frame.origin.x)
#define VIEW_TY(view) (view.frame.origin.y)

//get the width size of the view:width,height
#define VIEW_W(view)  (view.frame.size.width)
#define VIEW_H(view)  (view.frame.size.height)

//get the right bottom origin's x,y of a view
#define VIEW_BX(view) (view.frame.origin.x + view.frame.size.width)
#define VIEW_BY(view) (view.frame.origin.y + view.frame.size.height )

#pragma mark ---- UIImage  UIImageView  functions
#define IMG(name) [UIImage imageNamed:name]
#define IMGF(name) [UIImage imageNamedFixed:name]

#pragma mark - 接口基地址
//测试基地址
//#define RequestURL(action)           ([NSString stringWithFormat:@"http://192.168.0.107:9091/doPost.ashx?action=%@",action])
//生产基地址
#define RequestURL(action)           ([NSString stringWithFormat:@"http://service.jfb315.com:9091/doPost.ashx?action=%@",action])
//#define RequestURL(action)           ([NSString stringWithFormat:@"http://10.88.134.111:9091/doPost.ashx?action=%@",action])
//#define RequestURL(action)           ([NSString stringWithFormat:@"http://203.195.197.14:9091/doPost.ashx?action=%@",action])
//#define RequestURL(action)           ([NSString stringWithFormat:@"http://172.16.193.134:9091/doPost.ashx?action=%@",action])


#define ActivityUrl(url)              ([NSString stringWithFormat:@"http://activity.jfb315.com:9095/%@",url])

#define UserAgreement         @"UserAgreement/Index.aspx"  //用户协议
#define AboutUs                 @"more/AboutUs.aspx"  //关于积分宝
#define PayHelp                 @"more/PayHelp.aspx"  //支付帮助
#define MyPrize                 @"Prize/MyPrize.aspx"   //我的奖品

//#define RequestURLStr @"http://service.jfb315.com:9091/doPost.ashx"

#pragma mark - 商户商品相关接口及通知标识
#define GetLottery                 @"GetLottery"    //获取活动，大转盘和砸金蛋
#define GetBanner                  @"GetBanner"     //获取广告图
#define GetMerchantTypeList     @"GetMerchantTypeList" //获取商户类型列表
#define GetVersion                  @"GetVersion" //获取接口版本号
#define GetCityDistricts            @"GetCityDistrictsNew2" //获取市和县区
#define GetMerchantList            @"GetMerchantListNew" //获取商户列表
#define GetAnnexMerchantList     @"GetAnnexMerchantListNew" //获取地图附近商户列表
#define GetMerchantDetailInfo      @"GetMerchantDetailInfoNew"     //获取商户详情
#define GetMerchantAlbumList       @"GetMerchantAlbumListNew"      //获取商户相册
#define SubmitCollect                  @"SubmitCollect"         //收藏、取消收藏操作
#define GetGoodsDetail              @"GetGoodsDetailNew"  //获取商品详情
#define GetReviewList              @"GetReviewListNew"     //获取商品所有评价列表
#define GetOrderDetail              @"GetOrderDetailNew"   //获取订单详情
#define SubmitOrder                 @"SubmitOrder"      //提交订单
#define OrderPay                    @"OrderPay"           //订单支付

#define AliPayNotification                  @"AliPayNotification"   //支付宝支付完成通知标识
#define WxPayNotification                  @"WxPayNotification"   //微信支付完成通知标识

#pragma mark - 登录注册相关接口及通知标识
#define SendSMSVerifyCode       @"SendSMSVerifyCode"  //发送短信验证码
#define SendSMSVerifyCodeNew       @"SendSMSVerifyCodeNew"  //发送验证码,包括短信和语音
#define VerifyMobile                @"VerifyMobile"  //验证手机号码是否已注册
#define MemberRegister             @"MemberRegister"  //注册
#define ForgotPwd                    @"ForgotPwd"   //重置密码
#define BoundPhoneNumber            @"BoundPhoneNumber"  //绑定手机号码
#define ModifyPwd                   @"ModifyPwd"    //修改密码

#define MemberLogin                 @"MemberLogin"  //会员登录

#define ModifyPoint                  @"ModifyPoint"  //更新会员积分


#pragma mark - 个人信息相关
#define GetDeliveryAddressList      @"GetDeliveryAddressList"   //获取会员收获地址列表

#define AddDeliveryAddressInfo      @"AddDeliveryAddressInfo"   //新增收获地址信息
#define ModifyDeliveryAddressInfo   @"ModifyDeliveryAddressInfo"    //修改收货地址信息
#define DeleteDeliveryAddressInfo    @"DeleteDeliveryAddressInfo"   //删除地址

#define GetCollectList                  @"GetCollectListNew"   //收藏列表
#define DeleteCollect                   @"DeleteCollect"    //删除收藏

#define GetOrderList                    @"GetOrderList"  //获取订单列表
#define DeleteOrder                     @"DeleteOrder"   //删除订单

#define Refund                           @"Refund"  //退款

#define GetReviewListByMember       @"GetReviewListByMemberNew"    //获取会员的评论列表
#define SubmitReview                    @"SubmitReview"         //提交评价

#define MerchantApply                   @"MerchantApplyNew"    //商户申请

#define MemberActivate            @"MemberActivate"  //会员激活
#define ModifyMemberInfo            @"ModifyMemberInfo"  //会员激活

#define CardPackageInquiry        @"CardPackageInquiry"   //卡套餐查询
#define ExchangeCard                @"ExchangeCard"     //更换新会员卡号

#define GetPensionDetails           @"GetPensionDetails"    //获取养老金明细
#define GetPensionChart             @"GetPensionChart"      //养老金7日走势图

#define GetMemberInfo               @"GetMemberInfo"    //根据会员mId获取会员信息

#define UM_Appkey                   @"55dacc7ce0f55a6e9f001917"   //友盟key

//QQ分享
#define kShare_QQ_AppID @"1104799590"
#define kShare_QQ_Appkey @"ptNCRAehFaj4x6eA"

//微信分享
#define kShare_WeChat_Appkey @"wx05ff86a8e7e493b9"
#define kShare_WeChat_AppSecret @"da8a4c800f6fd171f016332797efdc18"



#define BaiduMap_Key @"QCl2C3hrhCy5GOHFnesR4G0a" //积分宝百度地图key

#endif
