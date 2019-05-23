//
//  DomesticCityModel.h
//  city_search
//
//  Created by apple on 2018/11/29.
//  Copyright © 2018年 张磊. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DomesticCityModel : NSObject
@property (nonatomic, assign)BOOL hasBGColor;

@property (nonatomic, copy)NSString *initial;

@property (nonatomic, strong)NSMutableArray *city;

@end

@interface AllModel :NSObject

@property (nonatomic, copy)NSString *cityId;

@property (nonatomic, copy)NSString *name;

//@property (nonatomic, assign)BOOL itemColor;

@end




