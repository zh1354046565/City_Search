//
//  ViewController.m
//  city_search
//
//  Created by apple on 2018/11/28.
//  Copyright © 2018年 张磊. All rights reserved.
//

#import "ViewController.h"
#import "CitySearchViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CitySearchViewController *vc = [CitySearchViewController new];
    vc.getCityNameBlock = ^(NSString *string) {
        
        NSLog(@"回调回来的city:%@",string);
    };
    [self.navigationController pushViewController:vc animated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
