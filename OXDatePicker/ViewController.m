//
//  ViewController.m
//  OXDatePicker
//
//  Created by Cloudoxou on 2017/7/11.
//  Copyright © 2017年 Tencare. All rights reserved.
//

#import "ViewController.h"
#import "OXDatePickerView.h"

#define SCREENWIDTH       [UIScreen mainScreen].bounds.size.width
#define SCREENHEIGHT      [UIScreen mainScreen].bounds.size.height

@interface ViewController () <OXDatePickerViewDelegate>

@property (nonatomic, strong) UILabel *label;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake((SCREENWIDTH-200)/2, 200, 200, 20)];
    [btn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [btn setTitle:@"安排入院" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(onClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    self.label = [[UILabel alloc] initWithFrame:CGRectMake(12, 300, SCREENWIDTH-24, 20)];
    self.label.text = @"入院日期：";
    self.label.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.label];

}

/**
 按钮响应
 */
- (void)onClick {
    OXDatePickerView *pickerView = [[OXDatePickerView alloc] initWithDefaultDate:1499040000 dateArray:[NSMutableArray arrayWithArray:@[[NSNumber numberWithLong: 1499040000], [NSNumber numberWithLong:1499083200], [NSNumber numberWithLong:1499123200], [NSNumber numberWithLong:1499020000], [NSNumber numberWithLong:1498816800], [NSNumber numberWithLong:1499162400], [NSNumber numberWithLong:1498744800]]]];
    pickerView.delegate = self;
    [self.view addSubview:pickerView];
}

#pragma mark - OXDatePickerViewDelegate
- (void)choosedDate:(long)date {
    NSLog(@"选择：%ld", date);
    self.label.text = [NSString stringWithFormat:@"入院日期：%ld", date];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
