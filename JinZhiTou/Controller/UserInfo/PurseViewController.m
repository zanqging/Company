//
//  PurseViewController.m
//  JinZhiTou
//
//  Created by BraveHeart on 16/3/22.
//  Copyright © 2016年 金指投. All rights reserved.
//

#import "PurseViewController.h"
#import "YeePayViewController.h"
@implementation PurseViewController

-(void) viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = ColorTheme;
    //设置标题
    self.navView.imageView.alpha=1;
    [self.navView setTitle:@"资金账户"];
    self.navView.titleLable.textColor=WriteColor;
    
    [self.navView.leftButton setImage:nil forState:UIControlStateNormal];
    [self.navView.leftButton setTitle:@"个人中心" forState:UIControlStateNormal];
    [self.navView.leftTouchView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(back:)]];
    
    [self setup];
    
    [self checkIsInvester];
//    [self isCheckUserConfirmed];
}

-(void)checkIsInvester
{
    [self.httpUtil getDataFromAPIWithOps:ISINVESTOR postParam:nil type:0 delegate:self sel:@selector(requestInvestCheck:)];
}

-(void)setup
{
    //1.init
    contentView = [UIScrollView new];
    
    //2.addSubViews
    [self.view addSubview:contentView];
    
    //3.set property
    contentView.backgroundColor = BackColor;
    
    //4. SDAutoLayout
    contentView.sd_layout
    .spaceToSuperView(UIEdgeInsetsMake(POS_Y(self.navView), 0, 0, 0));
}

-(void)addConfigView
{
    //1.init
    if (infoView) {
        infoView.alpha=0;
    }
    if (configView) {
        configView.alpha=1;
        return;
    }
    configView = [UIView new];
    
    UIImageView * imgView = [UIImageView new];
    UILabel * messageLabel = [UILabel new];
    UIButton * configButton = [UIButton new];
    
    //2.addSubViews
    [TDUtil addChildViewToView:contentView childViews:[NSArray arrayWithObjects:imgView,messageLabel,configView,configButton,nil]];
    
    //3.set property
    configView.backgroundColor = ClearColor;
    imgView.image = IMAGENAMED(@"empty");
    imgView.contentMode = UIViewContentModeScaleAspectFill;
    configButton.backgroundColor = [TDUtil colorWithHexString:@"#ff6700"];
    [configButton setTitle:@"开通资金帐户" forState:UIControlStateNormal];
    [configButton setTitleColor:WriteColor forState:UIControlStateNormal];
    [configButton addTarget:self action:@selector(goConfirm) forControlEvents:UIControlEventTouchUpInside];
    [configButton.titleLabel setFont:SYSTEMFONT(18)];
    
    messageLabel.text = @"您还没有没有开通资金帐户";
    messageLabel.textAlignment = NSTextAlignmentCenter;
    messageLabel.textColor = [TDUtil convertColorWithString:@"176176176"];
    //4. SDAutoLayout
    configView.sd_layout
    .spaceToSuperView(UIEdgeInsetsMake(0, 0, 0, 0));
    
    imgView.sd_layout
    .heightIs(170)
    .centerXEqualToView(contentView)
    .topSpaceToView(contentView, 50);
    
    messageLabel.sd_layout
    .heightIs(50)
    .leftSpaceToView(contentView, 0)
    .rightSpaceToView(contentView, 0)
    .topSpaceToView(imgView, 10);
    
//  [messageLabel setSingleLineAutoResizeWithMaxWidth:350];
    
    configButton.sd_layout
    .heightIs(40)
    .widthIs(265)
    .centerXEqualToView(contentView)
    .topSpaceToView(messageLabel, 30);
    
    [configButton setSd_cornerRadiusFromHeightRatio:[NSNumber numberWithFloat:0.5]];

}

-(void)addInfoView
{
    //1.init
    if (configView) {
        configView.alpha=0;
    }
    
    if (infoView) {
        infoView.alpha = 1;
        return;
    }
    
    infoView = [UIView new];
    UIImageView * imgView = [UIImageView new];
    UILabel * titleLabel = [UILabel new];
    UILabel * cardLabel = [UILabel new];
    UILabel * leftLabel = [UILabel new];
    UILabel * leftNumberLabel = [UILabel new];
    UILabel * useageLabel = [UILabel new];
    UILabel * useageNumberLabel = [UILabel new];
    UILabel * freezeLabel = [UILabel new];
    UILabel * freezeNumberLabel = [UILabel new];
    UILabel * noLabel = [UILabel new];
    UILabel * telLabel = [UILabel new];
    
    UIView * lineView = [UIView new];
    
    UIButton * bindButton = [UIButton new];
    
    //2.addSubViews
    [contentView addSubview:infoView];
    [contentView addSubview:bindButton];
    
    [TDUtil addChildViewToView:infoView childViews:[NSArray arrayWithObjects:imgView,titleLabel,cardLabel,leftLabel,leftNumberLabel,useageLabel,useageNumberLabel,freezeLabel,noLabel,telLabel,freezeNumberLabel,lineView,nil]];
    
    //3.set property
    infoView.backgroundColor = [TDUtil colorWithHexString:@"#00b8ec"];
    
    titleLabel.text = [BANK_LIST valueForKey:DICVFK(self.dataDic, @"bank")];
    titleLabel.font = FONT(@"PingFang SC", 16);
    titleLabel.textColor = WriteColor;
    
    cardLabel.text = DICVFK(self.dataDic, @"cardNo");
    cardLabel.font = FONT(@"PingFang SC", 24);
    cardLabel.textColor = WriteColor;
    
    leftLabel.text = @"余  额";
    leftLabel.textColor = WriteColor;
    leftLabel.font = FONT(@"PingFang SC", 12);
    leftLabel.textAlignment = NSTextAlignmentCenter;
    
    leftNumberLabel.text = STRING(@"%.2fw", [DICVFK(self.dataDic, @"balance") floatValue]/10000.0f);
    leftNumberLabel.textColor = WriteColor;
    leftNumberLabel.font = FONT(@"PingFang SC", 17);
    leftNumberLabel.textAlignment = NSTextAlignmentCenter;
    
    
    useageLabel.text = @"可用余额";
    useageLabel.textColor = WriteColor;
    useageLabel.font = FONT(@"PingFang SC", 12);
    useageLabel.textAlignment = NSTextAlignmentCenter;
    
    useageNumberLabel.text = STRING(@"%.2fw", [DICVFK(self.dataDic, @"availableAmount")  floatValue]/10000.0f
                                    );
    useageNumberLabel.textColor = WriteColor;
    useageNumberLabel.font = FONT(@"PingFang SC", 17);
    useageNumberLabel.textAlignment = NSTextAlignmentCenter;
    
    freezeLabel.text = @"冻结金额";
    freezeLabel.textColor = WriteColor;
    freezeLabel.font = FONT(@"PingFang SC", 12);
    freezeLabel.textAlignment = NSTextAlignmentCenter;
    
    freezeNumberLabel.text = STRING(@"%.2fw", [DICVFK(self.dataDic, @"freezeAmount") floatValue]/10000.0f);
    freezeNumberLabel.textColor = WriteColor;
    freezeNumberLabel.font = FONT(@"PingFang SC", 17);
    freezeNumberLabel.textAlignment = NSTextAlignmentCenter;
    
    
    noLabel.text = STRING(@"商户编号 %@", [TDUtil generateUserPlatformNo]);
    noLabel.textColor = WriteColor;
    noLabel.font = FONT(@"PingFang SC", 14);
    
    telLabel.text = STRING(@"手机 %@", DICVFK(self.dataDic, @"bindMobileNo"));
    telLabel.textColor = WriteColor;
    telLabel.font = FONT(@"PingFang SC", 14);
    telLabel.textAlignment = NSTextAlignmentCenter;
    
    lineView.backgroundColor = WriteColor;
    
    bindButton.backgroundColor = [TDUtil colorWithHexString:@"#ff6700"];
    [bindButton setTitle:@"绑定银行卡" forState:UIControlStateNormal];
    [bindButton setTitleColor:WriteColor forState:UIControlStateNormal];
    [bindButton addTarget:self action:@selector(bindCard) forControlEvents:UIControlEventTouchUpInside];
    [bindButton.titleLabel setFont:SYSTEMFONT(18)];
    
    if (DICVFK(self.dataDic, @"bank")) {
//        [bindButton setEnabled:NO];
//        [bindButton setAlpha:0];
        
        //===========================临时工作===========================//
//        [bindButton setTitle:@"提现" forState:UIControlStateNormal];
        [bindButton setTitle:@"提现" forState:UIControlStateNormal];
        [bindButton removeTarget:self action:@selector(bindCard) forControlEvents:UIControlEventTouchUpInside];
        //提现
        [bindButton addTarget:self action:@selector(toWithdrawConfirm) forControlEvents:UIControlEventTouchUpInside];
        //自动投标授权
//        [bindButton addTarget:self action:@selector(toAuthorizeAutoTransfer) forControlEvents:UIControlEventTouchUpInside];
        
        //确认转账
//        [bindButton addTarget:self action:@selector(confirmTender) forControlEvents:UIControlEventTouchUpInside];
        //余额转出
//         [bindButton addTarget:self action:@selector(finialConfirm) forControlEvents:UIControlEventTouchUpInside];

        //===========================临时工作===========================//
    }else{
        titleLabel.text = @"XXXX银行";
        cardLabel.text = @"还未绑定银行卡，请点击绑定";
        cardLabel.font = FONT(@"PingFang SC", 15);
        infoView.userInteractionEnabled = YES;
        [infoView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(bindCard)]];
    }

    
    //4. SDAutoLayout
    infoView.sd_layout
    .topSpaceToView(contentView, 23.5)
    .leftSpaceToView(contentView, 14)
    .rightSpaceToView(contentView, 14)
    .heightIs(210);
    
    infoView.sd_cornerRadius = [NSNumber numberWithInt:5];
    
    titleLabel.sd_layout
    .heightIs(16)
    .leftSpaceToView(infoView, 21)
    .topSpaceToView(infoView, 19);
    
    [titleLabel setSingleLineAutoResizeWithMaxWidth:200];
    
    cardLabel.sd_layout
    .heightIs(24)
    .leftSpaceToView(infoView, 21)
    .topSpaceToView(titleLabel, 21.5);
    
    [cardLabel setSingleLineAutoResizeWithMaxWidth:300];
    
    
    leftLabel.sd_layout
    .heightIs(12)
    .widthRatioToView(infoView, 0.333)
    .leftSpaceToView(infoView, 0)
    .topSpaceToView(cardLabel, 37);
    
    leftNumberLabel.sd_layout
    .heightIs(17)
    .widthRatioToView(infoView, 0.333)
    .leftEqualToView(leftLabel)
    .topSpaceToView(leftLabel, 9.5);
    
    useageLabel.sd_layout
    .heightIs(12)
    .widthRatioToView(infoView, 0.333)
    .leftSpaceToView(leftLabel, 0)
    .topEqualToView(leftLabel);
    
    useageNumberLabel.sd_layout
    .heightIs(17)
    .widthRatioToView(infoView, 0.333)
    .leftEqualToView(useageLabel)
    .topSpaceToView(leftLabel, 9.5);
    
    freezeLabel.sd_layout
    .heightIs(12)
    .widthRatioToView(infoView, 0.333)
    .leftSpaceToView(useageLabel, 0)
    .topEqualToView(leftLabel);
    
    freezeNumberLabel.sd_layout
    .heightIs(17)
    .widthRatioToView(infoView, 0.333)
    .leftEqualToView(freezeLabel)
    .topSpaceToView(leftLabel, 9.5);
    
    lineView.sd_layout
    .leftSpaceToView(infoView, 5.5)
    .rightSpaceToView(infoView, 5.5)
    .topSpaceToView(leftNumberLabel, 9.5)
    .heightIs(0.5);
    
    noLabel.sd_layout
    .leftSpaceToView(infoView, 10)
    .topSpaceToView(lineView,  11.5)
    .widthRatioToView(infoView, 0.45)
    .heightIs(14);
    
    telLabel.sd_layout
    .leftSpaceToView(noLabel, 0)
    .topEqualToView(noLabel)
    .widthRatioToView(infoView, 0.5)
    .heightIs(14);
    
    
    
    bindButton.sd_layout
    .heightIs(45)
    .widthIs(265)
    .centerXEqualToView(contentView)
    .topSpaceToView(infoView, 30);
    
    [bindButton setSd_cornerRadiusFromHeightRatio:[NSNumber numberWithFloat:0.5]];
    
}

-(void)isCheckUserConfirmed
{
    
    NSString * str = [TDUtil generateUserPlatformNo];
    
    NSMutableDictionary * dic = [NSMutableDictionary new];
    [dic setObject:str forKey:@"platformUserNo"];
    
    NSString * signString = [TDUtil convertDictoryToYeePayXMLString:dic];
    
    [self sign:signString sel:@selector(requestCheckUserSign:)];
    
    self.startLoading = YES;
}

-(void)loadUserInfo
{
     [self.httpUtil getDataFromAPIWithOps:[NSString stringWithFormat:@"%@",USERINFO] postParam:nil type:0 delegate:self sel:@selector(requestFinished:)];
}

-(void)goConfirm
{
    NSString* auth = [infoDic valueForKey:@"auth"];
    
    if (![auth isKindOfClass:NSNull.class]) {
        if (auth) {
            if ([auth respondsToSelector:@selector(isEqualToString:)]) {
                [[NSNotificationCenter defaultCenter]postNotificationName:@"alert" object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"您还未进行投资人身份认证，请先认证",@"msg",@"取消",@"cancel",@"去认证",@"sure",@"0",@"type",self,@"vController", nil]];
            }else{
                if([auth boolValue]){
                    NSUserDefaults * data = [NSUserDefaults standardUserDefaults];
                    NSString * str = [TDUtil generateUserPlatformNo];
                    
                    NSMutableDictionary * dic = [NSMutableDictionary new];
                    [dic setObject:str forKey:@"platformUserNo"];
                    [dic setObject:[TDUtil generateTradeNo] forKey:@"requestNo"];
                    [dic setObject:@"G2_IDCARD" forKey:@"idCardType"];
                    [dic setObject:@"ios://verify:" forKey:@"callbackUrl"];
                    [dic setObject:DICVFK(self.dataDic, @"tel") forKey:@"mobile"];
                    [dic setObject:DICVFK(self.dataDic, @"name") forKey:@"realName"];
                    [dic setObject:DICVFK(self.dataDic, @"idno") forKey:@"idCardNo"];
                    [dic setObject:notifyUrl forKey:@"notifyUrl"];
                    [dic setObject:[data valueForKey:USER_STATIC_NICKNAME] forKey:@"nickName"];
                    
                    
                    NSString * signString = [TDUtil convertDictoryToYeePayXMLString:dic];
                    
                    [self sign:signString sel:@selector(requestSign:)];
                }else if(![auth boolValue]){
                    [[NSNotificationCenter defaultCenter]postNotificationName:@"alert" object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"您的投资人身份认证未审核通过，请先联系客服",@"msg",@"",@"cancel",@"确定",@"sure",@"4",@"type",self,@"vController", nil]];
                }
            }
        }
    }else{
        [[NSNotificationCenter defaultCenter]postNotificationName:@"alert" object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"您的投资人身份认证正在审核中，请耐心等待",@"msg",@"",@"cancel",@"确定",@"sure",@"4",@"type",self,@"vController", nil]];
    }
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"reloadData" object:nil];
    
}

-(void)toWithdrawConfirm
{
    NSMutableDictionary * dic = [NSMutableDictionary new];
    
    [dic setObject:@"CONFIRM" forKey:@"mode"];
    [dic setObject:@"PLATFORM" forKey:@"feeMode"];
    [dic setObject:[TDUtil generateTradeNo] forKey:@"requestNo"];
    [dic setObject:@"ios://toWithdraw:" forKey:@"callbackUrl"];
    [dic setObject:[TDUtil generateUserPlatformNo] forKey:@"platformUserNo"];
    [dic setObject:notifyUrl forKey:@"notifyUrl"];
    NSString * signString = [TDUtil convertDictoryToYeePayXMLString:dic];
    [self sign:signString sel:@selector(requesttoWithdrawSign:)];

}

-(void)confirmTender
{
    NSString*filePath=[[NSBundle mainBundle] pathForResource:@"requestNo"ofType:@"txt"];
    
    NSString*str=[NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
//    NSLog(@"%@",str);
    NSArray * array = [str componentsSeparatedByString:@"\n"];
//    NSLog(@"%@",array);
    
    for (NSString * s in array) {
        NSMutableDictionary * dic = [NSMutableDictionary new];
        
        [dic setObject:@"CONFIRM" forKey:@"mode"];
        [dic setObject:s forKey:@"requestNo"];
        [dic setObject:notifyUrl forKey:@"notifyUrl"];
        NSString * signString = [TDUtil convertDictoryToYeePayXMLString:dic];
        [self sign:signString sel:@selector(requestConfirmTenderSign:)];
    }
    
}

//模拟投标
-(void)finialConfirm
{
    NSString * str = [TDUtil generateUserPlatformNo];
    
    float mount = [DICVFK(self.dataDic, @"availableAmount")  floatValue];
    float profit = 0.0f;
    
    float mount_profit = mount * profit;
    
    NSMutableDictionary * dic = [NSMutableDictionary new];
    
    NSMutableDictionary * dicItem = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%.2f",mount - mount_profit],@"amount",@"MEMBER",@"targetUserType",@"jinzht_0000_645",@"targetPlatformUserNo",@"TENDER",@"bizType", nil];
    NSMutableDictionary * dicItem2 = [NSMutableDictionary dictionaryWithObjectsAndKeys:STRING(@"%.2f", mount_profit),@"amount",@"MERCHANT",@"targetUserType",YeePayPlatformID,@"targetPlatformUserNo",@"TENDER",@"bizType", nil];
    
    [dic setObject:STRING(@"%.2f", mount) forKey:@"amount"];
    [dic setObject:str forKey:@"platformUserNo"];
    [dic setObject:@"MEMBER" forKey:@"userType"];
    [dic setObject:@"TENDER" forKey:@"bizType"];
    [dic setObject:[NSArray arrayWithObjects:dicItem,dicItem2,nil] forKey:@"details"];
    
    [dic setObject:[NSDictionary dictionaryWithObjectsAndKeys:[TDUtil generateTenderNo:@"24"],@"tenderOrderNo",@"重庆华合聚英企业管理咨询有限公司",@"tenderName",STRING(@"%.2f", 10000.0f),@"tenderAmount",@"重庆华合聚英企业管理咨询有限公司",@"tenderDescription",@"jinzht_0000_645",@"borrowerPlatformUserNo", nil] forKey:@"extend"];
    [dic setObject:[TDUtil generateTradeNo] forKey:@"requestNo"];
    [dic setObject:@"ios://tenderConfirm" forKey:@"callbackUrl"];
    [dic setObject:notifyUrl forKey:@"notifyUrl"];
    
    NSString * signString = [TDUtil convertDictoryToYeePayXMLString:dic];
    
    [self sign:signString sel:@selector(requestTender:)];
}


-(void)bindCard
{
    NSString * str = [TDUtil generateUserPlatformNo];
    
    NSMutableDictionary * dic = [NSMutableDictionary new];
    
    float mount = [[self.dataDic valueForKey:@"mount"] floatValue]*10000.00;
    
    [dic setObject:str forKey:@"platformUserNo"];
    [dic setObject:@"PLATFORM" forKey:@"feeMode"];
    [dic setObject:STRING(@"%.2f", mount) forKey:@"amount"];
    [dic setObject:[TDUtil generateTradeNo] forKey:@"requestNo"];
    [dic setObject:@"ios://bindCardConfirm" forKey:@"callbackUrl"];
    [dic setObject:notifyUrl forKey:@"notifyUrl"];
    
    
    NSString * signString = [TDUtil convertDictoryToYeePayXMLString:dic];
    
    [self sign:signString sel:@selector(requestSignBindCard:)];
}


/**
 * 自动转帐授权
 */
-(void)toAuthorizeAutoTransfer
{
    NSString * str = [TDUtil generateUserPlatformNo];
    
    NSMutableDictionary * dic = [NSMutableDictionary new];
    
    [dic setObject:str forKey:@"platformUserNo"];
    [dic setObject:[TDUtil generateTradeNo] forKey:@"requestNo"];
    [dic setObject:@"ios://bindCardConfirm" forKey:@"callbackUrl"];
    [dic setObject:notifyUrl forKey:@"notifyUrl"];
    
    
    NSString * signString = [TDUtil convertDictoryToYeePayXMLString:dic];
    
    [self sign:signString sel:@selector(requestSignAuthorizeAutoTransfer:)];
}


-(void)sign:(NSString*)signString sel:(SEL)sel
{
    [self.httpUtil getDataFromAPIWithOps:YeePaySignVerify postParam:[NSDictionary dictionaryWithObjectsAndKeys:signString,@"req",@"sign",@"method",nil] type:0 delegate:self sel:sel];
}


-(void)refresh
{
    [self isCheckUserConfirmed];
}
-(void)requestCheckUserSign:(ASIHTTPRequest *)request{
    NSString *jsonString = [TDUtil convertGBKDataToUTF8String:request.responseData];
    NSLog(@"返回:%@",jsonString);
    NSMutableDictionary* jsonDic = [jsonString JSONValue];
    
    if(jsonDic!=nil)
    {
        NSString* code = [jsonDic valueForKey:@"code"];
        if ([code intValue] == 0) {
            NSDictionary * data = [jsonDic valueForKey:@"data"];
            NSDictionary * dic = [NSDictionary dictionaryWithObjectsAndKeys:[data valueForKey:@"req"],@"req",[data valueForKey:@"sign"],@"sign",ACCOUNT_INFO,@"service", nil];
            [self.httpUtil getDataFromYeePayAPIWithOps:@"" postParam:dic type:0 delegate:self sel:@selector(requestCheckUser:)];
        }else if([code intValue] == 1){
            
        }
    }
}

-(void)requestCheckUser:(ASIHTTPRequest *)request{
    NSString *xmlString = [TDUtil convertGBKDataToUTF8String:request.responseData];
    NSLog(@"返回:%@",xmlString);
    NSDictionary * xmlDic = [TDUtil convertXMLStringElementToDictory:xmlString];
    
    if ([DICVFK(xmlDic, @"code") intValue]==101) {
        [self loadUserInfo];
        return;
    }else if([DICVFK(xmlDic, @"code") intValue]==1)
    {
        self.dataDic = [NSMutableDictionary dictionaryWithDictionary:xmlDic];
        [self addInfoView];
        self.startLoading  =NO;
        return;
    }else{
        
    }
     self.isNetRequestError = YES;
    
}

-(void)requestConfirmTender:(ASIHTTPRequest *)request{
    NSString *xmlString = [TDUtil convertGBKDataToUTF8String:request.responseData];
    NSLog(@"返回:%@",xmlString);
    NSDictionary * xmlDic = [TDUtil convertXMLStringElementToDictory:xmlString];
    
    if ([DICVFK(xmlDic, @"code") intValue]==101) {
        
        return;
    }else if([DICVFK(xmlDic, @"code") intValue]==1)
    {
        self.dataDic = [NSMutableDictionary dictionaryWithDictionary:xmlDic];
        NSLog(@"%@",self.dataDic);
        
        self.startLoading  =NO;
        return;
    }else{
        
    }
    self.isNetRequestError = YES;
    
}

-(void)requestSign:(ASIHTTPRequest *)request{
    NSString *jsonString = [TDUtil convertGBKDataToUTF8String:request.responseData];
    NSLog(@"返回:%@",jsonString);
    NSMutableDictionary* jsonDic = [jsonString JSONValue];
    
    if(jsonDic!=nil)
    {
        NSString* code = [jsonDic valueForKey:@"code"];
        if ([code intValue] == 0) {
            NSDictionary * data = [jsonDic valueForKey:@"data"];
            NSDictionary * dic = [NSDictionary dictionaryWithObjectsAndKeys:[data valueForKey:@"req"],@"req",[data valueForKey:@"sign"],@"sign", nil];
            YeePayViewController * controller = [[YeePayViewController alloc]init];
            controller.dic = nil;
            controller.PostPramDic = dic;
            controller.title = @"项目详情";
            controller.titleStr = @"实名认证";
            controller.state = PayStatusBindCard;
            controller.url = [NSURL URLWithString:STRING_3(@"%@%@",BUINESS_SERVER,YeePayToRegister,nil)];
            [self.navigationController pushViewController:controller animated:YES];
        }else if([code intValue] == 1){
            
        }
        self.startLoading  =NO;
        return;
    }
     self.isNetRequestError = YES;
}

-(void)requestFinished:(ASIHTTPRequest*)request
{
    NSString* jsonString =[TDUtil convertGBKDataToUTF8String:request.responseData];
    NSLog(@"返回:%@",jsonString);
    
    NSMutableDictionary* dic = [jsonString JSONValue];
    
    if (dic!=nil) {
        int code =[[dic valueForKey:@"code"] intValue];
        if (code == 0) {
            self.dataDic = DICVFK(dic, @"data");
            [self addConfigView];
        }
        self.startLoading = NO;
        return;
    }
     self.isNetRequestError = YES;
}


-(void)requesttoWithdrawSign:(ASIHTTPRequest *)request{
    NSString *jsonString = [TDUtil convertGBKDataToUTF8String:request.responseData];
    NSLog(@"返回:%@",jsonString);
    NSMutableDictionary* jsonDic = [jsonString JSONValue];
    
    if(jsonDic!=nil)
    {
        NSString* code = [jsonDic valueForKey:@"code"];
        if ([code intValue] == 0) {
            NSDictionary * data = [jsonDic valueForKey:@"data"];
            NSDictionary * dic = [NSDictionary dictionaryWithObjectsAndKeys:[data valueForKey:@"req"],@"req",[data valueForKey:@"sign"],@"sign", nil];
            YeePayViewController * controller = [[YeePayViewController alloc]init];
            controller.dic = nil;
            controller.PostPramDic = dic;
            controller.title = @"项目详情";
            controller.titleStr = @"提现";
            controller.state = PayToWithdraw;
            controller.url = [NSURL URLWithString:STRING_3(@"%@%@",BUINESS_SERVER,toWithdraw,nil)];
            [self.navigationController pushViewController:controller animated:YES];
        }else if([code intValue] == 1){
            
        }
    }
}

-(void)requestConfirmTenderSign:(ASIHTTPRequest *)request{
    NSString *jsonString = [TDUtil convertGBKDataToUTF8String:request.responseData];
    NSLog(@"返回:%@",jsonString);
    NSMutableDictionary* jsonDic = [jsonString JSONValue];
    
    if(jsonDic!=nil)
    {
        NSString* code = [jsonDic valueForKey:@"code"];
        if ([code intValue] == 0) {
            NSDictionary * data = [jsonDic valueForKey:@"data"];
            NSDictionary * dic = [NSDictionary dictionaryWithObjectsAndKeys:[data valueForKey:@"req"],@"req",[data valueForKey:@"sign"],@"sign",COMPLETE_TRANSACTION,@"service", nil];
            [self.httpUtil getDataFromYeePayAPIWithOps:@"" postParam:dic type:0 delegate:self sel:@selector(requestConfirmTender:)];
        }else if([code intValue] == 1){
            
        }
    }
}

-(void)requestSignBindCard:(ASIHTTPRequest *)request{
    NSString *jsonString = [TDUtil convertGBKDataToUTF8String:request.responseData];
    NSLog(@"返回:%@",jsonString);
    NSMutableDictionary* jsonDic = [jsonString JSONValue];
    
    if(jsonDic!=nil)
    {
        NSString* code = [jsonDic valueForKey:@"code"];
        if ([code intValue] == 0) {
            NSDictionary * data = [jsonDic valueForKey:@"data"];
            NSDictionary * dic = [NSDictionary dictionaryWithObjectsAndKeys:[data valueForKey:@"req"],@"req",[data valueForKey:@"sign"],@"sign", nil];
            YeePayViewController * controller = [[YeePayViewController alloc]init];
            controller.dic = nil;
            controller.PostPramDic = dic;
            controller.title = @"项目详情";
            controller.titleStr = @"绑定银行卡";
            controller.state = PayStatusBindCard;
            controller.url = [NSURL URLWithString:STRING_3(@"%@%@",BUINESS_SERVER,toBindBankCard,nil)];
            [self.navigationController pushViewController:controller animated:YES];
        }else if([code intValue] == 1){
            
        }
        self.startLoading  =NO;
        return ;
    }
    self.isNetRequestError = YES;
}


-(void)requestTender:(ASIHTTPRequest *)request{
    NSString *jsonString = [TDUtil convertGBKDataToUTF8String:request.responseData];
    NSLog(@"返回:%@",jsonString);
    NSMutableDictionary* jsonDic = [jsonString JSONValue];
    
    if(jsonDic!=nil)
    {
        NSString* code = [jsonDic valueForKey:@"code"];
        if ([code intValue] == 0) {
            NSDictionary * data = [jsonDic valueForKey:@"data"];
            NSDictionary * dic = [NSDictionary dictionaryWithObjectsAndKeys:[data valueForKey:@"req"],@"req",[data valueForKey:@"sign"],@"sign", nil];
            YeePayViewController * controller = [[YeePayViewController alloc]init];
            controller.dic = nil;
            controller.PostPramDic = dic;
            controller.title = @"项目详情";
            controller.titleStr = @"投标";
            controller.state = PayStatusBindCard;
            controller.url = [NSURL URLWithString:STRING_3(@"%@%@",BUINESS_SERVER,YeePayToCpTransaction,nil)];
            [self.navigationController pushViewController:controller animated:YES];
        }else if([code intValue] == 1){
            
        }
        self.startLoading  =NO;
        return ;
    }
    self.isNetRequestError = YES;
}


-(void)requestSignAuthorizeAutoTransfer:(ASIHTTPRequest *)request{
    NSString *jsonString = [TDUtil convertGBKDataToUTF8String:request.responseData];
    NSLog(@"返回:%@",jsonString);
    NSMutableDictionary* jsonDic = [jsonString JSONValue];
    
    if(jsonDic!=nil)
    {
        NSString* code = [jsonDic valueForKey:@"code"];
        if ([code intValue] == 0) {
            NSDictionary * data = [jsonDic valueForKey:@"data"];
            NSDictionary * dic = [NSDictionary dictionaryWithObjectsAndKeys:[data valueForKey:@"req"],@"req",[data valueForKey:@"sign"],@"sign", nil];
            YeePayViewController * controller = [[YeePayViewController alloc]init];
            controller.dic = nil;
            controller.PostPramDic = dic;
            controller.title = @"项目详情";
            controller.titleStr = @"自动转帐授权";
            controller.state = PayStatusBindCard;
            controller.url = [NSURL URLWithString:STRING_3(@"%@%@",BUINESS_SERVER,@"toAuthorizeAutoTransfer",nil)];
            [self.navigationController pushViewController:controller animated:YES];
        }else if([code intValue] == 1){
            
        }
        self.startLoading  =NO;
        return ;
    }
    self.isNetRequestError = YES;
}
/**
 *  权限检测
 *
 *  @param request
 */
-(void)requestInvestCheck:(ASIHTTPRequest *)request{
    NSString *jsonString = [TDUtil convertGBKDataToUTF8String:request.responseData];
    NSLog(@"返回:%@",jsonString);
    NSMutableDictionary* jsonDic = [jsonString JSONValue];
    
    if(jsonDic!=nil)
    {
        NSString* code = [jsonDic valueForKey:@"code"];
        if ([code intValue] == 0) {
            infoDic =[jsonDic valueForKey:@"data"];
        }else{
            if ([code intValue]==1) {
                [[NSNotificationCenter defaultCenter]postNotificationName:@"alert" object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[jsonDic valueForKey:@"msg"],@"msg",@"",@"cancel",@"确认",@"sure",@"4",@"type",self,@"vController", nil]];
            }else if([code intValue]==-1){
                //通知系统重新登录
                [[NSNotificationCenter defaultCenter]postNotificationName:@"login" object:nil];
            }
        }
    }else{
        [[DialogUtil sharedInstance] showDlg:self.view textOnly:[jsonDic valueForKey:@"msg"]];
    }
//    self.startLoading=NO;
}

-(void)requestFailed:(ASIHTTPRequest *)request
{
    NSString *jsonString = [TDUtil convertGBKDataToUTF8String:request.responseData];
    NSLog(@"返回:%@",jsonString);
     self.isNetRequestError = YES;
}



-(void)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self checkIsInvester];
    [self isCheckUserConfirmed];
}
@end
