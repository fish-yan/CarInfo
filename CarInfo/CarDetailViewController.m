//
//  CarDetailViewController.m
//  CarInfo
//
//  Created by 薛焱 on 16/4/8.
//  Copyright © 2016年 薛焱. All rights reserved.
//

#import "CarDetailViewController.h"
#import "CarInfoDetailCell.h"
#import "PickerView.h"
#import "DatePicker.h"

#define MARGIN -250

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface CarDetailViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *titleArray;
@property (nonatomic, strong) NSMutableArray *blowsArray;
@property (nonatomic, strong) NSMutableDictionary *dataDict;
@property (nonatomic, assign) BOOL canSelect;
@property (nonatomic, strong) CarInfoDetailCell *cell;
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, strong) DatePicker *datePicker;
@property (nonatomic, strong) PickerView *pickerView;

@end

@implementation CarDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _dataDict = [NSMutableDictionary dictionary];
    _blowsArray = [NSMutableArray array];
    [self loadPicker];
    [self readDataFromeLocal];
    // Do any additional setup after loading the view.
}

- (void)readDataFromeLocal{
    _titleArray = @[@"关联客户",@"车牌号码",@"联系方式",@"车辆品牌",@"车辆车系",@"车辆车型",@"车辆所有人",@"车辆颜色",@"车辆排量",@"品牌型号",@"车架号码",@"发动机号",@"注册日期",@"发证日期",@"保养时间",@"行驶证号",@"车间到期",@"公里数",@"保险公司",@"保险签单",@"保险到期",];
    for (NSString *key in _titleArray) {
        [_dataDict setObject:@"" forKey:key];
    }
    NSString *path = [[NSBundle mainBundle]pathForResource:@"blows" ofType:@"plist"];
    NSArray *blowsData = [NSArray arrayWithContentsOfFile:path];
    for (NSDictionary *blowDict in blowsData) {
        [_blowsArray addObject:blowDict[@"name"]];
    }
}

- (void)loadPicker{
    _datePicker = [[NSBundle mainBundle]loadNibNamed:@"DatePicker" owner:self options:nil].lastObject;
    _datePicker.frame = CGRectMake(0, 0, kScreenWidth, 250);
    [_datePicker.cancelBtn addTarget:self action:@selector(cancelBtnAction:) forControlEvents:(UIControlEventTouchUpInside)];
    [_datePicker.commitBtn addTarget:self action:@selector(commiteBtnAction:) forControlEvents:(UIControlEventTouchUpInside)];
    _pickerView = [[NSBundle mainBundle]loadNibNamed:@"PickerView" owner:self options:nil].lastObject;
    _pickerView.frame = CGRectMake(0, 0, kScreenWidth, 250);
    [_pickerView.cancelBtn addTarget:self action:@selector(cancelBtnAction:) forControlEvents:(UIControlEventTouchUpInside)];
    [_pickerView.commitBtn addTarget:self action:@selector(pickerCommiteBtnAction:) forControlEvents:(UIControlEventTouchUpInside)];
}

- (IBAction)backItemAction:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Picker View

- (void)commiteBtnAction:(UIButton *)sender {

    NSDate *date = _datePicker.datePic.date;
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    formatter.dateFormat = @"YYYY/MM/dd   HH:mm";
    _cell.infoTF.text = [formatter stringFromDate:date];
    [_dataDict setObject:_cell.infoTF.text forKey:_cell.titleLab.text];
    [self.view endEditing:YES];
}

- (void)pickerCommiteBtnAction:(UIButton *)sender {
    NSInteger row = _pickerView.row;
    NSString *str = _pickerView.pickerArray[row];
    _cell.infoTF.text = str;
    [self.view endEditing:YES];
}

- (void)cancelBtnAction:(UIButton *)sender {
    [self.view endEditing:YES];
}

#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 21;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CarInfoDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CarInfoDetailCell" forIndexPath:indexPath];
    cell.titleLab.text = _titleArray[indexPath.row];
    cell.infoTF.text = _dataDict[cell.titleLab.text];
    cell.infoTF.tag = indexPath.row;
    
    if ((indexPath.row == 0 || indexPath.row == 1) && !_isFromAddNewCarBtn) {
        cell.infoTF.userInteractionEnabled = NO;
        cell.infoTF.backgroundColor = UIColorFromRGB(0xEEEEEE);
    }else{
        cell.infoTF.userInteractionEnabled = YES;
    }
    
    if ((indexPath.row >= 12 && indexPath.row <= 14) || indexPath.row == 16 || indexPath.row == 19 || indexPath.row == 20) {
        cell.infoTF.inputView = _datePicker;
        cell.selectImage.hidden = NO;
        cell.infoTF.placeholder = @"请选择";
    }else if (indexPath.row == 3 || indexPath.row == 8 || indexPath.row == 18){
        cell.infoTF.inputView = _pickerView;
        cell.selectImage.hidden = NO;
        cell.infoTF.placeholder = @"请选择";
    }else{
        cell.infoTF.inputView = nil;
        cell.infoTF.placeholder = @"请输入";
        cell.selectImage.hidden = YES;
    }
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    _cell = (CarInfoDetailCell *)textField.superview.superview;
    if(textField.tag == 3){
        _pickerView.pickerArray = @[@"test",@"test1",@"test2",@"test3",@"test4",@"test5",];
        //车辆品牌
    }else if (textField.tag == 8){
        _pickerView.pickerArray = [_blowsArray mutableCopy];
        //车辆排量
    }else if (textField.tag == 18){
        _pickerView.pickerArray = @[@"中国人寿",@"太平洋保险",@"test2",@"test3",@"test4",@"test5",];
        //保险公司
    }
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(changeMargin:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [_pickerView.picker reloadAllComponents];
}
- (void)changeMargin:(NSNotification *)sender{
    CGRect rect = [sender.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    if (rect.origin.y < [UIScreen mainScreen].bounds.size.height) {
        _tableView.contentInset = UIEdgeInsetsMake(0, 0, rect.size.height, 0);
    }else{
        _tableView.contentInset = UIEdgeInsetsZero;
    }
}
- (void)textFieldDidEndEditing:(UITextField *)textField{
    [_dataDict setObject:_cell.infoTF.text forKey:_cell.titleLab.text];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
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
