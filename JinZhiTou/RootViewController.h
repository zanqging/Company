//
//  RootViewController.h
//  JinZhiTou
//
//  Created by air on 15/11/3.
//  Copyright © 2015年 金指投. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TDUtil.h"
#import "NavView.h"
#import "MobClick.h"
#import "HttpUtils.h"
#import "UConstants.h"
#import "DialogUtil.h"
#import "LoadingView.h"
#import "LoadingUtil.h"
#import "LoadingView.h"
#import "GlobalDefine.h"
#import "NSString+SBJSON.h"
#import "UIView+SDAutoLayout.h"
#include "JDStatusBarNotification.h"
@interface RootViewController : UIViewController<LoadingViewDelegate>
@property(assign,nonatomic)int code;
@property(retain,nonatomic)NavView* navView; //自定义导航视图
@property(retain,nonatomic)NSString* content; //提示信息内容
@property(assign,nonatomic)BOOL startLoading; //是否开始加载
@property(assign,nonatomic)BOOL isTransparent; //是否透明显示全局视图
@property(retain,nonatomic)HttpUtils* httpUtil; //网络请求对象
@property(assign,nonatomic)BOOL isNetRequestError; //是否请求出错
@property(assign,nonatomic)CGRect loadingViewFrame; //自定义加载视图大小
@property(retain,nonatomic)NSMutableDictionary* dataDic; //字典数据

- (void) refresh;  //刷新
- (void) resetLoadingView; //重置加载视图
@end
