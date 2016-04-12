//
//  UserInfoViewController.m
//  JinZhiTou
//
//  Created by air on 15/8/6.
//  Copyright (c) 2015年 金指投. All rights reserved.
//

#import "UserInfoViewController.h"
#import "ShareView.h"
#import "UserInfoHeader.h"
#import "UserInfoTableViewCell.h"
#import "UserTraceViewController.h"
#import "UserInfoSettingViewController.h"
@interface UserInfoViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSMutableArray *_selections;
}
@end

@implementation UserInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = ColorTheme;
    //设置标题
    self.navView.imageView.alpha=0;
    [self.navView setTitle:@"个人中心"];
    self.navView.titleLable.textColor=WriteColor;
    [self.navView.leftButton setImage:IMAGENAMED(@"gerenzhongxin-8") forState:UIControlStateNormal];
    [self.navView.leftTouchView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(setting:)]];
    self.tableView=[[UITableView alloc]initWithFrame:CGRectMake(0, POS_Y(self.navView), WIDTH(self.view)-40, HEIGHT(self.view)-kTopBarHeight-kStatusBarHeight)];
    self.tableView.bounces=YES;
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    self.tableView.allowsSelection=YES;
    self.tableView.delaysContentTouches=NO;
    self.tableView.backgroundColor=WriteColor;
    self.tableView.showsVerticalScrollIndicator=NO;
    self.tableView.showsHorizontalScrollIndicator=NO;
    self.tableView.contentSize = CGSizeMake(WIDTH(self.view), HEIGHT(self.view)+220);
    self.tableView.separatorStyle=UITableViewCellSeparatorStyleSingleLine;
    
    [self.view addSubview:self.tableView];
    
    UserInfoHeader* headerView =[[UserInfoHeader alloc]initWithFrame:CGRectMake(0, 0, WIDTH(self.view), 200)];
    [self.tableView setTableHeaderView:headerView];
    
    UIView* footView =[[UIView alloc]initWithFrame:CGRectMake(0, 0, WIDTH(self.tableView), 50)];
    [self.tableView setTableFooterView:footView];
    //加载数据
    [self loadData];
    //修改个人资料
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(modifyUserInfo:) name:@"modifyUserInfo" object:nil];
    //发送短信
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(upLoad:) name:@"upLoad" object:nil];
    //更新消息系统
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateStatus) name:@"updateMessageStatus" object:nil];
    
    self.isSelectPic = NO;
}

-(void)updateStatus
{
    [self.tableView reloadData];
}
-(void)upLoad:(id)sender
{
    [[DialogUtil sharedInstance]showDlg:self.view textOnly:@"上传头像"];
    
    [self btnSelect:nil];

}

-(void)uploadUserPic:(NSInteger)id
{
    [self.httpUtil getDataFromAPIWithOps:UPLOAD_USER_PIC postParam:nil file:USER_STATIC_HEADER_PIC postName:@"file" type:0 delegate:self sel:@selector(requestUploadHeaderImg:)];
}


-(void)modifyUserInfo:(id)sender
{
    UIStoryboard* storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    UIViewController* controller = [storyBoard instantiateViewControllerWithIdentifier:@"ModifyUserInfoViewController"];
    [self.navigationController pushViewController:controller animated:YES];
}

-(void)setting:(id)sender
{
    UserInfoSettingViewController* controller = [[UserInfoSettingViewController alloc]init];
    [self.navigationController pushViewController:controller animated:YES];
}
-(void)loadData
{
    NSMutableArray* array=[[NSMutableArray alloc]init];
    NSMutableDictionary* dic =[[NSMutableDictionary alloc]init];
    [dic setValue:@"1" forKey:@"index"];
    [dic setValue:@"与我相关" forKey:@"title"];
    [dic setValue:@"yes" forKey:@"isBedEnable"];
    [dic setValue:@"About" forKey:@"imageName"];
    [array addObject:dic];
    
    dic =[[NSMutableDictionary alloc]init];
    [dic setValue:@"2" forKey:@"index"];
    [dic setValue:@"资金账户" forKey:@"title"];
    [dic setValue:@"false" forKey:@"isBedEnable"];
    [dic setValue:@"Collect" forKey:@"imageName"];
    [array addObject:dic];
    
    
    dic =[[NSMutableDictionary alloc]init];
    [dic setValue:@"3" forKey:@"index"];
    [dic setValue:@"我的收藏" forKey:@"title"];
    [dic setValue:@"false" forKey:@"isBedEnable"];
    [dic setValue:@"Collect" forKey:@"imageName"];
    [array addObject:dic];
    
    dic =[[NSMutableDictionary alloc]init];
    [dic setValue:@"4" forKey:@"index"];
    [dic setValue:@"我的投融资" forKey:@"title"];
    [dic setValue:@"false" forKey:@"isBedEnable"];
    [dic setValue:@"Authenticate" forKey:@"imageName"];
    [array addObject:dic];
    
    
    dic =[[NSMutableDictionary alloc]init];
    [dic setValue:@"5" forKey:@"index"];
    [dic setValue:@"邀请好友" forKey:@"title"];
    [dic setValue:@"false" forKey:@"isBedEnable"];
    [dic setValue:@"Invite" forKey:@"imageName"];
    [array addObject:dic];
    
    dic =[[NSMutableDictionary alloc]init];
    [dic setValue:@"6" forKey:@"index"];
    [dic setValue:@"关于我们" forKey:@"title"];
    [dic setValue:@"false" forKey:@"isBedEnable"];
    [dic setValue:@"Related" forKey:@"imageName"];
    [array addObject:dic];
    
    self.dataArray=array;
    
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   
    NSString* indexStr = [self.dataArray[indexPath.row] valueForKey:@"index"];
    if (indexStr.integerValue == 5) {
        [self ShareAction];
    }else{
        [[NSNotificationCenter defaultCenter]postNotificationName:@"userInfoAction" object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:indexStr,@"index",nil]];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //声明静态字符串对象，用来标记重用单元格
    NSString* TableDataIdentifier=@"UserInfoViewCell";
    //用TableDataIdentifier标记重用单元格
    UserInfoTableViewCell* cell=(UserInfoTableViewCell*)[tableView dequeueReusableCellWithIdentifier:TableDataIdentifier];
    //如果单元格未创建，则需要新建
    if (cell==nil) {
        cell = [[UserInfoTableViewCell alloc]initWithFrame:CGRectMake(0, 0, WIDTH(tableView), 50)];
    }
    if (indexPath.row==0) {
        NSUserDefaults* dataStore = [NSUserDefaults standardUserDefaults];
        NSInteger newMessageCount = [[dataStore valueForKey:@"NewMessageCount"] integerValue];
        NSInteger systemMessageCount = [[dataStore valueForKey:@"SystemMessageCount"] integerValue];
        NSInteger count =newMessageCount+systemMessageCount;
        if (count>0) {
            cell.messageCount = [NSString stringWithFormat:@"%ld",count];
            [cell setIsBedgesEnabled:YES];
        }

    }

    NSInteger row =indexPath.row;
    NSDictionary* dic = self.dataArray[row];
    [cell setImageWithName:[dic valueForKey:@"imageName"] setTitle:[dic valueForKey:@"title"]];
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

-(void)setDataArray:(NSArray *)dataArray
{
    self->_dataArray = dataArray;
    [self.tableView reloadData];
}

-(void)btnAction:(id)sender
{
    UIStoryboard* storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    UIViewController* controller = [storyBoard instantiateViewControllerWithIdentifier:@"LoginController"];
    [self.navigationController pushViewController:controller animated:YES];
    
    for(UIViewController* c in self.navigationController.childViewControllers){
        if (![c isKindOfClass:controller.class]) {
            [c removeFromParentViewController];
        }
    }
}

-(void)ShareAction
{
    UIWindow* window =[UIApplication sharedApplication].windows[0];
    ShareView* shareView =[[ShareView alloc]initWithFrame:window.frame];
    shareView.type = 1;
    [window addSubview:shareView];
}



//*********************************************************照相机功能结束*****************************************************//


/**
 *  上传照片
 *
 *  @param request 返回上传结果
 */
-(void)requestUploadHeaderImg:(ASIHTTPRequest *)request{
    NSString *jsonString = [TDUtil convertGBKDataToUTF8String:request.responseData];
    NSLog(@"返回:%@",jsonString);
    NSMutableDictionary* jsonDic = [jsonString JSONValue];
    
    if(jsonDic!=nil)
    {
        NSString* code = [jsonDic valueForKey:@"code"];
        if ([code intValue] == 0) {
            
        }
        
        [[DialogUtil sharedInstance]showDlg:self.view textOnly:[jsonDic valueForKey:@"msg"]];
    }
}


- (void)btnSelect:(id)sender {
    self.isSelectPic  =YES;
    
    NSMutableArray *photos = [[NSMutableArray alloc] init];
    NSMutableArray *thumbs = [[NSMutableArray alloc] init];
    //    MWPhoto *photo;
    BOOL displayActionButton = YES;
    BOOL displaySelectionButtons = NO;
    BOOL displayNavArrows = NO;
    BOOL enableGrid = YES;
    BOOL startOnGrid = YES;
    BOOL autoPlayOnAppear = NO;
    
    
    displayActionButton = NO;
    displaySelectionButtons = YES;
    startOnGrid = YES;
    enableGrid = YES;
    
    @synchronized(_assets) {
        NSMutableArray *copy = [_assets copy];
        if (NSClassFromString(@"PHAsset")) {
            // Photos library
            UIScreen *screen = [UIScreen mainScreen];
            CGFloat scale = screen.scale;
            // Sizing is very rough... more thought required in a real implementation
            CGFloat imageSize = MAX(screen.bounds.size.width, screen.bounds.size.height) * 1.5;
            CGSize imageTargetSize = CGSizeMake(imageSize * scale, imageSize * scale);
            CGSize thumbTargetSize = CGSizeMake(imageSize / 3.0 * scale, imageSize / 3.0 * scale);
            for (PHAsset *asset in copy) {
                [photos addObject:[MWPhoto photoWithAsset:asset targetSize:imageTargetSize]];
                [thumbs addObject:[MWPhoto photoWithAsset:asset targetSize:thumbTargetSize]];
            }
        } else {
            // Assets library
            for (ALAsset *asset in copy) {
                MWPhoto *photo = [MWPhoto photoWithURL:asset.defaultRepresentation.url];
                [photos addObject:photo];
                MWPhoto *thumb = [MWPhoto photoWithImage:[UIImage imageWithCGImage:asset.thumbnail]];
                [thumbs addObject:thumb];
                if ([asset valueForProperty:ALAssetPropertyType] == ALAssetTypeVideo) {
                    photo.videoURL = asset.defaultRepresentation.url;
                    thumb.isVideo = true;
                }
            }
        }
    }
    
    
    self.photos = photos;
    self.thumbs = thumbs;
    // Create browser
    if (!self.browser) {
        self.browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    }
    self.browser.displayActionButton = displayActionButton;
    self.browser.displayNavArrows = displayNavArrows;
    self.browser.displaySelectionButtons = displaySelectionButtons;
    self.browser.alwaysShowControls = displaySelectionButtons;
    self.browser.zoomPhotosToFill = YES;
    self.browser.maxSelected = 1;
    self.browser.enableGrid = enableGrid;
    self.browser.startOnGrid = startOnGrid;
    self.browser.enableSwipeToDismiss = NO;
    self.browser.autoPlayOnAppear = autoPlayOnAppear;
    [self.browser setCurrentPhotoIndex:0];
    
    //    browser.customImageSelectedIconName = @"ImageSelected.png";
    //    browser.customImageSelectedSmallIconName = @"ImageSelectedSmall.png";
    
    // Reset selections
    if (displaySelectionButtons) {
        if(!_selections){
            _selections = [NSMutableArray new];
            for (int i = 0; i < photos.count; i++) {
                [_selections addObject:[NSNumber numberWithBool:NO]];
            }
        }
    }
    
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:self.browser];
    nc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:nc animated:YES completion:nil];
}


-(void)getSelectImage:(NSArray *)imageArr
{
    self.imgSelectArray  = [NSMutableArray arrayWithArray:imageArr];
    
    UIImage * croppedImage = self.imgSelectArray.firstObject;
    //保存图片
    [TDUtil saveCameraPicture:croppedImage fileName:USER_STATIC_HEADER_PIC];
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"changeUserPic" object:nil userInfo:[NSDictionary dictionaryWithObject:croppedImage forKey:@"img"]];
    
    //开始上传
    [self uploadUserPic:0];

}

-(void)showImage:(UITapGestureRecognizer*)sender
{
    UIImageView* imageView = (UIImageView*)(sender.view);
    self.isSelectPic = NO;
    
    BOOL displayActionButton = YES;
    BOOL displaySelectionButtons = NO;
    BOOL displayNavArrows = NO;
    BOOL enableGrid = YES;
    BOOL startOnGrid = YES;
    BOOL autoPlayOnAppear = NO;
    
    
    displayActionButton = NO;
    displaySelectionButtons = YES;
    startOnGrid = YES;
    enableGrid = YES;
    
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    browser.displayActionButton = displayActionButton;
    browser.displayNavArrows = displayNavArrows;
    browser.displaySelectionButtons = displaySelectionButtons;
    browser.alwaysShowControls = displaySelectionButtons;
    browser.zoomPhotosToFill = YES;
    browser.enableGrid = NO;
    browser.startOnGrid = NO;
    browser.enableSwipeToDismiss = NO;
    browser.autoPlayOnAppear = autoPlayOnAppear;
    [browser setCurrentPhotoIndex:imageView.tag];
    
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:browser];
    nc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:nc animated:YES completion:nil];
}
#pragma mark - MWPhotoBrowserDelegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    if (self.isSelectPic) {
        return _photos.count;
    }else{
        return self.imgSelectArray.count;
    }
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (self.isSelectPic) {
        if (index < _photos.count)
            return [_photos objectAtIndex:index];
        return nil;
    }else{
        return [self.imgSelectAssetArray objectAtIndex:index];
    }
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser thumbPhotoAtIndex:(NSUInteger)index {
    if (index < _thumbs.count)
        return [_thumbs objectAtIndex:index];
    return nil;
}

//- (MWCaptionView *)photoBrowser:(MWPhotoBrowser *)photoBrowser captionViewForPhotoAtIndex:(NSUInteger)index {
//    MWPhoto *photo = [self.photos objectAtIndex:index];
//    MWCaptionView *captionView = [[MWCaptionView alloc] initWithPhoto:photo];
//    return [captionView autorelease];
//}

//- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser actionButtonPressedForPhotoAtIndex:(NSUInteger)index {
//    NSLog(@"ACTION!");
//}

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser didDisplayPhotoAtIndex:(NSUInteger)index {
    NSLog(@"Did start viewing photo at index %lu", (unsigned long)index);
}

- (BOOL)photoBrowser:(MWPhotoBrowser *)photoBrowser isPhotoSelectedAtIndex:(NSUInteger)index {
    if (_selections && _selections.count>0) {
        return [[_selections objectAtIndex:index] boolValue];
    }
    return NO;
}

//- (NSString *)photoBrowser:(MWPhotoBrowser *)photoBrowser titleForPhotoAtIndex:(NSUInteger)index {
//    return [NSString stringWithFormat:@"Photo %lu", (unsigned long)index+1];
//}

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index selectedChanged:(BOOL)selected {
    [_selections replaceObjectAtIndex:index withObject:[NSNumber numberWithBool:selected]];
    int count = 0;
    for (int i = 0; i < _selections.count; i++) {
        if ([_selections[i] boolValue]) {
            count ++;
        }
    }
    
    if (count<=self.browser.maxSelected) {
        if (count<self.browser.maxSelected) {
            photoBrowser.limit  =NO;
        }else{
            photoBrowser.limit  =YES;
        }
    }
}

- (void)photoBrowserDidFinishModalPresentation:(MWPhotoBrowser *)photoBrowser {
    // If we subscribe to this method we must dismiss the view controller ourselves
    NSLog(@"Did finish modal presentation");
    NSMutableArray* array = [NSMutableArray new];
    for (int i = 0; i < _selections.count; i++) {
        if ([_selections[i] boolValue]) {
            if (!self.imgSelectAssetArray) {
                self.imgSelectAssetArray = [NSMutableArray new];
            }
            [self.imgSelectAssetArray addObject:[_photos objectAtIndex:i]];
            UIImage* image;
            if (NSClassFromString(@"PHAsset")) {
                PHAsset* photo = [_assets objectAtIndex:i];
                
                // 在资源的集合中获取第一个集合，并获取其中的图片
                PHCachingImageManager *imageManager = [[PHCachingImageManager alloc] init];
                [imageManager requestImageForAsset:photo
                                        targetSize:PHImageManagerMaximumSize
                                       contentMode:PHImageContentModeDefault
                                           options:nil
                                     resultHandler:^(UIImage *result, NSDictionary *info) {
                                         
                                         // 得到一张 UIImage，展示到界面上
                                         if (result) {
                                             [array addObject:result];
                                         }
                                         
                                         [self getSelectImage:array];
                                     }];
            }else{
                ALAsset* asset = _assets[i];
                image = [self fullResolutionImageFromALAsset:asset];
                [array addObject:image];
            }
        }
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (UIImage *)fullResolutionImageFromALAsset:(ALAsset *)asset
{
    ALAssetRepresentation *assetRep = [asset defaultRepresentation];
    CGImageRef imgRef = [assetRep fullResolutionImage];
    UIImage *img = [UIImage imageWithCGImage:imgRef
                                       scale:assetRep.scale
                                 orientation:(UIImageOrientation)assetRep.orientation];
    return img;
}
#pragma mark - Load Assets

- (void)loadAssets {
    if (NSClassFromString(@"PHAsset")) {
        
        // Check library permissions
        PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
        if (status == PHAuthorizationStatusNotDetermined) {
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                if (status == PHAuthorizationStatusAuthorized) {
                    [self performLoadAssets];
                }
            }];
        } else if (status == PHAuthorizationStatusAuthorized) {
            [self performLoadAssets];
        }
        
    } else {
        
        // Assets library
        [self performLoadAssets];
        
    }
}

- (void)performLoadAssets {
    
    // Initialise
    _assets = [NSMutableArray new];
    
    // Load
    if (NSClassFromString(@"PHAsset")) {
        
        // Photos library iOS >= 8
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            PHFetchOptions *options = [PHFetchOptions new];
            options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
            PHFetchResult *fetchResults = [PHAsset fetchAssetsWithOptions:options];
            [fetchResults enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [_assets addObject:obj];
            }];
        });
        
    } else {
        
        // Assets Library iOS < 8
        _ALAssetsLibrary = [[ALAssetsLibrary alloc] init];
        
        // Run in the background as it takes a while to get all assets from the library
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            NSMutableArray *assetGroups = [[NSMutableArray alloc] init];
            NSMutableArray *assetURLDictionaries = [[NSMutableArray alloc] init];
            
            // Process assets
            void (^assetEnumerator)(ALAsset *, NSUInteger, BOOL *) = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
                if (result != nil) {
                    NSString *assetType = [result valueForProperty:ALAssetPropertyType];
                    if ([assetType isEqualToString:ALAssetTypePhoto] || [assetType isEqualToString:ALAssetTypeVideo]) {
                        [assetURLDictionaries addObject:[result valueForProperty:ALAssetPropertyURLs]];
                        NSURL *url = result.defaultRepresentation.url;
                        [_ALAssetsLibrary assetForURL:url
                                          resultBlock:^(ALAsset *asset) {
                                              if (asset) {
                                                  @synchronized(_assets) {
                                                      [_assets addObject:asset];
                                                  }
                                              }
                                          }
                                         failureBlock:^(NSError *error){
                                             NSLog(@"operation was not successfull!");
                                         }];
                        
                    }
                }
            };
            
            // Process groups
            void (^ assetGroupEnumerator) (ALAssetsGroup *, BOOL *) = ^(ALAssetsGroup *group, BOOL *stop) {
                if (group != nil) {
                    [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:assetEnumerator];
                    [assetGroups addObject:group];
                }
            };
            
            // Process!
            [_ALAssetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll
                                            usingBlock:assetGroupEnumerator
                                          failureBlock:^(NSError *error) {
                                              NSLog(@"There is an error");
                                          }];
            
        });
        
    }
    
}

#pragma UploadPic
//*********************************************************照相机功能*****************************************************//




- (void) viewWillAppear: (BOOL)inAnimated {
    NSIndexPath *selected = [self.tableView indexPathForSelectedRow];
    if(selected) [self.tableView deselectRowAtIndexPath:selected animated:YES];
    
    if (!_assets) {
        [self loadAssets];
    }
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"userInfoAction" object:nil];
}
@end
