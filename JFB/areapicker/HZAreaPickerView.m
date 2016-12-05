//
//  HZAreaPickerView.m
//  JFB
//
//  Created by LYD on 15/8/26.
//  Copyright (c) 2015年 李俊阳. All rights reserved.
//

#import "HZAreaPickerView.h"
#import <QuartzCore/QuartzCore.h>
#import "AppDelegate.h"
#import "CityDistrictsCoreObject.h"

#define kDuration 0.3

@interface HZAreaPickerView ()
{
    AppDelegate *app;
    NSArray *provinces, *cities, *areas;
}

@end

@implementation HZAreaPickerView


- (id)initWithDelegate:(id<HZAreaPickerDelegate>)delegate
{
    
    self = [[[NSBundle mainBundle] loadNibNamed:@"HZAreaPickerView" owner:self options:nil] objectAtIndex:0];
    if (self) {
        self.delegate = delegate;
        self.locatePicker.dataSource = self;
        self.locatePicker.delegate = self;
        
        //加载数据
        
        app = (AppDelegate *)[UIApplication sharedApplication].delegate;
        provinces = [app selectDataWithLevel:@"1"];    //获取对应省份对象
        CityDistrictsCoreObject *prov = [provinces firstObject];
        cities = [app selectDataWithParentID:prov.areaId];
        CityDistrictsCoreObject *cit = [cities firstObject];
        
        self.state = prov.areaName;
        self.stateID = prov.areaId;
        self.city = cit.areaName;
        self.cityID = cit.areaId;
        
        areas = [app selectDataWithParentID:cit.areaId];
        
        
//        provinces = [[NSArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"area.plist" ofType:nil]];
//        cities = [[provinces objectAtIndex:0] objectForKey:@"cities"];
//        
//        self.state = [[provinces objectAtIndex:0] objectForKey:@"state"];
//        self.city = [[cities objectAtIndex:0] objectForKey:@"city"];
        
//        areas = [[cities objectAtIndex:0] objectForKey:@"areas"];
        if (areas.count > 0) {
//            self.district = [areas objectAtIndex:0];
            CityDistrictsCoreObject *are = [areas firstObject];
            self.district = are.areaName;
            self.districtID = are.areaId;
        } else{
            self.district = @"";
            self.districtID = @"";
        }
    }
    
    return self;
}



#pragma mark - PickerView lifecycle

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 3;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    switch (component) {
        case 0:
            return [provinces count];
            break;
        case 1:
            return [cities count];
            break;
        case 2:
                return [areas count];
                break;
        default:
            return 0;
            break;
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    switch (component) {
        case 0: {
            CityDistrictsCoreObject *prov = provinces [row];
            return prov.areaName;
        }
            break;
        case 1: {
            if ([cities count] > 0) {
                CityDistrictsCoreObject *cit = cities [row];
                return cit.areaName;
            }
            return @"";
        }
            break;
        case 2:{
            if ([areas count] > 0) {
                CityDistrictsCoreObject *are = areas [row];
                return are.areaName;
            }
            return @"";
        }
             break;
            
        default:
            return  @"";
            break;
    }
    return @"";
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    switch (component) {
        case 0: {
            CityDistrictsCoreObject *prov = provinces [row];
            cities = [app selectDataWithParentID:prov.areaId];
//            cities = [[provinces objectAtIndex:row] objectForKey:@"cities"];
            [self.locatePicker selectRow:0 inComponent:1 animated:YES];
            [self.locatePicker reloadComponent:1];
            
            CityDistrictsCoreObject *cit = [cities firstObject];
            areas = [app selectDataWithParentID:cit.areaId];
//            areas = [[cities objectAtIndex:0] objectForKey:@"areas"];
            [self.locatePicker selectRow:0 inComponent:2 animated:YES];
            [self.locatePicker reloadComponent:2];
            
            CityDistrictsCoreObject *prov2 = provinces [row];
            self.state = prov2.areaName;
            self.stateID = prov2.areaId;
//            self.state = [[provinces objectAtIndex:row] objectForKey:@"state"];
            if ([cities count] > 0) {
                CityDistrictsCoreObject *cit3 = [cities firstObject];
                self.city = cit3.areaName;
                self.cityID = cit3.areaId;
            } else{
                self.city = @"";
                self.cityID = @"";
            }
//            self.city = [[cities objectAtIndex:0] objectForKey:@"city"];
            if ([areas count] > 0) {
                CityDistrictsCoreObject *are = [areas firstObject];
                self.district = are.areaName;
                self.districtID = are.areaId;
//                self.district = [areas objectAtIndex:0];
            } else{
                self.district = @"";
                self.districtID = @"";
            }
        }
            break;
        case 1: {
            if ([cities count] > 0) {
                CityDistrictsCoreObject *cit = cities [row];
                areas = [app selectDataWithParentID:cit.areaId];
    //            areas = [[cities objectAtIndex:row] objectForKey:@"areas"];
                [self.locatePicker selectRow:0 inComponent:2 animated:YES];
                [self.locatePicker reloadComponent:2];
            }
            
            if ([cities count] > 0) {
                CityDistrictsCoreObject *cit2 = cities [row];
                self.city = cit2.areaName;
                self.cityID = cit2.areaId;
            }
            else {
                self.city = @"";
                self.cityID = @"";
            }
//            self.city = [[cities objectAtIndex:row] objectForKey:@"city"];
            if ([areas count] > 0) {
                CityDistrictsCoreObject *are = [areas firstObject];
                self.district = are.areaName;
                self.districtID = are.areaId;
//                self.district = [areas objectAtIndex:0];
            } else{
                self.district = @"";
                self.districtID = @"";
            }
        }
            break;
        case 2: {
            if ([areas count] > 0) {
                CityDistrictsCoreObject *are = areas [row];
                self.district = are.areaName;
                self.districtID = are.areaId;
//                self.district = [areas objectAtIndex:row];
            } else{
                self.district = @"";
                self.districtID = @"";
            }
        }
            break;
        default:
            break;
    }
    
    if([self.delegate respondsToSelector:@selector(pickerDidChaneStatus:)]) {
        [self.delegate pickerDidChaneStatus:self];
    }

}


#pragma mark - animation

- (void)showInView:(UIView *) view
{
    self.frame = CGRectMake(0, view.frame.size.height, self.frame.size.width, self.frame.size.height);
    [view addSubview:self];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.frame = CGRectMake(0, view.frame.size.height - self.frame.size.height, self.frame.size.width, self.frame.size.height);
    }];
    
}

- (void)cancelPicker
{
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.frame = CGRectMake(0, self.frame.origin.y+self.frame.size.height, self.frame.size.width, self.frame.size.height);
                     }
                     completion:^(BOOL finished){
                         [self removeFromSuperview];
                         
                     }];
    
}

@end
