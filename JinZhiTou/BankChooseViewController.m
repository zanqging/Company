//
//  BankChooseViewController.m
//  
//
//  Created by BraveHeart on 16/3/7.
//
//

#import "BankChooseViewController.h"
#import "InvestViewController.h"
@interface BankChooseViewController ()

@end

@implementation BankChooseViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    //设置标题
    self.navView.imageView.alpha=1;
    [self.navView setTitle:@"选择银行"];
    self.navView.titleLable.textColor=WriteColor;
    
    [self.navView.leftButton setImage:nil forState:UIControlStateNormal];
    [self.navView.leftButton setTitle:@"确认投资" forState:UIControlStateNormal];
    [self.navView.leftTouchView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(back:)]];
    
    [self setup];
    
    [self addChildView];
    
}

-(void)setup
{
    //1.init
    contentView = [UIScrollView new];
    
    //2. addSubView
    [self.view addSubview:contentView];
    
    //3.property
    contentView.bounces = YES;
    contentView.backgroundColor = BackColor;
    
    //4.layout
    contentView.sd_layout
    .spaceToSuperView(UIEdgeInsetsMake(kTopBarHeight + kStatusBarHeight, 0, 0, 0));
}

-(void)addChildView
{
    NSString * fileName = @"";
    UIView * view;
    UIView * lastView;
    UIImageView * imgView;
    
    for (int i = 1; i<=12; i++) {
        NSString * temp =@"bank_";
        if (i<10) {
            temp =@"bank_0";
        }
        fileName = [NSString stringWithFormat:@"%@%d",temp,i];
        
        view = [UIView new];
        imgView = [UIImageView new];
        [view addSubview:imgView];
        [contentView addSubview:view];
        
        view.backgroundColor = WriteColor;
        imgView.tag = 100+i;
        imgView.image = IMAGENAMED(fileName);
        imgView.userInteractionEnabled = YES;
        imgView.contentMode = UIViewContentModeScaleAspectFill;
        [imgView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(touchAction:)]];
        if (i==1) {
            view.sd_layout
            .leftSpaceToView(contentView,1)
            .topSpaceToView(contentView,1)
            .widthRatioToView(contentView, 0.33)
            .heightEqualToWidth();
        }else{
            if ((i-1)%3==0) {
                view.sd_layout
                .topSpaceToView(lastView,1)
                .leftSpaceToView(contentView,1)
                .widthRatioToView(contentView, 0.33)
                .heightEqualToWidth();
            }else{
                view.sd_layout
                .topEqualToView(lastView)
                .leftSpaceToView(lastView,1)
                .widthRatioToView(contentView, 0.33)
                .heightEqualToWidth();
            }
           
        }
        
        imgView.sd_layout
        .spaceToSuperView(UIEdgeInsetsMake(20, 20, 20, 20));
        
        lastView = view;
    }
}

-(void)touchAction:(UITapGestureRecognizer*)recongizer
{
    UIView * view = recongizer.view;
    NSInteger tag = view.tag;
    self.dataArray = [[NSMutableArray alloc]initWithObjects:@"浦发银行",@"中国民生银行",@"兴业银行",@"交通银行",@"中国建设银行",@"招商银行",@"中国工商银行",@"广发银行",@"中国银行",@"中国光大银行",@"中信银行",@"中国农业银行", nil];
    NSDictionary * dic = [NSDictionary dictionaryWithObject:self.dataArray[tag-100] forKey:@"bank"];
    InvestViewController * controller = (InvestViewController*)[[self.navigationController childViewControllers] objectAtIndex:0];
    controller.dic = dic;
    [self.navigationController popToViewController:controller animated:YES];
    
}

-(void)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}


@end
