//
//  BRDatePickerView+BR.h
//  BRPickerViewDemo
//
//  Created by prorigor on 2021/5/4.
//  Copyright © 2021 prorigor. All rights reserved.
//

#import "BRDatePickerView.h"

NS_ASSUME_NONNULL_BEGIN

@interface BRDatePickerView (BR)

/** 默认选中的日期 */
- (NSDate *)handlerSelectDate:(nullable NSDate *)selectDate dateFormat:(NSString *)dateFormat;

/** NSDate 转 NSString */
- (NSString *)br_stringFromDate:(NSDate *)date dateFormat:(NSString *)dateFormat;

/** NSString 转 NSDate */
- (NSDate *)br_dateFromString:(NSString *)dateString dateFormat:(NSString *)dateFormat;

/** 比较两个日期大小（可以指定比较级数，即按指定格式进行比较） */
- (NSComparisonResult)br_compareDate:(NSDate *)date targetDate:(NSDate *)targetDate dateFormat:(NSString *)dateFormat;

/** 获取 yearArr 数组 */
- (NSArray *)getYearArr;

/** 获取 monthArr 数组 */
- (NSArray *)getMonthArr:(NSInteger)year;

/** 获取 dayArr 数组 */
- (NSArray *)getDayArr:(NSInteger)year month:(NSInteger)month;

/** 获取 hourArr 数组 */
- (NSArray *)getHourArr:(NSInteger)year month:(NSInteger)month day:(NSInteger)day;

/** 获取 minuteArr 数组 */
- (NSArray *)getMinuteArr:(NSInteger)year month:(NSInteger)month day:(NSInteger)day hour:(NSInteger)hour;

/** 获取 secondArr 数组 */
- (NSArray *)getSecondArr:(NSInteger)year month:(NSInteger)month day:(NSInteger)day hour:(NSInteger)hour minute:(NSInteger)minute;

/** 添加 pickerView */
- (void)setupPickerView:(UIView *)pickerView toView:(UIView *)view;

/** 设置日期单位 */
- (NSArray *)setupPickerUnitLabel:(UIPickerView *)pickerView unitArr:(NSArray *)unitArr;

- (NSString *)getYearNumber:(NSInteger)year;

- (NSString *)getMDHMSNumber:(NSInteger)number;

- (NSString *)getYearText:(NSArray *)yearArr row:(NSInteger)row;

- (NSString *)getMonthText:(NSArray *)monthArr row:(NSInteger)row monthNames:(NSArray *)monthNames;

- (NSString *)getDayText:(NSArray *)dayArr row:(NSInteger)row mSelectDate:(NSDate *)mSelectDate;

- (NSString *)getHourText:(NSArray *)hourArr row:(NSInteger)row;

- (NSString *)getMinuteText:(NSArray *)minuteArr row:(NSInteger)row;

- (NSString *)getSecondText:(NSArray *)secondArr row:(NSInteger)row;

- (NSString *)getAMText;

- (NSString *)getPMText;

- (NSString *)getYearUnit;

- (NSString *)getMonthUnit;

- (NSString *)getDayUnit;

- (NSString *)getHourUnit;

- (NSString *)getMinuteUnit;

- (NSString *)getSecondUnit;

- (NSInteger)getIndexWithArray:(NSArray *)array object:(NSString *)obj;

@end

NS_ASSUME_NONNULL_END
