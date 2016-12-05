//
//  HZAreaPickerView.h
//  JFB
//
//  Created by LYD on 15/8/26.
//  Copyright (c) 2015年 李俊阳. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HZAreaPickerView;

@protocol HZAreaPickerDelegate <NSObject>

@optional
- (void)pickerDidChaneStatus:(HZAreaPickerView *)picker;

@end

@interface HZAreaPickerView : UIView <UIPickerViewDelegate, UIPickerViewDataSource>

@property (assign, nonatomic) id <HZAreaPickerDelegate> delegate;
@property (strong, nonatomic) IBOutlet UIPickerView *locatePicker;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *completeBarBtn;

@property (copy, nonatomic) NSString *state; // 省
@property (copy, nonatomic) NSString *city;  //市
@property (copy, nonatomic) NSString *district; //区

@property (copy, nonatomic) NSString *stateID; // 省
@property (copy, nonatomic) NSString *cityID;  //市
@property (copy, nonatomic) NSString *districtID; //区

- (id)initWithDelegate:(id <HZAreaPickerDelegate>)delegate;
- (void)showInView:(UIView *)view;
- (void)cancelPicker;

@end
