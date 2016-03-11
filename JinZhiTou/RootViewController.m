//
//  RootViewController.m
//  JinZhiTou
//
//  Created by air on 15/11/3.
//  Copyright © 2015年 金指投. All rights reserved.
//

#import "RootViewController.h"
@interface RootViewController ()
{
    LoadingView* loadingView;
}
@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = ColorTheme;
    //初始化网络请求对象
    self.httpUtil  =[[HttpUtils alloc]init];
    //导航栏设置
    //设置标题
    self.navView=[[NavView alloc]initWithFrame:CGRectMake(0,NAVVIEW_POSITION_Y,self.view.frame.size.width,NAVVIEW_HEIGHT)];
    [self.navView setTitle:self.title];
    self.navView.imageView.alpha  = 0;
    self.navView.titleLable.textColor=WriteColor;
    [self.view addSubview:self.navView];
    
}


/**
 *  网络请求错误
 *
 *  @param isNetRequestError 是否网络请求错误
 */
-(void)setIsNetRequestError:(BOOL)isNetRequestError
{
    
    self->_isNetRequestError = isNetRequestError;
    if (self.isNetRequestError) {
        if (!loadingView) {
            if (self.loadingViewFrame.size.height>0) {
                loadingView =[LoadingUtil shareinstance:self.view frame:self.loadingViewFrame];
            }else{
                loadingView = [LoadingUtil shareinstance:self.view];
            }
            loadingView.delegate  =self;
        }
        loadingView.isTransparent  = NO;
        loadingView.isError = YES;
    }else{
        [LoadingUtil close:loadingView];
        loadingView.isError = NO;
        loadingView.isTransparent  = YES;
    }
    
}

/**
 *  设置开始加载
 *
 *  @param startLoading 加载执行标致, true:开始加载动画 false:取消加载动画
 */
-(void)setStartLoading:(BOOL)startLoading
{
    
    self->_startLoading  = startLoading;
    if (self.startLoading) {
        if (!loadingView) {
            if (self.loadingViewFrame.size.height>0) {
                loadingView =[LoadingUtil shareinstance:self.view frame:self.loadingViewFrame];
            }else{
                loadingView = [LoadingUtil shareinstance:self.view];
            }
            loadingView.delegate  =self;
        }else{
            if (self.loadingViewFrame.size.height>0) {
                [loadingView setFrame:self.loadingViewFrame];
            }
        }
        
        self.isNetRequestError  =NO;
        loadingView.isTransparent  = NO;
        [LoadingUtil show:loadingView];
    }else{
        [LoadingUtil close:loadingView];
    }
    
}

/**
 *  设置全局视图是否透明
 *
 *  @param isTransparent 视图是否透明标志，true：透明显示，false：不透明
 */
-(void)setIsTransparent:(BOOL)isTransparent
{
    
    self->_isTransparent  =isTransparent;
    loadingView.isTransparent  =isTransparent;
    
}

/**
 *  设置加载视图内容大小
 *
 *  @param loadingViewFrame 视图内容大小
 */
-(void)setLoadingViewFrame:(CGRect)loadingViewFrame
{
    
    self->_loadingViewFrame =loadingViewFrame;
    
}

/**
 *  设置提示消息内容
 *
 *  @param content 消息内容信息
 */
-(void)setContent:(NSString *)content
{
    
    self->_content  =content;
    if ([TDUtil isValidString:self.content]) {
        loadingView.content  = self.content;
    }
    
}


/**
 *  设置数据字典
 *
 *  @param dataDic 数据字典
 */
-(void)setDataDic:(NSMutableDictionary *)dataDic
{
    
    self->_dataDic = dataDic;
    if (self.dataDic) {
        int code = [[dataDic valueForKey:@"code"] intValue];
        //设置状态码
        [self setCode:code];
    }
    
}

/**
 *  设置返回状态码
 *
 *  @param code 状态码
 */
-(void)setCode:(int)code
{
    self->_code = code;
    switch (self.code) {
        case 0:
            break;
        case 1:
            break;
        case 2:
            break;
        case -1:
            [[NSNotificationCenter defaultCenter]postNotificationName:@"login" object:nil];
            break;
        default:
            break;
    }
}

/**
 *  重新加载，刷新
 */
-(void)refresh
{
    
    self.startLoading = YES;
    
}

/**
 *  重新设置加载视图内容大小
 */
-(void)resetLoadingView
{
    
    [self.view bringSubviewToFront:loadingView];
    
}

//==============================网络请求处理开始==============================//
-(void)requestFinished:(ASIHTTPRequest *)request
{

    NSString *jsonString = [TDUtil convertGBKDataToUTF8String:request.responseData];
    NSLog(@"返回:%@",jsonString);
    self.startLoading =NO;

}

-(void)requestFailed:(ASIHTTPRequest *)request
{
    
    NSString *jsonString = [TDUtil convertGBKDataToUTF8String:request.responseData];
    NSLog(@"返回:%@",jsonString);
    self.isNetRequestError = YES;
    
}
//==============================网络请求处理结束==============================//



- (void)viewWillAppear:(BOOL)animated { [super viewWillAppear:animated];
    
    [MobClick beginLogPageView:self.navView.title];
    
    [[UIApplication sharedApplication]setStatusBarHidden:NO];
    
}

- (void)viewWillDisappear:(BOOL)animated { [super viewWillDisappear:animated];
    
    [MobClick endLogPageView:self.navView.title];
    
}

-(void)dealloc
{
    
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    
}
@end
