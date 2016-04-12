#import "SDTimeLineTableViewController.h"

#import "Cycle.h"
#import "MJRefresh.h"
#import "SDTimeLineCell.h"
#import "SDTimeLineCellModel.h"
#import "UIView+SDAutoLayout.h"
#import "BannerViewController.h"
#import "PublishViewController.h"
#import "SDTimeLineRefreshHeader.h"
#import "SDTimeLineRefreshFooter.h"
#import "SDTimeLineTableHeaderView.h"
#import "CustomImagePickerController.h"
#import "UITableView+SDAutoTableViewCellHeight.h"

#import "DAKeyboardControl.h"
#import "BannerViewController.h"
#import "PECropViewController.h"
#import "UIView+SDAutoLayout.h"
#import "PublishViewController.h"
#import "CustomImagePickerController.h"

#define kTimeLineTableViewCellId @"SDTimeLineCell"

static CGFloat textFieldH = 40;

@interface SDTimeLineTableViewController () <SDTimeLineCellDelegate, UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate,UITextViewDelegate,CustomImagePickerControllerDelegate>

{
    NSInteger currentPage;
    NSString* replyContent;
    NSString* conId,* atConId;
    SDTimeLineTableHeaderView *headerView;
    
    SDTimeLineCell * currentSelectedCell;
}
@property (nonatomic, strong) CustomImagePickerController* customPicker;
@end

@implementation SDTimeLineTableViewController

{
    CGFloat _lastScrollViewOffsetY;
    UITextField *_textField;
    CGFloat _totalKeybordHeight;
    NSIndexPath *_currentEditingIndexthPath;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.edgesForExtendedLayout = UIRectEdgeTop;
    
    //==============================TabBarItem 设置==============================//
    UIImage* image=IMAGENAMED(@"btn-quanzi-cheng");
    image=[image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [self.tabBarItem setSelectedImage:image];
    [self.tabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:AppColorTheme,NSForegroundColorAttributeName, nil] forState:UIControlStateSelected];
    //==============================TabBarItem 设置==============================//
    
    //==============================导航栏区域 设置==============================//
    [self.navView setTitle:@"金指投"];
    self.navView.titleLable.textColor=WriteColor;
    [self.navView.leftButton setImage:IMAGENAMED(@"home") forState:UIControlStateNormal];
    [self.navView.leftTouchView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(userInfoAction:)]];
    
    [self.navView.rightButton setImage:IMAGENAMED(@"circle_publish") forState:UIControlStateNormal];
    [self.navView.rightTouchView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(publishAction:)]];
    //==============================导航栏区域 设置==============================//
    
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, POS_Y(self.navView), WIDTH(self.view), HEIGHT(self.view)-POS_Y(self.navView)-kBottomBarHeight-87)];
    self.tableView.bounces=YES;
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    self.tableView.allowsSelection=YES;
    self.tableView.delaysContentTouches=NO;
    self.tableView.showsVerticalScrollIndicator=NO;
    self.tableView.showsHorizontalScrollIndicator=NO;
    self.tableView.separatorStyle=UITableViewCellSeparatorStyleSingleLine;
    [self.view addSubview:self.tableView];
    
    [TDUtil tableView:self.tableView target:self refreshAction:@selector(refreshProject) loadAction:@selector(loadProject)];
    
    [self.tableView setTableFooterView:[[UIView alloc]initWithFrame:CGRectZero]];
    

    
    headerView = [SDTimeLineTableHeaderView new];
    headerView.frame = CGRectMake(0, 0, 0, 260);
    [headerView._iconView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(UserInfoSetting:)]];
    [headerView._backgroundImageView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(takePhoto:)]];
    self.tableView.tableHeaderView = headerView;
    
    [self.tableView registerClass:[SDTimeLineCell class] forCellReuseIdentifier:kTimeLineTableViewCellId];
    [self.tableView setFrame:CGRectMake(0, POS_Y(self.navView), WIDTH(self.view), HEIGHT(self.view)-POS_Y(self.navView))];
    
    [self setupTextField];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardNotification:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
    //添加监听
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(loadData) name:@"reloadData" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(publishContent:) name:@"publish" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateNewMessage:) name:@"updateMessageStatus" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(publishContentNotification:) name:@"publishContent" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(userInteractionEnabled:) name:@"userInteractionEnabled" object:nil];
    
    //加载数据
//    [self loadOffLineData];
    [self loadData];
    [self updateNewMessage:nil];
}

/**
 *  加载离线数据
 */
-(void)loadOffLineData
{
    Cycle* cycleModel = [[Cycle alloc]init];
    NSMutableArray* dataArray = [cycleModel selectData:10 andOffset:(int)currentPage];
    
    if (dataArray && dataArray.count>0) {
        NSMutableArray * tempArray = [NSMutableArray new];
        for (int i = 0; i<dataArray.count; i++) {
            NSDictionary * dic = dataArray[i];
            SDTimeLineCellModel *model = [SDTimeLineCellModel new];
            model.iconName = [dic valueForKey:@"photo"];
            model.name = [dic valueForKey:@"name"];
            model.msgContent = [dic valueForKey:@"content"];
            
            
            //图片
            NSArray* array = [self.dataDic valueForKey:@"pic"];
            if (array && array.count>0) {
                model.picNamesArray =array;
            }
            
            //评论列表
            //                array = [self.dataDic valueForKey:@"comment"];
            //                model.commentItemsArray = array;
            
            int commentRandom = arc4random_uniform(3);
            NSMutableArray *tempComments = [NSMutableArray new];
            for (int i = 0; i < commentRandom; i++) {
                SDTimeLineCellCommentItemModel *commentItemModel = [SDTimeLineCellCommentItemModel new];
                int index = arc4random_uniform((int)10);
                commentItemModel.firstUserName = @"皇帝";
                commentItemModel.firstUserId = @"666";
                if (arc4random_uniform(10) < 5) {
                    commentItemModel.secondUserName = @"晨";
                    commentItemModel.secondUserId = @"888";
                }
                commentItemModel.commentString = @"It's a happy day!";
                [tempComments addObject:commentItemModel];
            }
            model.commentItemsArray = [tempComments copy];
            [tempArray addObject:model];
        }
        
        //状态栏提示
        [JDStatusBarNotification showWithStatus:STRING(@"已更新%ld条新数据", tempArray.count)  dismissAfter:3.0];
        self.dataArray = tempArray;
        
        //判断网络
        if ([TDUtil checkNetworkState] != NetStatusNone) {
            isRefresh = YES;
            [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(loadData) userInfo:nil repeats:NO];
        }
    }else{
        [self loadData];
    }
}


-(void)userInteractionEnabled:(NSDictionary*)dic

{
    
    BOOL isUserInteractionEnabled = [[[dic valueForKey:@"userInfo"] valueForKey:@"userInteractionEnabled"] boolValue];
    
    self.view.userInteractionEnabled = isUserInteractionEnabled;
    
}

/**
 *  消息提示
 *
 *  @param dic 通知数据
 */
-(void)updateNewMessage:(NSDictionary*)dic
{
    NSUserDefaults* dataStore = [NSUserDefaults standardUserDefaults];
    NSInteger newMessageCount = [[dataStore valueForKey:@"NewMessageCount"] integerValue];
    NSInteger systemMessageCount = [[dataStore valueForKey:@"SystemMessageCount"] integerValue];
    if (newMessageCount+systemMessageCount>0) {
        [self.navView setIsHasNewMessage:YES];
    }
    
}

/**
 *  加载数据
 */
-(void)loadData
{
    if (!self.dataArray) {
        self.startLoading = YES;
    }
    NSString* serverUrl = [CYCLE_CONTENT_LIST stringByAppendingFormat:@"%d/",curentPage];
    [self.httpUtil getDataFromAPIWithOps:serverUrl postParam:nil type:0 delegate:self sel:@selector(requestData:)];
}

-(void)refreshProject
{
    //加载动画
    isRefresh =YES;
    curentPage = 0;
    [self loadData];
    self.startLoading=NO;
}

-(void)loadProject
{
    //加载动画
    isRefresh =NO;
    if (!isEndOfPageSize) {
        curentPage++;
        [self loadData];
        self.startLoading=NO;
    }else{
        [[DialogUtil sharedInstance]showDlg:self.view textOnly:@"已加载全部"];
        isRefresh =NO;
    }
}


-(void)refresh
{
    [super refresh];
    
    [self loadData];
}

-(void)publishContentNotification:(NSDictionary*)dic
{
    NSDictionary* dataDic = [[dic valueForKey:@"userInfo"] valueForKey:@"data"];
    if (dataDic) {
        NSString* content = [dataDic valueForKey:@"content"];
        NSMutableArray* postArray =[dataDic valueForKey:@"files"];
        
        //组织数据
        //        NSMutableDictionary* dic = [[NSMutableDictionary alloc]init];
        NSUserDefaults* dataDefault =[NSUserDefaults standardUserDefaults];
        
        //重构数组,
        //用户id
        //        [dic setValue:@"YES" forKey:@"flag"];
        //        [dic setValue:postArray forKey:@"pic"];
        //        [dic setValue:@"刚刚" forKey:@"datetime"];
        //        [dic setValue:content forKey:@"content"];
        //        [dic setValue:[dataDefault valueForKey:@"userId"] forKey:@"uid"];
        //        //        [dic setValue:[dataDefault valueForKey:@"city"] forKey:@"city"];
        //        [dic setValue:[dataDefault valueForKey:@"name"] forKey:@"name"];
        //        [dic setValue:[dataDefault valueForKey:@"photo"] forKey:@"photo"];
        //        [dic setValue:[dataDefault valueForKey:@"STATIC_USER_TYPE"] forKey:@"position"];
        
//        Demo9Model* model = [[Demo9Model alloc]init];
        
        //        NSMutableArray* arr = [[NSMutableArray alloc]init];
        //        for (int i = 0; i<postArray.count; i++) {
        //            [arr addObject:[NSString stringWithFormat:@"file%d",i]];
        //        }
//        model.picNamesArray = postArray;
//        model.flag = true;
//        model.dateTime  = @"刚刚";
//        model.content = content;
//        model.uid = [[dataDefault valueForKey:@"userId"] integerValue];
//        model.name = [dataDefault valueForKey:@"name"];
//        model.iconName = [dataDefault valueForKey:@"photo"];
//        model.position = [dataDefault valueForKey:@"STATIC_USER_TYPE"];
//        
//        
//        [self.dataArray insertObject:model atIndex:0];
        [self.tableView reloadData];
        
        //1.获得全局的并发队列
        dispatch_queue_t queue =  dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        //2.添加任务到队列中，就可以执行任务
        //异步函数：具备开启新线程的能力
        dispatch_async(queue, ^{
            [self savePhoto:dataDic];
        });
        
        //[self performSelector:@selector(publishContent:) withObject:dataDic afterDelay:2];
    }
}


#pragma UploadPic
//*********************************************************照相机功能*****************************************************//


//照相功能

-(void)takePhoto:(NSDictionary*)dic
{
    [self showPicker];
}

- (void)showPicker
{
    CustomImagePickerController* picker = [[CustomImagePickerController alloc] init];
    
    //创建返回按钮
    UIButton* btn=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, NUMBERFORTY, NUMBERTHIRTY)];
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc]initWithCustomView:btn];
    [leftButton setStyle:UIBarButtonItemStylePlain];
    //创建设置按钮
    btn=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, NUMBERFORTY, NUMBERTHIRTY)];
    btn.tintColor=WriteColor;
    btn.titleLabel.textColor=WriteColor;
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc]initWithCustomView:btn];
    
    picker.navigationItem.leftBarButtonItem=leftButton;
    picker.navigationItem.rightBarButtonItem=rightButton;
    
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        [picker setSourceType:UIImagePickerControllerSourceTypeCamera];
    }else{
        [picker setIsSingle:YES];
        [picker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    }
    picker.modalPresentationStyle = UIModalPresentationCurrentContext;
    [picker setCustomDelegate:self];
    self.customPicker=picker;
    [self presentViewController:self.customPicker animated:YES completion:nil];
}

- (void)cameraPhoto:(UIImage *)imageCamera  //选择完图片
{
    [self openEditor:imageCamera];
}

- (void)openEditor:(UIImage*)imageCamera
{
    PECropViewController *controller = [[PECropViewController alloc] init];
    controller.delegate = self;
    controller.image = imageCamera;
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    
    [self presentViewController:navigationController animated:YES completion:NULL];
}

- (void)cropViewController:(PECropViewController *)controller didFinishCroppingImage:(UIImage *)croppedImage
{
    [controller dismissViewControllerAnimated:YES completion:NULL];
    //保存图片
    [TDUtil saveCameraPicture:croppedImage fileName:STATIC_USER_BACKGROUND_PIC];
    
    //    [[NSNotificationCenter defaultCenter]postNotificationName:@"changeUserPic" object:nil userInfo:[NSDictionary dictionaryWithObject:croppedImage forKey:@"img"]];
    //修改头部背景
    [headerView._backgroundImageView setImage:croppedImage];
    
    //开始上传
    [self uploadUserPic:0];
}


-(void)cropViewControllerDidCancel:(PECropViewController *)controller
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}


//取消照相
-(void)cancelCamera
{
    
}



//上传头像
-(void)uploadUserPic:(NSInteger)id
{
    [self.httpUtil getDataFromAPIWithOps:CYCLE_CONTENT_BACKGROUND_UPLOAD postParam:nil file:STATIC_USER_BACKGROUND_PIC postName:@"file" type:0 delegate:self sel:@selector(requestUploadHeaderImg:)];
}

-(void)savePhoto:(NSDictionary*)dic
{
    NSMutableArray* uploadFiles =[NSMutableArray new];
    NSMutableArray* postArray =[dic valueForKey:@"files"];
    int i=0;
    for (UIView* v in postArray) {
        UIImage* image = (UIImage*)v;
        BOOL flag = [TDUtil saveContent:image fileName:[NSString stringWithFormat:@"file%d",i]];
        if (flag) {
            [uploadFiles addObject:[NSString stringWithFormat:@"file%d",i]];
            i++;
        }
    }
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"publish" object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:uploadFiles,@"uploadFiles",[dic valueForKey:@"content" ],@"content", nil]];
}

-(void)UserInfoSetting:(id)sender
{
    UIStoryboard* storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    UIViewController* controller = [storyBoard instantiateViewControllerWithIdentifier:@"ModifyUserInfoViewController"];
    [self.navigationController pushViewController:controller animated:YES];
}

-(void)userInfoAction:(id)sender
{
    [[NSNotificationCenter defaultCenter]postNotificationName:@"userInfo" object:nil];
}

-(void)publishContent:(NSDictionary*)dic
{
    NSMutableArray* uploadFiles =[[dic valueForKey:@"userInfo"] valueForKey:@"uploadFiles"];
    NSString* content = [[dic valueForKey:@"userInfo"] valueForKey:@"content"];
    [self.httpUtil getDataFromAPIWithOps:CYCLE_CONTENT_PUBLISH postParam:[NSDictionary dictionaryWithObject:content forKey:@"content"] files:uploadFiles postName:@"file" type:0 delegate:self sel:@selector(requestPublishContent:)];
    
    //    self.startLoading  =YES;
    //    self.isTransparent = YES;
}

-(BOOL)commentAction:(id)sender
{
    NSString* content = _textField.text;
    if ([content isEqualToString:@""] || [content isEqualToString:replyContent]) {
        [[DialogUtil sharedInstance]showDlg:self.view textOnly:@"请输入回复内容"];
        [_textField resignFirstResponder];
        return false;
    }
    
    [_textField resignFirstResponder];
    
    NSString* serverUrl = [CYCLE_CONTENT_REPLY stringByAppendingFormat:@"%@/",conId];
    [self.httpUtil getDataFromAPIWithOps:serverUrl postParam:[NSDictionary dictionaryWithObjectsAndKeys:content,@"content",atConId,@"at", nil] type:0 delegate:self sel:@selector(requestReply:)];
    return true;
}

-(void)publishAction:(id)sender
{
    UIStoryboard* board = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    PublishViewController* controller = [board instantiateViewControllerWithIdentifier:@"PublishViewController"];
    controller.controller = self;
    [self.navigationController presentViewController:controller animated:YES completion:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
//    if (!_refreshHeader.superview) {
//        
//        _refreshHeader = [SDTimeLineRefreshHeader refreshHeaderWithCenter:CGPointMake(40, 45)];
//        _refreshHeader.scrollView = self.tableView;
//        __weak typeof(_refreshHeader) weakHeader = _refreshHeader;
//        __weak typeof(self) weakSelf = self;
//        [_refreshHeader setRefreshingBlock:^{
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                weakSelf.dataArray = [[weakSelf creatModelsWithCount:10] mutableCopy];
//                [weakHeader endRefreshing];
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [weakSelf.tableView reloadData];
//                });
//            });
//        }];
//        [self.tableView.superview addSubview:_refreshHeader];
//    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [_textField resignFirstResponder];
}

- (void)dealloc
{
    [_textField removeFromSuperview];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupTextField
{
    _textField = [UITextField new];
    _textField.returnKeyType = UIReturnKeyDone;
    _textField.delegate = self;
    _textField.layer.borderColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.8].CGColor;
    _textField.layer.borderWidth = 1;
    _textField.backgroundColor = [UIColor whiteColor];
    _textField.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height, self.view.width, textFieldH);
    [[UIApplication sharedApplication].keyWindow addSubview:_textField];
    
    [_textField becomeFirstResponder];
    [_textField resignFirstResponder];
}

- (NSArray *)creatModelsWithCount:(NSInteger)count
{
    NSArray *iconImageNamesArray = @[@"icon0.jpg",
                                     @"icon1.jpg",
                                     @"icon2.jpg",
                                     @"icon3.jpg",
                                     @"icon4.jpg",
                                     ];
    
    NSArray *namesArray = @[@"GSD_iOS",
                            @"风口上的猪",
                            @"当今世界网名都不好起了",
                            @"我叫郭德纲",
                            @"Hello Kitty"];
    
    NSArray *textArray = @[@"当你的 app 没有提供 3x 的 LaunchImage 时，系统默认进入兼容模式，https://github.com/gsdios/SDAutoLayout大屏幕一切按照 320 宽度渲染，屏幕宽度返回 320；然后等比例拉伸到大屏。这种情况下对界面不会产生任何影响，等于把小屏完全拉伸。",
                           @"然后等比例拉伸到大屏。这种情况下对界面不会产生任何影响，https://github.com/gsdios/SDAutoLayout等于把小屏完全拉伸。",
                           @"当你的 app 没有提供 3x 的 LaunchImage 时屏幕宽度返回 320；然后等比例拉伸到大屏。这种情况下对界面不会产生任何影响，等于把小屏完全拉伸。但是建议不要长期处于这种模式下。屏幕宽度返回 320；https://github.com/gsdios/SDAutoLayout然后等比例拉伸到大屏。这种情况下对界面不会产生任何影响，等于把小屏完全拉伸。但是建议不要长期处于这种模式下。屏幕宽度返回 320；然后等比例拉伸到大屏。这种情况下对界面不会产生任何影响，等于把小屏完全拉伸。但是建议不要长期处于这种模式下。",
                           @"但是建议不要长期处于这种模式下，否则在大屏上会显得字大，内容少，容易遭到用户投诉。",
                           @"屏幕宽度返回 320；https://github.com/gsdios/SDAutoLayout然后等比例拉伸到大屏。这种情况下对界面不会产生任何影响，等于把小屏完全拉伸。但是建议不要长期处于这种模式下。"
                           ];
    
    NSArray *commentsArray = @[@"社会主义好！👌👌👌👌",
                               @"正宗好凉茶，正宗好声音。。。",
                               @"你好，我好，大家好才是真的好",
                               @"有意思",
                               @"你瞅啥？",
                               @"瞅你咋地？？？！！！",
                               @"hello，看我",
                               @"曾经在幽幽暗暗反反复复中追问，才知道平平淡淡从从容容才是真",
                               @"人艰不拆",
                               @"咯咯哒",
                               @"呵呵~~~~~~~~",
                               @"我勒个去，啥世道啊",
                               @"真有意思啊你💢💢💢"];
    
    NSArray *picImageNamesArray = @[ @"pic0.jpg",
                                     @"pic1.jpg",
                                     @"pic2.jpg",
                                     @"pic3.jpg",
                                     @"pic4.jpg",
                                     @"pic5.jpg",
                                     @"pic6.jpg",
                                     @"pic7.jpg",
                                     @"pic8.jpg"
                                     ];
    NSMutableArray *resArr = [NSMutableArray new];
    
    for (int i = 0; i < count; i++) {
        int iconRandomIndex = arc4random_uniform(5);
        int nameRandomIndex = arc4random_uniform(5);
        int contentRandomIndex = arc4random_uniform(5);
        
        SDTimeLineCellModel *model = [SDTimeLineCellModel new];
        model.iconName = iconImageNamesArray[iconRandomIndex];
        model.name = namesArray[nameRandomIndex];
        model.msgContent = textArray[contentRandomIndex];
        
        
        // 模拟“随机图片”
        int random = arc4random_uniform(6);
        
        NSMutableArray *temp = [NSMutableArray new];
        for (int i = 0; i < random; i++) {
            int randomIndex = arc4random_uniform(9);
            [temp addObject:picImageNamesArray[randomIndex]];
        }
        if (temp.count) {
            model.picNamesArray = [temp copy];
        }
        
        int commentRandom = arc4random_uniform(3);
        NSMutableArray *tempComments = [NSMutableArray new];
        for (int i = 0; i < commentRandom; i++) {
            SDTimeLineCellCommentItemModel *commentItemModel = [SDTimeLineCellCommentItemModel new];
            int index = arc4random_uniform((int)namesArray.count);
            commentItemModel.firstUserName = namesArray[index];
            commentItemModel.firstUserId = @"666";
            if (arc4random_uniform(10) < 5) {
                commentItemModel.secondUserName = namesArray[arc4random_uniform((int)namesArray.count)];
                commentItemModel.secondUserId = @"888";
            }
            commentItemModel.commentString = commentsArray[arc4random_uniform((int)commentsArray.count)];
            [tempComments addObject:commentItemModel];
        }
        model.commentItemsArray = [tempComments copy];
        
        [resArr addObject:model];
    }
    return [resArr copy];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SDTimeLineCell *cell = [tableView dequeueReusableCellWithIdentifier:kTimeLineTableViewCellId];
    cell.indexPath = indexPath;
    __weak typeof(self) weakSelf = self;
    if (!cell.moreButtonClickedBlock) {
        [cell setMoreButtonClickedBlock:^(NSIndexPath *indexPath) {
            SDTimeLineCellModel *model = weakSelf.dataArray[indexPath.row];
            model.isOpening = !model.isOpening;
            [weakSelf.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }];
        cell.delegate = self;
    }
    
    ////// 此步设置用于实现cell的frame缓存，可以让tableview滑动更加流畅 //////
    
    [cell useCellFrameCacheWithIndexPath:indexPath tableView:tableView];
    
    ///////////////////////////////////////////////////////////////////////
    
    cell.model = self.dataArray[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // >>>>>>>>>>>>>>>>>>>>> * cell自适应 * >>>>>>>>>>>>>>>>>>>>>>>>
    id model = self.dataArray[indexPath.row];
    return [self.tableView cellHeightForIndexPath:indexPath model:model keyPath:@"model" cellClass:[SDTimeLineCell class] contentViewWidth:[self cellContentViewWith]];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [_textField resignFirstResponder];
}




- (CGFloat)cellContentViewWith
{
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    
    // 适配ios7
    if ([UIApplication sharedApplication].statusBarOrientation != UIInterfaceOrientationPortrait && [[UIDevice currentDevice].systemVersion floatValue] < 8) {
        width = [UIScreen mainScreen].bounds.size.height;
    }
    return width;
}


#pragma mark - SDTimeLineCellDelegate

- (void)didClickcCommentButtonInCell:(UITableViewCell *)cell
{
    [_textField becomeFirstResponder];
    _currentEditingIndexthPath = [self.tableView indexPathForCell:cell];
    
    [self adjustTableViewToFitKeyboard];
    
}

- (void)didClickLickButtonInCell:(UITableViewCell *)cell
{
    
}


- (void)adjustTableViewToFitKeyboard
{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:_currentEditingIndexthPath];
    CGRect rect = [cell.superview convertRect:cell.frame toView:window];
    CGFloat delta = CGRectGetMaxY(rect) - (window.bounds.size.height - _totalKeybordHeight);
    
    CGPoint offset = self.tableView.contentOffset;
    offset.y += delta;
    if (offset.y < 0) {
        offset.y = 0;
    }
    
    [self.tableView setContentOffset:offset animated:YES];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.text.length) {
        [_textField resignFirstResponder];
        
        SDTimeLineCellModel *model = self.dataArray[_currentEditingIndexthPath.row];
        NSMutableArray *temp = [NSMutableArray new];
        [temp addObjectsFromArray:model.commentItemsArray];
        
        NSUserDefaults * data = [NSUserDefaults standardUserDefaults];
        NSString * userName  = [data valueForKey:USER_STATIC_NICKNAME];
        NSString * userId  = [data valueForKey:USER_STATIC_USER_ID];
        
        SDTimeLineCellCommentItemModel *commentItemModel = [SDTimeLineCellCommentItemModel new];
        commentItemModel.firstUserName = userName;
        commentItemModel.commentString = textField.text;
        commentItemModel.firstUserId = userId;
        [temp addObject:commentItemModel];
        
        model.commentItemsArray = [temp copy];
        
        [self.tableView reloadRowsAtIndexPaths:@[_currentEditingIndexthPath] withRowAnimation:UITableViewRowAnimationNone];
        
        
        [self commentAction:nil];
        
        _textField.text = @"";
        return YES;
    }
    return NO;
}



- (void)keyboardNotification:(NSNotification *)notification
{
    NSDictionary *dict = notification.userInfo;
    CGRect rect = [dict[@"UIKeyboardFrameEndUserInfoKey"] CGRectValue];
    
    
    
    CGRect textFieldRect = CGRectMake(0, rect.origin.y - textFieldH, rect.size.width, textFieldH);
    if (rect.origin.y == [UIScreen mainScreen].bounds.size.height) {
        textFieldRect = rect;
    }
    
    [UIView animateWithDuration:0.25 animations:^{
        _textField.frame = textFieldRect;
    }];
    
    CGFloat h = rect.size.height + textFieldH;
    if (_totalKeybordHeight != h) {
        _totalKeybordHeight = h;
        [self adjustTableViewToFitKeyboard];
    }
}

#pragma WeiboTableViewCellDelegate
-(void)weiboTableViewCell:(id)weiboTableViewCell userId:(NSString*)userId isSelf:(BOOL)isSelf
{
//    UserLookForViewController* controller = [[UserLookForViewController alloc]init];
//    controller.userId = userId;
//    [self.navigationController pushViewController:controller animated:YES];
}

-(void)weiboTableViewCell:(id)weiboTableViewCell contentId:(NSString *)contentId atId:(NSString *)atId isSelf:(BOOL)isSelf
{
    atConId  =atId;
    conId  =contentId;
    currentSelectedCell = weiboTableViewCell;
    
    if (atConId) {
        //获取被@对象名称
        NSString* name = @"";
        for (int i = 0 ; i<currentSelectedCell.model.commentItemsArray.count; i++) {
            SDTimeLineCellCommentItemModel* model  = currentSelectedCell.model.commentItemsArray[i];
            if ([model.firstUserId integerValue]==[atId integerValue]) {
                name = model.firstUserName;
            }
        }
        
        _textField.text= [NSString stringWithFormat:@"回复%@:",name];
        replyContent = _textField.text;
        _textField.textColor = LightGrayColor;
    }else{
        replyContent = @"";
        _textField.text  = replyContent;
    }
    
    
    [_textField becomeFirstResponder];
    
    _currentEditingIndexthPath = [self.tableView indexPathForCell:weiboTableViewCell];
    
    [self adjustTableViewToFitKeyboard];
}

-(void)weiboTableViewCell:(id)weiboTableViewCell deleteDic:(id)cycle
{
    if ([self.dataArray containsObject:cycle]) {
        [self.dataArray removeObject:cycle];
        [self.tableView reloadData];
    }
}

-(void)weiboTableViewCell:(id)weiboTableViewCell priseDic:(SDTimeLineCellLikeItemModel *)item msg:(NSString *)msg
{
    NSIndexPath* indexPath = [self.tableView indexPathForCell:weiboTableViewCell];
    SDTimeLineCellModel * model = ((SDTimeLineCell*)weiboTableViewCell).model;
    
    if (!model.isLike) {
        NSMutableArray* array = [NSMutableArray arrayWithArray:model.likeItemsArray];
        [array insertObject:item atIndex:0];
        model.likeItemsArray = array;
        self.dataArray[indexPath.row] = model;
        model.isLike = YES;
    }else{
        NSMutableArray* array = [NSMutableArray arrayWithArray:model.likeItemsArray];
        for (int i= 0 ;i<array.count;i++) {
            SDTimeLineCellLikeItemModel* d = array[i];
            if ([d.userId integerValue]==[item.userId integerValue]) {
                [array removeObject:d];
            }
        }
        model.isLike = NO;
        model.likeItemsArray = array;
        self.dataArray[indexPath.row] = model;
    }
    [self.tableView reloadData];
    
}
-(void)weiboTableViewCell:(id)weiboTableViewCell refresh:(BOOL)refresh
{
//    Demo9Model* model =((DemoVC9Cell*)weiboTableViewCell).model;
//    NSIndexPath* inPath = [self.tableView indexPathForCell:weiboTableViewCell];
//    Demo9Model* modelInstance = [self.dataArray objectAtIndex:inPath.row];
//    modelInstance.commentArray = model.commentArray;
//    
//    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:inPath] withRowAnimation:UITableViewRowAnimationFade];
//    
//    [self.tableView reloadData];
    
}

-(void)weiboTableViewCell:(id)weiboTableViewCell didSelectedContent:(BOOL)isSelected
{
    NSIndexPath* indexPath =[self.tableView indexPathForCell:weiboTableViewCell];
    //    NSDictionary* dic = self.dataArray[indexPath.row];
    //    //内容
    //    NSString* content = [dic valueForKey:@"content"];
    //    NSInteger picsCount = [[dic valueForKey:@"pics"] count];
    //
    //
    //    int number = [TDUtil convertToInt:content] / 17;
    //    if (number==0) {
    //        if ([content length]>0) {
    //            number++;
    //        }
    //    }
    //
    //    CGFloat height = number*25;
    //    if(picsCount>0 && picsCount<=3){
    //        height +=70;
    //    }else{
    //        if (picsCount%3!=0) {
    //            height += (picsCount/3+1)*80;
    //        }else{
    //            height += (picsCount/3)*80;
    //        }
    //    }
    //
    //
    //    height+=160;
    
//    ActionDetailViewController* controller = [[ActionDetailViewController alloc]init];
//    controller.dic = self.dataArray[indexPath.row];
//    [self.navigationController pushViewController:controller animated:YES];
}


-(void)weiboTableViewCell:(id)weiboTableViewCell didSelectedShareContentUrl:(NSURL *)urlStr
{
    SDTimeLineCellModel * model = ((SDTimeLineCell*)weiboTableViewCell).model;
    BannerViewController* controller =[[BannerViewController alloc]init];
    controller.type=3;
    controller.url =urlStr;
    controller.title=@"圈子";
    controller.titleStr=@"资讯详情";
    controller.dic = model.shareDic;
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma 设置数据
-(void)setDataArray:(NSMutableArray *)dataArray
{
    if (dataArray && dataArray.count>0) {
        self->_dataArray = dataArray;
        [self.tableView reloadData];
    }
}


#pragma ASIHttpRequest
-(void)requestData:(ASIHTTPRequest*)request
{
    NSString* jsonString = [TDUtil convertGBKDataToUTF8String:request.responseData];
    
    NSLog(@"返回:%@",jsonString);
    NSMutableDictionary * dic =[jsonString JSONValue];
    if (dic!=nil) {
        NSString* code = [dic valueForKey:@"code"];
        if ([code integerValue]==0  || [code integerValue]==2) {
            NSArray* tempArray = [dic valueForKey:@"data"];
            NSMutableArray* modelArray=[NSMutableArray new];
            NSDictionary* dic;
            for (int i=0; i<tempArray.count; i++) {
                dic = [tempArray objectAtIndex:i];
                
                SDTimeLineCellModel *model = [SDTimeLineCellModel new];
                model.iconName = [dic valueForKey:@"photo"];
                model.name = [dic valueForKey:@"name"];
                model.msgContent = [dic valueForKey:@"content"];
                model.address = [dic valueForKey:@"addr"];
                model.position = [dic valueForKey:@"position"];
                model.dateTime = [dic valueForKey:@"datetime"];
                model.id = [[dic valueForKey:@"id"] integerValue];
                model.flag = [[dic valueForKey:@"flag"] boolValue];
                model.uid = [[dic valueForKey:@"uid"] integerValue];
                model.isLike = [[dic valueForKey:@"is_like"] boolValue];
                
                
                //分享
                NSDictionary* dicShare =[dic valueForKey:@"share"];
                if (dicShare) {
                    model.shareDic=dicShare;
                }
                
                //图片
                NSArray* array = [dic valueForKey:@"pic"];
                if (array && array.count>0) {
                    model.picNamesArray =array;
                }
                
                array = [dic valueForKey:@"like"];
                NSMutableArray *tempComments = [NSMutableArray new];
                for (int i = 0; i < array.count; i++) {
                    NSDictionary * dic = array[i];
                    SDTimeLineCellLikeItemModel * likeItemModel = [[SDTimeLineCellLikeItemModel alloc]init];
                    likeItemModel.userId=DICVFK(dic, @"uid");
                    likeItemModel.userName =DICVFK(dic, @"name");
                    [tempComments addObject:likeItemModel];
                    
                }
                
                model.likeItemsArray = tempComments;
                
                //评论列表
                array = [dic valueForKey:@"comment"];
                
                tempComments = [NSMutableArray new];
                for (int i = 0; i < array.count; i++) {
                    NSDictionary * dic = array[i];
                    
                    SDTimeLineCellCommentItemModel *commentItemModel = [SDTimeLineCellCommentItemModel new];
                    commentItemModel.firstUserName = DICVFK(dic, @"name");
                    commentItemModel.firstUserId = DICVFK(dic, @"id");
                    commentItemModel.secondUserName = DICVFK(dic, @"at_name");
                    commentItemModel.secondUserId = DICVFK(dic, @"at_uid");
                    commentItemModel.commentString = DICVFK(dic, @"content");
                    [tempComments addObject:commentItemModel];
                }
                model.commentItemsArray = [tempComments copy];
                
                
                [modelArray addObject:model];
            }
            
            if (isRefresh) {
                self.dataArray = modelArray;
            }else{
                if (self.dataArray) {
                    [self.dataArray addObjectsFromArray:modelArray];
                    [self.tableView reloadData];
                }else{
                    self.dataArray = modelArray;
                }
            }
            
            
            if (curentPage == 0 && tempArray && tempArray.count>0) {
                //缓存离线数据
            }
            
            //保存数据
            if (isRefresh) {
                [self.tableView.header endRefreshing];
            }else{
                [self.tableView.footer endRefreshing];
            }
            if ([code integerValue]==2) {
                [[DialogUtil sharedInstance]showDlg:self.view textOnly:@"已加载全部数据"];
            }
            [[DialogUtil sharedInstance]showDlg:self.view textOnly:[dic valueForKey:@"msg"]];
            //            self.startLoading = NO;
            //移除重新加载数据监听
            [[NSNotificationCenter defaultCenter]removeObserver:self name:@"reloadData" object:nil];
            
            //关闭加载动画
            self.startLoading = NO;
        }else if([code intValue]==-1){
            //添加重新加载数据监听
            [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(loadData) name:@"reloadData" object:nil];
            //通知系统重新登录
            [[NSNotificationCenter defaultCenter]postNotificationName:@"login" object:nil];
        }else{
            self.isNetRequestError = YES;
        }
    }else{
        self.isNetRequestError = YES;
    }
}
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
//            headerView.headerBackView.image  =[TDUtil loadContent:STATIC_USER_BACKGROUND_PIC];
        }
        
        [[DialogUtil sharedInstance]showDlg:self.view textOnly:[jsonDic valueForKey:@"msg"]];
    }
}

-(void)requestReply:(ASIHTTPRequest*)request
{
    NSString* jsonString = [TDUtil convertGBKDataToUTF8String:request.responseData];
    
    NSLog(@"返回:%@",jsonString);
    NSMutableDictionary * dic =[jsonString JSONValue];
    if (dic!=nil) {
        NSString* status = [dic valueForKey:@"code"];
        if ([status integerValue] ==0) {
            [self.tableView reloadData];
        }
        [[DialogUtil sharedInstance]showDlg:self.view textOnly:[dic valueForKey:@"msg"]];
    }
}

-(void)requestPublishContent:(ASIHTTPRequest*)request
{
    NSString* jsonString = [TDUtil convertGBKDataToUTF8String:request.responseData];
    
    NSLog(@"返回:%@",jsonString);
    NSMutableDictionary * dic =[jsonString JSONValue];
    if (dic!=nil) {
        NSString* code = [dic valueForKey:@"code"];
        if ([code integerValue] == 0) {
            NSDictionary* dataDic = [dic valueForKey:@"data"];
            
            
//            Demo9Model *model = [Demo9Model new];
//            model.id = [[dataDic valueForKey:@"id"] integerValue];
//            model.uid = [[dataDic valueForKey:@"uid"] integerValue];
//            model.isLike = [[dataDic valueForKey:@"is_like"] boolValue];
//            model.name = [dataDic valueForKey:@"name"];
//            model.address = [dataDic valueForKey:@"addr"];
//            model.iconName = [dataDic valueForKey:@"photo"];
//            model.content = [dataDic valueForKey:@"content"];
//            model.position = [dataDic valueForKey:@"position"];
//            model.dateTime = [dataDic valueForKey:@"datetime"];
//            
//            //分享
//            NSDictionary* dicShare =[dataDic valueForKey:@"share"];
//            if (dicShare) {
//                model.shareDic=dicShare;
//            }
//            
//            //图片
//            NSArray* array = [dataDic valueForKey:@"pic"];
//            if (array && array.count>0) {
//                model.picNamesArray =array;
//            }
//            
//            //评论列表
//            array = [dataDic valueForKey:@"comment"];
//            model.commentArray = array;
//            
//            //点赞列表
//            array = [dataDic valueForKey:@"like"];
//            model.likersArray = array;
//            
//            [self.dataArray replaceObjectAtIndex:0 withObject:model];
//            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForItem:0 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        }
        
        self.startLoading = NO;
        [[DialogUtil sharedInstance]showDlg:self.view textOnly:[dic valueForKey:@"msg"]];
    }
}


-(void)requestFailed:(ASIFormDataRequest*)request
{
    [self.tableView.header endRefreshing];
    [self.tableView.footer endRefreshing];
    self.isNetRequestError = YES;
}

@end
