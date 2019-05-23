//
//  CitySearchViewController.h
//  city_search
//
//  Created by apple on 2018/11/28.
//  Copyright © 2018年 张磊. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchModel : NSObject

@property (nonatomic, copy)NSString *cityId;

@property (nonatomic, copy)NSString *name;

@end
@interface CitySearchViewController : UIViewController


@property(nonatomic,copy)void(^getCityNameBlock)(NSString *string);

@end
