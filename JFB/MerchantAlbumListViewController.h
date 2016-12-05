//
//  MerchantAlbumListViewController.h
//  JFB
//
//  Created by LYD on 15/9/15.
//  Copyright (c) 2015年 李俊阳. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MerchantAlbumListViewController : UIViewController

@property (strong, nonatomic) NSString *merchant_id;

@property (weak, nonatomic) IBOutlet UICollectionView *myCollectionView;

@end
