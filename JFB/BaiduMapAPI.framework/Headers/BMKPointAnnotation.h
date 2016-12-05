/*
 *  BMKPointAnnotation.h
 *  BMapKit
 *
 *  Copyright 2011 Baidu Inc. All rights reserved.
 *
 */


#import <Foundation/Foundation.h>
#import "BMKShape.h"
#import <CoreLocation/CLLocation.h>

///表示一个点的annotation
@interface BMKPointAnnotation : BMKShape {
	@package
    CLLocationCoordinate2D _coordinate;
    NSUInteger _tag;
}
///该点的坐标
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

/// 标注的tag
@property (nonatomic, assign) NSUInteger tag;

@end
