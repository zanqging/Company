//
//  TeamDetailViewController.m
//  JinZhiTou
//
//  Created by air on 15/7/28.
//  Copyright (c) 2015年 金指投. All rights reserved.
//

#import "TeamDetailViewController.h"
#import "TDUtil.h"
#import "NavView.h"
#import "HttpUtils.h"
#import "LoadingUtil.h"
#import "LoadingView.h"
#import "UConstants.h"
#import "GlobalDefine.h"
#import "NSString+SBJSON.h"
#import "ASIFormDataRequest.h"
#import "UIImageView+WebCache.h"
@interface TeamDetailViewController ()<UIScrollViewDelegate,ASIHTTPRequestDelegate>
{
    UITextView* textView;
    HttpUtils* httpUtils;
    LoadingView* loadingView;
    UIScrollView* scrollView;
}
@end

@implementation TeamDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = ColorTheme;
    //设置标题
    self.navView.imageView.alpha=1;
    [self.navView setTitle:@"团队成员详情"];
    self.navView.titleLable.textColor=WriteColor;
    
    [self.navView.leftButton setImage:nil forState:UIControlStateNormal];
    [self.navView.leftButton setTitle:@"核心团队" forState:UIControlStateNormal];
    [self.navView.leftTouchView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(back:)]];
    
    [self setup];
    
}

-(void)setup{
    UIView* backView = [UIView new];
    backView.backgroundColor = WriteColor;
    [self.view addSubview:backView];
    
    UIImageView* imageView = [UIImageView new];
    imageView.backgroundColor =BackColor;
    imageView.tag = 1001;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view  addSubview:imageView];
    
    scrollView = [UIScrollView new];
    scrollView.delegate=self;
    scrollView.bounces = YES;
    scrollView.backgroundColor=ClearColor;
    scrollView.contentInset=UIEdgeInsetsMake(150, 0, 0, 0);
    [self.view addSubview:scrollView];
    
    UIView* v = [[UIView alloc]initWithFrame:CGRectMake(0, 0, WIDTH(scrollView), HEIGHT(self.view))];
    v.tag = 2001;
    v.backgroundColor = WriteColor;
    [scrollView addSubview:v];
    
    
    //头像
    UIImageView* headerImgView = [UIImageView new];
    headerImgView.image=IMAGENAMED(@"coremember");
    headerImgView.layer.cornerRadius=35;
    headerImgView.layer.masksToBounds=YES;
    headerImgView.tag = 1002;
    [v addSubview:headerImgView];
    
    //名称
    UILabel* lbl = [[UILabel alloc]initWithFrame:CGRectMake(0, POS_Y(imageView), WIDTH(scrollView), 30)];
    lbl.textAlignment = NSTextAlignmentCenter;
    lbl.tag = 6001;
    lbl.font = SYSTEMFONT(18);
    lbl.backgroundColor = WriteColor;
    [v addSubview:lbl];
//
    UILabel * lblTitle = [[UILabel alloc]initWithFrame:CGRectMake(0, POS_Y(lbl), WIDTH(scrollView), 30)];
    lblTitle.tag = 6002;
    lblTitle.font = SYSTEMFONT(16);
    lblTitle.backgroundColor = WriteColor;
    lblTitle.textAlignment = NSTextAlignmentCenter;
    [v addSubview:lblTitle];
//
    
    textView = [[UITextView alloc]initWithFrame:CGRectMake(10, POS_Y(lbl)+10, WIDTH(scrollView)-20, 350)];
    
    [v addSubview:textView];
    
    backView.sd_layout
    .spaceToSuperView(UIEdgeInsetsMake(POS_Y(self.navView), 0, 0, 0));
    
    imageView.sd_layout
    .leftEqualToView(self.view)
    .rightEqualToView(self.view)
    .topSpaceToView(self.navView, 0)
    .heightIs(200);
    
    
    scrollView.sd_layout
    .spaceToSuperView(UIEdgeInsetsMake(POS_Y(self.navView), 0, 0, 0));
    
    v.sd_layout
    .leftEqualToView(scrollView)
    .rightEqualToView(scrollView)
    .topSpaceToView(scrollView,0)
    .heightRatioToView(scrollView, 0.9f);
    
    headerImgView.sd_layout
    .heightIs(70)
    .topSpaceToView(v, -30)
    .widthEqualToHeight()
    .rightSpaceToView(v, 30);
    
    
    lbl.sd_layout
    .leftEqualToView(v)
    .rightEqualToView(v)
    .topSpaceToView(headerImgView, 10)
    .heightIs(30);
    
    lblTitle.sd_layout
    .leftEqualToView(v)
    .rightEqualToView(v)
    .topSpaceToView(lbl, 10)
    .heightIs(30);
    
    textView.sd_layout
    .leftSpaceToView(v, 10)
    .rightSpaceToView(v, 10)
    .topSpaceToView(lblTitle,10)
    .heightIs(300);
    
    [scrollView setupAutoContentSizeWithBottomView:textView bottomMargin:0];
    
    
}

-(void)setDataDic:(NSDictionary *)dataDic
{
    [super setDataDic:[NSMutableDictionary dictionaryWithDictionary:dataDic]];
    if (self.dataDic) {
        //头像背景
        UIImageView* imgView = (UIImageView*)[self.view viewWithTag:1001];
        [imgView sd_setImageWithURL:[self.dataDic valueForKey:@"photo"] placeholderImage:IMAGENAMED(@"coremember")];
        
        imgView = (UIImageView*)[scrollView viewWithTag:1002];
        [imgView sd_setImageWithURL:[self.dataDic valueForKey:@"photo"]];
        
        //姓名
        UIView* view = [scrollView viewWithTag:2001];
        UILabel* label = (UILabel*)[view viewWithTag:6001];
        label.text = [self.dataDic valueForKey:@"name"];
        
        //职位
        label = (UILabel*)[view viewWithTag:6002];
        label.text = [self.dataDic valueForKey:@"position"];
        
        //内容
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineSpacing = 10;// 字体的行间距
        
        NSDictionary *attributes = @{
                                     NSFontAttributeName:[UIFont systemFontOfSize:15],
                                     NSParagraphStyleAttributeName:paragraphStyle
                                     };
        textView.attributedText = [[NSAttributedString alloc] initWithString:[self.dataDic valueForKey:@"profile"] attributes:attributes];
        

    }
    
}


-(void)doAction:(id)sender
{
    
}

-(void)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}


-(void)requestFailed:(ASIHTTPRequest *)request
{
    
    loadingView.isError = YES;
    loadingView.content =@"网络连接失败!";
}
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
@end
