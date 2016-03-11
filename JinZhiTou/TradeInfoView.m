//
//  TradeInfoView.m
//  JinZhiTou
//
//  Created by BraveHeart on 16/3/8.
//  Copyright © 2016年 金指投. All rights reserved.
//

#import "TradeInfoView.h"
#import "TDUtil.h"
#import "UConstants.h"
#import "GlobalDefine.h"

@implementation TradeInfoView
-(id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = WriteColor;
        [self setup];
    }
    return self;
}

-(void)setup
{
    //1.init
    titleLabel = [UILabel new];
    countLabel = [UILabel new];
    tipLabel1 = [UILabel new];
    tipLabel2 = [UILabel new];
    imgView = [UIImageView new];
    unitCountLabel = [UILabel new];
    closeImgView = [UIImageView new];
    seprateImgView = [UIImageView new];
    
    enterView1 = [TradePasswdEnterView new];
    enterView2 = [TradePasswdEnterView new];
    
    
    //2.addChildViewToParentView
    [TDUtil addChildViewToView:self childViews:[NSArray arrayWithObjects:titleLabel,countLabel,imgView,unitCountLabel,closeImgView,seprateImgView,tipLabel1,tipLabel2, enterView1,enterView2,nil]];
    //3.setting
    imgView.image = IMAGENAMED(@"rmb");
    imgView.contentMode = UIViewContentModeScaleAspectFill;
    
    closeImgView.image = IMAGENAMED(@"rmb_x");
    closeImgView.contentMode = UIViewContentModeScaleAspectFill;
    
    countLabel.text = @"2000000.00";
    countLabel.font = SYSTEMFONT(16);
    
    unitCountLabel.text = @"20万";
    unitCountLabel.font = SYSTEMFONT(16);
    unitCountLabel.textColor  = [TDUtil colorWithHexString:@"ff6700"];
    
    seprateImgView.image = IMAGENAMED(@"rmb_line");
    
    tipLabel1.text = @"请输入支付密码";
    tipLabel2.text = @"请确认支付密码";
    tipLabel1.textAlignment = NSTextAlignmentCenter;
    tipLabel2.textAlignment = NSTextAlignmentCenter;
    
    //4.SDAutoLayout
    closeImgView.sd_layout
    .rightSpaceToView(self, 10)
    .topSpaceToView(self, 10)
    .heightIs(20)
    .widthIs(20);
    
    imgView.sd_layout
    .leftSpaceToView(self, 40)
    .topSpaceToView(self, 40)
    .heightIs(40)
    .widthIs(40);
    
    countLabel.sd_layout
    .leftSpaceToView(imgView, 5)
    .topEqualToView(imgView);
    
    [countLabel setSingleLineAutoResizeWithMaxWidth:150];
    
    unitCountLabel.sd_layout
    .leftSpaceToView(countLabel, 5)
    .topEqualToView(countLabel);
    
    [unitCountLabel setSingleLineAutoResizeWithMaxWidth:100];
    
    seprateImgView.sd_layout
    .heightIs(7)
    .leftEqualToView(imgView)
    .topSpaceToView(imgView, 5)
    .rightEqualToView(unitCountLabel);
    
    tipLabel1.sd_layout
    .heightIs(30)
    .leftSpaceToView(self, 20)
    .rightSpaceToView(self, 20)
    .topSpaceToView(seprateImgView, 5);
    
    enterView1.sd_layout
    .leftSpaceToView(self, 20)
    .rightSpaceToView(self, 20)
    .topSpaceToView(tipLabel1, 5);
    
    tipLabel2.sd_layout
    .heightIs(30)
    .leftSpaceToView(self, 20)
    .rightSpaceToView(self, 20)
    .topSpaceToView(enterView1, 5);
    
    enterView2.sd_layout
    .leftSpaceToView(self, 20)
    .rightSpaceToView(self, 20)
    .topSpaceToView(tipLabel2, 5);
    
    
    [self setupAutoHeightWithBottomView:enterView2 bottomMargin:30];
    
    
    
}
@end
