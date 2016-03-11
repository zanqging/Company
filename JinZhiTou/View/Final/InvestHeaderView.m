//
//  InvestHeaderView.m
//  JinZhiTou
//
//  Created by BraveHeart on 16/3/5.
//  Copyright © 2016年 金指投. All rights reserved.
//

#import "InvestHeaderView.h"
#import "TDUtil.h"
#import "UConstants.h"
#import "GlobalDefine.h"
#import "InvestHeaderItemView.h"
@implementation InvestHeaderView
- (id)initWithFrame:(CGRect)frame
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
    singleLineView = [UIView new];
    self.titleLabel = [UILabel new];
    self.imgView = [UIImageView new];
    self.subTitleLabel = [UILabel new];
    
    //2.添加到视图
    [TDUtil addChildViewToView:self childViews:[NSArray arrayWithObjects:singleLineView,self.imgView,self.titleLabel,self.subTitleLabel, nil]];
    
    //3.设置属性
    self.titleLabel.text = @"逸景营地";
    self.titleLabel.font = SYSTEMFONT(15);
    self.subTitleLabel.font = SYSTEMFONT(12);
    self.imgView.image = IMAGENAMED(@"test");
    self.subTitleLabel.text = @"逸景营地投资有限公司";
    self.titleLabel.textColor = [TDUtil colorWithHexString:@"#474747"];
    self.subTitleLabel.textColor = [TDUtil colorWithHexString:@"#747474"];
    singleLineView.backgroundColor = [TDUtil colorWithHexString:@"#838383"];
    
    //4.自适应布局
    self.imgView.sd_layout
    .topSpaceToView(self, 12)
    .leftSpaceToView(self, 25)
    .widthIs(70)
    .heightIs(56);
    
    self.titleLabel.sd_layout
    .topEqualToView(self.imgView)
    .leftSpaceToView(self.imgView, 12)
    .autoHeightRatio(0);
    
    [self.titleLabel setSingleLineAutoResizeWithMaxWidth:250];
    
    self.subTitleLabel.sd_layout
    .leftEqualToView(self.titleLabel)
    .topSpaceToView(self.titleLabel, 2)
    .autoHeightRatio(0);
    
    [self.subTitleLabel setSingleLineAutoResizeWithMaxWidth:300];
    
    singleLineView.sd_layout
    .heightIs(1)
    .rightSpaceToView(self, 10)
    .leftEqualToView(self.imgView)
    .topSpaceToView(self.imgView, 5);
    
    
    InvestHeaderItemView * itemView = [InvestHeaderItemView new];
    itemView.tag = 1001;
    itemView.subTitleLabel.text = @"融资总额";
    itemView.imgView.image = IMAGENAMED(@"iconfont-rong");
    [self addSubview:itemView];
    
    itemView.sd_layout
    .heightIs(70)
    .widthRatioToView(self,0.3)
    .topSpaceToView(singleLineView, 5)
    .leftSpaceToView(self, 0);
    
    itemView = [InvestHeaderItemView new];
    itemView.tag = 1002;
    itemView.imgView.image = IMAGENAMED(@"coins");
    itemView.subTitleLabel.text = @"已融金额";
    [self addSubview:itemView];
    UIView * view = [self viewWithTag:1001];
    
    itemView.sd_layout
    .heightIs(70)
    .widthRatioToView(self,0.3)
    .topSpaceToView(singleLineView, 5)
    .leftSpaceToView(view,0);
    
    itemView = [InvestHeaderItemView new];
    itemView.tag = 1003;
    itemView.imgView.image = IMAGENAMED(@"iconfont-fukuanfangshiheedu");
    itemView.subTitleLabel.text = @"最低融资额";
    [self addSubview:itemView];
    
    view = [self viewWithTag:1002];
    
    itemView.sd_layout
    .heightIs(70)
    .widthRatioToView(self,0.4)
    .topSpaceToView(singleLineView, 5)
    .leftSpaceToView(view,0);
    
    [self setupAutoHeightWithBottomView:itemView bottomMargin:5];
}
@end
