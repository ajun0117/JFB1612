//
//  GlobalSetting.m
//  JFB
//
//  Created by 李俊阳 on 15/8/17.
//  Copyright (c) 2015年 李俊阳. All rights reserved.
//

#import "GlobalSetting.h"
static GlobalSetting *globalSetting;
@implementation GlobalSetting

-(instancetype)init{
    if ([super init]) {
        
    }
    return self;
}

+(GlobalSetting *)shareGlobalSettingInstance{
    if (!globalSetting) {
        globalSetting = [[self alloc] init];
    }
    return globalSetting;
}

+ (UIColor *) colorWithHexString: (NSString *) hexString

{
    
    NSString *colorString = [[hexString stringByReplacingOccurrencesOfString: @"#"withString: @""] uppercaseString];
    
    CGFloat alpha = 0.0f;
    CGFloat red = 0.0f;
    CGFloat blue = 0.0f;
    CGFloat green = 0.0f;
    
    switch ([colorString length]) {
            
        case 3: // #RGB
            
            alpha = 1.0f;
            
            red   = [self colorComponentFrom: colorString start: 0 length: 1];
            
            green = [self colorComponentFrom: colorString start: 1 length: 1];
            
            blue  = [self colorComponentFrom: colorString start: 2 length: 1];
            
            break;
            
        case 4: // #ARGB
            
            alpha = [self colorComponentFrom: colorString start: 0 length: 1];
            
            red   = [self colorComponentFrom: colorString start: 1 length: 1];
            
            green = [self colorComponentFrom: colorString start: 2 length: 1];
            
            blue  = [self colorComponentFrom: colorString start: 3 length: 1];
            
            break;
            
        case 6: // #RRGGBB
            
            alpha = 1.0f;
            
            red   = [self colorComponentFrom: colorString start: 0 length: 2];
            
            green = [self colorComponentFrom: colorString start: 2 length: 2];
            
            blue  = [self colorComponentFrom: colorString start: 4 length: 2];
            
            break;
            
        case 8: // #AARRGGBB
            
            alpha = [self colorComponentFrom: colorString start: 0 length: 2];
            
            red   = [self colorComponentFrom: colorString start: 2 length: 2];
            
            green = [self colorComponentFrom: colorString start: 4 length: 2];
            
            blue  = [self colorComponentFrom: colorString start: 6 length: 2];
            
            break;
            
        default:
            alpha = 1.0f;
            red = 0.0f;
            blue = 0.0f;
            green = 0.0f;
            break;
            
    }
    
    return [UIColor colorWithRed: red green: green blue: blue alpha: alpha];
    
}

+ (CGFloat) colorComponentFrom: (NSString *) string start: (NSUInteger) start length: (NSUInteger) length

{
    
    NSString *substring = [string substringWithRange: NSMakeRange(start, length)];
    
    NSString *fullHex = length == 2 ? substring : [NSString stringWithFormat: @"%@%@", substring, substring];
    
    unsigned hexComponent;
    
    [[NSScanner scannerWithString: fullHex] scanHexInt: &hexComponent];
    
    return hexComponent / 255.0;
    
}

#pragma mark - 工具方法
//给一个时间，给一个数，正数是以后n个月，负数是前n个月；
-(NSDate *)getPriousorLaterDateFromDate:(NSDate *)date withMonth:(int)month
{
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setMonth:month];
    NSCalendar *calender = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate *mDate = [calender dateByAddingComponents:comps toDate:date options:0];
    
    return mDate;
}


-(NSString *)transformToStarStringWithString:(NSString *)normalString {
    int leng = (int)[normalString length];
    NSRange range = NSMakeRange(1, leng - 1);
    NSMutableString *starString = [[NSMutableString alloc] init];
    for (int i = 0; i < leng - 1; ++i) {
        [starString appendString:@"*"];
    }
    NSString *transformStarString = [normalString stringByReplacingCharactersInRange:range withString:starString];
    
    return transformStarString;
}


/**
 *@brief 银行卡输入，textField4位加空格，16个数字后还能添加14位数字
 */
- (NSString *)addSpacingToLabelWithString:(NSString *)toBeString
{
    //检测是否为纯数字
    if ([self isPureInt:toBeString]) {
        //添加空格，每4位之后，4组之后不加空格，格式为xxxx xxxx xxxx xxxx xxxxxxxxxxxxxx
        if (toBeString.length % 5 == 4 && toBeString.length < 22) {
            toBeString = [NSString stringWithFormat:@"%@ ", toBeString];
        }
    }
    return toBeString;
}

- (BOOL)isPureInt:(NSString *)string{
    NSScanner* scan = [NSScanner scannerWithString:string];
    int val;
    return [scan scanInt:&val] && [scan isAtEnd];
}



#pragma mark - NSUserDefaults存储方法...

-(void) setCityDistricts_Version:(NSString *)cityDistricts_Version {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:cityDistricts_Version forKey:@"Save_CityDistricts_Version"];
    [userDefaults synchronize];
}

-(NSString *) cityDistricts_Version {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults objectForKey:@"Save_CityDistricts_Version"];
}


-(void) setMerchantTypeList_Version:(NSString *)merchantTypeList_Version {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:merchantTypeList_Version forKey:@"Save_MerchantTypeList_Version"];
    [userDefaults synchronize];
}

-(NSString *) merchantTypeList_Version {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults objectForKey:@"Save_MerchantTypeList_Version"];
}


-(BOOL)isNotFirst{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults boolForKey:KIsFirst];
}

-(void)setIsNotFirst:(BOOL)isNotFirst{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:isNotFirst forKey:KIsFirst];
    [userDefaults synchronize];
}

-(NSString *)appVersion {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults objectForKey:KAppVersion];
}

-(void)setAppVersion:(NSString *)appVersion{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:appVersion forKey:KAppVersion];
    [userDefaults synchronize];
}

//-(CityObject *)CityObject {
//    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//    return [userDefaults objectForKey:@"CityObject"];
//}
//
//-(void)setCityObject:(CityObject *)city {
//    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//    [userDefaults setObject:city forKey:@"CityObject"];
//    [userDefaults synchronize];
//}
//
//-(CityObject *)CountyObject {
//    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//    return [userDefaults objectForKey:@"CountyObject"];
//}
//
//-(void)setCountyObject:(CountysObject *)county {
//    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//    [userDefaults setObject:county forKey:@"CountyObject"];
//    [userDefaults synchronize];
//}


-(NSMutableDictionary *)homeSelectedDic {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults objectForKey:@"HomeSelectedDic"];
}

-(void)setHomeSelectedDic:(NSMutableDictionary *)dic {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:dic forKey:@"HomeSelectedDic"];
    [userDefaults synchronize];
}


-(void)setLoginPWD:(NSString *)pwd {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:pwd forKey:kLoginPWD];
    [userDefaults synchronize];
}

-(NSString *)loginPWD {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults valueForKey:kLoginPWD];
}

-(void)setUserID:(NSString *)uid {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:uid forKey:kUserID];
    [userDefaults synchronize];
}

-(NSString *)userID {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults valueForKey:kUserID];
}

-(void)setOrganizationID:(NSString *)oid {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:oid forKey:@"OrganizationID"];
    [userDefaults synchronize];
}

-(NSString *)organizationID {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults valueForKey:@"OrganizationID"];
}

-(void)setmName:(NSString *)mName {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:mName forKey:@"mName"];
    [userDefaults synchronize];
}

-(NSString *)mName {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults valueForKey:@"mName"];
}

-(void)setmIdentityId:(NSString *)mIdentityId {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:mIdentityId forKey:@"mIdentityId"];
    [userDefaults synchronize];
}

-(NSString *)mIdentityId {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults valueForKey:@"mIdentityId"];
}

-(void)setmEmail:(NSString *)mEmail {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:mEmail forKey:@"mEmail"];
    [userDefaults synchronize];
}

-(NSString *)mEmail {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults valueForKey:@"mEmail"];
}

-(void)setmlocation:(NSString *)mlocation {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:mlocation forKey:@"mlocation"];
    [userDefaults synchronize];
}

-(NSString *)mlocation {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults valueForKey:@"mlocation"];
}



-(void)setAuthenticate:(id)authenticate {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:authenticate forKey:@"isAuthenticate"];
    [userDefaults synchronize];
}

-(id)authenticate {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults valueForKey:@"isAuthenticate"];
}

-(void)setIsChangeCard:(id)isChangeCard{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:isChangeCard forKey:@"isChangeCard"];
    [userDefaults synchronize];
}

-(id)isChangeCard{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults valueForKey:@"isChangeCard"];
}


-(void)setmBinding:(id)mBinding {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:mBinding forKey:@"mBinding"];
    [userDefaults synchronize];
}

-(id)mBinding {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults valueForKey:@"mBinding"];
}


-(void)setmMobile:(id)mMobile {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:mMobile forKey:@"mMobile"];
    [userDefaults synchronize];
}

-(id)mMobile {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults valueForKey:@"mMobile"];
}


-(void)setPension:(NSString *)pension {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:pension forKey:@"pension"];
    [userDefaults synchronize];
}

-(NSString *)pension {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults valueForKey:@"pension"];
}


-(void)setcId:(id)cId {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:cId forKey:@"cId"];
    [userDefaults synchronize];
}

-(id)cId {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults valueForKey:@"cId"];
}


-(void)setUserInfo:(NSDictionary *)userInfo {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:userInfo forKey:KUserInfo];
    [userDefaults synchronize];
}

-(NSDictionary *)userInfo {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults valueForKey:KUserInfo];
}


-(void)setMerchantTypeList:(NSDictionary *)merchantTypeList {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:merchantTypeList forKey:KMerchantTypeList];
    [userDefaults synchronize];
}

-(NSDictionary *)merchantTypeList {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults valueForKey:KMerchantTypeList];
}

-(void)setMyLocationWithDic:(NSDictionary *)locationDic {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:locationDic forKey:KMyLocation];
    [userDefaults synchronize];
}

-(NSDictionary *)myLocation {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults valueForKey:KMyLocation];
}

-(void)setIsLogined:(BOOL)islogined {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:islogined forKey:kIsLogined];
    [userDefaults synchronize];
    
}

-(BOOL)isLogined {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults boolForKey:kIsLogined];
}


-(void)logoutRemoveAllUserInfo {    //退出登录，清空用户信息
    [[GlobalSetting shareGlobalSettingInstance] setLoginPWD:@""]; //存储登录密码
    [[GlobalSetting shareGlobalSettingInstance] setIsLogined:NO];  //未登录标示
    [[GlobalSetting shareGlobalSettingInstance] setUserID:@""];
    [[GlobalSetting shareGlobalSettingInstance] setAuthenticate:@""];
    [[GlobalSetting shareGlobalSettingInstance] setmBinding:@""];
    [[GlobalSetting shareGlobalSettingInstance] setmMobile:@""];
    [[GlobalSetting shareGlobalSettingInstance] setPension:@""];
    [[GlobalSetting shareGlobalSettingInstance] setcId:@""];
    [[GlobalSetting shareGlobalSettingInstance] setIsChangeCard:@""];
    [[GlobalSetting shareGlobalSettingInstance] setOrganizationID:@""];
    [[GlobalSetting shareGlobalSettingInstance] setmName:@""];
    [[GlobalSetting shareGlobalSettingInstance] setmIdentityId:@""];
    [[GlobalSetting shareGlobalSettingInstance] setmEmail:@""];
    [[GlobalSetting shareGlobalSettingInstance] setmlocation:@""];
    
}

/**
 *  设置城市区县数据
 *
 *  @param citysDic 城市区县数据字典
 */
-(void)setCitysDic:(NSDictionary *)citysDic {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:citysDic forKey:kCitysDic];
    [userDefaults synchronize];
}

-(NSDictionary *)citysDic {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults objectForKey:kCitysDic];
}


//商户搜索历史记录
-(void)setSearchHistory:(NSArray *)historys {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:historys forKey:KSearchHistory];
    [userDefaults synchronize];
}

-(NSArray *)historys {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults objectForKey:KSearchHistory];
}

-(void)removeUserDefaultsValue{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    
    [userDefaults synchronize];
}


#pragma mark - 工具方法...

#pragma mark - 电话号码正则验证
-(BOOL)validatePhone:(NSString *)phone {
    NSString *phoneRegex = @"^1[3|4|5|7|8][0-9]\\d{8}$";
    
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", phoneRegex];
    return [emailTest evaluateWithObject:phone];
}

@end
