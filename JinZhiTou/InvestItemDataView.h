//
//  InvestItemDataView.h
//  JinZhiTou
//
//  Created by BraveHeart on 16/3/5.
//  Copyright © 2016年 金指投. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+SDAutoLayout.h"
#import "UIImageView+WebCache.h"
@interface InvestItemDataView : UIView
@property(retain, nonatomic)UILabel * titleLabel;
@property(retain, nonatomic)UIButton *  btnAction;
@property(retain, nonatomic)UIImageView *  imgView;
@property(retain, nonatomic)UITextField * textField;

@property(assign, nonatomic)BOOL isCanChoose;
@property(assign, nonatomic)BOOL isButtonShow;
@end
