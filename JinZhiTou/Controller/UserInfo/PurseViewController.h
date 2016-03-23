//
//  PurseViewController.h
//  JinZhiTou
//
//  Created by BraveHeart on 16/3/22.
//  Copyright © 2016年 金指投. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RootViewController.h"
#import "UIView+SDAutoLayout.h"
@interface PurseViewController : RootViewController
{
    UIScrollView * contentView;
    UIView * configView; //实名认证视图
    UIView * infoView; //认证信息视图
}

-(void)isCheckUserConfirmed;
@end
