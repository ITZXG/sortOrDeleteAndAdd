

#import "SortCollectionView.h"
#import "AppCollectionViewCell.h"


static NSString *identifier = @"AppsCell";

static CGFloat itemMargin = 15;
static CGFloat leftMargin = 5;

@interface SortCollectionView ()<UICollectionViewDataSource>

@property (nonatomic,strong) UILongPressGestureRecognizer *longPress;
@property (nonatomic, strong) NSIndexPath *originalIndexPath;
@property (nonatomic, weak) UIView *tempMoveCell;
@property (nonatomic, assign) CGPoint lastPoint;
@property (nonatomic, strong) NSIndexPath *moveIndexPath;
@end
@implementation SortCollectionView
- (instancetype)initWithCustomFrame:(CGRect)frame {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    CGFloat itemH = ([UIScreen mainScreen].bounds.size.width - 3 * itemMargin - 2 * leftMargin) / 4;
    layout.itemSize = CGSizeMake(itemH, itemH);
    layout.minimumLineSpacing = itemMargin;
    layout.minimumInteritemSpacing = itemMargin;
    self.collectionViewLayout = layout;
   return [self initWithFrame:frame collectionViewLayout:layout];
}

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout {
    if (self = [super initWithFrame:frame collectionViewLayout:layout]) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    _isEditing = NO;
    self.backgroundColor = RGB(238, 238, 244);
    self.alwaysBounceVertical = YES;
    
    _longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressMoving:)];
    _longPress.minimumPressDuration = 1.0;
    [self addGestureRecognizer:_longPress];
    
    // 如果使用storyboard来加载cell就不要在注册了，否则会调用initWithFrame方法，重新加载一遍
    [self registerClass:[AppCollectionViewCell class] forCellWithReuseIdentifier:identifier];
    
    // 在storyboard中已设置过dataSource和delegate
    //_collectionView.dataSource = self;
//    self.contentInset = UIEdgeInsetsMake(leftMargin, leftMargin, 0, leftMargin);
    self.dataSource = self;
}


#pragma mark - 长按cell进入编辑状态，可以进行移动删除操作
- (void)longPressMoving:(UILongPressGestureRecognizer *)longPress {
    switch (longPress.state) {
        case UIGestureRecognizerStateBegan:
        {
            //获取当前手指长按的cell的indexPath
            _originalIndexPath = [self indexPathForItemAtPoint:[longPress locationInView:self]];
            if (_originalIndexPath.row > _viewModels.count) {
                return;
            }
            
            if (!_isEditing) {
                [self enterEditingModel];
            }
            
            //获取到手指所在cell
            AppCollectionViewCell *cell = (AppCollectionViewCell *)[self cellForItemAtIndexPath:_originalIndexPath];
            
            //生成一个和cell一样的view，类似于生成快照
            UIView *cellView = [self viewFromCell:cell];
            // 生成cellView一样的image
            UIImage *cellImage = [self imageFromView:cellView];
            UIImageView *snapView = [[UIImageView alloc] initWithImage:cellImage];
            // 临时cell
            _tempMoveCell = snapView;
            _tempMoveCell.frame = cell.frame;
            
            // 当前的真实cell隐藏,表面上显示的临时的cell
            cell.hidden = YES;
            [self addSubview:_tempMoveCell];
            
            _lastPoint = [longPress locationOfTouch:0 inView:longPress.view];
            
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            // 当前cell移动的相对距离
            CGFloat tranX = [longPress locationOfTouch:0 inView:longPress.view].x - _lastPoint.x;
            CGFloat tranY = [longPress locationOfTouch:0 inView:longPress.view].y - _lastPoint.y;
            /*
             函数说明：某点通过矩阵变换之后的点
             CGPoint CGPointApplyAffineTransform(CGPoint point, CGAffineTransform t)
             point:某点
             t:变换矩阵
             
             相对平移函数：(相对的是屏幕的左上角(0,0)点)
             CGAffineTransformMakeTranslation(CGFloat tx,CGFloat ty)
             */
            
            _tempMoveCell.center = CGPointApplyAffineTransform(_tempMoveCell.center, CGAffineTransformMakeTranslation(tranX, tranY));
            _lastPoint = [longPress locationOfTouch:0 inView:longPress.view];
            // 移动cell
            [self moveCell];
            
        }
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        {
            if (_originalIndexPath.row > _viewModels.count) {
                return;
            }
            AppCollectionViewCell *cell = (AppCollectionViewCell *)[self cellForItemAtIndexPath:_originalIndexPath];
            self.userInteractionEnabled = NO;
            cell.hidden = NO;
            cell.alpha = 0.0;
            
            [UIView animateWithDuration:0.25 animations:^{
                _tempMoveCell.center = cell.center;
                _tempMoveCell.alpha = 0.0;
                cell.alpha = 1.0;
                
            } completion:^(BOOL finished) {
                [_tempMoveCell removeFromSuperview];
                _originalIndexPath = nil;
                _tempMoveCell = nil;
                self.userInteractionEnabled = YES;
                
            }];
            
        }
            break;
        default:
            break;
    }
}

- (void)moveCell{
    for (AppCollectionViewCell *cell in [self visibleCells]) {
        NSIndexPath *index = [self indexPathForCell:cell];
        if (index == _originalIndexPath) {
            continue;
        }
        //计算中心距
        CGFloat spacingX = fabs(_tempMoveCell.center.x - cell.center.x);
        CGFloat spacingY = fabs(_tempMoveCell.center.y - cell.center.y);
        if (spacingX <= _tempMoveCell.bounds.size.width / 2.0f && spacingY <= _tempMoveCell.bounds.size.height / 2.0f) {
            _moveIndexPath = [self indexPathForCell:cell];
            if (_moveIndexPath.row<_viewModels.count) { //超出cell范围时移动会崩溃
                //更新数据源
                [self updateDataSource];
                //移动
                [self moveItemAtIndexPath:_originalIndexPath toIndexPath:_moveIndexPath];
                //设置移动后的起始indexPath
                _originalIndexPath = _moveIndexPath;
            }
            
            break;
        }
    }
    
}



//更新数据源
- (void)updateDataSource{
    NSMutableArray *temp = @[].mutableCopy;
    [temp addObjectsFromArray:_viewModels];
    if (_moveIndexPath.item > _originalIndexPath.item) {
        for (NSUInteger i = _originalIndexPath.item; i < _moveIndexPath.item ; i++) {
            [temp exchangeObjectAtIndex:i withObjectAtIndex:i + 1];
        }
    }else{
        for (NSUInteger i = _originalIndexPath.item; i > _moveIndexPath.item ; i--) {
            [temp exchangeObjectAtIndex:i withObjectAtIndex:i - 1];
        }
    }
    _viewModels = temp.mutableCopy;
}


#pragma mark - App editing
// 进入编辑状态
- (void)enterEditingModel{
    _isEditing = YES;
    if (self.startEditBLock) {
        self.startEditBLock();
    }
//    rightButton.hidden = NO;
    _longPress.minimumPressDuration = 0.5;
    
    for (AppCollectionViewCell *cell in [self visibleCells]) {
        cell.deleteBtn.hidden = NO;
    }
    
}

- (void)stopEditingModel {
    _isEditing = NO;
    _longPress.minimumPressDuration = 1.0;
    if (self.endEditBLock) {
        self.endEditBLock();
    }
//    rightButton.hidden = YES;
    
    for (AppCollectionViewCell *cell in [self visibleCells]) {
        cell.deleteBtn.hidden = YES;
    }
}


#pragma mark - 生成一个和当前cell一样的view
- (UIView *)viewFromCell:(AppCollectionViewCell *)cell {
    
    UIView *view = [[UIView alloc] initWithFrame:cell.frame];
    view.backgroundColor = RGB(230, 230, 230);
    
    UIImageView *appImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width/3, cell.frame.size.width/3)];
    appImageView.image = cell.appImageView.image;
    appImageView.center = CGPointMake(cell.frame.size.width / 2.0, cell.frame.size.height / 2.0 - 10);
    [view addSubview:appImageView];
    
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width, 20)];
    nameLabel.backgroundColor = [UIColor clearColor];
    nameLabel.font = [UIFont boldSystemFontOfSize:12.0];
    nameLabel.text = cell.nameLabel.text;
    nameLabel.textAlignment = NSTextAlignmentCenter;
    nameLabel.textColor = RGB(55, 55, 55);
    nameLabel.center = CGPointMake(cell.frame.size.width / 2.0, appImageView.frame.origin.y + appImageView.frame.size.height + nameLabel.frame.size.height / 2.0 + 3);
    [view addSubview:nameLabel];
    
    
    UIButton *deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [deleteBtn setImage:[UIImage imageNamed:@"shanchu"] forState:UIControlStateNormal];
    deleteBtn.frame = CGRectMake(cell.frame.size.width - 30, 0, 30, 30);
    deleteBtn.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
    deleteBtn.hidden = NO;
    [view addSubview:deleteBtn];
    
    return view;
}

#pragma mark - 根据生成的临时View转成image
- (UIImage *)imageFromView:(UIView *)snapView {
    UIGraphicsBeginImageContext(snapView.frame.size);
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    [snapView.layer renderInContext:contextRef];
    UIImage *targetImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return targetImage;
}


#pragma mark -  UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return _viewModels.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    AppCollectionViewCell *cell = (AppCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    DataModel *model = _viewModels[indexPath.item];
    [cell showInfoWithModel:model];
    
    [cell.deleteBtn addTarget:self action:@selector(deleteButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    if (_isEditing) {
        cell.deleteBtn.hidden = NO;
    } else {
        cell.deleteBtn.hidden = YES;
    }
    
    return cell;
}

#pragma mark - 按钮点击事件监听
// 点击删除按钮，删除应用
- (void)deleteButtonPressed:(id)sender{
    AppCollectionViewCell *cell = (AppCollectionViewCell *)[sender superview].superview;
    NSIndexPath *indexPath = [self indexPathForCell:cell];
    
    [_viewModels removeObjectAtIndex:indexPath.row];
    
    [self reloadData];
}


@end
