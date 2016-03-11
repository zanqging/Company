//
//  InvestHeaderItemView.m
//  JinZhiTou
//
//  Created by BraveHeart on 16/3/5.
//  Copyright © 2016年 金指投. All rights reserved.
//

#import "InvestHeaderItemView.h"
#import "TDUtil.h"
@implementation InvestHeaderItemView
-(id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setup];
        self.backgroundColor = WriteColor;
    }
    return self;
}

/**
 *  初始化工作
 */
-(void)setup
{
    //SDAutoLayout自适应
    //1.初始化控件
    self.titleLabel = [UILabel new];
    self.imgView = [UIImageView new];
    self.subTitleLabel = [UILabel new];
    
    //2.添加到View
    [TDUtil addChildViewToView:self childViews:[NSArray arrayWithObjects:self.titleLabel,self.imgView,self.subTitleLabel,nil]];
    
    //3.设置属性
    self.titleLabel.text = @"1000万";
    self.titleLabel.font = SYSTEMFONT(13);
    self.subTitleLabel.font = SYSTEMFONT(13);
    self.titleLabel.textColor = [TDUtil colorWithHexString:@"#ff6700"];
    self.subTitleLabel.textColor = [TDUtil colorWithHexString:@"#747474"];
    
    //4.自适应布局
    self.imgView.sd_layout
    .leftSpaceToView(self,10)
    .topSpaceToView(self, 10)
    .widthIs(30)
    .heightEqualToWidth();
    
    self.titleLabel.sd_layout
    .leftSpaceToView(self.imgView, 5)
    .topSpaceToView(self, 5)
    .autoHeightRatio(0);
    
    [self.titleLabel setSingleLineAutoResizeWithMaxWidth:150];
    
    
    self.subTitleLabel.sd_layout
    .leftSpaceToView(self.imgView, 5)
    .topSpaceToView(self.titleLabel, 2)
    .autoHeightRatio(0);
    
    [self.subTitleLabel setSingleLineAutoResizeWithMaxWidth:150];
    
    [self setupAutoHeightWithBottomView:self.subTitleLabel bottomMargin:10];
}
@end
