//
//  BRDatePickerView.h
//  BRPickerViewDemo
//
//  Created by prorigor on 2021/5/4.
//  Copyright © 2021 prorigor. All rights reserved.
//

#import "BRBaseView.h"
#import "NSDate+BRPickerView.h"

NS_ASSUME_NONNULL_BEGIN

/// 日期选择器格式
typedef NS_ENUM(NSInteger, BRDatePickerMode) {
    // ----- 以下是自定义样式 -----
    /** 【yyyy-MM-dd HH:mm】年月日时分 */
    BRDatePickerModeYMDHM,
};

/// 日期单位显示的位置
typedef NS_ENUM(NSInteger, BRShowUnitType) {
    /** 日期单位显示全部行（默认）*/
    BRShowUnitTypeAll,
    /** 日期单位仅显示中间行 */
    BRShowUnitTypeOnlyCenter,
    /** 日期单位不显示（隐藏日期单位）*/
    BRShowUnitTypeNone
};

/// 月份名称类型
typedef NS_ENUM(NSInteger, BRMonthNameType) {
    /** 月份英文全称 */
    BRMonthNameTypeFullName,
    /** 月份英文简称 */
    BRMonthNameTypeShortName,
    /** 月份数字 */
    BRMonthNameTypeNumber
};

typedef void (^BRDateResultBlock)(NSDate * _Nullable selectDate, NSString * _Nullable selectValue);

@interface BRDatePickerView : BRBaseView

/**
 //////////////////////////////////////////////////////////////////////////
 ///
 ///   【用法一】
 ///    特点：灵活，扩展性强（推荐使用！）
 ///
 ////////////////////////////////////////////////////////////////////////*/

/** 日期选择器显示类型 */
@property (nonatomic, assign) BRDatePickerMode pickerMode;

/** 设置选中的日期（推荐使用 selectDate） */
@property (nullable, nonatomic, strong) NSDate *selectDate;
@property (nullable, nonatomic, copy) NSString *selectValue;

/** 最小日期（可使用 NSDate+BRPickerView 分类中对应的方法进行创建）*/
@property (nullable, nonatomic, strong) NSDate *minDate;
/** 最大日期（可使用 NSDate+BRPickerView 分类中对应的方法进行创建）*/
@property (nullable, nonatomic, strong) NSDate *maxDate;

/** 选择结果的回调 */
@property (nullable, nonatomic, copy) BRDateResultBlock resultBlock;

/** 滚动选择时触发的回调 */
@property (nullable, nonatomic, copy) BRDateResultBlock changeBlock;

/** 日期单位显示类型 */
@property (nonatomic, assign) BRShowUnitType showUnitType;

/** 是否显示【星期】，默认为 NO */
@property (nonatomic, assign, getter=isShowWeek) BOOL showWeek;

/** 是否显示【今天】，默认为 NO */
@property (nonatomic, assign, getter=isShowToday) BOOL showToday;

/** 选择器上数字是否带有前导零，默认为 NO（如：无前导零:2020-1-1；有前导零:2020-01-01）*/
@property (nonatomic, assign, getter=isNumberFullName) BOOL numberFullName;

/** 设置分的时间间隔，默认为1（范围：1 ~ 30）*/
@property (nonatomic, assign) NSInteger minuteInterval;

/** 设置秒的时间间隔，默认为1（范围：1 ~ 30）*/
@property (nonatomic, assign) NSInteger secondInterval;

/** for `BRDatePickerModeYMD` or `BRDatePickerModeYM`, ignored otherwise. */
@property (nonatomic, assign) BRMonthNameType monthNameType;

/** 设置时区，默认为当前时区 */
@property (nullable, nonatomic, copy) NSTimeZone *timeZone;

/** 指定不允许选择的日期 */
@property (nullable, nonatomic, copy) NSArray <NSDate *> *nonSelectableDates;

/// 初始化日期选择器
/// @param pickerMode  日期选择器显示类型
- (instancetype)initWithPickerMode:(BRDatePickerMode)pickerMode;

/// 弹出选择器视图
- (void)show;

/// 关闭选择器视图
- (void)dismiss;

//================================================= 华丽的分割线 =================================================

/**
 //////////////////////////////////////////////////////////////////////////
 ///
 ///   【用法二】：快捷使用，直接选择下面其中的一个方法进行使用
 ///    特点：快捷，方便
 ///
 ////////////////////////////////////////////////////////////////////////*/

/**
 *  1.显示日期选择器
 *
 *  @param mode             日期显示类型
 *  @param title            选择器标题
 *  @param selectValue      默认选中的日期（默认选中当前日期）
 *  @param resultBlock      选择结果的回调
 *
 */
+ (void)showDatePickerWithMode:(BRDatePickerMode)mode
                         title:(nullable NSString *)title
                   selectValue:(nullable NSString *)selectValue
                   resultBlock:(nullable BRDateResultBlock)resultBlock;

/**
 *  2.显示日期选择器
 *
 *  @param mode             日期显示类型
 *  @param title            选择器标题
 *  @param selectValue      默认选中的日期（默认选中当前日期）
 *  @param isAutoSelect     是否自动选择，即滚动选择器后就执行结果回调，默认为 NO
 *  @param resultBlock      选择结果的回调
 *
 */
+ (void)showDatePickerWithMode:(BRDatePickerMode)mode
                         title:(nullable NSString *)title
                   selectValue:(nullable NSString *)selectValue
                  isAutoSelect:(BOOL)isAutoSelect
                   resultBlock:(nullable BRDateResultBlock)resultBlock;

/**
 *  3.显示日期选择器
 *
 *  @param mode             日期显示类型
 *  @param title            选择器标题
 *  @param selectValue      默认选中的日期（默认选中当前日期）
 *  @param minDate          最小日期（可使用 NSDate+BRPickerView 分类中对应的方法进行创建）
 *  @param maxDate          最大日期（可使用 NSDate+BRPickerView 分类中对应的方法进行创建）
 *  @param isAutoSelect     是否自动选择，即滚动选择器后就执行结果回调，默认为 NO
 *  @param resultBlock      选择结果的回调
 *
 */
+ (void)showDatePickerWithMode:(BRDatePickerMode)mode
                         title:(nullable NSString *)title
                   selectValue:(nullable NSString *)selectValue
                       minDate:(nullable NSDate *)minDate
                       maxDate:(nullable NSDate *)maxDate
                  isAutoSelect:(BOOL)isAutoSelect
                   resultBlock:(nullable BRDateResultBlock)resultBlock;


@end

NS_ASSUME_NONNULL_END
