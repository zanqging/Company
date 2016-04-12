//


#import "SDTimeLineCell.h"
#import "TDUtil.h"
#import "HttpUtils.h"
#import "ShareContentView.h"
#import "ASIFormDataRequest.h"
#import "SDTimeLineCellModel.h"
#import "UIView+SDAutoLayout.h"
#import "UIImageView+WebCache.h"
#import "SDWeiXinPhotoContainerView.h"
#import "SDTimeLineCellCommentView.h"
#import "SDTimeLineCellOperationMenu.h"
const CGFloat contentLabelFontSize = 15;
CGFloat maxContentLabelHeight = 0; // 根据具体font而定

NSString *const kSDTimeLineCellOperationButtonClickedNotification = @"SDTimeLineCellOperationButtonClickedNotification";

@implementation SDTimeLineCell

{
    UIImageView *_iconView;
    UILabel *_nameLable;
    UILabel *_positionLable;
    UILabel *_contentLabel;
    UILabel *_timeLabel;
    UIButton *_moreButton;
    UIButton *_shareButton;
    UIButton *_operationButton;
    //分享内容
    int currentTag;
    HttpUtils* httpUtils;
    ShareContentView* _shareView;
    BOOL _shouldOpenContentLabel;
    SDTimeLineCellCommentView *_commentView;
    SDWeiXinPhotoContainerView *_picContainerView;
}


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setup];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)setup
{
    
    _shouldOpenContentLabel = NO;
    
    _iconView = [UIImageView new];
    
    _nameLable = [UILabel new];
    _nameLable.font = [UIFont systemFontOfSize:14];
    _nameLable.textColor = [UIColor colorWithRed:(54 / 255.0) green:(71 / 255.0) blue:(121 / 255.0) alpha:0.9];
    
    _positionLable = [UILabel new];
    _positionLable.font = [UIFont systemFontOfSize:14];
    _positionLable.textColor = [UIColor colorWithRed:(54 / 255.0) green:(71 / 255.0) blue:(121 / 255.0) alpha:0.9];
    
    _contentLabel = [UILabel new];
    _contentLabel.font = [UIFont systemFontOfSize:contentLabelFontSize];
    _contentLabel.numberOfLines = 0;
    if (maxContentLabelHeight == 0) {
        maxContentLabelHeight = _contentLabel.font.lineHeight * 3;
    }
    
    _shareView = [[ShareContentView alloc]init];
    
    
    _moreButton = [UIButton new];
    [_moreButton setTitle:@"全文" forState:UIControlStateNormal];
    [_moreButton setTitleColor:TimeLineCellHighlightedColor forState:UIControlStateNormal];
    [_moreButton addTarget:self action:@selector(moreButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    _moreButton.titleLabel.font = [UIFont systemFontOfSize:14];
    
    _operationButton = [UIButton new];
    [_operationButton setImage:[UIImage imageNamed:@"gossip_comment"] forState:UIControlStateNormal];
    [_operationButton addTarget:self action:@selector(commentAction) forControlEvents:UIControlEventTouchUpInside];
    
    _shareButton = [UIButton new];
    [_shareButton setImage:[UIImage imageNamed:@"gossip_like_normal"] forState:UIControlStateNormal];
    [_shareButton addTarget:self action:@selector(priseAction:) forControlEvents:UIControlEventTouchUpInside];
    
    
    _picContainerView = [SDWeiXinPhotoContainerView new];
    
    _commentView = [SDTimeLineCellCommentView new];
    
    _timeLabel = [UILabel new];
    _timeLabel.font = [UIFont systemFontOfSize:13];
    _timeLabel.textColor = [UIColor lightGrayColor];
    
    //加入监听事件
    _shareView.userInteractionEnabled = YES;
    [_shareView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(shareContent:)]];
    
    
    
    NSArray *views = @[_iconView, _nameLable,_positionLable,_shareView,_contentLabel, _moreButton, _picContainerView, _timeLabel, _operationButton,_shareButton, _commentView];
    
    [self.contentView sd_addSubviews:views];
    
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setModel:(SDTimeLineCellModel *)model
{
    _model = model;
    
    UIView *contentView = self.contentView;
    CGFloat margin = 10;
    
    _iconView.sd_layout
    .leftSpaceToView(contentView, margin)
    .topSpaceToView(contentView, margin + 5)
    .widthIs(40)
    .heightIs(40);
    
    _nameLable.sd_layout
    .leftSpaceToView(_iconView, margin)
    .topEqualToView(_iconView)
    .heightIs(18);
    [_nameLable setSingleLineAutoResizeWithMaxWidth:200];
    
    _positionLable.sd_layout
    .leftSpaceToView(_iconView, margin)
    .topSpaceToView(_nameLable, margin)
    .heightIs(18);
    [_positionLable setSingleLineAutoResizeWithMaxWidth:200];
    
    _contentLabel.sd_layout
    .leftEqualToView(_nameLable)
    .topSpaceToView(_positionLable, margin)
    .rightSpaceToView(contentView, margin)
    .autoHeightRatio(0);
    
    // morebutton的高度在setmodel里面设置
    _moreButton.sd_layout
    .leftEqualToView(_contentLabel)
    .topSpaceToView(_contentLabel, 0)
    .widthIs(30);
    
    
    _shareView.sd_layout
    .leftEqualToView(_contentLabel)
    .topSpaceToView(_moreButton,10)
    .rightSpaceToView(contentView, margin+10);
    
    _picContainerView.sd_layout
    .leftEqualToView(_contentLabel);
    
    if (model.shareDic) {
        _shareView.sd_layout
        .heightIs(50);
        _shareView.alpha=1;
        _picContainerView.sd_layout.topSpaceToView(_shareView, 10);
    }else{
        _shareView.sd_layout
        .heightIs(0);
        _shareView.alpha=0;
        
        _picContainerView.sd_layout.topSpaceToView(_moreButton, 10);
    }
    
    
    _timeLabel.sd_layout
    .leftEqualToView(_contentLabel)
    .topSpaceToView(_picContainerView, margin)
    .heightIs(15)
    .autoHeightRatio(0);
    
    [_timeLabel setSingleLineAutoResizeWithMaxWidth:200];
    
    _operationButton.sd_layout
    .rightSpaceToView(contentView, margin)
    .centerYEqualToView(_timeLabel)
    .heightIs(25)
    .widthIs(25);
    
    _shareButton.sd_layout
    .rightSpaceToView(_operationButton, margin)
    .centerYEqualToView(_timeLabel)
    .heightIs(25)
    .widthIs(25);
    
    _commentView.sd_layout
    .leftEqualToView(_contentLabel)
    .rightSpaceToView(self.contentView, margin)
    .topSpaceToView(_timeLabel, margin); // 已经在内部实现高度自适应所以不需要再设置高度
    
    //分享
    if (model.shareDic) {
        _shareView.dic = model.shareDic;
    }

    
    _commentView.frame = CGRectZero;
    [_commentView setupWithLikeItemsArray:model.likeItemsArray commentItemsArray:model.commentItemsArray];
    
    _shouldOpenContentLabel = NO;
    
    [_iconView sd_setImageWithURL:[NSURL URLWithString:model.iconName]];
    _nameLable.text = model.name;
    // 防止单行文本label在重用时宽度计算不准的问题
    [_nameLable sizeToFit];
    _contentLabel.text = model.msgContent;
    _picContainerView.picPathStringsArray = model.picNamesArray;
    
    if (model.shouldShowMoreButton) { // 如果文字高度超过60
        _moreButton.sd_layout.heightIs(20);
        _moreButton.hidden = NO;
        if (model.isOpening) { // 如果需要展开
            _contentLabel.sd_layout.maxHeightIs(MAXFLOAT);
            [_moreButton setTitle:@"收起" forState:UIControlStateNormal];
        } else {
            _contentLabel.sd_layout.maxHeightIs(maxContentLabelHeight);
            [_moreButton setTitle:@"全文" forState:UIControlStateNormal];
        }
    } else {
        _moreButton.sd_layout.heightIs(0);
        _moreButton.hidden = YES;
    }
    
    
    UIView *bottomView;
    
    if (!model.commentItemsArray.count && !model.likeItemsArray.count) {
        _commentView.fixedWidth = @0; // 如果没有评论或者点赞，设置commentview的固定宽度为0（设置了fixedWith的控件将不再在自动布局过程中调整宽度）
        _commentView.fixedHeight = @0; // 如果没有评论或者点赞，设置commentview的固定高度为0（设置了fixedHeight的控件将不再在自动布局过程中调整高度）
        _commentView.sd_layout.topSpaceToView(_timeLabel, 0);
        bottomView = _timeLabel;
    } else {
        _commentView.fixedHeight = nil; // 取消固定宽度约束
        _commentView.fixedWidth = nil; // 取消固定高度约束
        _commentView.sd_layout.topSpaceToView(_timeLabel, 10);
        bottomView = _commentView;
    }
    
    [self setupAutoHeightWithBottomView:bottomView bottomMargin:15];
    
    _timeLabel.text = model.dateTime;
    _positionLable.text = [NSString stringWithFormat:@"%@ | %@",model.address,model.position];
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
}

#pragma mark - private actions

- (void)moreButtonClicked
{
    if (self.moreButtonClickedBlock) {
        self.moreButtonClickedBlock(self.indexPath);
    }
}

- (void)commentAction
{
    if ([_delegate respondsToSelector:@selector(weiboTableViewCell:contentId:atId:isSelf:)]) {
        [_delegate weiboTableViewCell:self contentId:STRING(@"%ld", self.model.id) atId:nil isSelf:NO];
    }
}

- (void)priseAction
{
    if ([_delegate respondsToSelector:@selector(weiboTableViewCell:priseDic:msg:)]) {
        [_delegate didClickLickButtonInCell:self];
        SDTimeLineCellLikeItemModel* model = [[SDTimeLineCellLikeItemModel alloc]init];
        model.userId = STRING(@"%ld", self.model.uid);
        model.userName = self.model.name;
        
        [_delegate weiboTableViewCell:self priseDic:model msg:@""];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
}


/**
 *  点赞
 *
 *  @param sender 触发实例
 */
-(void)priseAction:(id)sender
{
    if (!httpUtils) {
        httpUtils = [[HttpUtils alloc]init];
    }
    NSInteger id = self.model.id;
    
    NSString* serverUrl = [CYCLE_CONTENT_PRISE stringByAppendingFormat:@"%ld/%d/",id,self.model.isLike];
    [httpUtils getDataFromAPIWithOps:serverUrl  type:0 delegate:self sel:@selector(requestPriseFinished:) method:@"GET"];
}


/**
 *  评论
 *
 *  @param sender 触发实例
 */
-(void)commentAction:(id)sender
{
    if ([_delegate respondsToSelector:@selector(weiboTableViewCell:contentId:atId:isSelf:)]) {
        [_delegate weiboTableViewCell:self contentId:[NSString stringWithFormat:@"%ld",self.model.id] atId:nil isSelf:NO];
    }
}

/**
 *  分享新三板点击
 *
 *  @param sender 触发实例
 */
-(void)shareContent:(id)sender
{
    if ([_delegate respondsToSelector:@selector(weiboTableViewCell:didSelectedShareContentUrl:)]) {
        //分享链接
        NSURL * url = [NSURL URLWithString:[self.model.shareDic valueForKey:@"url"]];
        [_delegate weiboTableViewCell:self didSelectedShareContentUrl:url];
    }
}

-(void)deleteAction:(id)sender
{
    UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"金指投温馨提示" message:@"是否确认删除内容?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"删除", nil];
    [alertView show];
    
    //设置为删除内容
    currentTag = 1;
}
#pragma CycleCommentDelegate
-(void)cycleComment:(id)cycleComment contentId:(NSString *)contentId atId:(NSString *)atId isSelf:(BOOL)isSelf
{
    if ([_delegate respondsToSelector:@selector(weiboTableViewCell:contentId:atId:isSelf:)]) {
//        [_delegate weiboTableViewCell:self contentId:[NSString stringWithFormat:@"%ld",self.model.id] atId:atId isSelf:NO];
    }
}

-(void)cycleComment:(id)cycleComment deleteId:(NSString *)deleteId
{
    UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:nil message:@"删除" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"删除", nil];
    alertView.tag  = [deleteId integerValue];
    alertView.delegate = self;
    [alertView show];
    currentTag = 0;
}

-(void)cycleComment:(id)cycleComment refresh:(BOOL)refresh data:(NSArray *)dataArray
{
    if (refresh) {
//        self.model.commentArray = dataArray;
        if ([_delegate respondsToSelector:@selector(weiboTableViewCell:refresh:)]) {
            [_delegate weiboTableViewCell:self refresh:YES];
        }
    }
}

-(void)requestDeleteFinished:(ASIHTTPRequest*)request
{
    NSString* jsonString = [TDUtil convertGBKDataToUTF8String:request.responseData];
    
    NSLog(@"返回:%@",jsonString);
    NSMutableDictionary * dic =[jsonString JSONValue];
    if (dic!=nil) {
        NSString* status = [dic valueForKey:@"code"];
        if ([status integerValue]==0) {
            if ([_delegate respondsToSelector:@selector(weiboTableViewCell:deleteDic:)]) {
                [_delegate weiboTableViewCell:self deleteDic:self.model];
            }
        }
    }
}


#pragma ASIHttpRequest
-(void)requestPriseFinished:(ASIHTTPRequest*)request
{
    NSString* jsonString = [TDUtil convertGBKDataToUTF8String:request.responseData];
    
    NSLog(@"返回:%@",jsonString);
    NSMutableDictionary * dic =[jsonString JSONValue];
    if (dic!=nil) {
        NSString* status = [dic valueForKey:@"code"];
        if ([status integerValue]>=0) {
            NSDictionary * data = [dic valueForKey:@"data"];
            if ([_delegate respondsToSelector:@selector(weiboTableViewCell:priseDic:msg:)]) {
                SDTimeLineCellLikeItemModel * model = [[SDTimeLineCellLikeItemModel alloc]init];
                model.userId = DICVFK(data, @"uid");
                model.userName = DICVFK(data, @"name");
                
                self.model.isLike = ![DICVFK(data, @"is_like") boolValue];
                
                [_delegate weiboTableViewCell:self  priseDic:model msg:[dic valueForKey:@"msg"]];
            }
        }
        
    }
}

-(void)requestDeleteReplyFinished:(ASIHTTPRequest*)request
{
    NSString* jsonString = [TDUtil convertGBKDataToUTF8String:request.responseData];
    
    NSLog(@"返回:%@",jsonString);
    NSMutableDictionary * dic =[jsonString JSONValue];
    if (dic!=nil) {
        NSString* status = [dic valueForKey:@"code"];
        if ([status integerValue]==0) {
            
            
        }
    }
}

@end
