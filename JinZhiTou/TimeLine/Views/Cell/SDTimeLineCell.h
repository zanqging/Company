//
//  SDTimeLineCell.h
//  GSD_WeiXin(wechat)
//
//  Created by gsd on 16/2/25.
//  Copyright © 2016年 GSD. All rights reserved.
//

/*
 
 *********************************************************************************
 *
 * GSD_WeiXin
 *
 * QQ交流群: 459274049
 * Email : gsdios@126.com
 * GitHub: https://github.com/gsdios/GSD_WeiXin
 * 新浪微博:GSD_iOS
 *
 * 此“高仿微信”用到了很高效方便的自动布局库SDAutoLayout（一行代码搞定自动布局）
 * SDAutoLayout地址：https://github.com/gsdios/SDAutoLayout
 * SDAutoLayout视频教程：http://www.letv.com/ptv/vplay/24038772.html
 * SDAutoLayout用法示例：https://github.com/gsdios/SDAutoLayout/blob/master/README.md
 *
 *********************************************************************************
 
 */

#import <UIKit/UIKit.h>
#import "SDTimeLineCellModel.h"
@protocol SDTimeLineCellDelegate <NSObject>

- (void)didClickLickButtonInCell:(UITableViewCell *)cell;
- (void)didClickcCommentButtonInCell:(UITableViewCell *)cell;
-(void)weiboTableViewCell:(id)weiboTableViewCell refresh:(BOOL)refresh;
-(void)weiboTableViewCell:(id)weiboTableViewCell deleteDic:(id) cycle;
-(void)weiboTableViewCell:(id)weiboTableViewCell priseDic:(SDTimeLineCellLikeItemModel*)item msg:(NSString*)msg;
-(void)weiboTableViewCell:(id)weiboTableViewCell userId:(NSString*)userId isSelf:(BOOL) isSelf;
-(void)weiboTableViewCell:(id)weiboTableViewCell contentId:(NSString*)contentId atId:(NSString*)atId isSelf:(BOOL) isSelf;
-(void)weiboTableViewCell:(id)weiboTableViewCell didSelectedContent:(BOOL)isSelected;
-(void)weiboTableViewCell:(id)weiboTableViewCell didSelectedShareContentUrl:(NSURL*)urlStr;

@end

@class SDTimeLineCellModel;

@interface SDTimeLineCell : UITableViewCell

@property (nonatomic, weak) id<SDTimeLineCellDelegate> delegate;

@property (nonatomic, strong) SDTimeLineCellModel *model;

@property (nonatomic, strong) NSIndexPath *indexPath;

@property (nonatomic, copy) void (^moreButtonClickedBlock)(NSIndexPath *indexPath);

@end
