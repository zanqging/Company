//
//  UserInfoViewController.h
//  JinZhiTou
//
//  Created by air on 15/8/6.
//  Copyright (c) 2015年 金指投. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MWPhotoBrowser.h"
#import "RootViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
@interface UserInfoViewController : RootViewController<MWPhotoBrowserDelegate>
@property(retain,nonatomic)NSArray* dataArray;
@property (strong, nonatomic)UITableView *tableView;

@property(retain,nonatomic)NSMutableArray* imgSelectArray;
@property(retain,nonatomic)NSMutableArray* imgSelectAssetArray;
@property (nonatomic, strong) NSMutableArray *photos;
@property (nonatomic, strong) NSMutableArray *thumbs;
@property (nonatomic, strong) NSMutableArray *assets;
@property(retain,nonatomic)MWPhotoBrowser *browser;
@property(assign,nonatomic)BOOL isSelectPic;

@property (nonatomic, strong) ALAssetsLibrary *ALAssetsLibrary;
@end
