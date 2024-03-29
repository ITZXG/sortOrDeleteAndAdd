

#define RGB(r,g,b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0]

#import <UIKit/UIKit.h>
#import "DataModel.h"

@interface AppCollectionViewCell : UICollectionViewCell

@property (nonatomic,strong) UIButton *deleteBtn;
@property (nonatomic,strong) UIImageView *appImageView;
@property (nonatomic,strong) UILabel *nameLabel;

- (void)showInfoWithModel:(DataModel *)model;

@end
