//
//  GlobalSetting.h
//  JFB
//
//  Created by 李俊阳 on 15/8/17.
//  Copyright (c) 2015年 李俊阳. All rights reserved.
//

#define KUserId         @"uid"
#define KLoginName      @"LoginName"
#define KPassword       @"Password"

#define KIsFirst        @"isfisrt"
#define KAppVersion     @"appVersion"

#define kLoginPWD       @"loginPWD"
#define kUserID         @"userID"
#define KUserInfo       @"userInfo"

#define KMerchantTypeList    @"merchantTypeList"

#define KMyLocation            @"myLocation"

#define kIsLogined              @"isLogined"

#define kCitysDic              @"citysDic"

#define KSearchHistory          @"searchHistory"

#import <Foundation/Foundation.h>
//#import "CityObject.h"
//#import "CountysObject.h"

@interface GlobalSetting : NSObject

/**
 *  返回一个全局设置的类的单例
 *
 *  @return
 */
+(GlobalSetting *)shareGlobalSettingInstance;

/**
 *  返回一个颜色值
 *
 *  @return
 */
+ (UIColor *) colorWithHexString: (NSString *) hexString;

#pragma mark - 工具方法
//给一个时间，给一个数，正数是以后n个月，负数是前n个月；
-(NSDate *)getPriousorLaterDateFromDate:(NSDate *)date withMonth:(int)month;

//字符串转换为*
-(NSString *)transformToStarStringWithString:(NSString *)normalString;

- (NSString *)addSpacingToLabelWithString:(NSString *)toBeString;

#pragma mark - NSUserDefaults存储方法...

///存储当前城市区县接口版本号
-(void) setCityDistricts_Version:(NSString *)cityDistricts_Version;
-(NSString *) cityDistricts_Version;


///存储当前商户类型接口版本号
-(void) setMerchantTypeList_Version:(NSString *)merchantTypeList_Version;
-(NSString *) merchantTypeList_Version;


/**
 *  是否是第一次进入应用
 *
 *  @return
 */
-(BOOL)isNotFirst;

/**
 *  设置第一次进入
 *
 *  @param isNotFirst
 */
-(void)setIsNotFirst:(BOOL)isNotFirst;

/**
 *  设置第一次进入
 *
 *  @param isNotFirst
 */
-(NSString *)appVersion;


-(void)setAppVersion:(NSString *)appVersion;


///**
// *  存取City对象
// *
// *  @return City对象
// */
//-(CityObject *)CityObject;
//
//-(void)setCityObject:(CityObject *)city;
//
//
///**
// *  存取County对象
// *
// *  @return County对象
// */
//-(CityObject *)CountyObject;
//
//-(void)setCountyObject:(CountysObject *)county;


/**
 *  存取首页已选数据
 *
 *  @return 已选数据字典
 */
-(NSMutableDictionary *)homeSelectedDic;

-(void)setHomeSelectedDic:(NSMutableDictionary *)dic;


/**
 *  存储用户登录密码
 *
 *  @param pwd 登录密码
 */
-(void)setLoginPWD:(NSString *)pwd;

-(NSString *)loginPWD;


/**
 *  存储用户会员id
 *
 *  @param uid 会员id
 */
-(void)setUserID:(NSString *)uid;

-(NSString *)userID;

//组织ID
-(void)setOrganizationID:(NSString *)oid;
-(NSString *)organizationID;

//认证姓名
-(void)setmName:(NSString *)mName;
-(NSString *)mName;

//认证身份证号
-(void)setmIdentityId:(NSString *)mIdentityId;
-(NSString *)mIdentityId;

//邮箱
-(void)setmEmail:(NSString *)mEmail;
-(NSString *)mEmail;

//会员位置信息
-(void)setmlocation:(NSString *)mlocation;
-(NSString *)mlocation;

/**
 *  是否认证
 *
 *  @param authenticate
 */
-(void)setAuthenticate:(id)authenticate;
-(id)authenticate;

/**
 *  是否可以换卡
 *
 *  @param authenticate
 */
-(void)setIsChangeCard:(id)isChangeCard;
-(id)isChangeCard;

/**
 *  是否绑定手机号
 *
 *  @param mBinding
 */
-(void)setmBinding:(id)mBinding;
-(id)mBinding;

/**
 *  绑定的手机号
 *
 *  @param mMobile
 */
-(void)setmMobile:(id)mMobile;
-(id)mMobile;

/**
 *  养老金金额
 *
 *  @param pension
 */
-(void)setPension:(NSString *)pension;
-(NSString *)pension;

/**
 *  卡号
 *
 *  @param cId
 */
-(void)setcId:(id)cId;
-(id)cId;


/**
 *  存储用户信息字典
 *
 *  @param userInfo 用户信息
 */
-(void)setUserInfo:(NSDictionary *)userInfo;

-(NSDictionary *)userInfo;

/**
 *  存储商户类型列表数据
 *
 *  @param merchantTypeList 列表数据
 */
-(void)setMerchantTypeList:(NSDictionary *)merchantTypeList;

-(NSDictionary *)merchantTypeList;

/**
 *  存储当前位置坐标
 *
 *  @param locationDic 坐标字典
 */
-(void)setMyLocationWithDic:(NSDictionary *)locationDic;

-(NSDictionary *)myLocation;


/**
 *  设置登录状态
 *
 *  @param islogined 是否登录标识
 */
-(void)setIsLogined:(BOOL)islogined;

-(BOOL)isLogined;


/**
 *  退出登录，清空用户信息，并置登录状态为NO
 */
-(void)logoutRemoveAllUserInfo;


/**
 *  设置城市区县数据
 *
 *  @param citysDic 城市区县数据字典
 */
-(void)setCitysDic:(NSDictionary *)citysDic;

-(NSDictionary *)citysDic;


//商户搜索历史记录
-(void)setSearchHistory:(NSArray *)historys;

-(NSArray *)historys;


/**
 *  移除UserDefaults
 */
-(void)removeUserDefaultsValue;


/**
 *  手机号码正则判断
 *
 *  @param phone 手机号码
 *
 *  @return 是手机号码，返回YES
 */
-(BOOL)validatePhone:(NSString *)phone;


@end
