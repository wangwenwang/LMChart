//
//  MarkModel.h
//  LMChart
//
//  Created by 凯东源 on 2017/11/3.
//  Copyright © 2017年 iOS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MarkModel : NSObject

// 位置
@property (assign, nonatomic) CGRect rect;

// 文字
@property (strong, nonatomic) NSString *text;

// Layer
@property (strong, nonatomic) CAShapeLayer *layer;

// Center
@property (assign, nonatomic) CGPoint point;

@end
