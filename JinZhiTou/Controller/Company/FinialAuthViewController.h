//
//  FinialAuthViewController.h
//  JinZhiTou
//
//  Created by air on 15/8/4.
//  Copyright (c) 2015年 金指投. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MWPhotoBrowser.h"
#import "RootViewController.h"
#import "UIView+SDAutoLayout.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "UITableView+SDAutoTableViewCellHeight.h"
@interface FinialAuthViewController : RootViewController<MWPhotoBrowserDelegate>
{
    int selectedIndex;
}
@property(assign,nonatomic)int type;
@property(retain,nonatomic)NSString* titleStr;
@property(retain,nonatomic)UITableView* tableView;
@property(retain,nonatomic)NSMutableArray* dataArray;

@property(retain,nonatomic)NSMutableArray* imgSelectArray;
@property(retain,nonatomic)NSMutableArray* imgSelectAssetArray;
@property (nonatomic, strong) NSMutableArray *photos;
@property (nonatomic, strong) NSMutableArray *thumbs;
@property (nonatomic, strong) NSMutableArray *assets;
@property(retain,nonatomic)MWPhotoBrowser *browser;
@property(assign,nonatomic)BOOL isSelectPic;

@property (nonatomic, strong) ALAssetsLibrary *ALAssetsLibrary;
@end
