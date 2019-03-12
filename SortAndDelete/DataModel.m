

#import "DataModel.h"

@implementation DataModel

- (instancetype)initWith:(NSDictionary *)dict {
    
    self = [super init];
    if (self) {
        [self setValuesForKeysWithDictionary:dict];
    }
    
    return self;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
    
}

+(instancetype)initWithDict:(NSDictionary *)dict{

    return [[self alloc] initWith:dict];
}

@end
