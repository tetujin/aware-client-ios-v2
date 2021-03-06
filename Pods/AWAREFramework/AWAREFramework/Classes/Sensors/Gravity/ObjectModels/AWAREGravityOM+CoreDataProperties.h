//
//  AWAREGravityOM+CoreDataProperties.h
//  
//
//  Created by Yuuki Nishiyama on 2019/12/10.
//
//

#import "AWAREGravityOM+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface AWAREGravityOM (CoreDataProperties)

+ (NSFetchRequest<AWAREGravityOM *> *)fetchRequest;

@property (nonatomic) int16_t accuracy;
@property (nullable, nonatomic, copy) NSString *device_id;
@property (nonatomic) double double_values_0;
@property (nonatomic) double double_values_1;
@property (nonatomic) double double_values_2;
@property (nullable, nonatomic, copy) NSString *label;
@property (nonatomic) int64_t timestamp;

@end

NS_ASSUME_NONNULL_END
