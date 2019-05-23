//
//  DomesiticCityAllCell.m
//  city_search
//
//  Created by apple on 2018/11/29.
//  Copyright © 2018年 张磊. All rights reserved.
//

#import "DomesiticCityAllCell.h"

@interface DomesiticCityAllCell()
@property (weak, nonatomic) IBOutlet UILabel *cityL;
@end
@implementation DomesiticCityAllCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setModel:(AllModel *)model {
    self.cityL.text = model.name;
}

@end

