

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^voidBlock)(void);

@interface SortCollectionView : UICollectionView

@property (nonatomic,assign) BOOL isEditing;
@property (nonatomic,strong) NSMutableArray *viewModels;
@property (nonatomic,copy) voidBlock startEditBLock;
@property (nonatomic,copy) voidBlock endEditBLock;
- (instancetype)initWithCustomFrame:(CGRect)frame;
- (void)stopEditingModel;
@end

NS_ASSUME_NONNULL_END
