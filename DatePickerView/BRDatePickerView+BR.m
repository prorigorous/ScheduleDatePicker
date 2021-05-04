//
//  BRDatePickerView+BR.m
//  BRPickerViewDemo
//
//  Created by prorigor on 2020/6/16.
//  Copyright © 2021 prorigor. All rights reserved.
//

#import "BRDatePickerView+BR.h"
#import "NSBundle+BRPickerView.h"

BRSYNTH_DUMMY_CLASS(BRDatePickerView_BR)

//////////////////////////////////////////
/// 本分类主要是给 BRDatePickerView 文件瘦身
//////////////////////////////////////////

@implementation BRDatePickerView (BR)

#pragma mark - 默认选中的日期
- (NSDate *)handlerSelectDate:(NSDate *)selectDate dateFormat:(NSString *)dateFormat {
    // selectDate 优先级高于 selectValue（推荐使用 selectDate 设置默认选中的日期）
    if (!selectDate) {
        if (self.selectValue && self.selectValue.length > 0) {
            NSDate *date = nil;
            date = [self br_dateFromString:self.selectValue dateFormat:dateFormat];
            if (!date) {
                BRErrorLog(@"参数异常！字符串 selectValue 的正确格式是：%@", dateFormat);
                NSAssert(date, @"参数异常！请检查字符串 selectValue 的格式");
                date = [NSDate date]; // 默认值参数格式错误时，重置/忽略默认值，防止在 Release 环境下崩溃！
            }
            selectDate = date;
        } else {
            if (self.minuteInterval > 1 || self.secondInterval > 1) {
                NSDate *date = [NSDate date];
                NSInteger minute = self.minDate.br_minute % self.minuteInterval == 0 ? self.minDate.br_minute : 0;
                NSInteger second = self.minDate.br_second % self.secondInterval == 0 ? self.minDate.br_second : 0;
                selectDate = [NSDate br_setYear:date.br_year month:date.br_month day:date.br_day hour:date.br_hour minute:minute second:second];
            } else {
                // 默认选中今天的日期
                selectDate = [NSDate date];
            }
        }
    }
    
    // 判断日期是否超过边界限制
    BOOL selectLessThanMin = [self br_compareDate:selectDate targetDate:self.minDate dateFormat:dateFormat] == NSOrderedAscending;
    BOOL selectMoreThanMax = [self br_compareDate:selectDate targetDate:self.maxDate dateFormat:dateFormat] == NSOrderedDescending;
    if (selectLessThanMin) {
        BRErrorLog(@"默认选择的日期不能小于最小日期！");
        selectDate = self.minDate;
    }
    if (selectMoreThanMax) {
        BRErrorLog(@"默认选择的日期不能大于最大日期！");
        selectDate = self.maxDate;
    }
    
    return selectDate;
}

#pragma mark - NSDate 转 NSString
- (NSString *)br_stringFromDate:(NSDate *)date dateFormat:(NSString *)dateFormat {
    return [NSDate br_stringFromDate:date dateFormat:dateFormat timeZone:self.timeZone language:self.pickerStyle.language];
}

#pragma mark - NSString 转 NSDate
- (NSDate *)br_dateFromString:(NSString *)dateString dateFormat:(NSString *)dateFormat {
    return [NSDate br_dateFromString:dateString dateFormat:dateFormat timeZone:self.timeZone language:self.pickerStyle.language];
}

#pragma mark - 比较两个日期大小（可以指定比较级数，即按指定格式进行比较）
- (NSComparisonResult)br_compareDate:(NSDate *)date targetDate:(NSDate *)targetDate dateFormat:(NSString *)dateFormat {
    NSString *dateString1 = [self br_stringFromDate:date dateFormat:dateFormat];
    NSString *dateString2 = [self br_stringFromDate:targetDate dateFormat:dateFormat];
    NSDate *date1 = [self br_dateFromString:dateString1 dateFormat:dateFormat];
    NSDate *date2 = [self br_dateFromString:dateString2 dateFormat:dateFormat];
    if ([date1 compare:date2] == NSOrderedDescending) {
        return 1; // 大于
    } else if ([date1 compare:date2] == NSOrderedAscending) {
        return -1; // 小于
    } else {
        return 0; // 等于
    }
}

#pragma mark - 获取 yearArr 数组
- (NSArray *)getYearArr {
    NSMutableArray *tempArr = [[NSMutableArray alloc]init];
    for (NSInteger i = self.minDate.br_year; i <= self.maxDate.br_year; i++) {
        [tempArr addObject:[self getYearNumber:i]];
    }
    return [tempArr copy];
}

#pragma mark - 获取 monthArr 数组
- (NSArray *)getMonthArr:(NSInteger)year {
    NSInteger startMonth = 1;
    NSInteger endMonth = 12;
    if (year == self.minDate.br_year) {
        startMonth = self.minDate.br_month;
    }
    if (year == self.maxDate.br_year) {
        endMonth = self.maxDate.br_month;
    }
    NSMutableArray *tempArr = [[NSMutableArray alloc]init];
    for (NSInteger i = startMonth; i <= endMonth; i++) {
        [tempArr addObject:[self getMDHMSNumber:i]];
    }
    
    return [tempArr copy];
}

#pragma mark - 获取 dayArr 数组
- (NSArray *)getDayArr:(NSInteger)year month:(NSInteger)month {
    NSInteger startDay = 1;
    NSInteger endDay = [NSDate br_getDaysInYear:year month:month];
    if (year == self.minDate.br_year && month == self.minDate.br_month) {
        startDay = self.minDate.br_day;
    }
    if (year == self.maxDate.br_year && month == self.maxDate.br_month) {
        endDay = self.maxDate.br_day;
    }
    NSMutableArray *tempArr = [[NSMutableArray alloc]init];
    for (NSInteger i = startDay; i <= endDay; i++) {
        [tempArr addObject:[self getMDHMSNumber:i]];
    }
    
    return [tempArr copy];
}

#pragma mark - 获取 hourArr 数组
- (NSArray *)getHourArr:(NSInteger)year month:(NSInteger)month day:(NSInteger)day {
    NSInteger startHour = 0;
    NSInteger endHour = 23;
    if (year == self.minDate.br_year && month == self.minDate.br_month && day == self.minDate.br_day) {
        startHour = self.minDate.br_hour;
    }
    if (year == self.maxDate.br_year && month == self.maxDate.br_month && day == self.maxDate.br_day) {
        endHour = self.maxDate.br_hour;
    }
    NSMutableArray *tempArr = [[NSMutableArray alloc]init];
    for (NSInteger i = startHour; i <= endHour; i++) {
        [tempArr addObject:[self getMDHMSNumber:i]];
    }
    
    return [tempArr copy];
}

#pragma mark - 获取 minuteArr 数组
- (NSArray *)getMinuteArr:(NSInteger)year month:(NSInteger)month day:(NSInteger)day hour:(NSInteger)hour {
    NSInteger startMinute = 0;
    NSInteger endMinute = 59;
    if (year == self.minDate.br_year && month == self.minDate.br_month && day == self.minDate.br_day && hour == self.minDate.br_hour) {
        startMinute = self.minDate.br_minute;
    }
    if (year == self.maxDate.br_year && month == self.maxDate.br_month && day == self.maxDate.br_day && hour == self.maxDate.br_hour) {
        endMinute = self.maxDate.br_minute;
    }
    NSMutableArray *tempArr = [[NSMutableArray alloc]init];
    for (NSInteger i = startMinute; i <= endMinute; i += self.minuteInterval) {
        [tempArr addObject:[self getMDHMSNumber:i]];
    }
    
    return [tempArr copy];
}

#pragma mark - 获取 secondArr 数组
- (NSArray *)getSecondArr:(NSInteger)year month:(NSInteger)month day:(NSInteger)day hour:(NSInteger)hour minute:(NSInteger)minute {
    NSInteger startSecond = 0;
    NSInteger endSecond = 59;
    if (year == self.minDate.br_year && month == self.minDate.br_month && day == self.minDate.br_day && hour == self.minDate.br_hour && minute == self.minDate.br_minute) {
        startSecond = self.minDate.br_second;
    }
    if (year == self.maxDate.br_year && month == self.maxDate.br_month && day == self.maxDate.br_day && hour == self.maxDate.br_hour && minute == self.maxDate.br_minute) {
        endSecond = self.maxDate.br_second;
    }
    NSMutableArray *tempArr = [[NSMutableArray alloc]init];
    for (NSInteger i = startSecond; i <= endSecond; i += self.secondInterval) {
        [tempArr addObject:[self getMDHMSNumber:i]];
    }
    
    return [tempArr copy];
}

#pragma mark - 添加 pickerView
- (void)setupPickerView:(UIView *)pickerView toView:(UIView *)view {
    if (view) {
        // 立即刷新容器视图 view 的布局（防止 view 使用自动布局时，选择器视图无法正常显示）
        [view setNeedsLayout];
        [view layoutIfNeeded];
        
        self.frame = view.bounds;
        CGFloat pickerHeaderViewHeight = self.pickerHeaderView ? self.pickerHeaderView.bounds.size.height : 0;
        CGFloat pickerFooterViewHeight = self.pickerFooterView ? self.pickerFooterView.bounds.size.height : 0;
        pickerView.frame = CGRectMake(0, pickerHeaderViewHeight, view.bounds.size.width, view.bounds.size.height - pickerHeaderViewHeight - pickerFooterViewHeight);
        [self addSubview:pickerView];
    } else {
        [self.alertView addSubview:pickerView];
    }
}

#pragma mark - 获取日期单位
- (NSArray *)setupPickerUnitLabel:(UIPickerView *)pickerView unitArr:(NSArray *)unitArr {
    NSMutableArray *tempArr = [[NSMutableArray alloc]init];
    for (NSInteger i = 0; i < pickerView.numberOfComponents; i++) {
        // label宽度
        CGFloat labelWidth = pickerView.bounds.size.width / pickerView.numberOfComponents;
        // 根据占位文本长度去计算宽度
        NSString *tempText = @"00";
        if (i == 0) {
            switch (self.pickerMode) {
                case BRDatePickerModeYMDHM:
                    break;
                    
                default:
                    break;
            }
        }
        // 文本宽度
        CGFloat labelTextWidth = [tempText boundingRectWithSize:CGSizeMake(MAXFLOAT, self.pickerStyle.rowHeight)
                                                        options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                     attributes:@{NSFontAttributeName: self.pickerStyle.pickerTextFont}
                                                        context:nil].size.width;
        // 单位label
        UILabel *unitLabel = [[UILabel alloc]init];
        unitLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        unitLabel.backgroundColor = [UIColor clearColor];
        unitLabel.textAlignment = NSTextAlignmentCenter;
        unitLabel.font = self.pickerStyle.dateUnitTextFont;
        unitLabel.textColor = self.pickerStyle.dateUnitTextColor;
        // 字体自适应属性
        unitLabel.adjustsFontSizeToFitWidth = YES;
        // 自适应最小字体缩放比例
        unitLabel.minimumScaleFactor = 0.5f;
        unitLabel.text = (unitArr.count > 0 && i < unitArr.count) ? unitArr[i] : nil;
        
        CGFloat originX = i * labelWidth + labelWidth / 2.0 + labelTextWidth / 2.0 + self.pickerStyle.dateUnitOffsetX;
        CGFloat originY = (pickerView.frame.size.height - self.pickerStyle.rowHeight) / 2 + self.pickerStyle.dateUnitOffsetY;
        unitLabel.frame = CGRectMake(originX, originY, self.pickerStyle.rowHeight, self.pickerStyle.rowHeight);
        
        [tempArr addObject:unitLabel];
        
        [pickerView addSubview:unitLabel];
    }
    
    return [tempArr copy];
}

- (NSString *)getYearNumber:(NSInteger)year {
    NSString *yearString = [NSString stringWithFormat:@"%@", @(year)];
    if (self.isNumberFullName) {
        yearString = [NSString stringWithFormat:@"%04d", [yearString intValue]];
    }
    return yearString;
}

- (NSString *)getMDHMSNumber:(NSInteger)number {
    NSString *string = [NSString stringWithFormat:@"%@", @(number)];
    if (self.isNumberFullName) {
        string = [NSString stringWithFormat:@"%02d", [string intValue]];
    }
    return string;
}

- (NSString *)getYearText:(NSArray *)yearArr row:(NSInteger)row {
    NSInteger index = 0;
    if (row >= 0) {
        index = MIN(row, yearArr.count - 1);
    }
    NSString *yearString = [yearArr objectAtIndex:index];
    NSString *yearUnit = self.showUnitType == BRShowUnitTypeAll ? [self getYearUnit] : @"";
    return [NSString stringWithFormat:@"%@%@", yearString, yearUnit];
}

- (NSString *)getMonthText:(NSArray *)monthArr row:(NSInteger)row monthNames:(NSArray *)monthNames {
    NSInteger index = 0;
    if (row >= 0) {
        index = MIN(row, monthArr.count - 1);
    }
    NSString *monthString = [monthArr objectAtIndex:index];
    if ([self.pickerStyle.language hasPrefix:@"zh"]) {
        self.monthNameType = BRMonthNameTypeNumber;
    }
    NSString *monthUnit = self.showUnitType == BRShowUnitTypeAll ? [self getMonthUnit] : @"";
    return [NSString stringWithFormat:@"%@%@", monthString, monthUnit];
}

- (NSString *)getDayText:(NSArray *)dayArr row:(NSInteger)row mSelectDate:(NSDate *)mSelectDate {
    NSInteger index = 0;
    if (row >= 0) {
        index = MIN(row, dayArr.count - 1);
    }
    NSString *dayString = [dayArr objectAtIndex:index];
    
    NSString *dayUnit = self.showUnitType == BRShowUnitTypeAll ? [self getDayUnit] : @"";
    dayString = [NSString stringWithFormat:@"%@%@", dayString, dayUnit];
    if (self.isShowWeek) {
        NSDate *date = [NSDate br_setYear:mSelectDate.br_year month:mSelectDate.br_month day:[dayString integerValue]];
        NSString *weekdayString = [NSBundle br_localizedStringForKey:[date br_weekdayString] language:self.pickerStyle.language];
        dayString = [NSString stringWithFormat:@"%@%@", dayString, weekdayString];
        return dayString;
    }
    if (self.isShowToday && mSelectDate.br_year == [NSDate date].br_year && mSelectDate.br_month == [NSDate date].br_month && [dayString integerValue] == [NSDate date].br_day) {
        dayString = [NSString stringWithFormat:@"%@%@", dayString,
        [NSBundle br_localizedStringForKey:@"今天" language:self.pickerStyle.language]];
        return dayString;
    }
    return dayString;
}

- (NSString *)getHourText:(NSArray *)hourArr row:(NSInteger)row {
    NSInteger index = 0;
    if (row >= 0) {
        index = MIN(row, hourArr.count - 1);
    }
    NSString *hourString = [hourArr objectAtIndex:index];
    NSString *hourUnit = self.showUnitType == BRShowUnitTypeAll ? [self getHourUnit] : @"";
    return [NSString stringWithFormat:@"%@%@", hourString, hourUnit];
}

- (NSString *)getMinuteText:(NSArray *)minuteArr row:(NSInteger)row {
    NSInteger index = 0;
    if (row >= 0) {
        index = MIN(row, minuteArr.count - 1);
    }
    NSString *minuteString = [minuteArr objectAtIndex:index];
    NSString *minuteUnit = self.showUnitType == BRShowUnitTypeAll ? [self getMinuteUnit] : @"";
    return [NSString stringWithFormat:@"%@%@", minuteString, minuteUnit];
}

- (NSString *)getSecondText:(NSArray *)secondArr row:(NSInteger)row {
    NSInteger index = 0;
    if (row >= 0) {
        index = MIN(row, secondArr.count - 1);
    }
    NSString *secondString = [secondArr objectAtIndex:index];
    NSString *secondUnit = self.showUnitType == BRShowUnitTypeAll ? [self getSecondUnit] : @"";
    return [NSString stringWithFormat:@"%@%@", secondString, secondUnit];
}

- (NSString *)getAMText {
    return [NSBundle br_localizedStringForKey:@"上午" language:self.pickerStyle.language];
}

- (NSString *)getPMText {
    return [NSBundle br_localizedStringForKey:@"下午" language:self.pickerStyle.language];
}

- (NSString *)getYearUnit {
    if (![self.pickerStyle.language hasPrefix:@"zh"]) {
        return @"";
    }
    return [NSBundle br_localizedStringForKey:@"年" language:self.pickerStyle.language];
}

- (NSString *)getMonthUnit {
    if (![self.pickerStyle.language hasPrefix:@"zh"]) {
        return @"";
    }
    return [NSBundle br_localizedStringForKey:@"月" language:self.pickerStyle.language];
}

- (NSString *)getDayUnit {
    if (![self.pickerStyle.language hasPrefix:@"zh"]) {
        return @"";
    }
    return [NSBundle br_localizedStringForKey:@"日" language:self.pickerStyle.language];
}

- (NSString *)getHourUnit {
    if (![self.pickerStyle.language hasPrefix:@"zh"]) {
        return @"";
    }
    return [NSBundle br_localizedStringForKey:@"时" language:self.pickerStyle.language];
}

- (NSString *)getMinuteUnit {
    if (![self.pickerStyle.language hasPrefix:@"zh"]) {
        return @"";
    }
    return [NSBundle br_localizedStringForKey:@"分" language:self.pickerStyle.language];
}

- (NSString *)getSecondUnit {
    if (![self.pickerStyle.language hasPrefix:@"zh"]) {
        return @"";
    }
    return [NSBundle br_localizedStringForKey:@"秒" language:self.pickerStyle.language];
}

- (NSInteger)getIndexWithArray:(NSArray *)array object:(NSString *)obj {
    if (!array || array.count == 0 || !obj) {
        return 0;
    }
    if ([array containsObject:obj]) {
        return [array indexOfObject:obj];
    }
    return 0;
}

@end
