//
//  CityChooseDataBase.m
//  city_search
//
//  Created by apple on 2018/11/29.
//  Copyright © 2018年 张磊. All rights reserved.
//

#import "CityChooseDataBase.h"
#import "FMDatabase.h"

@interface CityChooseDataBase()
@property (nonatomic, strong)FMDatabase *db;
@end
@implementation CityChooseDataBase

+ (instancetype)shareDataBase {
    static CityChooseDataBase *cityChooseDB = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cityChooseDB = [CityChooseDataBase new];
    });
    return cityChooseDB;
}

- (void)openDB {
    if (self.db != nil) {
        NSLog(@"数据开已经打开");
        return;
    }
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *fileName = [documentPath stringByAppendingPathComponent:@"history_city.sqlite"];
    self.db = [FMDatabase databaseWithPath:fileName];
    if ([self.db open]) {
        NSLog(@"数据库打开成功");
    }else {
        NSLog(@"数据库打开失败");
    }
}

- (void)createTable {
    BOOL result = [self.db executeUpdate:@"CREATE TABLE IF NOT EXISTS domesitic (id INTEGER PRIMARY KEY AUTOINCREMENT, cityId TEXT, name TEXT, parent_id TEXT, userName TEXT);"];
    if (result) {
        NSLog(@"创表成功");
    }else{
        NSLog(@"创表失败");
    }
}

- (void)insertCity:(AllModel *)model userName:(NSString *)userName {
    NSString *sql = [NSString stringWithFormat:@"INSERT INTO domesitic(cityId, name, userName) VALUES('%@', '%@', '%@')", model.cityId, model.name, userName];
    BOOL result = [self.db executeUpdate:sql];
    if (result) {
        NSLog(@"插入成功");
    }else{
        NSLog(@"插入失败");
    }
}

- (NSMutableArray *)selectCity:(NSString *)userName {
    NSMutableArray *array = @[].mutableCopy;
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM domesitic WHERE userName = '%@'", userName];
    FMResultSet *resultSet = [self.db executeQuery:sql];
    while ([resultSet next]) {
        NSString *cityId = [resultSet objectForColumn:@"cityId"];
        NSString *name = [resultSet objectForColumn:@"name"];
//        AllModel *model = [[AllModel alloc] init];
//        model.cityId = cityId;
//        model.name = name;
        NSDictionary *dic = @{@"name":name,
                              @"id":cityId,
                              };
        
        [array addObject:dic];
    }
    return array;
}

- (void)deleteCity:(NSString *)cityName {
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM domesitic WHERE name = '%@'", cityName];
    BOOL result = [self.db executeUpdate:sql];
    if (result) {
        NSLog(@"删除成功");
    } else {
        NSLog(@"删除失败");
    }
}

- (void)dropTable {
    NSString *sql = [NSString stringWithFormat:@"DROP TABLE domesitic"];
    BOOL result = [self.db executeUpdate:sql];
    if (result) {
        NSLog(@"删表成功");
    }else {
        NSLog(@"删表失败");
    }
}

@end
