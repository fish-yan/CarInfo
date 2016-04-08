//
//  CarInfoViewController.m
//  CarInfo
//
//  Created by 薛焱 on 16/4/7.
//  Copyright © 2016年 薛焱. All rights reserved.
//

#import "CarInfoViewController.h"
#import "CarInfoCell.h"
#import "CarDetailViewController.h"
#import "DatePicker.h"

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define MARGIN -250

@interface CarInfoViewController ()<UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *queryViewTopMargin;
@property (weak, nonatomic) IBOutlet UITextField *beganTimeTF;
@property (weak, nonatomic) IBOutlet UITextField *endTimeTF;
@property (weak, nonatomic) IBOutlet UIView *maskView;
@property (weak, nonatomic) IBOutlet UIButton *addNewCarInfoBtn;

@property (nonatomic, strong) UITextField *currentTF;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) DatePicker *datePicker;
@end

@implementation CarInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _tableView.hidden = YES;
    _dataArray = [NSMutableArray array];
    _datePicker = [[NSBundle mainBundle]loadNibNamed:@"DatePicker" owner:self options:nil].lastObject;
    _datePicker.frame = CGRectMake(0, 0, kScreenWidth, 250);
    [_datePicker.cancelBtn addTarget:self action:@selector(cancelBtnAction:) forControlEvents:(UIControlEventTouchUpInside)];
    [_datePicker.commitBtn addTarget:self action:@selector(commiteBtnAction:) forControlEvents:(UIControlEventTouchUpInside)];
    _beganTimeTF.inputView = _datePicker;
    _endTimeTF.inputView = _datePicker;
    _addNewCarInfoBtn.layer.borderColor = UIColorFromRGB(0x2778D3).CGColor;
    _addNewCarInfoBtn.layer.borderWidth = 1;
    _addNewCarInfoBtn.layer.cornerRadius = 5;
    
    for (UIView *view in self.searchBar.subviews) {
        // for before iOS7.0
        if ([view isKindOfClass:NSClassFromString(@"UISearchBarBackground")]) {
            [view removeFromSuperview];
            break;
        }
        // for later iOS7.0(include)
        if ([view isKindOfClass:NSClassFromString(@"UIView")] && view.subviews.count > 0) {
            [[view.subviews objectAtIndex:0] removeFromSuperview];
            break;
        }
    }
    // Do any additional setup after loading the view.
}

- (void)readData{
    _dataArray = @[@"1",@"2",@"3",@"4",@"5"].mutableCopy;
    [_tableView reloadData];
}
- (IBAction)rightItemAction:(UIBarButtonItem *)sender {
    [self.view endEditing:YES];
    _queryViewTopMargin.constant = 0;
    [UIView animateWithDuration:0.3 animations:^{
        _maskView.alpha = 0.5;
        [self.view layoutIfNeeded];
    }];
    
}
- (IBAction)addNewCarInfoBtnAction:(UIButton *)sender {
    [self performSegueWithIdentifier:@"detail" sender:@"fromBtn"];
}

- (IBAction)queryBtnAction:(UIButton *)sender {
    [self cancleQuery];
}

- (void)cancleQuery{
    _queryViewTopMargin.constant = -100;
    [UIView animateWithDuration:0.3 animations:^{
        _maskView.alpha = 0;
        [self.view layoutIfNeeded];
    }];
    [self.view endEditing:YES];
}
#pragma mark - DatePickerMethod
- (void)commiteBtnAction:(UIButton *)sender {
    NSDate *date = _datePicker.datePic.date;
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    formatter.dateFormat = @"YYYY/MM/dd";
    _currentTF.text = [formatter stringFromDate:date];
    [self.view endEditing:YES];
}
- (void)cancelBtnAction:(UIButton *)sender {
    [self.view endEditing:YES];
}

- (IBAction)scanBtnAction:(UIButton *)sender {
    //二维码扫描
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UISearchBarDelegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length > 0) {
        _tableView.hidden = NO;
    }else{
        _tableView.hidden = YES;
    }
    [self readData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    NSLog(@"search");
}

#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CarInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CarInfoCell" forIndexPath:indexPath];
    cell.CarNumLab.text = _dataArray[indexPath.row];
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.view endEditing:YES];
    [self performSegueWithIdentifier:@"detail" sender:nil];
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    _currentTF = textField;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (touches.anyObject.view == _maskView) {
        [self cancleQuery];
    }
    
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    CarDetailViewController *carInfoDetailVC = segue.destinationViewController;
    if ([sender isEqualToString:@"fromBtn"]) {
        carInfoDetailVC.isFromAddNewCarBtn = YES;
    }
}


@end
