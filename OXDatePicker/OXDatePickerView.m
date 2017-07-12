//
//  OXView.m
//  OXDatePicker
//
//  Created by Cloudoxou on 2017/7/11.
//  Copyright © 2017年 Tencare. All rights reserved.
//

#import "OXDatePickerView.h"

#define SCREENWIDTH       [UIScreen mainScreen].bounds.size.width
#define SCREENHEIGHT      [UIScreen mainScreen].bounds.size.height
// block解决循环引用
#define WeakSelf   __typeof(&*self) __weak weakSelf = self;
#define StrongSelf __typeof(&*self) __strong strongSelf = weakSelf;

@interface OXDatePickerView () <UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UIPickerView *pickerView;

@property (nonatomic, strong) NSMutableArray *allDateArray;
@property (nonatomic, strong) NSMutableArray *monthArray;
@property (nonatomic, strong) NSMutableArray *dayArray;
@property (nonatomic, strong) NSMutableArray *timeArray;

@property (nonatomic, copy) NSString *year;
@property (nonatomic, copy) NSString *month;
@property (nonatomic, copy) NSString *day;
@property (nonatomic, copy) NSString *time;

@end

@implementation OXDatePickerView

- (instancetype)initWithDefaultDate:(long)defaultDate dateArray:(NSArray *)dateArray {
    self = [super initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT)];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:((float)((0x999999 & 0xFF0000) >> 16))/255.0 green:((float)((0x999999 & 0xFF00) >> 8))/255.0 blue:((float)(0x999999 & 0xFF))/255.0 alpha:0.7];
        
        // 背景白色
        self.bgView = [[UIView alloc] initWithFrame:CGRectMake(20, SCREENHEIGHT, SCREENWIDTH-40, 250)];
        self.bgView.backgroundColor = [UIColor whiteColor];
        self.bgView.layer.cornerRadius = 10;
        self.bgView.layer.masksToBounds = true;
        [self addSubview:self.bgView];
        
        [self configWithDefaultDate:defaultDate dateArray:dateArray];
        
        WeakSelf
        [UIView animateWithDuration:0.2 animations:^{
            StrongSelf
            if (strongSelf) {
                // 改变位置
                CGPoint center = strongSelf.bgView.center;// 获取原来的中心位置
                center.y = SCREENHEIGHT-140;// 改变中心位置的X坐标
                strongSelf.bgView.center = center;// 设置方块的中心位置到新的位置
            }
        }];
    }
    return self;
}

/**
 配置日期

 @param defaultDate 默认显示日期
 @param dateArray 可选择日期数组
 */
- (void)configWithDefaultDate:(long)defaultDate dateArray:(NSMutableArray *)dateArray {
    
    self.allDateArray = [[NSMutableArray alloc] init];
    self.monthArray = [[NSMutableArray alloc] init];
    self.dayArray = [[NSMutableArray alloc] init];
    self.timeArray = [[NSMutableArray alloc] init];
    
    // 对数组排序为升序
    [dateArray sortUsingComparator:^NSComparisonResult(id _Nonnull obj1, id _Nonnull obj2)
     {
         //此处的规则含义为：若前一元素比后一元素小，则返回降序（即后一元素在前，为从大到小排列）
         if (obj1 > obj2)
         {
             return NSOrderedDescending;
         }
         else
         {
             return NSOrderedAscending;
         }
     }];
    
    // 遍历日期数组处理数据
    for (int i = 0; i < [dateArray count]; i++) {
        NSNumber *number = dateArray[i];
        NSString *dateStr = [self convertNSDateToNSString:[NSDate dateWithTimeIntervalSince1970:[number longValue]]];
        // 月份
        NSString *month = [dateStr substringToIndex:2];
        [self.monthArray addObject:month];
        
        // 记录当月的日子
        NSMutableArray *monthDayArray = [[NSMutableArray alloc] init];
        for (; i < [dateArray count]; i++) {
            NSNumber *number = dateArray[i];
            NSString *dateStr1 = [self convertNSDateToNSString:[NSDate dateWithTimeIntervalSince1970:[number longValue]]];
            if ([[dateStr1 substringToIndex:2] isEqualToString:month]) {// 仍是当月
                NSString *day = [dateStr1 substringWithRange:NSMakeRange(2, 2)];// 记录日期
                
                // 记录当日的上午下午
                NSMutableArray *dayTimeArray = [[NSMutableArray alloc] init];
                for (; i < [dateArray count]; i++) {
                    NSNumber *number = dateArray[i];
                    NSString *dateStr2 = [self convertNSDateToNSString:[NSDate dateWithTimeIntervalSince1970:[number longValue]]];
                    if ([[dateStr2 substringWithRange:NSMakeRange(2, 2)] isEqualToString:day]) {// 仍是当日
                        NSString *time = [dateStr2 substringFromIndex:4];
                        if ([time intValue] < 12) {
                            BOOL has = NO;
                            for (NSString *tempTime in dayTimeArray) {
                                if ([tempTime isEqualToString:@"上午"]) {
                                    has = YES;
                                }
                            }
                            if (!has) {
                                [dayTimeArray addObject:@"上午"];
                            }
                        } else {
                            BOOL has = NO;
                            for (NSString *tempTime in dayTimeArray) {
                                if ([tempTime isEqualToString:@"下午"]) {
                                    has = YES;
                                }
                            }
                            if (!has) {
                                [dayTimeArray addObject:@"下午"];
                            }
                        }
                    } else {
                        i--;
                        break;
                    }
                }
                NSDictionary *dayTimeDic = @{day: dayTimeArray};
                
                [monthDayArray addObject:[dayTimeDic copy]];
            } else {// 新月份
                i--;
                break;
            }
        }
        NSDictionary *monthDayDic = @{month: monthDayArray};
        [self.allDateArray addObject:[monthDayDic copy]];
    }
    
    
    
    // 默认所在日期
    NSDate *defaultNSDate = [NSDate dateWithTimeIntervalSince1970:defaultDate];
    NSString *defaultDateStr = [self convertNSDateToNSString:defaultNSDate];
    NSLog(@"%@", [self convertNSDateToNSString:defaultNSDate]);
    
    NSInteger monthDefaultRow = 0;
    NSInteger dayDefaultRow = 0;
    NSInteger timeDefaultRow = 0;
    // 记录默认月份在第几行
    for (int i = 0; i < [self.monthArray count]; i++) {
        if ([self.monthArray[i] isEqualToString:[defaultDateStr substringToIndex:2]]) {
            monthDefaultRow = i;
            self.month = self.monthArray[i];
            
            // 记录默认日子在第几行
            NSDictionary *monthDayDic = self.allDateArray[i];
            NSArray *dayTimeArray = [monthDayDic objectForKey:self.monthArray[i]];
            for (int j = 0; j < [dayTimeArray count] ; j++) {
                NSDictionary *dayTimeDic = dayTimeArray[j];
                NSString *dayName = @"";
                for (NSString *day in dayTimeDic) {// 其实只有一个key
                    [self.dayArray addObject:[day copy]];
                    dayName = day;
                }
                
                
                if ([dayName isEqualToString:[defaultDateStr substringWithRange:NSMakeRange(2, 2)]]) {// 是要找的日子
                    dayDefaultRow = j;
                    self.day = dayName;
                    
                    [self.timeArray addObjectsFromArray:[[dayTimeDic objectForKey:dayName] copy]];
                    
                    // 记录默认的时间在第几行
                    NSString *time = [defaultDateStr substringFromIndex:4];
                    if ([time intValue] < 12) {
                        time = @"上午";
                    } else {
                        time = @"下午";
                    }
                    for (int k = 0; k < [self.timeArray count]; k++) {
                        if ([self.timeArray[k] isEqualToString:time]) {
                            timeDefaultRow = k;
                            self.time = time;
                            break;
                        }
                    }
                }
            }
            
            break;
        }
    }
    
    // 创建pickerview
    self.pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 50, SCREENWIDTH-40, 200)];
    self.pickerView.dataSource = self;
    self.pickerView.delegate = self;
    [self.pickerView setBackgroundColor:[UIColor whiteColor]];
    [self.bgView addSubview:self.pickerView];
    
    // 工具栏
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH-40, 35)];
    toolbar.barTintColor = [UIColor whiteColor];
    toolbar.backgroundColor = [UIColor clearColor];
    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(setSheduleDate:)];;
    UIBarButtonItem *spaceBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancelPickController:)];
    [toolbar setItems:@[cancelBtn, spaceBtn, doneBtn] animated:NO];
//    [toolbar sizeToFit];
    //    CGSize size = self.view.frame.size;
//    toolbar.width = size.width - 20;
    [self.bgView addSubview:toolbar];
    
    // 默认显示默认日期
    [self.pickerView selectRow:monthDefaultRow inComponent:0 animated:NO];
    [self.pickerView selectRow:dayDefaultRow inComponent:1 animated:NO];
    [self.pickerView selectRow:timeDefaultRow inComponent:2 animated:NO];
}

/**
 确定按钮响应
 */
- (void)setSheduleDate:(id)sender {
    //    NSLog(@"%@", [self convertNSDateToNSString:self.pickerView]);
    NSLog(@"%@%@%@", self.month, self.day, self.time);
    NSString *dateStr = [NSString stringWithFormat:@"%@%@%@%@", self.year, self.month, self.day, [self.time isEqualToString:@"上午"] ? @"00" : @"12"];
    NSLog(@"%ld", [self convertNSStringToNSDate:dateStr]);
    
    if ([self.delegate respondsToSelector:@selector(choosedDate:)]) {
        [self.delegate choosedDate:[self convertNSStringToNSDate:dateStr]];
    }
    
    [self cancelPickController:nil];
}

/**
 日期字符串转日期标准时间戳
 
 @param string 日期字符串
 @return 标准时间戳
 */
- (long)convertNSStringToNSDate:(NSString *)string
{
    if (!string)
        string = @"";
    
    NSTimeZone *zone = [NSTimeZone timeZoneWithName:@"UTC"];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMddHH"];
    [formatter setTimeZone:zone];
    
    
    NSDate *date = [formatter dateFromString:string];
    return (long)[date timeIntervalSince1970];
}

/**
 日期转字符串
 
 @param date 日期
 @return 日期字符串
 */
- (NSString *)convertNSDateToNSString:(NSDate *)date
{
    if (!date)
        date = [NSDate date];
    
    NSTimeZone *zone = [NSTimeZone timeZoneWithName:@"UTC"];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMddHH"];
    [formatter setTimeZone:zone];
    
    NSString *totalStr = [formatter stringFromDate:date];
    self.year = [totalStr substringToIndex:4];
//    NSLog(@"%@", str);
    return [totalStr substringFromIndex:4];
}

/**
 取消
 */
- (void)cancelPickController:(id)sender {
    WeakSelf
    [UIView animateWithDuration:0.2 animations:^{
        StrongSelf
        if (strongSelf) {
            // 改变位置
            CGPoint center = strongSelf.bgView.center;// 获取原来的中心位置
            center.y = SCREENHEIGHT+130;// 改变中心位置的X坐标
            strongSelf.bgView.center = center;// 设置方块的中心位置到新的位置
        }
    } completion:^(BOOL finished) {// 结束时继续执行
        StrongSelf
        if (strongSelf) {
            [strongSelf removeFromSuperview];
            strongSelf = nil;
        }
    }];
}

#pragma mark - UIPickerView DataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 3;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    return self.pickerView.frame.size.width/3.0;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 30;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (component == 0) {
        return [self.monthArray count];
    } else if (component == 1) {
        return [self.dayArray count];
    } else {
        return [self.timeArray count];
    }
}

- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (component == 0) {
        return [NSString stringWithFormat:@"%@月", self.monthArray[row]];
    } else if (component == 1) {
        return self.dayArray[row];
    } else {
        return self.timeArray[row];
    }
}

#pragma mark - UIPickerView Delegate
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (component == 0) {
        self.month = self.monthArray[row];
        
        // 更新日、时间的列表内容
        NSDictionary *monthDayDic = self.allDateArray[row];
        NSArray *dayTimeArray = [monthDayDic objectForKey:self.month];
        [self.dayArray removeAllObjects];
        for (int j = 0; j < [dayTimeArray count] ; j++) {
            NSDictionary *dayTimeDic = dayTimeArray[j];
            NSString *dayName = @"";
            for (NSString *day in dayTimeDic) {// 其实只有一个key
                [self.dayArray addObject:[day copy]];
                dayName = day;
            }
            if (j == 0) {
                [self.timeArray removeAllObjects];
                [self.timeArray addObjectsFromArray:[dayTimeDic objectForKey:self.dayArray[0]]];
            }
            
        }
        [self.pickerView reloadComponent:1];
        [self.pickerView reloadComponent:2];
        [self.pickerView selectRow:0 inComponent:1 animated:NO];
        [self.pickerView selectRow:0 inComponent:2 animated:NO];
        
    } else if (component == 1) {
        self.day = self.dayArray[row];
        
        for (int i = 0; i < [self.allDateArray count]; i++) {
            NSDictionary *monthDayDic = self.allDateArray[i];
            BOOL find = NO;
            for (NSString *month in monthDayDic) {// 其实只有一个key
                if ([self.month isEqualToString:month]) {
                    NSArray *dayTimeArray = [monthDayDic objectForKey:month];
                    for (int j = 0; j < [dayTimeArray count]; j++) {
                        BOOL findDay = NO;
                        NSDictionary *dayTimeDic = dayTimeArray[j];
                        for (NSString *day in dayTimeDic) {// 其实只有一个key
                            if ([day isEqualToString:self.day]) {
                                [self.timeArray removeAllObjects];
                                [self.timeArray addObjectsFromArray:[dayTimeDic objectForKey:day]];
                                
                                findDay = YES;
                                break;
                            }
                        }
                        if (findDay) {
                            break;
                        }
                    }
                    
                    find = YES;
                    break;
                }
            }
            if (find) {
                break;
            }
        }
        
        [self.pickerView reloadComponent:2];
        [self.pickerView selectRow:0 inComponent:2 animated:NO];
    } else {
        self.time = self.timeArray[row];
    }
}


@end
