//
//  DomesticCityModel.m
//  city_search
//
//  Created by apple on 2018/11/29.
//  Copyright © 2018年 张磊. All rights reserved.
//

#import "DomesticCityModel.h"

@implementation DomesticCityModel
- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    
}

- (void)setCity:(NSMutableArray *)city {
    if (_city != city) {
        _city = city;
    }
    NSMutableArray *tempArray = @[].mutableCopy;
    for (NSDictionary *dic in _city) {
        AllModel *model = [AllModel new];
//        [model setValuesForKeysWithDictionary:dic];
        model.cityId = dic[@"id"];
        model.name = dic[@"name"];
        [tempArray addObject:model];
    }
    _city = [NSMutableArray arrayWithArray:tempArray];
}

@end
@implementation AllModel

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
//    if ([key isEqualToString:@"id"]) {
//        self.cityId = value;
//    }
}
@end
