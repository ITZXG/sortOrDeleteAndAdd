

#import <UIKit/UIKit.h>

@interface DataModel : NSObject

@property (nonatomic,strong) NSString *imageName;

@property (nonatomic,strong) NSString *appName;


+(instancetype)initWithDict:(NSDictionary *)dict;

@end
