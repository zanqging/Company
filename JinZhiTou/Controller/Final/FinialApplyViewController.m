//
//  FinialApplyViewController.m
//  JinZhiTou
//
//  Created by air on 15/8/5.
//  Copyright (c) 2015年 金指投. All rights reserved.
//

#import "FinialApplyViewController.h"
#import "FinialKind.h"
#import "YeePayViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "UserFinialViewController.h"
#import "PaySuccessViewController.h"
#import "FinialSuccessViewController.h"
@interface FinialApplyViewController ()<UIScrollViewDelegate,UITextFieldDelegate,ASIHTTPRequestDelegate>
{
    int currentSelect;
    BOOL isShowInfoView;
    
    NSInteger currentTag;
    UIScrollView* scrollView;
    
}

@end

@implementation FinialApplyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = ColorTheme;
    //设置标题
    self.navView.imageView.alpha=1;
    [self.navView setTitle:@"投资"];
    self.navView.titleLable.textColor=WriteColor;
    
    [self.navView.leftButton setImage:nil forState:UIControlStateNormal];
    [self.navView.leftButton setTitle:@"项目详情" forState:UIControlStateNormal];
    [self.navView.leftButton setTitle:self.titleStr forState:UIControlStateNormal];
    [self.navView.leftTouchView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(back:)]];
    
    [self addView];
    
    [self loadData];
    
    //数据初始化
    currentSelect=1;
    currentTag=20002;
}

-(void)addView
{
    scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, POS_Y(self.navView), WIDTH(self.view), HEIGHT(self.view)-POS_Y(self.navView))];
    scrollView.tag =40001;
    scrollView.delegate=self;
    scrollView.bounces = NO;
    scrollView.backgroundColor=BackColor;
    [self.view addSubview:scrollView];
    
    UITapGestureRecognizer* recognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doAction:)];
    //自然投资人
    FinialKind* finialKindView = [[FinialKind alloc]initWithFrame:CGRectMake(30, 10, WIDTH(self.view)/2-35, 40)];
    finialKindView.tag = 20001;
    finialKindView.isSelected = YES;
    finialKindView.backgroundColor = AppColorTheme;
    finialKindView.label.textColor = WriteColor;
    [finialKindView addGestureRecognizer:recognizer];
    [finialKindView setImageWithNmame:@"Lead investor-white" setText:@"我要领投"];
    [scrollView addSubview:finialKindView];
    
    recognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doAction:)];
    //机构投资人
    finialKindView = [[FinialKind alloc]initWithFrame:CGRectMake(WIDTH(self.view)/2+5, 10, WIDTH(self.view)/2-35, 40)];
    finialKindView.tag = 20002;
    finialKindView.isSelected = NO;
    finialKindView.label.textColor = AppColorTheme;
    [finialKindView addGestureRecognizer:recognizer];
    [finialKindView setImageWithNmame:@"With investment" setText:@"我要跟投"];
    [scrollView addSubview:finialKindView];
    
    //填写信息
    UIView* view = [[UIView alloc]initWithFrame:CGRectMake(10, POS_Y(finialKindView)+10, WIDTH(self.view)-20, 50)];
    view.tag = 30001;
    view.backgroundColor  =WriteColor;
    [scrollView addSubview:view];
    
    
    view.userInteractionEnabled =YES;
    view.backgroundColor  =WriteColor;
    
    //投资额度
    UILabel* lable = [[UILabel alloc]initWithFrame:CGRectMake(0, 10, WIDTH(scrollView)*1/4, 30)];
    lable.text = @"投资额度";
    lable.font = SYSTEMFONT(16);
    lable.textAlignment = NSTextAlignmentRight;
    lable.textColor = BACKGROUND_LIGHT_GRAY_COLOR;
    [view addSubview:lable];
    
    //输入投资额度
    UITextField* textField = [[UITextField alloc]initWithFrame:CGRectMake(POS_X(lable)+10, Y(lable), 180, 30)];
    textField.tag =500001;
    textField.enabled  =YES;
    textField.delegate = self;
    textField.font  =SYSTEMFONT(18);
    textField.userInteractionEnabled = YES;
    textField.returnKeyType = UIReturnKeyDone;
    textField.placeholder = @"投资额度:单位：万元";
    textField.keyboardType  =UIKeyboardTypeDecimalPad;
    textField.autocorrectionType = UITextAutocorrectionTypeNo;
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    textField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    [view addSubview:textField];
    
    [scrollView addSubview:view];
    
    
    UIButton* btnAction =[UIButton buttonWithType:UIButtonTypeRoundedRect ];
    btnAction.tag =30004;
    btnAction.layer.cornerRadius = 5;
    btnAction.backgroundColor = AppColorTheme;
    [btnAction setTitle:@"提交资料" forState:UIControlStateNormal];
    [btnAction setTitleColor:WriteColor forState:UIControlStateNormal];
    [btnAction addTarget:self action:@selector(finialSubmmit:) forControlEvents:UIControlEventTouchUpInside];
    [btnAction setFrame:CGRectMake(30, POS_Y(view)+50, WIDTH(self.view)-60, 40)];
    [scrollView addSubview:btnAction];
}

-(void)loadData
{
    self.startLoading  =YES;
    [self.httpUtil getDataFromAPIWithOps:[NSString stringWithFormat:@"%@?projectId=%ld",USERINFO,self.projectId] postParam:nil type:0 delegate:self sel:@selector(requestFinished:)];
}

-(void)isCheckUserConfirmed
{
    NSString * str = [TDUtil generateUserPlatformNo];
    
    NSMutableDictionary * dic = [NSMutableDictionary new];
    [dic setObject:str forKey:@"platformUserNo"];
    
    NSString * signString = [TDUtil convertDictoryToYeePayXMLString:dic];
    
    [self sign:signString sel:@selector(requestCheckUserSign:)];
}

-(void)goConfirm
{
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
    [dic setObject:@"http//jinzht.com/admin/" forKey:@"notifyUrl"];
    [dic setObject:[data valueForKey:USER_STATIC_NICKNAME] forKey:@"nickName"];
    
    
    NSString * signString = [TDUtil convertDictoryToYeePayXMLString:dic];
    
    [self sign:signString sel:@selector(requestSign:)];
    
}

-(void)goInvest
{
    NSString * str = [TDUtil generateUserPlatformNo];
    
    NSMutableDictionary * dic = [NSMutableDictionary new];
    
    
    UIView* view = [scrollView viewWithTag:30001];
    UITextField* textField = (UITextField*)[view viewWithTag:500001];
    NSString* mount =textField.text;
    mount = [mount stringByReplacingOccurrencesOfString:@"万元" withString:@""];
    float money = [mount floatValue];
    
    mount = [NSString stringWithFormat:@"%.2f",money * 10000];
    
    
    [dic setObject:mount forKey:@"amount"];
    [dic setObject:str forKey:@"platformUserNo"];
    [dic setObject:@"PLATFORM" forKey:@"feeMode"];
    [dic setObject:[TDUtil generateTradeNo] forKey:@"requestNo"];
    [dic setObject:@"ios://finialConfirm" forKey:@"callbackUrl"];
    [dic setObject:@"http//jinzht.com/admin/" forKey:@"notifyUrl"];
    
    
    NSString * signString = [TDUtil convertDictoryToYeePayXMLString:dic];
    
    [self sign:signString sel:@selector(requestSignFinial:)];
}


-(void)sign:(NSString*)signString sel:(SEL)sel
{
    [self.httpUtil getDataFromAPIWithOps:YeePaySignVerify postParam:[NSDictionary dictionaryWithObjectsAndKeys:signString,@"req",@"sign",@"method",nil] type:0 delegate:self sel:sel];
}


-(void)finialSubmmit:(id)sender
{
    UIView* view = [scrollView viewWithTag:30001];
    UITextField* textField = (UITextField*)[view viewWithTag:500001];
    NSString* mount =textField.text;
    mount = [mount stringByReplacingOccurrencesOfString:@"万元" withString:@""];
    if (!mount  || [mount isEqualToString:@""]) {
        [[DialogUtil sharedInstance]showDlg:self.view textOnly:@"请输入投资金额"];
    }else{
        [self resignKeyboard];
        
        BOOL isActive = [DICVFK(self.dataDic, @"is_actived") boolValue];
        if (isActive) {
            double virtual_currency = [DICVFK(self.dataDic, @"virtual_currency") doubleValue];
            if (virtual_currency > 0.0) {
                NSString* url = [INVEST stringByAppendingFormat:@"%ld/%d/",(long)self.projectId,currentSelect];
                NSMutableDictionary* dic = [[NSMutableDictionary alloc]init];
                
                
                [dic setValue:mount forKey:@"amount"];
                [dic setValue:[TDUtil generateTradeNo] forKey:@"investCode"];
                [dic setValue:[NSString stringWithFormat:@"%d",currentSelect] forKey:@"flag"];
                [self.httpUtil getDataFromAPIWithOps:url postParam:dic type:0 delegate:self sel:@selector(requestFinialSubmmmit:)];
                self.startLoading  =YES;
                self.isTransparent  =YES;
                return;
            }
        }
        
        [self isCheckUserConfirmed];
        
    }
}


-(void)doAction:(UITapGestureRecognizer*)recognizer
{
    
    FinialKind* finialKind = (FinialKind*)recognizer.view;
    if (finialKind) {
        currentTag =finialKind.tag;
    }
    
    if (currentSelect==0) {
        if (currentTag == 20001) {
            currentSelect=1;
            finialKind.backgroundColor = AppColorTheme;
            finialKind.label.textColor =WriteColor;
            [finialKind setImageWithNmame:@"Lead investor-white" setText:@"我要领投"];
            FinialKind* view = (FinialKind*)[scrollView viewWithTag:20002];
            view.backgroundColor = WriteColor;
            view.label.textColor = ColorTheme2;
            [view setImageWithNmame:@"With investment" setText:@"我要跟投"];
        }
        
    }else{
        if (currentTag == 20002) {
            currentSelect=0;
            finialKind.backgroundColor = AppColorTheme;
            finialKind.label.textColor =WriteColor;
            [finialKind setImageWithNmame:@"With investment-white" setText:@"我要跟投"];
            FinialKind* view = (FinialKind*)[scrollView viewWithTag:20001];
            view.backgroundColor = WriteColor;
            
            view.label.textColor = ColorTheme2;
            [view setImageWithNmame:@"Lead investor" setText:@"我要领投"];
        }
    }
}


-(void)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma UITextFieldDelegate
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    
}
-(void)textFieldDidEndEditing:(UITextField *)textField
{
    NSString* textStr = textField.text;
    if (textStr && textStr.length>0) {
        if (![textStr containsString:@"万元"]) {
            textStr = [NSString stringWithFormat:@" %@万元",textStr];
        }
        textField.text = textStr;
    }
    [textField resignFirstResponder];
}

-(void)resignKeyboard
{
    //收起键盘
    UITextField* textField = (UITextField*)[scrollView viewWithTag:500001];
    [textField resignFirstResponder];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(void)textFieldDidChange:(id)sender
{
    
}

//*********************************************************网络请求开始*****************************************************//
-(void)requestFinished:(ASIHTTPRequest*)request
{
    NSString* jsonString =[TDUtil convertGBKDataToUTF8String:request.responseData];
    NSLog(@"返回:%@",jsonString);
    
    NSMutableDictionary* dic = [jsonString JSONValue];
    
    if (dic!=nil) {
        int code =[[dic valueForKey:@"code"] intValue];
        if (code == 0) {
            self.dataDic = DICVFK(dic, @"data");
            
            BOOL isActive = [DICVFK(self.dataDic, @"is_actived") boolValue];
            if(!isActive)
            {
                UIButton * btnAction = [scrollView viewWithTag:30004];
                [btnAction setTitle:@"立即支付" forState:UIControlStateNormal];
            }
        }
        self.startLoading = NO;
    }
}

-(void)requestFinialSubmmmit:(ASIHTTPRequest *)request
{
    NSString *jsonString = [TDUtil convertGBKDataToUTF8String:request.responseData];
    NSLog(@"返回:%@",jsonString);
    NSMutableDictionary* jsonDic = [jsonString JSONValue];
    
    if(jsonDic!=nil)
    {
        NSString* code = [jsonDic valueForKey:@"code"];
        if ([code intValue] == 0) {
            BOOL isActive = [DICVFK(self.dataDic, @"is_actived") boolValue];
            if (isActive) {
                double virtual_currency = [DICVFK(self.dataDic, @"virtual_currency") doubleValue];
                if (virtual_currency > 0.0) {
//                    [[NSNotificationCenter defaultCenter]postNotificationName:@"alert" object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[jsonDic valueForKey:@"msg"],@"msg",@"",@"cancel",@"确认",@"sure",@"4",@"type",self,@"vController", nil]];
                    self.startLoading = NO;
                    
                    PaySuccessViewController * controller = [[PaySuccessViewController alloc]init];
                    [self.navigationController pushViewController:controller animated:YES];
                    return;
                }
            }
            
        }else{
//            if ([code intValue] == 1) {
//                double delayInSeconds = 1.0;
//                //__block RoadShowDetailViewController* bself = self;
//                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
//                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//                    UserFinialViewController* controller = [[UserFinialViewController alloc]init];
//                    //来现场
//                    controller.selectedIndex =1;
//                    controller.navTitle =  self.navView.title;
//                    [self.navigationController pushViewController:controller animated:YES];
//                });
//            }
//            [[DialogUtil sharedInstance] showDlg:self.view textOnly:[jsonDic valueForKey:@"msg"]];
            [[NSNotificationCenter defaultCenter]postNotificationName:@"alert" object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[jsonDic valueForKey:@"msg"],@"msg",@"",@"cancel",@"确认",@"sure",@"4",@"type",self,@"vController", nil]];
        }
        self.startLoading = NO;
    }
}

-(void)requestSignFinial:(ASIHTTPRequest *)request{
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
            controller.title = @"确认投资";
            controller.titleStr = @"易宝支付";
            controller.PostPramDic = dic;
            controller.dic = self.dic;
            
            
            UIView* view = [scrollView viewWithTag:30001];
            UITextField* textField = (UITextField*)[view viewWithTag:500001];
            
            NSString* mount =textField.text;
            mount = [mount stringByReplacingOccurrencesOfString:@"万元" withString:@"0000"];
            
            [controller.dic setValue:mount forKey:@"mount"];
            [controller.dic setValue:STRING(@"%d", currentSelect) forKey:@"currentSelect"];
            controller.url = [NSURL URLWithString:STRING_3(@"%@%@",BUINESS_SERVER,YeePayMent,nil)];
            [self.navigationController pushViewController:controller animated:YES];
        }else if([code intValue] == 1){
            
        }
        self.startLoading  =NO;
    }
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
        self.startLoading  =NO;
    }
}

-(void)requestCheckUser:(ASIHTTPRequest *)request{
    NSString *xmlString = [TDUtil convertGBKDataToUTF8String:request.responseData];
    NSLog(@"返回:%@",xmlString);
    NSDictionary * xmlDic = [TDUtil convertXMLStringElementToDictory:xmlString];
    
    NSLog(@"%@",xmlDic);
    
    if ([DICVFK(xmlDic, @"code") intValue]==101) {
        [self goConfirm];
    }else if([DICVFK(xmlDic, @"code") intValue]==1)
    {
        [self goInvest];
    }else{
        
    }
    

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
            controller.title = @"项目详情";
            controller.titleStr = @"实名认证";
            controller.PostPramDic = dic;
            controller.dic = self.dic;
            [controller.dic setValue:STRING(@"%d", currentSelect) forKey:@"currentSelect"];
            controller.url = [NSURL URLWithString:STRING_3(@"%@%@",BUINESS_SERVER,YeePayToRegister,nil)];
            [self.navigationController pushViewController:controller animated:YES];
        }else if([code intValue] == 1){
            
        }
        self.startLoading  =NO;
    }
}


-(void)requestFailed:(ASIHTTPRequest *)request
{
    NSString *jsonString = [TDUtil convertGBKDataToUTF8String:request.responseData];
    NSLog(@"返回:%@",jsonString);
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // 禁用 iOS7 返回手势
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        if (!self.navigationController.interactivePopGestureRecognizer.enabled) {
            self.navigationController.interactivePopGestureRecognizer.enabled = YES;
        }
        
    }
}
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
@end
