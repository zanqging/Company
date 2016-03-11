//
//  InvestHeaderView.h
//  JinZhiTou
//
//  Created by BraveHeart on 16/3/5.
//  Copyright © 2016年 金指投. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+SDAutoLayout.h"
#import "UIImageView+WebCache.h"
@interface InvestHeaderView : UIView
{
    UIView * singleLineView; //横线
}

@property(retain, nonatomic) UIImageView * imgView;
@property(retain, nonatomic) UILabel * titleLabel; //标题
@property(retain, nonatomic) UILabel * subTitleLabel; //二级标题
@end
