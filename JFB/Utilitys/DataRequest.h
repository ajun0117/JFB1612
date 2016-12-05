//
//  DataRequest.h
//  JFB
//
//  Created by 李俊阳 on 15/8/16.
//  Copyright (c) 2015年 李俊阳. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking.h>

@interface DataRequest : NSObject{
    NSString *version;
}

/**
 *  创建一个访问网络的单例
 *
 *  @return 返回一个访问网络的单例
 */
+(DataRequest *)sharedDataRequest;

//检查网络
+(BOOL) checkNetwork;

//get方式访问网络
-(void) getDataWithUrl:(NSString *)urlStr delegate:(id)delegate params:(NSDictionary *)params info:(NSDictionary *)infoDic;
//post方式访问网络
-(void) postDataWithUrl:(NSString *)urlStr delegate:(id)delegate params:(id)params info:(NSDictionary *)infoDic;

/////
-(void) cancelRequest;
@end
