//
//  BRDatePickerView.m
//  BRPickerViewDemo
//
//  Created by prorigor on 2021/5/4.
//  Copyright © 2021 prorigor. All rights reserved.
//

#import "BRDatePickerView.h"
#import "NSBundle+BRPickerView.h"
#import "BRDatePickerView+BR.h"


@interface BRDatePickerView ()<UIPickerViewDataSource, UIPickerViewDelegate>
{
    UIDatePickerMode _datePickerMode;
    UIView *_containerView;
    BOOL _isAdjustSelectRow; // 设置minDate时，调整日期联动的选择(解决日期选择器联动不正确的问题)
}
/** 日期选择器1 */
//@property (nonatomic, strong) UIDatePicker *datePicker;
/** 日期选择器2 */
@property (nonatomic, strong) UIPickerView *pickerView;

/// 日期存储数组
@property(nonatomic, copy) NSArray *yearArr;
@property(nonatomic, copy) NSArray *monthArr;
@property(nonatomic, copy) NSArray *dayArr;
@property(nonatomic, copy) NSArray *hourArr;
@property(nonatomic, copy) NSArray *minuteArr;
@property(nonatomic, copy) NSArray *secondArr;

/// 记录 年、月、日、时、分、秒 当前选择的位置
@property(nonatomic, assign) NSInteger yearIndex;
@property(nonatomic, assign) NSInteger monthIndex;
@property(nonatomic, assign) NSInteger dayIndex;
@property(nonatomic, assign) NSInteger hourIndex;
@property(nonatomic, assign) NSInteger minuteIndex;
@property(nonatomic, assign) NSInteger secondIndex;

// 记录选择的值
@property (nonatomic, strong) NSDate *mSelectDate;
@property (nonatomic, copy) NSString *mSelectValue;

/** 日期的格式 */
@property (nonatomic, copy) NSString *dateFormatter;
/** 单位数组 */
@property (nonatomic, copy) NSArray *unitArr;
/** 单位label数组 */
@property (nonatomic, copy) NSArray <UILabel *> *unitLabelArr;
/** 获取所有月份名称 */
@property (nonatomic, copy) NSArray <NSString *> *monthNames;

@end

@implementation BRDatePickerView

#pragma mark - 1.显示日期选择器
+ (void)showDatePickerWithMode:(BRDatePickerMode)mode
                         title:(NSString *)title
                   selectValue:(NSString *)selectValue
                   resultBlock:(BRDateResultBlock)resultBlock {
    [self showDatePickerWithMode:mode title:title selectValue:selectValue minDate:nil maxDate:nil isAutoSelect:NO resultBlock:resultBlock];
}

#pragma mark - 2.显示日期选择器
+ (void)showDatePickerWithMode:(BRDatePickerMode)mode
                         title:(NSString *)title
                   selectValue:(NSString *)selectValue
                  isAutoSelect:(BOOL)isAutoSelect
                   resultBlock:(BRDateResultBlock)resultBlock {
    [self showDatePickerWithMode:mode title:title selectValue:selectValue minDate:nil maxDate:nil isAutoSelect:isAutoSelect resultBlock:resultBlock];
}

#pragma mark - 3.显示日期选择器
+ (void)showDatePickerWithMode:(BRDatePickerMode)mode
                         title:(NSString *)title
                   selectValue:(NSString *)selectValue
                       minDate:(NSDate *)minDate
                       maxDate:(NSDate *)maxDate
                  isAutoSelect:(BOOL)isAutoSelect
                   resultBlock:(BRDateResultBlock)resultBlock {
    // 创建日期选择器
    BRDatePickerView *datePickerView = [[BRDatePickerView alloc]init];
    datePickerView.pickerMode = mode;
    datePickerView.title = title;
    datePickerView.selectValue = selectValue;
    datePickerView.minDate = minDate;
    datePickerView.maxDate = maxDate;
    datePickerView.isAutoSelect = isAutoSelect;
    datePickerView.resultBlock = resultBlock;
    // 显示
    [datePickerView show];
}

#pragma mark - 初始化日期选择器
- (instancetype)initWithPickerMode:(BRDatePickerMode)pickerMode {
    if (self = [super init]) {
        self.pickerMode = pickerMode;
    }
    return self;
}

#pragma mark - 处理选择器数据
- (void)handlerPickerData {
    
    BOOL minMoreThanMax = [self br_compareDate:self.minDate targetDate:self.maxDate dateFormat:self.dateFormatter] == NSOrderedDescending;
    NSAssert(!minMoreThanMax, @"最小日期不能大于最大日期！");
    
    // 默认选中的日期
    self.mSelectDate = [self handlerSelectDate:self.selectDate dateFormat:self.dateFormatter];

    // 设置选择器日期数据
    [self setupDateArray];
    
    self.mSelectValue = [self br_stringFromDate:self.mSelectDate dateFormat:self.dateFormatter];
}

#pragma mark - 设置默认日期数据源
- (void)setupDateArray {
    self.yearArr = [self getYearArr];
    self.monthArr = [self getMonthArr:self.mSelectDate.br_year];
    self.dayArr = [self getDayArr:self.mSelectDate.br_year month:self.mSelectDate.br_month];
    self.hourArr = [self getHourArr:self.mSelectDate.br_year month:self.mSelectDate.br_month day:self.mSelectDate.br_day];
    self.minuteArr = [self getMinuteArr:self.mSelectDate.br_year month:self.mSelectDate.br_month day:self.mSelectDate.br_day hour:self.mSelectDate.br_hour];
    self.secondArr = [self getSecondArr:self.mSelectDate.br_year month:self.mSelectDate.br_month day:self.mSelectDate.br_day hour:self.mSelectDate.br_hour minute:self.mSelectDate.br_minute];
}

- (void)setupDateFormatter:(BRDatePickerMode)mode {
    switch (mode) {
        case BRDatePickerModeYMDHM:
        {
            self.dateFormatter = @"yyyy-MM-dd HH:mm";
            self.unitArr = @[[self getYearUnit], [self getMonthUnit], [self getDayUnit], [self getHourUnit], [self getMinuteUnit]];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - 更新日期数据源数组
- (void)reloadDateArrayWithUpdateMonth:(BOOL)updateMonth updateDay:(BOOL)updateDay updateHour:(BOOL)updateHour updateMinute:(BOOL)updateMinute updateSecond:(BOOL)updateSecond {
    _isAdjustSelectRow = NO;
    // 1.更新 monthArr
    if (self.yearArr.count == 0) {
        return;
    }
    NSString *yearString = [self getYearString];
    if (updateMonth) {
        NSString *lastSelectMonth = [self getMDHMSNumber:self.mSelectDate.br_month];
        self.monthArr = [self getMonthArr:[yearString integerValue]];
        if (self.mSelectDate) {
            if ([self.monthArr containsObject:lastSelectMonth]) {
                NSInteger monthIndex = [self.monthArr indexOfObject:lastSelectMonth];
                if (monthIndex != self.monthIndex) {
                    _isAdjustSelectRow = YES;
                    self.monthIndex = monthIndex;
                }
            } else {
                _isAdjustSelectRow = YES;
                self.monthIndex = ([lastSelectMonth intValue] < [self.monthArr.firstObject intValue]) ? 0 : (self.monthArr.count - 1);
            }
        }
    }
    
    // 2.更新 dayArr
    if (self.monthArr.count == 0) {
        return;
    }
    NSString *monthString = [self getMonthString];
    if (updateDay) {
        NSString *lastSelectDay = [self getMDHMSNumber:self.mSelectDate.br_day];
        self.dayArr = [self getDayArr:[yearString integerValue] month:[monthString integerValue]];
        if (self.mSelectDate) {
            if ([self.dayArr containsObject:lastSelectDay]) {
                NSInteger dayIndex = [self.dayArr indexOfObject:lastSelectDay];
                if (dayIndex != self.dayIndex) {
                    _isAdjustSelectRow = YES;
                    self.dayIndex = dayIndex;
                }
            } else {
                _isAdjustSelectRow = YES;
                self.dayIndex = ([lastSelectDay intValue] < [self.dayArr.firstObject intValue]) ? 0 : (self.dayArr.count - 1);
            }
        }
    }
    
    // 3.更新 hourArr
    if (self.dayArr.count == 0) {
        return;
    }
    NSInteger day = [[self getDayString] integerValue];
    if (updateHour) {
        NSString *lastSelectHour = [self getMDHMSNumber:self.mSelectDate.br_hour];
        self.hourArr = [self getHourArr:[yearString integerValue] month:[monthString integerValue] day:day];
        if (self.mSelectDate) {
            if ([self.hourArr containsObject:lastSelectHour]) {
                NSInteger hourIndex = [self.hourArr indexOfObject:lastSelectHour];
                if (hourIndex != self.hourIndex) {
                    _isAdjustSelectRow = YES;
                    self.hourIndex = hourIndex;
                }
            } else {
                _isAdjustSelectRow = YES;
                self.hourIndex = ([lastSelectHour intValue] < [self.hourArr.firstObject intValue]) ? 0 : (self.hourArr.count - 1);
            }
        }
    }
    
    // 4.更新 minuteArr
    if (self.hourArr.count == 0) {
        return;
    }
    NSString *hourString = [self getHourString];
    if (updateMinute) {
        NSString *lastSelectMinute = [self getMDHMSNumber:self.mSelectDate.br_minute];
        self.minuteArr = [self getMinuteArr:[yearString integerValue] month:[monthString integerValue] day:day hour:[hourString integerValue]];
        if (self.mSelectDate) {
            if ([self.minuteArr containsObject:lastSelectMinute]) {
                NSInteger minuteIndex = [self.minuteArr indexOfObject:lastSelectMinute];
                if (minuteIndex != self.minuteIndex) {
                    _isAdjustSelectRow = YES;
                    self.minuteIndex = minuteIndex;
                }
            } else {
                _isAdjustSelectRow = YES;
                self.minuteIndex = ([lastSelectMinute intValue] < [self.minuteArr.firstObject intValue]) ? 0 : (self.minuteArr.count - 1);
            }
        }
    }
    
    // 5.更新 secondArr
    if (self.minuteArr.count == 0) {
        return;
    }
    NSString *minuteString = [self getMinuteString];
    if (updateSecond) {
        NSString *lastSelectSecond = [self getMDHMSNumber:self.mSelectDate.br_second];
        self.secondArr = [self getSecondArr:[yearString integerValue] month:[monthString integerValue] day:day hour:[hourString integerValue] minute:[minuteString integerValue]];
        if (self.mSelectDate) {
            if ([self.secondArr containsObject:lastSelectSecond]) {
                NSInteger secondIndex = [self.secondArr indexOfObject:lastSelectSecond];
                if (secondIndex != self.secondIndex) {
                    _isAdjustSelectRow = YES;
                    self.secondIndex = secondIndex;
                }
            } else {
                _isAdjustSelectRow = YES;
                self.secondIndex = ([lastSelectSecond intValue] < [self.secondArr.firstObject intValue]) ? 0 : (self.secondArr.count - 1);
            }
        }
    }
}

#pragma mark - 滚动到指定日期的位置(更新选择的索引)
- (void)scrollToSelectDate:(NSDate *)selectDate animated:(BOOL)animated {
    self.yearIndex = [self getIndexWithArray:self.yearArr object:[self getYearNumber:selectDate.br_year]];
    self.monthIndex = [self getIndexWithArray:self.monthArr object:[self getMDHMSNumber:selectDate.br_month]];
    self.dayIndex = [self getIndexWithArray:self.dayArr object:[self getMDHMSNumber:selectDate.br_day]];
    self.hourIndex = [self getIndexWithArray:self.hourArr object:[self getMDHMSNumber:selectDate.br_hour]];
    self.minuteIndex = [self getIndexWithArray:self.minuteArr object:[self getMDHMSNumber:selectDate.br_minute]];
    self.secondIndex = [self getIndexWithArray:self.secondArr object:[self getMDHMSNumber:selectDate.br_second]];
    
    NSArray *indexArr = nil;
    if (self.pickerMode == BRDatePickerModeYMDHM) {
        indexArr = @[@(self.dayIndex), @(self.hourIndex), @(self.minuteIndex)];
    }
    
    if (!indexArr) return;
    for (NSInteger i = 0; i < indexArr.count; i++) {
        [self.pickerView selectRow:[indexArr[i] integerValue] inComponent:i animated:animated];
    }
}

#pragma mark - 滚动到【自定义字符串】的位置
- (void)scrollToCustomString:(BOOL)animated {
    switch (self.pickerMode) {
        case BRDatePickerModeYMDHM:
            break;

        default:
            break;
    }
}

#pragma mark - 日期选择器
- (UIPickerView *)pickerView {
    if (!_pickerView) {
        CGFloat pickerHeaderViewHeight = self.pickerHeaderView ? self.pickerHeaderView.bounds.size.height : 0;
        _pickerView = [[UIPickerView alloc]initWithFrame:CGRectMake(0, self.pickerStyle.titleBarHeight + pickerHeaderViewHeight, self.keyView.bounds.size.width, self.pickerStyle.pickerHeight)];
        _pickerView.backgroundColor = self.pickerStyle.pickerColor;
        _pickerView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
        _pickerView.dataSource = self;
        _pickerView.delegate = self;
    }
    return _pickerView;
}

#pragma mark - UIPickerViewDataSource
// 1.设置 pickerView 的列数
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    if (self.pickerMode == BRDatePickerModeYMDHM) {
        return 3;
    }
    return 0;
}

// 2.设置 pickerView 每列的行数
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    NSArray *rowsArr = [NSArray array];
    if (self.pickerMode == BRDatePickerModeYMDHM) {
        rowsArr = @[@(self.dayArr.count), @(self.hourArr.count), @(self.minuteArr.count)];
    }
    if (component >= 0 && component < rowsArr.count) {
        return [rowsArr[component] integerValue];
    }
    return 0;
}

#pragma mark - UIPickerViewDelegate
// 3. 设置 pickerView 的显示内容
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(nullable UIView *)view {
    // 1.自定义 row 的内容视图
    UILabel *label = (UILabel *)view;
    if (!label) {
        label = [[UILabel alloc]init];
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = self.pickerStyle.pickerTextFont;
        label.textColor = self.pickerStyle.pickerTextColor;
        // 字体自适应属性
        label.adjustsFontSizeToFitWidth = YES;
        // 自适应最小字体缩放比例
        label.minimumScaleFactor = 0.5f;
    }
    label.text = [self pickerView:pickerView titleForRow:row forComponent:component];
    
    // 2.设置选择器中间选中行的样式
    [self.pickerStyle setupPickerSelectRowStyle:pickerView titleForRow:row forComponent:component];

    return label;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSString *titleString = @"";
    if (self.pickerMode == BRDatePickerModeYMDHM) {
        if (component == 0) {
            NSString *monthString = [self getMonthText:self.monthArr row:row monthNames:self.monthNames];
            NSString *dayString = [self getDayText:self.dayArr row:row mSelectDate:self.mSelectDate];
            titleString = [NSString stringWithFormat:@"%@%@", monthString, dayString];
        } else if (component == 1) {
            titleString = [self getHourText:self.hourArr row:row];
        } else if (component == 2) {
            titleString = [self getMinuteText:self.minuteArr row:row];
        }
    }
    
    return titleString;
}

// 4.滚动 pickerView 执行的回调方法
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSDate *lastSelectDate = self.mSelectDate;
    if (self.pickerMode == BRDatePickerModeYMDHM) {
        if (component == 0) {
            self.dayIndex = row;
            [self reloadDateArrayWithUpdateMonth:NO updateDay:NO updateHour:YES updateMinute:YES updateSecond:NO];
            [self.pickerView reloadComponent:1];
            [self.pickerView reloadComponent:2];
        } else if (component == 1) {
            self.hourIndex = row;
            [self reloadDateArrayWithUpdateMonth:NO updateDay:NO updateHour:NO updateMinute:YES updateSecond:NO];
            [self.pickerView reloadComponent:2];
        } else if (component == 2) {
            self.minuteIndex = row;
        }
        
        if (self.yearArr.count * self.monthArr.count * self.dayArr.count * self.hourArr.count * self.minuteArr.count == 0) return;
        int year = [[self getYearString] intValue];
        int month = [[self getMonthString] intValue];
        int day = [[self getDayString] intValue];
        int hour = [[self getHourString] intValue];
        int minute = [[self getMinuteString] intValue];
        self.mSelectDate = [NSDate br_setYear:year month:month day:day hour:hour minute:minute];
        self.mSelectValue = [NSString stringWithFormat:@"%04d-%02d-%02d %02d:%02d", year, month, day, hour, minute];
    }
    
    // 纠正选择日期（解决：由【自定义字符串】滚动到 其它日期时，或设置 minDate，日期联动不正确问题）
    if (_isAdjustSelectRow) {
        [self scrollToSelectDate:self.mSelectDate animated:NO];
    }
    
    // 禁止选择日期：回滚到上次选择的日期
    if (self.nonSelectableDates && self.nonSelectableDates.count > 0) {
        for (NSDate *date in self.nonSelectableDates) {
            if ([self br_compareDate:date targetDate:self.mSelectDate dateFormat:self.dateFormatter] == NSOrderedSame) {
                // 如果当前的日期不可选择，就回滚到上次选择的日期
                [self scrollToSelectDate:lastSelectDate animated:YES];
                self.mSelectDate = lastSelectDate;
                break;
            }
        }
    }
    
    // 滚动选择时执行 changeBlock 回调
    if (self.changeBlock) {
        self.changeBlock(self.mSelectDate, self.mSelectValue);
    }
    
    // 设置自动选择时，滚动选择时就执行 resultBlock
    if (self.isAutoSelect) {
        // 滚动完成后，执行block回调
        if (self.resultBlock) {
            self.resultBlock(self.mSelectDate, self.mSelectValue);
        }
    }
}

// 设置行高
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return self.pickerStyle.rowHeight;
}

#pragma mark - 重写父类方法
- (void)reloadData {
    // 1.处理数据源
    [self handlerPickerData];
    // 2.刷新选择器
    [self.pickerView reloadAllComponents];
    // 3.滚动到选择的日期
    [self scrollToSelectDate:self.mSelectDate animated:NO];
}

- (void)addPickerToView:(UIView *)view {
    _containerView = view;
    [self setupDateFormatter:self.pickerMode];
    // 1.添加日期选择器
    [self setupPickerView:self.pickerView toView:view];
    if (self.showUnitType == BRShowUnitTypeOnlyCenter) {
        // 添加日期单位到选择器
        [self addUnitLabel];
    }
    
    // ③添加中间选择行的两条分割线
    if (self.pickerStyle.clearPickerNewStyle) {
        [self.pickerStyle addSeparatorLineView:self.pickerView];
    }
    
    // 2.绑定数据
    [self reloadData];
    
    __weak typeof(self) weakSelf = self;
    self.doneBlock = ^{
        // 点击确定按钮后，执行block回调
        [weakSelf removePickerFromView:view];
        
        if (weakSelf.resultBlock) {
            weakSelf.resultBlock(weakSelf.mSelectDate, weakSelf.mSelectValue);
        }
    };
    
    [super addPickerToView:view];
}

#pragma mark - 添加日期单位到选择器
- (void)addUnitLabel {
    if (self.unitLabelArr.count > 0) {
        for (UILabel *unitLabel in self.unitLabelArr) {
            [unitLabel removeFromSuperview];
        }
        self.unitLabelArr = nil;
    }
    self.unitLabelArr = [self setupPickerUnitLabel:self.pickerView unitArr:self.unitArr];
}

#pragma mark - 重写父类方法
- (void)addSubViewToPicker:(UIView *)customView {
    [self.pickerView addSubview:customView];
}

#pragma mark - 弹出选择器视图
- (void)show {
    [self addPickerToView:nil];
}

#pragma mark - 关闭选择器视图
- (void)dismiss {
    [self removePickerFromView:nil];
}

#pragma mark - setter 方法
- (void)setPickerMode:(BRDatePickerMode)pickerMode {
    _pickerMode = pickerMode;
    // 非空，表示二次设置
    if (_pickerView) {
        [self setupDateFormatter:pickerMode];
        [self setupPickerView:self.pickerView toView:_containerView];
        // 刷新选择器数据
        [self reloadData];
        if (self.showUnitType == BRShowUnitTypeOnlyCenter) {
            // 添加日期单位到选择器
            [self addUnitLabel];
        }
    }
}

// 支持动态设置选择的值
- (void)setSelectDate:(NSDate *)selectDate {
    _selectDate = selectDate;
    _mSelectDate = selectDate;
    if (_pickerView) {
        // 刷新选择器数据
        [self reloadData];
    }
}

- (void)setSelectValue:(NSString *)selectValue {
    _selectValue = selectValue;
    _mSelectValue = selectValue;
    if (_pickerView) {
        // 刷新选择器数据
        [self reloadData];
    }
}

#pragma mark - getter 方法
- (NSArray *)yearArr {
    if (!_yearArr) {
        _yearArr = [NSArray array];
    }
    return _yearArr;
}

- (NSArray *)monthArr {
    if (!_monthArr) {
        _monthArr = [NSArray array];
    }
    return _monthArr;
}

- (NSArray *)dayArr {
    if (!_dayArr) {
        _dayArr = [NSArray array];
    }
    return _dayArr;
}

- (NSArray *)hourArr {
    if (!_hourArr) {
        _hourArr = [NSArray array];
    }
    return _hourArr;
}

- (NSArray *)minuteArr {
    if (!_minuteArr) {
        _minuteArr = [NSArray array];
    }
    return _minuteArr;
}

- (NSArray *)secondArr {
    if (!_secondArr) {
        _secondArr = [NSArray array];
    }
    return _secondArr;
}

- (NSInteger)minuteInterval {
    if (_minuteInterval < 1 || _minuteInterval > 30) {
        _minuteInterval = 1;
    }
    return _minuteInterval;
}

- (NSInteger)secondInterval {
    if (_secondInterval < 1 || _secondInterval > 30) {
        _secondInterval = 1;
    }
    return _secondInterval;
}

- (NSArray *)unitArr {
    if (!_unitArr) {
        _unitArr = [NSArray array];
    }
    return _unitArr;
}

- (NSArray<UILabel *> *)unitLabelArr {
    if (!_unitLabelArr) {
        _unitLabelArr = [NSArray array];
    }
    return _unitLabelArr;
}

- (NSArray<NSString *> *)monthNames {
    if (!_monthNames) {
        if (self.monthNameType == BRMonthNameTypeFullName) {
            _monthNames = @[@"January", @"February", @"March", @"April", @"May", @"June", @"July", @"August", @"September", @"October", @"November", @"December"];
        } else {
            _monthNames = @[@"Jan", @"Feb", @"Mar", @"Apr", @"May", @"Jun", @"Jul", @"Aug", @"Sep", @"Oct", @"Nov", @"Dec"];
        }
    }
    return _monthNames;
}

- (NSString *)getYearString {
    NSInteger index = 0;
    if (self.yearIndex >= 0 && self.yearIndex < self.yearArr.count) {
        index = self.yearIndex;
    }
    return [self.yearArr objectAtIndex:index];
}

- (NSString *)getMonthString {
    NSInteger index = 0;
    if (self.monthIndex >= 0 && self.monthIndex < self.monthArr.count) {
        index = self.monthIndex;
    }
    return [self.monthArr objectAtIndex:index];
}

- (NSString *)getDayString {
    NSInteger index = 0;
    if (self.dayIndex >= 0 && self.dayIndex < self.dayArr.count) {
        index = self.dayIndex;
    }
    return [self.dayArr objectAtIndex:index];
}

- (NSString *)getHourString {
    NSInteger index = 0;
    if (self.hourIndex >= 0 && self.hourIndex < self.hourArr.count) {
        index = self.hourIndex;
    }
    return [self.hourArr objectAtIndex:index];
}

- (NSString *)getMinuteString {
    NSInteger index = 0;
    if (self.minuteIndex >= 0 && self.minuteIndex < self.minuteArr.count) {
        index = self.minuteIndex;
    }
    return [self.minuteArr objectAtIndex:index];
}

- (NSString *)getSecondString {
    NSInteger index = 0;
    if (self.secondIndex >= 0 && self.secondIndex < self.secondArr.count) {
        index = self.secondIndex;
    }
    return [self.secondArr objectAtIndex:index];
}

@end
