//
//  InvestViewController.h
//  JinZhiTou
//
//  Created by BraveHeart on 16/3/5.
//  Copyright © 2016年 金指投. All rights reserved.
//

#import "RootViewController.h"
#import "InvestHeaderView.h"
@interface InvestViewController : RootViewController
{
    InvestHeaderView * headerView;
    UIScrollView * contentView;
}
@property(retain, nonatomic)NSDictionary * dic;
@end
