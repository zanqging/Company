#import "SDTimeLineTableHeaderView.h"

#import "TDUtil.h"
#import "HttpUtils.h"
#import "NSString+SBJSON.h"
#import "UIView+SDAutoLayout.h"
#import "UIImageView+WebCache.h"
#import "ASIFormDataRequest.h"
@implementation SDTimeLineTableHeaderView

{
    UILabel *_nameLabel;
    HttpUtils * httpUtils;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    NSUserDefaults * data = [NSUserDefaults standardUserDefaults];
    NSString * name = [data valueForKey:USER_STATIC_NICKNAME];

    self._backgroundImageView = [UIImageView new];
    self._backgroundImageView.image = [UIImage imageNamed:@"pbg.jpg"];
    [self addSubview:self._backgroundImageView];
    
    self._iconView = [UIImageView new];
    self._iconView.image = [UIImage imageNamed:@"picon.jpg"];
    self._iconView.layer.borderColor = [UIColor whiteColor].CGColor;
    self._iconView.layer.borderWidth = 3;
    [self addSubview:self._iconView];
    
    
    self._backgroundImageView.userInteractionEnabled = YES;
    self._iconView.userInteractionEnabled = YES;
    _nameLabel = [UILabel new];
    _nameLabel.text = name;
    _nameLabel.textColor = [UIColor whiteColor];
    _nameLabel.textAlignment = NSTextAlignmentRight;
    _nameLabel.font = [UIFont boldSystemFontOfSize:15];
    [self addSubview:_nameLabel];
    
    
    self._backgroundImageView.sd_layout.spaceToSuperView(UIEdgeInsetsMake(-60, 0, 40, 0));
    
    self._iconView.sd_layout
    .widthIs(70)
    .heightIs(70)
    .rightSpaceToView(self, 15)
    .bottomSpaceToView(self, 20);
    
    
    _nameLabel.tag = 1000;
    [_nameLabel setSingleLineAutoResizeWithMaxWidth:200];
    _nameLabel.sd_layout
    .rightSpaceToView(self._iconView, 20)
    .bottomSpaceToView(self._iconView, -35)
    .heightIs(20);
    
    
    [self loadData];
    
    //添加更改
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(loadData) name:@"changePic" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(changeUserPic:) name:@"changeUserPic" object:nil];
}

-(void)changeUserPic:(NSDictionary*)dic
{
    UIImage* img = [[dic valueForKey:@"userInfo"] valueForKey:@"img"];
    if (img) {
        self._iconView.image = img;
    }
}


-(void)loadData
{
    httpUtils =[[HttpUtils alloc]init];
    [httpUtils getDataFromAPIWithOps:CYCLE_CONTENT_BACKGROUND_UPLOAD type:0 delegate:self sel:@selector(requestFinished:) method:@"GET"];
}

-(void)requestFinished:(ASIHTTPRequest*)request
{
    NSString* jsonString = [TDUtil convertGBKDataToUTF8String:request.responseData];
    
    NSLog(@"返回:%@",jsonString);
    NSMutableDictionary * dic =[jsonString JSONValue];
    if (dic!=nil) {
        NSString* code = [dic valueForKey:@"code"];
        if ([code integerValue] ==0) {
            NSDictionary* data = [dic valueForKey:@"data"];
            [self._backgroundImageView sd_setImageWithURL:[NSURL URLWithString:[data valueForKey:@"bg"]] placeholderImage:[TDUtil loadContent:USER_STATIC_CYCLE_BG] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                if (image) {
                    [TDUtil saveCameraPicture:image fileName:USER_STATIC_CYCLE_BG];
                    self._backgroundImageView.image = image;
                }
            }];
            [self._iconView sd_setImageWithURL:[NSURL URLWithString:[data valueForKey:@"photo"]]placeholderImage:[TDUtil loadContent:USER_STATIC_HEADER_PIC] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                if (image) {
                    [TDUtil saveCameraPicture:image fileName:USER_STATIC_HEADER_PIC];
                    self._iconView.image = image;
                }
            }];
            //移除重新加载数据
            [[NSNotificationCenter defaultCenter]removeObserver:self name:@"reloadData" object:nil];
        }else if ([code intValue]==-1){
            //添加重新加载数据监听
            [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(loadData) name:@"reloadData" object:nil];
        }
    }
}

-(void)requestFailed:(ASIHTTPRequest *)request
{
    NSLog(@"%@",request.responseString);
}


@end
