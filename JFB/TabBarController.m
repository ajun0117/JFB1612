//
//  TabBarController.m
//  JFB
//
//  Created by 李俊阳 on 15/8/13.
//  Copyright (c) 2015年 李俊阳. All rights reserved.
//

#import "TabBarController.h"
#import "UITabBarItem+Universal.h"

@implementation TabBarController

- (void)initTabBar {
    //[self.tabBar setBackgroundImage:[UIImage imageNamed:@"tab_bg"]];
    
    UIOffset offset = UIOffsetMake(0, -3);
    
    UIColor *redColor = RGBCOLOR(234, 33, 62);//主题红色
    
    NSDictionary *normalDict = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor blackColor],NSForegroundColorAttributeName, nil];
    NSDictionary *selectedDict = [NSDictionary dictionaryWithObjectsAndKeys:redColor,NSForegroundColorAttributeName, nil];
    
    UIImage *selectedImage0 = [UIImage imageNamed:@"tab_menu_home_pressed"];
    UIImage *unselectedImage0 = [UIImage imageNamed:@"tab_menu_home_normal"];
    UIImage *selectedImage1 = [UIImage imageNamed:@"tab_menu_customer_pressed"];
    UIImage *unselectedImage1 = [UIImage imageNamed:@"tab_menu_customer_normal"];
    UIImage *selectedImage2 = [UIImage imageNamed:@"tab_menu_self_pressed"];
    UIImage *unselectedImage2 = [UIImage imageNamed:@"tab_menu_self_normal"];
    UIImage *selectedImage3 = [UIImage imageNamed:@"tab_menu_more_pressed"];
    UIImage *unselectedImage3 = [UIImage imageNamed:@"tab_menu_more_normal"];
    
    UITabBar *tabBar = self.tabBar;
    UITabBarItem *item0 = [tabBar.items objectAtIndex:0];
    UITabBarItem *item1 = [tabBar.items objectAtIndex:1];
    UITabBarItem *item2 = [tabBar.items objectAtIndex:2];
    UITabBarItem *item3 = [tabBar.items objectAtIndex:3];
    
    [item0 itemWithImage:unselectedImage0 selectedImage:selectedImage0];
    [item1 itemWithImage:unselectedImage1 selectedImage:selectedImage1];
    [item2 itemWithImage:unselectedImage2 selectedImage:selectedImage2];
    [item3 itemWithImage:unselectedImage3 selectedImage:selectedImage3];
    
    [item0 setTitle:@"首页"];
    [item1 setTitle:@"商家"];
    [item2 setTitle:@"我的"];
    [item3 setTitle:@"更多"];
    
    [item0 setTitlePositionAdjustment:offset];
    [item1 setTitlePositionAdjustment:offset];
    [item2 setTitlePositionAdjustment:offset];
    [item3 setTitlePositionAdjustment:offset];
    
    [item0 setTitleTextAttributes:normalDict forState:UIControlStateNormal];
    [item0 setTitleTextAttributes:selectedDict forState:UIControlStateSelected];
    [item1 setTitleTextAttributes:normalDict forState:UIControlStateNormal];
    [item1 setTitleTextAttributes:selectedDict forState:UIControlStateSelected];
    [item2 setTitleTextAttributes:normalDict forState:UIControlStateNormal];
    [item2 setTitleTextAttributes:selectedDict forState:UIControlStateSelected];
    [item3 setTitleTextAttributes:normalDict forState:UIControlStateNormal];
    [item3 setTitleTextAttributes:selectedDict forState:UIControlStateSelected];
    
    // 解决超出屏幕tabbar图片背后显示黑线的问题
    [[UITabBar appearance] setShadowImage:[[UIImage alloc] init]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initTabBar];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
