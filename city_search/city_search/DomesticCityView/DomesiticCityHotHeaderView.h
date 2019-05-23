//
//  DomesiticCityHotHeaderView.h
//  city_search
//
//  Created by apple on 2018/11/29.
//  Copyright © 2018年 张磊. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DomesiticCityHotHeaderView : UICollectionReusableView


@property (weak, nonatomic) IBOutlet UILabel *titleL;

- (void)headerViewTitle:(NSString *)title hasBGColor:(BOOL)hasBGColor;

@end
