//
//  InvestViewController.m
//  JinZhiTou
//
//  Created by BraveHeart on 16/3/5.
//  Copyright © 2016年 金指投. All rights reserved.
//

#import "InvestViewController.h"
#import "TradePasswdView.h"
#import "InvestItemDataView.h"
#import "BankChooseViewController.h"
#import "PaySuccessViewController.h"
@interface InvestViewController ()

@end

@implementation InvestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //设置标题
    self.navView.imageView.alpha=1;
    [self.navView setTitle:@"确认投资"];
    self.navView.titleLable.textColor=WriteColor;
    
    [self.navView.leftButton setImage:nil forState:UIControlStateNormal];
    [self.navView.leftButton setTitle:@"项目详情" forState:UIControlStateNormal];
    [self.navView.leftTouchView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(back:)]];
    
    [self setup];
}

-(void)setup
{
    //1.init
    contentView = [UIScrollView new];
    headerView = [InvestHeaderView new];
    InvestItemDataView * itemDataView1 = [InvestItemDataView new];
    InvestItemDataView * itemDataView2 = [InvestItemDataView new];
    InvestItemDataView * itemDataView3 = [InvestItemDataView new];
    InvestItemDataView * itemDataView4 = [InvestItemDataView new];
    InvestItemDataView * itemDataView5 = [InvestItemDataView new];
    InvestItemDataView * itemDataView6 = [InvestItemDataView new];
    
    UIButton * btnAction = [UIButton new];
    
    
    //2. addSubView
    [self.view addSubview:contentView];
    [contentView addSubview:headerView];
    [contentView addSubview:itemDataView1];
    [contentView addSubview:itemDataView2];
    [contentView addSubview:itemDataView3];
    [contentView addSubview:itemDataView4];
    [contentView addSubview:itemDataView5];
    [contentView addSubview:itemDataView6];
    [contentView addSubview:btnAction];
    
    //3.property
    contentView.bounces = YES;
    contentView.backgroundColor = BackColor;
    
    itemDataView1.tag = 1001;
    itemDataView1.titleLabel.text = @"持卡人";
    itemDataView1.textField.placeholder = @"请输入持卡人姓名";
    
    itemDataView2.tag = 1002;
    itemDataView2.titleLabel.text = @"卡号";
    itemDataView2.textField.placeholder = @"请输入持卡人卡号";
    
    itemDataView3.tag = 1003;
    itemDataView3.isCanChoose = YES;
    itemDataView3.titleLabel.text = @"选择银行";
    itemDataView3.userInteractionEnabled = YES;
    [itemDataView3 addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(actionChooseBank:)]];
    itemDataView3.textField.placeholder = @"";
    
    
    itemDataView4.tag = 1004;
    itemDataView4.titleLabel.text = @"金额";
    itemDataView4.textField.placeholder = @"请输入金额";
    
    itemDataView5.tag = 1005;
    itemDataView5.titleLabel.text = @"电话";
    itemDataView5.textField.placeholder = @"请输入银行预留手机号码";
    
    itemDataView6.tag = 1006;
    itemDataView6.isButtonShow = YES;
    itemDataView6.titleLabel.text = @"验证码";
    itemDataView6.textField.placeholder = @"请输入短信验证码";
    
    
    [btnAction setImage:IMAGENAMED(@"btnPay") forState:UIControlStateNormal];
    [btnAction addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    
    //4.layout
    contentView.sd_layout
    .spaceToSuperView(UIEdgeInsetsMake(kTopBarHeight + kStatusBarHeight, 0, 0, 0));
    
    headerView.sd_layout
    .topSpaceToView(contentView,10)
    .leftSpaceToView(contentView, 0)
    .rightSpaceToView(contentView, 0)
    .autoHeightRatio(0);
    
    itemDataView1.sd_layout
    .heightIs(46)
    .topSpaceToView(headerView, 10)
    .leftSpaceToView(contentView, 0)
    .rightSpaceToView(contentView, 0);
    
    
    itemDataView2.sd_layout
    .heightIs(46)
    .topSpaceToView(itemDataView1, 0)
    .leftSpaceToView(contentView, 0)
    .rightSpaceToView(contentView, 0);
    
    
    itemDataView3.sd_layout
    .heightIs(46)
    .topSpaceToView(itemDataView2, 0)
    .leftSpaceToView(contentView, 0)
    .rightSpaceToView(contentView, 0);

    
    itemDataView4.sd_layout
    .heightIs(46)
    .topSpaceToView(itemDataView3, 0)
    .leftSpaceToView(contentView, 0)
    .rightSpaceToView(contentView, 0);

    

    itemDataView5.sd_layout
    .heightIs(46)
    .topSpaceToView(itemDataView4, 0)
    .leftSpaceToView(contentView, 0)
    .rightSpaceToView(contentView, 0);

    
    itemDataView6.sd_layout
    .heightIs(46)
    .topSpaceToView(itemDataView5, 0)
    .leftSpaceToView(contentView, 0)
    .rightSpaceToView(contentView, 0);
    
    btnAction.sd_layout
    .topSpaceToView(itemDataView6, 13)
    .leftSpaceToView(contentView, 25)
    .rightSpaceToView(contentView, 25)
    .heightIs(40);
    
    [contentView setupAutoContentSizeWithBottomView:btnAction bottomMargin:40];
}

-(void)actionChooseBank:(id)sender
{
    BankChooseViewController * controller = [[BankChooseViewController alloc]init];
    [self.navigationController pushViewController:controller animated:YES];
}


- (void)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)btnAction:(id)sender
{
//    PaySuccessViewController * controller = [[PaySuccessViewController alloc]init];
//    [self.navigationController pushViewController:controller animated:YES];
    
    TradePasswdView * tradePasswdView = [[TradePasswdView alloc]initWithFrame:FRAME(self.view)];
    [self.view addSubview:tradePasswdView];
    
    [UIView animateWithDuration:0.75f animations:^{
        
        tradePasswdView.frame = CGRectMake(0, 640, self.view.frame.size.width, self.view.frame.size.height);
        
        tradePasswdView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        
    } completion:^(BOOL finished) {
        
    }];
}

@end
