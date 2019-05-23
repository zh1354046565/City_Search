//
//  DomesticCityViewController.m
//  city_search
//
//  Created by apple on 2018/11/28.
//  Copyright © 2018年 张磊. All rights reserved.
//

#import "DomesticCityViewController.h"
#import "DomesiticCityCollectionViewCell.h"
#import "DomesiticCityHotHeaderView.h"
#import "DomesiticCityAllCell.h"
#import "CityChooseDataBase.h"
#import "DomesticCityModel.h"

#define SCREEN_HEIGHT                      [UIScreen mainScreen].bounds.size.height
#define SCREEN_WIDTH                       [UIScreen mainScreen].bounds.size.width
//状态栏与导航栏高度
#define kStatusBarHeight [[UIApplication sharedApplication] statusBarFrame].size.height
#define kNavBarHeight 44.0

@interface DomesticCityViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong)NSMutableArray *hotArray;


@property (nonatomic, strong)UICollectionView *collectionView;


@end

@implementation DomesticCityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    //
//    [[CityChooseDataBase shareDataBase] openDB];
//    [[CityChooseDataBase shareDataBase] createTable];
    
//    self.historyArr = [[CityChooseDataBase shareDataBase]selectCity:@"123"];
//    //将数组倒序
//    self.historyArr = (NSMutableArray *)[[self.historyArr reverseObjectEnumerator] allObjects];
//    if (self.historyArr.count > 0) {
//        NSDictionary *dicAll = @{
//                                 @"initial": @"最近常用",
//                                 @"city": self.historyArr,
//                                 @"hasBGColor": @(YES),
//                                 };
//        DomesticCityModel *modelAll = [DomesticCityModel new];
//        [modelAll setValuesForKeysWithDictionary:dicAll];
//        [self.allArray addObject:modelAll];
//    }
    
//    [self getData];
    [self setUI];
}

- (void)setUI {
    UICollectionViewFlowLayout *flowLayout = [UICollectionViewFlowLayout new];
    flowLayout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
    flowLayout.minimumLineSpacing = 10;
    flowLayout.minimumInteritemSpacing = 10;
    self.collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-110-kStatusBarHeight-kNavBarHeight) collectionViewLayout:flowLayout];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.collectionView registerNib:[UINib nibWithNibName:@"DomesiticCityCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"kDomesiticCityHotCell"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"DomesiticCityAllCell" bundle:nil] forCellWithReuseIdentifier:@"kDomesiticCityAllCell"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"DomesiticCityHotHeaderView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"kHotHeaderView"];
    [self.view addSubview:self.collectionView];
}

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    if ([self.allArray[indexPath.section] hasBGColor]) {
        DomesiticCityCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"kDomesiticCityHotCell" forIndexPath:indexPath];
        cell.modelss = [self.allArray[indexPath.section] city][indexPath.item];
        return cell;
    }else {
        DomesiticCityAllCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"kDomesiticCityAllCell" forIndexPath:indexPath];
        cell.model = [self.allArray[indexPath.section] city][indexPath.item];
        return cell;
    }
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView; {
    return self.allArray.count;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.allArray[section] city].count;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if (kind == UICollectionElementKindSectionHeader) {
        DomesiticCityHotHeaderView *headerV = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"kHotHeaderView" forIndexPath:indexPath];
        
        [headerV headerViewTitle:[self.allArray[indexPath.section] initial] hasBGColor:[self.allArray[indexPath.section] hasBGColor]];
        return headerV;
    }
    return nil;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(SCREEN_WIDTH-20, 40);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([self.allArray[indexPath.section] hasBGColor]) {
        return CGSizeMake((SCREEN_WIDTH-50)/3, 36);
    }else {
        return CGSizeMake(SCREEN_WIDTH-20, 36);
    }
    
    return CGSizeZero;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    AllModel *model = [self.allArray[indexPath.section] city][indexPath.row];
    if ([[self.allArray[indexPath.section] initial] isEqualToString:@"最近常用"]) {
        
    }else {
        BOOL jjj = [self traverseHistoryArrDeleteRepeatCity:model.name];
        if (jjj) {
            [[CityChooseDataBase shareDataBase]deleteCity:model.name];
            [[CityChooseDataBase shareDataBase]insertCity:model userName:@"123"];
        }else {
            [[CityChooseDataBase shareDataBase]insertCity:model userName:@"123"];
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"getCityName" object:@{@"cityName":model.name}];
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)traverseHistoryArrDeleteRepeatCity:(NSString *)cityName {
    for (int i = 0; i<self.historyArr.count; i++) {
        if ([[self.historyArr[i] objectForKey:@"name"] isEqualToString:cityName]) {
            return YES;
        }
    }
    return NO;
}

- (void)getData {
    NSString *jsonString = [[NSBundle mainBundle]pathForResource:@"domestic_city" ofType:@"json"];
    NSData *jsonData = [NSData dataWithContentsOfFile:jsonString];
    NSDictionary *dataDic = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:nil];
    if ([dataDic[@"status"] isEqual:@(1)]) {
        for (NSDictionary *dic in dataDic[@"data"][@"hot"]) {
            [self.hotArray addObject:dic];
        }
        NSDictionary *dicHot = @{
                              @"initial": @"热门城市",
                              @"city": self.hotArray,
                              @"hasBGColor": @(YES),
                              };
        DomesticCityModel *modelHot = [DomesticCityModel new];
        [modelHot setValuesForKeysWithDictionary:dicHot];
        [self.allArray addObject:modelHot];

        for (NSDictionary *dic in dataDic[@"data"][@"all"]) {
            NSDictionary *dicAll = @{
                                     @"initial":                dic[@"initial"],
                                     @"city": dic[@"city"],
                                     @"hasBGColor": @(NO),
                                     };
            DomesticCityModel *modelAll = [DomesticCityModel new];
            [modelAll setValuesForKeysWithDictionary:dicAll];
            [self.allArray addObject:modelAll];
        }
    }
}

//- (NSMutableArray *)historyArr {
//    if (!_historyArr) {
//        _historyArr = @[].mutableCopy;
//    }
//    return _historyArr;
//}

- (NSMutableArray *)hotArray {
    if (!_hotArray) {
        _hotArray = @[].mutableCopy;
    }
    return _hotArray;
}

//- (NSMutableArray *)allArray {
//    if (!_allArray) {
//        _allArray = @[].mutableCopy;
//    }
//    return _allArray;
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
