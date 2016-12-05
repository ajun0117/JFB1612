//
//  DataRequest.m
//  JFB
//
//  Created by 李俊阳 on 15/8/16.
//  Copyright (c) 2015年 李俊阳. All rights reserved.
//

#import "DataRequest.h"
//#import "Reachability.h"



static DataRequest *dataRequest;
@implementation DataRequest

-(instancetype)init{
    if (self = [super init]) {
        version = [self getVersion];
    }
    return self;
}

+(DataRequest *)sharedDataRequest{
    if (!dataRequest) {
        dataRequest = [[self alloc] init];
    }
    return dataRequest;
}

-(NSString*)getVersion{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    CFShow((__bridge CFTypeRef)(infoDictionary));
    // app名称
    //NSString *app_Name = [infoDictionary objectForKey:@"CFBundleDisplayName"];
    // app版本
    NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    // app build版本
    //NSString *app_build = [infoDictionary objectForKey:@"CFBundleVersion"];
    return app_Version;
}

//+(BOOL) checkNetwork{
//    Reachability *r = [Reachability reachabilityWithHostName:@"www.baidu.com"];
//    switch ([r currentReachabilityStatus]) {
//        case NotReachable:
//            return NO;
//            break;
//        case ReachableViaWWAN:
//            return YES;
//            break;
//        case ReachableViaWiFi:
//            return YES;
//            break;
//        default:
//            return NO;
//    }
//}

//get方式访问网络
-(void) getDataWithUrl:(NSString *)urlStr delegate:(id)delegate params:(NSDictionary *)params info:(NSDictionary *)infoDic{
    
    NSMutableString *appendString = [NSMutableString stringWithFormat:@"%@?_fs=1/_vc=%@",urlStr,version];
    if ([urlStr rangeOfString:@"?"].location != NSNotFound) {
        appendString = [urlStr mutableCopy];
    }
    
//    if ([DataRequest checkNetwork]) {
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
        manager.requestSerializer.timeoutInterval = 15;
        [manager GET:[appendString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"JSON: %@", responseObject);
            NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"success",@"RespResult",@"成功获取数据！",@"ContentResult", responseObject, @"RespData", [infoDic objectForKey:@"op"], @"op",nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:[infoDic objectForKey:@"op"] object:nil userInfo:userInfo];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
            NSDictionary *userInfo = nil;
            if (error.code == -1001) {
                userInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"error",@"RespResult",@"请求超时！",@"ContentResult",error,@"RespData",[infoDic objectForKey:@"op"], @"op", nil];
            }else {
                userInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"error",@"RespResult",@"网络请求失败！",@"ContentResult",error,@"RespData",[infoDic objectForKey:@"op"], @"op", nil];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:[infoDic objectForKey:@"op"] object:nil userInfo:userInfo];
        }];
//    } else {
//        NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"error",@"RespResult",@"网络无法连接！",@"ContentResult",[infoDic objectForKey:@"op"], @"op", nil];
//        [[NSNotificationCenter defaultCenter] postNotificationName:[infoDic objectForKey:@"op"] object:nil userInfo:userInfo];
//    }
}

//post方式访问网络
-(void) postDataWithUrl:(NSString *)urlStr delegate:(id)delegate params:(id)params info:(NSDictionary *)infoDic{
    
//    NSMutableString *appendString = [NSMutableString stringWithFormat:@"%@?_fs=1/_vc=%@",urlStr,version];
    
//    if ([DataRequest checkNetwork]) {
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];  //设置传参方式为JSON

        manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObjectsFromArray:[NSArray arrayWithObjects:@"text/plain", @"text/html",nil]];
        manager.requestSerializer.timeoutInterval = 120;
        [manager POST:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"JSON: %@", responseObject);
            NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"success",@"RespResult",@"成功获取数据！",@"ContentResult", responseObject, @"RespData", [infoDic objectForKey:@"op"], @"op",nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:[infoDic objectForKey:@"op"] object:nil userInfo:userInfo];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error.description);
            NSLog(@"Error: %@", error.debugDescription);
            NSDictionary *userInfo = nil;
            if (error.code == -1001) {
                userInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"error",@"RespResult",@"请求超时！",@"ContentResult",error,@"RespData",[infoDic objectForKey:@"op"], @"op", nil];
            } else {
                userInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"error",@"RespResult",@"网络请求失败！",@"ContentResult",error,@"RespData",[infoDic objectForKey:@"op"], @"op", nil];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:[infoDic objectForKey:@"op"] object:nil userInfo:userInfo];
        }];
//    } else {
//        NSDictionary *result = [[NSDictionary alloc] initWithObjectsAndKeys:@"error",@"RespResult",@"网络无法连接！",@"ContentResult", [infoDic objectForKey:@"op"], @"op",nil];
//        [[NSNotificationCenter defaultCenter] postNotificationName:[infoDic objectForKey:@"op"] object:nil userInfo:result];
//    }
}


-(void)cancelRequest{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.operationQueue cancelAllOperations];
    NSArray *operations = [manager.operationQueue operations];
}
@end
