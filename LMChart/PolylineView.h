//
//  PolylineView.h
//  LMChart
//
//  Created by 凯东源 on 2017/11/8.
//  Copyright © 2017年 LM. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PolylineView : UIView


/**
 数据源
 */
@property (strong, nonatomic) NSArray *data;


/**
 X轴数据
 */
@property (strong, nonatomic) NSArray *axisXMark;


/**
 Y轴距上, 默认80
 */
@property (assign, nonatomic) CGFloat axisY_top;


/**
 Y轴距左, 默认30
 */
@property (assign, nonatomic) CGFloat axisY_edge;


/**
 Y轴Label最大宽度, 默认150
 */
@property (assign, nonatomic) CGFloat maxAxisYMarkWidth;

@end
