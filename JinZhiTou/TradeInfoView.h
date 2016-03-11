//
//  TradeInfoView.h
//  JinZhiTou
//
//  Created by BraveHeart on 16/3/8.
//  Copyright © 2016年 金指投. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TradePasswdEnterView.h"
@interface TradeInfoView : UIView
{
    UILabel * titleLabel; //标题
    UILabel * tipLabel1; //提示
    UILabel * tipLabel2; //提示
    UILabel * countLabel; //总金额（数字）
    UIImageView * imgView; //图标
    UILabel * unitCountLabel; //总金额（单位）
    UIImageView * closeImgView; //关闭按钮
    UIImageView * seprateImgView; //分割图片
    
    TradePasswdEnterView * enterView1;
    TradePasswdEnterView * enterView2;
}
@end
