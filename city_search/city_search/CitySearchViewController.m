//
//  CitySearchViewController.m
//  city_search
//
//  Created by apple on 2018/11/28.
//  Copyright © 2018年 张磊. All rights reserved.
//

#import "CitySearchViewController.h"
#import "HMSegmentedControl.h"
#import "DomesticCityViewController.h"
#import "CityViewController.h"
#import "DomesticCityModel.h"
#import "CityChooseDataBase.h"

#define SCREEN_HEIGHT                      [UIScreen mainScreen].bounds.size.height
#define SCREEN_WIDTH                       [UIScreen mainScreen].bounds.size.width
//状态栏与导航栏高度
#define kStatusBarHeight [[UIApplication sharedApplication] statusBarFrame].size.height
#define kNavBarHeight 44.0
#define headerHeight 60
#define segmentHeight 50

#define CATEGORY @[@"国内", @"国际/港澳"]
@interface CitySearchViewController ()<UISearchBarDelegate,UIScrollViewDelegate,UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate>

@property (nonatomic, strong) HMSegmentedControl *segmentControl;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UIScrollView *bottomScrollView;
@property (nonatomic, strong) UIView *searchView;
@property (nonatomic, strong) UITableView *searchTableV;
@property (nonatomic, strong) NSMutableArray *resultArray;
@property (nonatomic, strong) UITextField *searchField;
@property (nonatomic, strong) NSMutableArray *allArray;
@property (nonatomic, strong) NSMutableArray *dataArr;
@property (nonatomic, strong) NSMutableArray *historyArr;
@property (nonatomic, strong) UILabel *resultLable;
@end

@implementation CitySearchViewController

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.translucent = NO;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.navigationItem.title = @"城市选择";
    [self searchBox];
    [self.view addSubview:self.segmentControl];
    _searchView = [[UIView alloc]initWithFrame:CGRectMake(0, headerHeight, SCREEN_WIDTH, SCREEN_HEIGHT - headerHeight - kNavBarHeight - kStatusBarHeight)];
    _searchView.hidden = YES;
    [self.view addSubview:self.searchView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction)];
    tap.delegate = self;
    [_searchView addGestureRecognizer:tap];
    [self.searchView addSubview:self.searchTableV];
//    [[CityChooseDataBase shareDataBase] dropTable];
    [[CityChooseDataBase shareDataBase] openDB];
    [[CityChooseDataBase shareDataBase] createTable];
    
    self.historyArr = [[CityChooseDataBase shareDataBase]selectCity:@"123"];
    //将数组倒序
    self.historyArr = (NSMutableArray *)[[self.historyArr reverseObjectEnumerator] allObjects];
    if (self.historyArr.count > 0) {
        NSDictionary *dicAll = @{
                                 @"initial": @"最近常用",
                                 @"city": self.historyArr,
                                 @"hasBGColor": @(YES),
                                 };
        DomesticCityModel *modelAll = [DomesticCityModel new];
        [modelAll setValuesForKeysWithDictionary:dicAll];
        [self.allArray addObject:modelAll];
    }
    [self getData];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(getCityName:) name:@"getCityName" object:nil];
}

- (void)getCityName:(NSNotification *)notif {
    if (_getCityNameBlock) {
        _getCityNameBlock(notif.object[@"cityName"]);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"getCityName" object:nil];
}
#pragma mark -
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch  {
    //点击的view的类名
    NSLog(@"%@", NSStringFromClass([touch.view class]));
    // UITableViewCellContentView就是点击了tableViewCell，则不截获点击事件
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"]){
        return NO;
    }
    return  YES;
}

//轻拍手势方法执行
- (void)tapAction {
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.5 animations:^{
        [weakSelf.searchBar resignFirstResponder];
        weakSelf.searchView.hidden = YES;
    }];
}

#pragma mark - lazy
- (NSMutableArray *)resultArray {
    if (!_resultArray) {
        _resultArray = @[].mutableCopy;
    }
    return _resultArray;
}

- (NSMutableArray *)allArray {
    if (!_allArray) {
        _allArray = @[].mutableCopy;
    }
    return _allArray;
}

- (NSMutableArray *)dataArr {
    if (!_dataArr) {
        _dataArr = @[].mutableCopy;
    }
    return _dataArr;
}

- (NSMutableArray *)historyArr {
    if (!_historyArr) {
        _historyArr = @[].mutableCopy;
    }
    return _historyArr;
}

- (void)searchBox {
    UIView *titleView = [[UIView alloc] init];
    titleView.frame = CGRectMake(0, 0, SCREEN_WIDTH, headerHeight);
    titleView.backgroundColor = [UIColor blueColor];
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(10, 0, SCREEN_WIDTH-80, headerHeight)];
    [titleView addSubview:searchBar];
    titleView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:titleView];
    // 关闭自动调整
    searchBar.translatesAutoresizingMaskIntoConstraints = NO;
    searchBar.placeholder = @"请输入城市名称";
    searchBar.delegate = self;
    self.searchBar = searchBar;
    [[[[searchBar.subviews objectAtIndex:0] subviews] objectAtIndex:0] removeFromSuperview];
    [searchBar setBackgroundColor:[UIColor clearColor]];
    searchBar.returnKeyType = UIReturnKeySearch;
    [searchBar setPositionAdjustment:UIOffsetMake(10, 0) forSearchBarIcon:UISearchBarIconSearch];
    searchBar.searchBarStyle = UISearchBarStyleProminent;
    UITextField *searchField = [searchBar valueForKey:@"searchField"];
    if (searchField) {
        CGRect rect  = searchField.leftView.frame;
        rect = CGRectMake(0, 0, 15, 15);
        searchField.leftView.frame = rect;
        [searchField setBackgroundColor:[UIColor whiteColor]];
        searchField.layer.masksToBounds = YES;
        searchField.layer.cornerRadius = 18;
//        searchField.returnKeyType = UIReturnKeySearch;
        [searchField setTintColor:[UIColor blueColor]];
    }
    _searchField = searchField;
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(SCREEN_WIDTH-70, 0, 70, headerHeight);
    [button setTitle:@"搜索" forState:UIControlStateNormal];
    button.titleLabel.textColor = [UIColor whiteColor];
    button.titleLabel.font = [UIFont boldSystemFontOfSize:19.f];
    [titleView addSubview:button];
    [button addTarget:self action:@selector(searchBtnSender) forControlEvents:(UIControlEventTouchUpInside)];
}

- (UITableView *)searchTableV {
    if (!_searchTableV) {
        _searchTableV = [[UITableView alloc]initWithFrame:self.searchView.bounds style:(UITableViewStylePlain)];
        _searchTableV.dataSource = self;
        _searchTableV.delegate = self;
        _searchTableV.tableFooterView = [UIView new];
        _searchTableV.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        [_searchTableV registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    }
    return _searchTableV;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.resultArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = [self.resultArray[indexPath.row] name];
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}

- (BOOL)traverseHistoryArrDeleteRepeatCity:(NSString *)cityName {
    for (int i = 0; i<self.historyArr.count; i++) {
        if ([[self.historyArr[i] objectForKey:@"name"] isEqualToString:cityName]) {
            return YES;
        }
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.searchBar resignFirstResponder];
    _searchView.hidden = YES;
    SearchModel *model = self.resultArray[indexPath.row];
    BOOL jjj = [self traverseHistoryArrDeleteRepeatCity:model.name];
    if (jjj) {
        AllModel *allModel = [AllModel new];
        allModel.name = model.name;
        allModel.cityId = model.cityId;
        [[CityChooseDataBase shareDataBase]deleteCity:model.name];
        [[CityChooseDataBase shareDataBase]insertCity:allModel userName:@"123"];
    }
    if (_getCityNameBlock) {
        _getCityNameBlock(model.name);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

/*搜索点击方法*/
- (void)searchBtnSender {
    NSLog(@"----%@",self.searchField.text);
    [UIView animateWithDuration:0.5 animations:^{
        [self.view bringSubviewToFront:self.searchView];
        self.searchView.hidden = NO;
    }];
    NSString *dd = self.searchField.text;
    [self.resultArray removeAllObjects];
    dispatch_queue_t globalQueue = dispatch_get_global_queue(0, 0);
    dispatch_async(globalQueue, ^{
        if (dd!=nil && dd.length>0) {
            for (SearchModel *model in self.dataArr) {
                NSString *tempStr = model.name;
                //--------把所有的搜索结果转成成拼音
                NSString *pinyin = [self transformToPinyin:tempStr];
                //                NSLog(@"pinyin--%@",pinyin);
                if ([pinyin rangeOfString:dd options:NSCaseInsensitiveSearch].length >0 ) {
                    //把搜索结果存放self.resultArray数组
                    [self.resultArray addObject:model];
                }
            }
        }else{
            //            self.resultArray = [NSMutableArray arrayWithArray:self.dataArray];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.resultArray.count > 0) {
                [self.resultLable removeFromSuperview];
            }else {
                [self.resultLable removeFromSuperview];
                [self setupNoSearchResult];
            }
            [self.searchBar resignFirstResponder];
            [self.searchTableV reloadData];
        });
    });
}

- (void)setupNoSearchResult {
    self.resultLable = [[UILabel alloc] init];
    self.resultLable.textAlignment = NSTextAlignmentCenter;
    self.resultLable.textColor = [UIColor colorWithRed:128/255.f green:128/255.f blue:128/255.f alpha:1];
    self.resultLable.font = [UIFont boldSystemFontOfSize:16.f];
    self.resultLable.text = @"没有搜索到该城市!";
    self.resultLable.numberOfLines = 0;
    self.resultLable.center = CGPointMake(self.searchTableV.center.x, self.searchTableV.center.y - 30);
    self.resultLable.bounds = CGRectMake(0, 0, 240, 52);
    [self.searchTableV addSubview:self.resultLable];
}

- (void)setupChilldController {
    _bottomScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, segmentHeight+headerHeight, SCREEN_WIDTH, SCREEN_HEIGHT-segmentHeight-headerHeight-kNavBarHeight-kStatusBarHeight)];
    _bottomScrollView.translatesAutoresizingMaskIntoConstraints = NO;
    _bottomScrollView.delegate = self;
    _bottomScrollView.contentSize = CGSizeMake(2 * SCREEN_WIDTH, 0.1);
    _bottomScrollView.showsHorizontalScrollIndicator = NO;
    _bottomScrollView.pagingEnabled = YES;
    [self.view addSubview:_bottomScrollView];
    /*********/
    DomesticCityViewController *domesticCityVC = [DomesticCityViewController new];
    [self addChildViewController:domesticCityVC];
    domesticCityVC.historyArr = self.historyArr;
    domesticCityVC.allArray = self.allArray;
    domesticCityVC.view.frame = CGRectMake(0, 0, SCREEN_WIDTH, CGRectGetHeight(_bottomScrollView.frame));
    [_bottomScrollView addSubview:domesticCityVC.view];
    CityViewController *cityVC = [CityViewController new];
    [self addChildViewController:cityVC];
    cityVC.view.frame = CGRectMake(SCREEN_WIDTH, 0, SCREEN_WIDTH, CGRectGetHeight(_bottomScrollView.frame));
    [_bottomScrollView addSubview:cityVC.view];
}








- (HMSegmentedControl *)segmentControl {
    if (!_segmentControl) {
        _segmentControl = [[HMSegmentedControl alloc]initWithFrame:CGRectMake(0, headerHeight, SCREEN_WIDTH, segmentHeight)];
        _segmentControl.sectionTitles = CATEGORY;
        _segmentControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
        _segmentControl.selectionIndicatorHeight = 3;
        _segmentControl.selectionStyle = HMSegmentedControlSelectionStyleFullWidthStripe;
        _segmentControl.selectionIndicatorColor = [UIColor blueColor];
        _segmentControl.segmentEdgeInset = UIEdgeInsetsMake(0, 15, 0, 15);
        [_segmentControl setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor lightGrayColor],NSFontAttributeName:[UIFont systemFontOfSize:17.f]}];
        [_segmentControl setSelectedTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor blueColor],NSFontAttributeName:[UIFont systemFontOfSize:19.f]}];
        [_segmentControl addTarget:self action:@selector(titleSegmentControlChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return _segmentControl;
}

#pragma mark - 点击选项卡方法
- (void)titleSegmentControlChanged:(HMSegmentedControl *)segmentedControl {
    _bottomScrollView.contentOffset = CGPointMake(SCREEN_WIDTH*segmentedControl.selectedSegmentIndex, 0);
    [self.segmentControl setSelectedSegmentIndex:segmentedControl.selectedSegmentIndex animated:YES];
}

#pragma mark - scrollDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    double dindex = scrollView.contentOffset.x/SCREEN_WIDTH;
    NSInteger index = (NSInteger)(dindex+0.5);
    if (index == self.segmentControl.selectedSegmentIndex) {
        return;
    }
    [self.segmentControl setSelectedSegmentIndex:index animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.searchBar resignFirstResponder];
}

#pragma mark - UISearchBarDelegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [UIView animateWithDuration:0.5 animations:^{
        [self.view bringSubviewToFront:self.searchView];
        self.searchView.hidden = NO;
    }];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    //将键盘搜索与按钮"搜索"关联
    [self searchBtnSender];
}

- (NSString *)transformToPinyin:(NSString *)aString
{
    //转成了可变字符串
    NSMutableString *str = [NSMutableString stringWithString:aString];
    CFStringTransform((CFMutableStringRef)str,NULL, kCFStringTransformMandarinLatin,NO);
    
    //再转换为不带声调的拼音
    CFStringTransform((CFMutableStringRef)str,NULL, kCFStringTransformStripDiacritics,NO);
    NSArray *pinyinArray = [str componentsSeparatedByString:@" "];
    NSMutableString *allString = [NSMutableString new];
    int count = 0;
    for (int  i = 0; i < pinyinArray.count; i++)
    {
        for(int i = 0; i < pinyinArray.count;i++)
        {
            if (i == count) {
                [allString appendString:@"#"];
                //区分第几个字母
            }
            [allString appendFormat:@"%@",pinyinArray[i]];
        }
        [allString appendString:@","];
        count ++;
    }
    NSMutableString *initialStr = [NSMutableString new];
    //拼音首字母
    for (NSString *s in pinyinArray)
    {
        if (s.length > 0)
        {
            [initialStr appendString:  [s substringToIndex:1]];
        }
    }
    [allString appendFormat:@"#%@",initialStr];
    [allString appendFormat:@",#%@",aString];
    return allString;
}

- (void)getData {
    NSString *jsonString = [[NSBundle mainBundle]pathForResource:@"domestic_city" ofType:@"json"];
    NSData *jsonData = [NSData dataWithContentsOfFile:jsonString];
    NSDictionary *dataDic = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:nil];
    NSMutableArray *hotArray = @[].mutableCopy;
    if ([dataDic[@"status"] isEqual:@(1)]) {
        for (NSDictionary *dic in dataDic[@"data"][@"hot"]) {
            [hotArray addObject:dic];
        }
        NSDictionary *dicHot = @{
                                 @"initial": @"热门城市",
                                 @"city": hotArray,
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
            /******存储搜索的总数据的数组*******/
            for (NSDictionary *searchDic in dic[@"city"]) {
                SearchModel *model = [SearchModel new];
                model.cityId = searchDic[@"id"];
                model.name = searchDic[@"name"];
                [self.dataArr addObject:model];
            }
        }
        /*******************************/
        [self setupChilldController];
    }
    
}

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
@implementation SearchModel
- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    if ([key isEqualToString:@"id"]) {
        self.cityId = value;
    }
}

@end
