//
//  BannerViewController.m
//  JinZhiTou
//
//  Created by air on 15/8/13.
//  Copyright (c) 2015年 金指投. All rights reserved.
//

#import "YeePayViewController.h"
#import "ShareView.h"
#import "DialogUtil.h"
#import "ShareNewsView.h"
#import "GDataXMLNode.h"
#import "PurseViewController.h"
#import "PaySuccessViewController.h"
#import "FinialApplyViewController.h"
@interface YeePayViewController ()<UIWebViewDelegate,UIAlertViewDelegate>
{
    BOOL isGetStatus;
    ShareNewsView* shareNewsView;
}
@end

@implementation YeePayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //设置背景颜色
    self.view.backgroundColor=ColorTheme;
    //隐藏导航栏
    [self.navigationController.navigationBar setHidden:YES];
    //设置标题
    self.navView.imageView.alpha=1;
    [self.navView setTitle:self.titleStr];
    self.navView.titleLable.textColor=WriteColor;
    
    [self.navView.leftButton setImage:nil forState:UIControlStateNormal];
    [self.navView.leftButton setTitle:self.title forState:UIControlStateNormal];
    [self.navView.leftTouchView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(back:)]];
    
    [self.view addSubview:self.navView];
    
    self.webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, POS_Y(self.navView), WIDTH(self.view), HEIGHT(self.view)-POS_Y(self.navView))];
    self.webView.delegate = self;
    self.webView.dataDetectorTypes  = UIDataDetectorTypeAll;
    [self.view addSubview:self.webView];
    self.canBack = YES;
    
     [self loadUrl];
    
}

-(void)back:(id)sender
{
//    switch (self.state) {
//        case PayStatusConfirm:
//            [self.navigationController popViewControllerAnimated:YES];
//            break;
//        case PayStatusBindCard:
//            [self.navigationController popViewControllerAnimated:YES];
//            break;
//        case PayStatusPayfor:
////            [[DialogUtil sharedInstance]showDlg:self.view textOnly:@"业务进行中，无法返回!"];
//            break;
//        case PayStatusTransfer:
////            [[DialogUtil sharedInstance]showDlg:self.view textOnly:@"业务进行中，无法返回!"];
//            break;
//            
//        default:
//            break;
//    }
    if (self.canBack) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [[DialogUtil sharedInstance]showDlg:self.view textOnly:@"业务进行中，无法返回!"];
    }
}

-(void)setUrl:(NSURL *)url
{
    self->_url = url;
    
    [self loadUrl];
}

-(void)setDic:(NSDictionary *)dic
{
    self->_dic  = dic;
    isGetStatus = YES;
}


-(void)loadUrl
{
    if (!self.webView.loading) {
        NSString * postString = [TDUtil convertDictoryToFormat:@"%@=%@&" dicData:self.PostPramDic];
        
//        postString = [self encodeToPercentEscapeString:postString];
        
        NSLog(@"post前:%@",postString);
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:self.url];
        [request setHTTPMethod: @"POST"];
        [request setHTTPBody: [postString dataUsingEncoding: NSUTF8StringEncoding]];
        
        [self.webView loadRequest:request];
    }
}


-(void)setType:(int)type
{
    self->_type = type;
}

-(void)bindCardConfirm:(NSDictionary*)dic
{
//    for(UIViewController * c in self.navigationController.childViewControllers)
//    {
//        if ([c isKindOfClass:PurseViewController.class]) {
//            [c removeFromParentViewController];
//            
//            PurseViewController * controller = [[PurseViewController alloc]init];
//            [self.navigationController pushViewController:controller animated:YES];
//        }
//    }
    
    [self back:nil];
}

-(void)verify:(NSDictionary*)dic
{
    NSLog(@"%@",dic);
    
    switch (self.state) {
        case PayStatusConfirm:
            [self back:nil];
            break;
        case PayStatusBindCard:
            [self bindCard];
            break;
        case PayStatusPayfor:
            [self goPayfor];
            break;
        case PayStatusTransfer:
            [self finialConfirm:dic];
            break;
            
        default:
            break;
    }
    
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

-(void)goPayfor
{
    NSString * str = [TDUtil generateUserPlatformNo];
    
    NSMutableDictionary * dic = [NSMutableDictionary new];
    
    float mount = [[self.dataDic valueForKey:@"mount"] floatValue]*10000.00;
    
    [dic setObject:str forKey:@"platformUserNo"];
    [dic setObject:@"PLATFORM" forKey:@"feeMode"];
    [dic setObject:STRING(@"%.2f", mount) forKey:@"amount"];
    [dic setObject:[TDUtil generateTradeNo] forKey:@"requestNo"];
    [dic setObject:@"ios://finialConfirm" forKey:@"callbackUrl"];
    [dic setObject:notifyUrl forKey:@"notifyUrl"];
    
    
    NSString * signString = [TDUtil convertDictoryToYeePayXMLString:dic];
    
    [self sign:signString sel:@selector(requestSignFinial:)];
}


-(void)sign:(NSString*)signString sel:(SEL)sel
{
    [self.httpUtil getDataFromAPIWithOps:YeePaySignVerify postParam:[NSDictionary dictionaryWithObjectsAndKeys:signString,@"req",@"sign",@"method",nil] type:0 delegate:self sel:sel];
}



-(void)finialConfirm:(NSDictionary*)dicData
{
    NSLog(@"%@",dicData);
    if ([DICVFK(dicData, @"code") intValue]==1) {
        self.canBack = NO;
    }
    NSString * str = [TDUtil generateUserPlatformNo];
    
    float mount = [DICVFK(self.dic, @"mount") floatValue];
    float profit = [DICVFK(self.dic, @"profit") floatValue];
    
    float mount_profit = mount * profit;
    
    NSMutableDictionary * dic = [NSMutableDictionary new];
    
    NSMutableDictionary * dicItem = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%.2f",mount - mount_profit],@"amount",@"MEMBER",@"targetUserType",DICVFK(self.dic, @"brrow_user_no"),@"targetPlatformUserNo",@"TENDER",@"bizType", nil];
    NSMutableDictionary * dicItem2 = [NSMutableDictionary dictionaryWithObjectsAndKeys:STRING(@"%.2f", mount_profit),@"amount",@"MERCHANT",@"targetUserType",YeePayPlatformID,@"targetPlatformUserNo",@"TENDER",@"bizType", nil];
    
    [dic setObject:STRING(@"%.2f", mount) forKey:@"amount"];
    [dic setObject:str forKey:@"platformUserNo"];
    [dic setObject:@"MEMBER" forKey:@"userType"];
    [dic setObject:@"TENDER" forKey:@"bizType"];
    [dic setObject:[NSArray arrayWithObjects:dicItem,dicItem2,nil] forKey:@"details"];
    
     [dic setObject:[NSDictionary dictionaryWithObjectsAndKeys:[TDUtil generateTenderNo:DICVFK(self.dic, @"id")],@"tenderOrderNo",DICVFK(self.dic, @"company"),@"tenderName",STRING(@"%.2f", [DICVFK(self.dic, @"planfinance") floatValue]*10000),@"tenderAmount",DICVFK(self.dic, @"company"),@"tenderDescription",DICVFK(self.dic, @"brrow_user_no"),@"borrowerPlatformUserNo", nil] forKey:@"extend"];
    [dic setObject:[TDUtil generateTradeNo] forKey:@"requestNo"];
    [dic setObject:@"ios://tenderConfirm" forKey:@"callbackUrl"];
    [dic setObject:notifyUrl forKey:@"notifyUrl"];
    

    NSString * signString = [TDUtil convertDictoryToYeePayXMLString:dic];
    
    [self sign:signString];
}

-(void)tenderConfirm:(NSDictionary*)dicData
{
    NSLog(@"%@",dicData);
    self.startLoading = YES;
    NSString* url = [INVEST stringByAppendingFormat:@"%@/%@/",DICVFK(self.dic, @"id"),DICVFK(self.dic, @"currentSelect")];
    NSMutableDictionary* dic = [[NSMutableDictionary alloc]init];
    float mount = [DICVFK(self.dic, @"mount") floatValue]/10000.00;
    
    [dic setValue:STRING(@"%.2f", mount) forKey:@"amount"];
    [dic setValue:[TDUtil generateTradeNo] forKey:@"investCode"];
    [dic setValue:[NSString stringWithFormat:@"%@",DICVFK(self.dic, @"currentSelect")] forKey:@"flag"];
    [self.httpUtil getDataFromAPIWithOps:url postParam:dic type:0 delegate:self sel:@selector(requestFinialSubmmmit:)];
}


-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *urlstr = request.URL.absoluteString;
    NSRange range = [urlstr rangeOfString:@"ios://"];
    
    if(range.length!=0)
    {
        
        NSString *method = [urlstr substringFromIndex:(range.location+range.length)];
        method = [method stringByAppendingString:@":"];
        SEL selctor = NSSelectorFromString(method);
        
        NSData * httpBody = request.HTTPBody;
        NSString* responseString = [[NSString alloc] initWithData:httpBody encoding:NSUTF8StringEncoding];
        //获取字符串
        NSString *content = responseString;
        //替换+ 为空格
        content = [content stringByReplacingOccurrencesOfString:@"+" withString:@" "];
        //decode
        content = [content stringByRemovingPercentEncoding];
        
        NSString * sign =@"";
        NSRange rangeSign = [content rangeOfString:@"&sign="];
        NSRange rangeResp = [content rangeOfString:@"resp="];
        if (rangeSign.length!=0 && rangeResp.length!=0) {
            
            sign = [content substringFromIndex:(rangeSign.location+rangeSign.length)];
            content = [content substringToIndex:rangeSign.location];
            
            rangeResp = [content rangeOfString:@"resp="];
            content = [content substringFromIndex:(rangeResp.location+rangeResp.length)];
            
            NSDictionary * dic =[TDUtil convertXMLStringElementToDictory:content];
            
            [self performSelector:selctor withObject:dic];
        }
        
        return NO;
    }else{
//        NSRange range = [urlstr rangeOfString:@"swiftRecharge"];
//        
//        if (range.length != 0) {
//            [_webView stringByEvaluatingJavaScriptFromString:@"submit();"];
////            return NO;
//        }
    }
    
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
//    self.loadingViewFrame = CGRectMake(0, POS_X(self.navView), WIDTH(self.view), HEIGHT(self.view)-POS_X(self.navView));
    self.startLoading = YES;
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSString * str =  [webView stringByEvaluatingJavaScriptFromString:@"document.head.innerHTML"];
    if ([str containsString:@"操作成功"]) {
        [_webView stringByEvaluatingJavaScriptFromString:@"submit();"];
    }else{
        NSString * string =  [webView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML"];
        NSLog(@"返回内容:%@",string);
        [self.webView.scrollView setContentSize:CGSizeMake(WIDTH(self.webView.scrollView), self.webView.scrollView.contentSize.height + 80)];
    }
    self.startLoading =NO;
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"%@",error);
    self.isNetRequestError = YES;
}

-(void)refresh
{
    [super refresh];

    [self loadUrl];
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

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //添加监听
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"shareNews" object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"shareNewContent" object:nil];
}
-(void)dealloc
{
    self.webView = nil;
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

-(void)sign:(NSString*)signString
{
    [self.httpUtil getDataFromAPIWithOps:YeePaySignVerify postParam:[NSDictionary dictionaryWithObjectsAndKeys:signString,@"req",@"sign",@"method",nil] type:0 delegate:self sel:@selector(requestSign:)];
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
            
            self.titleStr = @"确认投资";
            self.PostPramDic = dic;
            self.url = [NSURL URLWithString:STRING_3(@"%@%@",BUINESS_SERVER,YeePayToCpTransaction,nil)];
            return;
        }else if([code intValue] == 1){
            
        }
        self.isNetRequestError = YES;
        self.startLoading  =NO;
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
            
            PaySuccessViewController * controller = [[PaySuccessViewController alloc]init];
            controller.dataDic = [NSMutableDictionary dictionaryWithDictionary:self.dic];
            [self.navigationController pushViewController:controller animated:YES];
            self.startLoading = NO;
            return;
        }else{
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
            self.PostPramDic = dic;
            self.url = [NSURL URLWithString:STRING_3(@"%@%@",BUINESS_SERVER,YeePayMent,nil)];
            self.startLoading  =NO;
            return;
        }
        self.isNetRequestError = YES;
        self.startLoading  =NO;
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
            self.PostPramDic = dic;
            self.url = [NSURL URLWithString:STRING_3(@"%@%@",BUINESS_SERVER,toBindBankCard,nil)];
            self.startLoading  =NO;
            return;
        }
        self.isNetRequestError = YES;
        self.startLoading  =NO;
    }
}

@end
