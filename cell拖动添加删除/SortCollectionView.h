//
//  SortCollectionView.h
//  cell拖动添加删除
//
//  Created by Beepay001 on 2019/3/12.
//  Copyright © 2019 weiguang. All rights reserved.
//

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
