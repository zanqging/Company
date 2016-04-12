#import "SDBaseTableViewController.h"
#import "RootViewController.h"
@interface SDTimeLineTableViewController : RootViewController
{
    BOOL isRefresh;
    BOOL isEndOfPageSize;
    int curentPage;
}
@property(retain,nonatomic)UITableView* tableView;
@property(retain, nonatomic) NSMutableArray * dataArray;
@end
