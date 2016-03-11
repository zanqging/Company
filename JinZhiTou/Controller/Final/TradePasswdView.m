//
//  TradePasswdViewController.m
//  JinZhiTou
//
//  Created by BraveHeart on 16/3/8.
//  Copyright © 2016年 金指投. All rights reserved.
//

#import "TradePasswdView.h"
#import "TDUtil.h"
#import "UConstants.h"
#import "GlobalDefine.h"
#import <QuartzCore/QuartzCore.h>
@implementation TradePasswdView
-(id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setup];
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(missViewController:)]];
    }
    
    return self;
}

-(void)setup
{
    //1.init
    contentView = [TradeInfoView new];
    backgroundView = [UIView new];
    
    //2.addChildViewToParentView
    [TDUtil addChildViewToView:self childViews:[NSArray arrayWithObjects:backgroundView,contentView, nil]];
    
    //3.setting
    backgroundView.alpha = 0.5f;
    self.backgroundColor = ClearColor;
    backgroundView.backgroundColor = BlackColor;
    
    contentView.layer.cornerRadius = 5;
    contentView.backgroundColor = WriteColor;
    
    //4. SDAutoLayout
    backgroundView.sd_layout
    .spaceToSuperView(UIEdgeInsetsMake(0, 0, 0, 0));
    
    contentView.sd_layout
    .topSpaceToView(self, 70)
    .leftSpaceToView(self, 25)
    .rightSpaceToView(self, 25)
    .bottomSpaceToView(self, 100);
}



-(void)missViewController:(id)sender
{
    [self removeFromSuperview];
}
@end
