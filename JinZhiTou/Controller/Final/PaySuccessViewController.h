//
//  PaySuccessViewController.h
//  JinZhiTou
//
//  Created by BraveHeart on 16/3/7.
//  Copyright © 2016年 金指投. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RootViewController.h"
@interface PaySuccessViewController : RootViewController
{
    UIScrollView * contentView;
    UIButton * btnAction;
    UILabel * labelContent;
    UIImageView * imgView;
    UIImageView * imgSuccessView;
}
@property(retain, nonatomic) UIImageView * imgView;
@property(retain, nonatomic) UILabel * titleLabel; //标题
@property(retain, nonatomic) UILabel * subTitleLabel; //二级标题
@end
