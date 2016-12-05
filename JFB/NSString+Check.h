//
//  NSString+Check.h
//  JFB
//
//  Created by 李俊阳 on 15/8/24.
//  Copyright (c) 2015年 李俊阳. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Check)
//判断是否是合法的电话号码
+(BOOL) checkPhoneNumWithPhone:(NSString *)phone;
//判断string是否是纯数字,不是纯数字的字符串：返回YES
+(BOOL) checkStringWithString:(NSString *)string;
//短短string是不是一个网络链接
+(BOOL) checkUrlWithString:(NSString *)string;
//身份证号格式验证
+ (BOOL) validateIdentityCard: (NSString *)identityCard;
@end
