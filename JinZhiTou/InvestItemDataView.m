//
//  InvestItemDataView.m
//  JinZhiTou
//
//  Created by BraveHeart on 16/3/5.
//  Copyright © 2016年 金指投. All rights reserved.
//

#import "InvestItemDataView.h"
#import "TDUtil.h"
@implementation InvestItemDataView
-(id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setup];
        self.backgroundColor = WriteColor;
    }
    return self;
}

-(void)setup
{
    //1.初始化控件
    self.titleLabel = [UILabel new];
    self.btnAction = [UIButton new];
    self.imgView = [UIImageView new];
    self.textField = [UITextField new];
    UIView * singleView = [UIView new];
    
    //2.添加到视图
    [TDUtil addChildViewToView:self childViews:[NSArray arrayWithObjects:self.titleLabel,self.textField,self.imgView,singleView,self.btnAction,nil]];
    //3.设置属性
    singleView.backgroundColor = [TDUtil colorWithHexString:@"#a0a0a0"];
    self.textField.font = SYSTEMFONT(13);
    self.titleLabel.font = SYSTEMFONT(15);
    self.titleLabel.textColor = [TDUtil colorWithHexString:@"#474747"];
    
    
    //4.自适应布局
    self.titleLabel.sd_layout
    .widthIs(70)
    .leftSpaceToView(self, 10)
    .topSpaceToView(self, 10)
    .autoHeightRatio(0);
    
    self.textField.sd_layout
    .heightIs(44)
    .leftSpaceToView(self.titleLabel, 0)
    .rightSpaceToView(self, 5);
    
    self.btnAction.sd_layout
    .leftSpaceToView(self.textField, 0)
    .topSpaceToView(self, 5)
    .widthIs(0)
    .heightRatioToView(self, 0.8);
    
    self.imgView.sd_layout
    .leftSpaceToView(self.btnAction, 0)
    .rightSpaceToView(self, 10);
    
    
    singleView.sd_layout
    .heightIs(1)
    .leftEqualToView(self.titleLabel)
    .rightSpaceToView(self, 10)
    .topSpaceToView(self.textField,0);
    
    [self setupAutoHeightWithBottomView:singleView bottomMargin:0];
}


-(void)setIsCanChoose:(BOOL)isCanChoose
{
    self->_isCanChoose = isCanChoose;
    
    self.imgView.sd_layout
    .widthIs(12)
    .heightIs(20.5)
    .topSpaceToView(self, 10)
    .rightSpaceToView(self,31);
    
    self.textField.enabled = NO;
    self.imgView.image = IMAGENAMED(@"btnMore");
    
}

-(void)setIsButtonShow:(BOOL)isButtonShow
{
    self->_isButtonShow = isButtonShow;
    
    //重新布局
    self.btnAction.sd_layout
    .rightSpaceToView(self, 10)
    .heightIs(38)
    .widthIs(107);
    
    self.textField.sd_layout
    .rightSpaceToView(self.btnAction, 5);
    
    
    [self.btnAction setImage:IMAGENAMED(@"btnSendCode") forState:UIControlStateNormal];
    
}

@end
