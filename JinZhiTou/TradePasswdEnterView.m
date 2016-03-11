//
//  TradePasswdEnterView.m
//  JinZhiTou
//
//  Created by BraveHeart on 16/3/8.
//  Copyright © 2016年 金指投. All rights reserved.
//

#import "TradePasswdEnterView.h"
#import "TDUtil.h"
#import "UConstants.h"
#import "GlobalDefine.h"
#import <QuartzCore/QuartzCore.h>
#define  kMaxLength 1
@implementation TradePasswdEnterView
-(id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

-(void)setup
{
    self.textFieldArray = [NSMutableArray new];
    UITextField * textField,*oldTextFiled;
    for (int i = 0; i<6; i++) {
        //1.init
        textField = [UITextField new];
        //2 addSubview
        [self addSubview:textField];
        //3.setting
        textField.delegate = self;
        textField.font = SYSTEMFONT(20);
        textField.secureTextEntry = YES;
        textField.layer.borderWidth = 1;
        textField.textAlignment = NSTextAlignmentCenter;
        textField.keyboardType = UIKeyboardTypeNumberPad;
        textField.layer.borderColor = BlackColor.CGColor;
        
        //4.SDAutoLayout
        if (i==0) {
            textField.sd_layout
            .topSpaceToView(self, 0)
            .leftSpaceToView(self, 0)
            .heightEqualToWidth()
            .widthRatioToView(self, 0.16666);
        }else{
            textField.sd_layout
            .heightEqualToWidth()
            .leftSpaceToView(oldTextFiled,0)
            .widthRatioToView(oldTextFiled, 1)
            .topEqualToView(oldTextFiled);
        }
        
        
        oldTextFiled = textField;
        
        [self.textFieldArray addObject:oldTextFiled];
        [self setupAutoHeightWithBottomView:oldTextFiled bottomMargin:0];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    NSInteger strLength = textField.text.length - range.length + string.length;
    BOOL flag = (strLength <= kMaxLength);
    if (flag) {
        for (int i = 0 ; i<self.textFieldArray.count;i++) {
            UITextField * textField = [self.textFieldArray objectAtIndex:i];
            if ([textField isFirstResponder] && [textField.text isEqualToString:@""]) {
                if (i != self.textFieldArray.count-1) {
                    UITextField * textFieldNext = [self.textFieldArray objectAtIndex:i+1];
                    [textFieldNext becomeFirstResponder];
                    textField.text = textField.text;
                    textFieldNext.text = @"";
                    break;
                }else{
                    [textField resignFirstResponder];
                }
            }
        }
    }
    return flag;
}

-(BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    return true;
}
@end
