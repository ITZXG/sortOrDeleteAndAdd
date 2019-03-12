

#import "ViewController.h"
#import "AppCollectionViewCell.h"
#import "SortCollectionView.h"


static NSString *identifier = @"AppsCell";

static CGFloat itemMargin = 15;
static CGFloat leftMargin = 5;

@interface ViewController ()
{
    BOOL isEditing;
    UIButton *rightButton;
    UIButton *leftButton;
}

@property (nonatomic,strong) SortCollectionView *collectionView;
@property (nonatomic,strong) NSMutableArray *viewModels;
@property (nonatomic,strong) UILongPressGestureRecognizer *longPress;
@property (nonatomic, strong) NSIndexPath *originalIndexPath;
@property (nonatomic, weak) UIView *tempMoveCell;
@property (nonatomic, assign) CGPoint lastPoint;
@property (nonatomic, strong) NSIndexPath *moveIndexPath;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
    
    [self getData];
}

// 获取数据源，此处为固定的
- (void)getData{
   
    _viewModels = [NSMutableArray array];
    
    NSArray *dataArr = @[@{@"imageName" : @"icaiwuyun", @"appName" : @"财务云"}, @{@"imageName" : @"icbaobiao", @"appName" : @"报表"}, @{@"imageName" : @"icchanghongyouxiang", @"appName" : @"邮箱"}, @{@"imageName" : @"icfuwucaigou", @"appName" : @"服务采购"}, @{@"imageName" : @"icgongwenchengbao", @"appName" : @"呈报"}, @{@"imageName" : @"icrenwu", @"appName" : @"任务"}, @{@"imageName" : @"icshenghuofuwu", @"appName" : @"生活服务"}, @{@"imageName" : @"icshenpi", @"appName" : @"审批"}, @{@"imageName" : @"icwenjian", @"appName" : @"文件"}, @{@"imageName" : @"iczixun", @"appName" : @"资讯"},@{@"imageName" : @"more", @"appName" : @"更多"}];
    
    for (NSDictionary *dict in dataArr) {
        
        DataModel *model = [DataModel initWithDict:dict];
        [_viewModels addObject:model];
    }
    self.collectionView.viewModels = _viewModels;
    [self.collectionView reloadData];
}

// 设置UI界面
- (void)setupUI{
    
    SortCollectionView *collectionView = [[SortCollectionView alloc]initWithCustomFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    collectionView.startEditBLock = ^{
        rightButton.hidden = NO;
    };
    collectionView.endEditBLock = ^{
        rightButton.hidden = YES;
    };
    self.collectionView = collectionView;
    [self.view addSubview:collectionView];
    // 设置右边的item
    rightButton = [self setupBarButtonItem:@"完成"];
    [rightButton addTarget:self action:@selector(rightItemClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightItem;
    rightButton.hidden = YES;
    
    // 设置左边添加按钮
    leftButton = [self setupBarButtonItem:@"添加"];
    [leftButton addTarget:self action:@selector(leftItemClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *lefItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = lefItem;
}
#pragma mark - 生成左右button
- (UIButton *)setupBarButtonItem:(NSString *)title {
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 50, 30);
    [button setBackgroundColor:[UIColor clearColor]];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:16];
    
    return button;
}


- (void)rightItemClick{
    if (self.collectionView.isEditing) {
        [self.collectionView stopEditingModel];

    }

}

// 点击添加按钮，随机添加数据
- (void)leftItemClick {
    int x = arc4random() % _viewModels.count;
    DataModel *model = _viewModels[x];
    
    [_viewModels addObject:model];
    self.collectionView.viewModels = _viewModels;
    [self.collectionView reloadData];
}

@end
