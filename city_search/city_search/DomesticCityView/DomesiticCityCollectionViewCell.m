//
//  DomesiticCityCollectionViewCell.m
//  city_search
//
//  Created by apple on 2018/11/29.
//  Copyright © 2018年 张磊. All rights reserved.
//

#import "DomesiticCityCollectionViewCell.h"

@interface DomesiticCityCollectionViewCell()

@property (weak, nonatomic) IBOutlet UILabel *nameL;

@end
@implementation DomesiticCityCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}


- (void)setModelss:(AllModel *)modelss {
    self.nameL.text = modelss.name;
}


@end

