

#import <Foundation/Foundation.h>

@class SDTimeLineCellLikeItemModel, SDTimeLineCellCommentItemModel;

@interface SDTimeLineCellModel : NSObject

@property (nonatomic, copy) NSString *iconName;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *msgContent;
@property (nonatomic, strong) NSArray *picNamesArray;

@property (nonatomic, assign) bool isLike; //是否点赞
@property (nonatomic, assign) bool flag; //是否点赞
@property (nonatomic, assign) NSInteger id;  //id
@property (nonatomic, assign) NSInteger uid;  //uid
@property (nonatomic, copy) NSString *dateTime;  //姓名
@property (nonatomic, copy) NSString *address;//地址
@property (nonatomic, copy) NSString *position;//位置
@property (nonatomic, copy) NSString *content;//内容
@property (nonatomic, retain) NSDictionary* shareDic;


@property (nonatomic, strong) NSArray<SDTimeLineCellLikeItemModel *> *likeItemsArray;
@property (nonatomic, strong) NSArray<SDTimeLineCellCommentItemModel *> *commentItemsArray;

@property (nonatomic, assign) BOOL isOpening;

@property (nonatomic, assign, readonly) BOOL shouldShowMoreButton;


@end


@interface SDTimeLineCellLikeItemModel : NSObject

@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *userId;

@end


@interface SDTimeLineCellCommentItemModel : NSObject

@property (nonatomic, copy) NSString *commentString;

@property (nonatomic, copy) NSString *firstUserName;
@property (nonatomic, copy) NSString *firstUserId;

@property (nonatomic, copy) NSString *secondUserName;
@property (nonatomic, copy) NSString *secondUserId;




@end