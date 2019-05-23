//
//  CityChooseDataBase.h
//  city_search
//
//  Created by apple on 2018/11/29.
//  Copyright © 2018年 张磊. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DomesticCityModel.h"

@interface CityChooseDataBase : NSObject

+ (instancetype)shareDataBase;
- (void)openDB;
- (void)createTable;
- (void)insertCity:(AllModel *)model userName:(NSString *)userName;
- (NSMutableArray *)selectCity:(NSString *)userName;
- (void)deleteCity:(NSString *)cityName;
- (void)dropTable;
@end
