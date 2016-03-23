//
//  BannerViewController.m
//  JinZhiTou
//
//  Created by air on 15/8/13.
//  Copyright (c) 2015年 金指投. All rights reserved.
//

#import "YeePayViewController.h"
#import "ShareView.h"
#import "ShareNewsView.h"
#import "GDataXMLNode.h"
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
    
     [self loadUrl];
    
}

-(void)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
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
    [dic setObject:@"http//jinzht.com/admin/" forKey:@"notifyUrl"];
    
    
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
    [dic setObject:@"http//jinzht.com/admin/" forKey:@"notifyUrl"];
    
    
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
    NSString * str = [TDUtil generateUserPlatformNo];
    
    NSMutableDictionary * dic = [NSMutableDictionary new];
//    NSMutableDictionary * dicItem = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"1",@"amount",@"MEMBER",@"targetUserType",str,@"targetPlatformUserNo",@"TENDER",@"bizType", nil];
    
     NSMutableDictionary * dicItem = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"1",@"amount",@"MEMBER",@"targetUserType",str,@"targetPlatformUserNo",@"TENDER",@"bizType", nil];
    NSMutableDictionary * dicItem2 = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"1",@"amount",@"MERCHANT",@"targetUserType",YeePayPlatformID,@"targetPlatformUserNo",@"TENDER",@"bizType", nil];
    
    [dic setObject:@"1" forKey:@"amount"];
    [dic setObject:str forKey:@"platformUserNo"];
    [dic setObject:@"MEMBER" forKey:@"userType"];
    [dic setObject:@"TENDER" forKey:@"bizType"];
    //            [dic setObject:@"2019-03-15 21:00:00" forKey:@"expired"];
    [dic setObject:[NSArray arrayWithObjects:dicItem,dicItem2,nil] forKey:@"details"];
//    [dic setObject:[NSDictionary dictionaryWithObjectsAndKeys:[TDUtil generateTenderNo:DICVFK(self.dic, @"id")],@"tenderOrderNo",@"逸景营地众筹项目",@"tenderName",@"5000000",@"tenderAmount",@"随便投",@"tenderDescription",str,@"borrowerPlatformUserNo",@"10000000",@"tenderSumLimit", nil] forKey:@"extend"];
     [dic setObject:[NSDictionary dictionaryWithObjectsAndKeys:[TDUtil generateTenderNo:DICVFK(self.dic, @"id")],@"tenderOrderNo",@"逸景营地众筹项目",@"tenderName",@"5000000",@"tenderAmount",@"随便投",@"tenderDescription",str,@"borrowerPlatformUserNo",@"10000000",@"tenderSumLimit", nil] forKey:@"extend"];
    [dic setObject:[TDUtil generateTradeNo] forKey:@"requestNo"];
    [dic setObject:@"ios://tenderConfirm" forKey:@"callbackUrl"];
    [dic setObject:@"http://www.jinzht.com" forKey:@"notifyUrl"];
    
    
    NSString * signString = [TDUtil convertDictoryToYeePayXMLString:dic];
    
    [self sign:signString];
}

-(void)tenderConfirm:(NSDictionary*)dicData
{
    NSLog(@"%@",dicData);
    self.startLoading = YES;
    NSString* url = [INVEST stringByAppendingFormat:@"%@/%@/",DICVFK(self.dic, @"id"),DICVFK(self.dic, @"currentSelect")];
    NSMutableDictionary* dic = [[NSMutableDictionary alloc]init];
    
    [dic setValue:DICVFK(self.dic, @"mount") forKey:@"amount"];
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
        }else if([code intValue] == 1){
            
        }
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
        }else if([code intValue] == 1){
            
        }
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
        }else if([code intValue] == 1){
            
        }
        self.startLoading  =NO;
    }
}

@end