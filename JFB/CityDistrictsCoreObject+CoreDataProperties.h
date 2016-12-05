//
//  CityDistrictsCoreObject+CoreDataProperties.h
//  JFB
//
//  Created by LYD on 15/9/28.
//  Copyright © 2015年 李俊阳. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "CityDistrictsCoreObject.h"

NS_ASSUME_NONNULL_BEGIN

@interface CityDistrictsCoreObject (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *isopen;
@property (nullable, nonatomic, retain) NSString *areaId;
@property (nullable, nonatomic, retain) NSString *areaName;
@property (nullable, nonatomic, retain) NSString *pyName;
@property (nullable, nonatomic, retain) NSString *level;
@property (nullable, nonatomic, retain) NSString *current_code;
@property (nullable, nonatomic, retain) NSString *parentID;

@end

NS_ASSUME_NONNULL_END
