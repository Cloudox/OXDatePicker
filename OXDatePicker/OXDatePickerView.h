//
//  OXView.h
//  OXDatePicker
//
//  Created by Cloudoxou on 2017/7/11.
//  Copyright © 2017年 Tencare. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol OXDatePickerViewDelegate <NSObject>

/**
 选中时间的回调
 
 @param date long型标准时间戳，上午为当日0点，下午为当日12点
 */
- (void)choosedDate:(long)date;

@end

@interface OXDatePickerView : UIView

- (instancetype)initWithDefaultDate:(long)defaultDate dateArray:(NSArray *)dateArray;
- (void)configWithDefaultDate:(long)defaultDate dateArray:(NSArray *)dateArray;

@property (nonatomic, weak) id<OXDatePickerViewDelegate> delegate;

@end
