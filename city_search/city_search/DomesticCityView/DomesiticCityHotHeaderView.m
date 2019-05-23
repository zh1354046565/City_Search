//
//  DomesiticCityHotHeaderView.m
//  city_search
//
//  Created by apple on 2018/11/29.
//  Copyright © 2018年 张磊. All rights reserved.
//

#import "DomesiticCityHotHeaderView.h"

@interface DomesiticCityHotHeaderView()

@end
@implementation DomesiticCityHotHeaderView

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)headerViewTitle:(NSString *)title hasBGColor:(BOOL)hasBGColor {
    if (hasBGColor) {
        self.titleL.backgroundColor = [UIColor whiteColor];
    }else {
        self.titleL.backgroundColor = [UIColor groupTableViewBackgroundColor];
    }
    self.titleL.text = title;
}

@end
