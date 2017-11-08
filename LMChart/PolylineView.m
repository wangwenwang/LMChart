//
//  PolylineView.m
//  LMChart
//
//  Created by 凯东源 on 2017/11/8.
//  Copyright © 2017年 LM. All rights reserved.
//

#import "PolylineView.h"
#import "MarkModel.h"

@interface PolylineView ()

// Y轴长度
@property (assign, nonatomic) CGFloat axisY_height;

// X轴长度
@property (assign, nonatomic) CGFloat axisX_width;

// 描点
@property (strong, nonatomic) NSMutableArray *dataMarks;

// 画线
@property (strong, nonatomic) CAShapeLayer *lineChartLayer;


@end

static NSInteger countq = 0;

@implementation PolylineView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
        _axisY_top = 80;
        _axisY_height = 200;
        _axisY_edge = 30;
        _axisX_width = 250;
        _maxAxisYMarkWidth = 150;
    }
    return self;
}


- (void)setData:(NSArray *)data {
    
    _data = data;
}


- (void)drawRect:(CGRect)rect {
    
    // 筛选最大值
    CGFloat maxValue = [[_data valueForKeyPath:@"@max.floatValue"] floatValue];
    
    // 画X、Y轴
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineWidth(context, 1.5);
    CGContextSetAllowsAntialiasing(context, true);
    CGContextSetRGBStrokeColor(context, 70.0 / 255.0, 241.0 / 255.0, 241.0 / 255.0, 1.0);
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, _axisY_edge, _axisY_top);
    CGContextAddLineToPoint(context, _axisY_edge, _axisY_top + _axisY_height);
    CGContextAddLineToPoint(context, _axisX_width + _axisY_edge, _axisY_top + _axisY_height);
    CGContextStrokePath(context);
    
    // 画Y轴参考线
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineWidth(context, 1.0);
    CGContextSetAllowsAntialiasing(context, true);
    CGContextSetRGBStrokeColor(context, 255 / 255.0, 255 / 255.0, 255 / 255.0, 0.4);
    CGContextBeginPath(context);
    CGFloat lineCount = 5;
    CGFloat eachValue = maxValue / lineCount;
    CGFloat oneLineYHeight = _axisY_height / lineCount;
    for (int i = 0; i < lineCount; i++) {
        CGContextMoveToPoint(context, 30, _axisY_top + oneLineYHeight * (lineCount - 1 - i) + 0.5);
        CGContextAddLineToPoint(context, _axisY_edge + _axisX_width, _axisY_top + oneLineYHeight * (lineCount - 1 - i) + 0.5);
    }
    CGContextStrokePath(context);
    
    // Y轴文字
    NSMutableArray *MarkModelArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < lineCount; i++) {
        MarkModel *markModel = [[MarkModel alloc] init];
        markModel.text = [NSString stringWithFormat:@"%.0f", eachValue * (i + 1)];
        UIFont *font;
        CGFloat oneLineHeight;
        CGFloat mulLineHeight;
        CGFloat fontSize = 13.5;
        do {
            fontSize -= 0.5;
            font = [UIFont fontWithName:@"Courier" size:fontSize];
            oneLineHeight = [self getHeightOfString:@"fds" font:font andWidth:_axisY_edge];
            mulLineHeight = [self getHeightOfString:markModel.text font:font andWidth:_axisY_edge];
        } while (mulLineHeight > oneLineHeight);
        
        CGFloat MarkModelX = 0;
        CGFloat MarkModelWidth = _axisY_edge;
        CGFloat MarkModelY = _axisY_top + oneLineYHeight * (lineCount - 1 - i) - mulLineHeight / 2;
        markModel.rect = CGRectMake(MarkModelX, MarkModelY, MarkModelWidth, mulLineHeight);
        [MarkModelArray addObject:markModel];
        CGContextSetRGBFillColor (context,  1, 0, 0, 1.0);
        
        NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        paragraphStyle.alignment = NSTextAlignmentRight;
        NSDictionary *attributes = @{ NSFontAttributeName: font,
                                      NSForegroundColorAttributeName: [UIColor greenColor],
                                      NSParagraphStyleAttributeName: paragraphStyle };
        [markModel.text drawInRect:markModel.rect withAttributes:attributes];
    }
    CGContextStrokePath(context);
    
    // 描点Label
    CGFloat oneColumnWidth = _axisX_width / _data.count;
    NSMutableArray *pointLabelArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < _data.count; i++) {
        MarkModel *pointLabel = [[MarkModel alloc] init];
        pointLabel.text = [self formatFloat:[_data[i] floatValue]];
        UIFont *font = [UIFont fontWithName:@"Courier" size:13];
        CGFloat pointLabelX = _axisY_edge + oneColumnWidth * i + oneColumnWidth / 2;
        CGFloat pointLabelY = _axisY_top + _axisY_height - [_data[i] intValue] / maxValue * _axisY_height;
        CGFloat pointLabelW = [self getWidthOfString:pointLabel.text font:font];
        CGFloat pointLabelH = [self getHeightOfString:pointLabel.text font:font andWidth:CGFLOAT_MAX];
        pointLabel.rect = CGRectMake(pointLabelX, pointLabelY, pointLabelW, pointLabelH);
        [pointLabelArray addObject:pointLabel];
    }
    _dataMarks = pointLabelArray;
    
    [self addDataMark];
    
    [self addLine];
    
    [self addDataMarkLabel:_dataMarks];
    
    [self addAxisXMark];
}


- (void)addAxisXMark {
    
    for (int i = (int)(self.subviews.count - 1); i >= 0; i--) {
        UIView *v = self.subviews[i];
        if(v.tag == 1002) [v removeFromSuperview];
    }
    
    CGFloat minFontSize = MAXFLOAT;
    for (int i = 0; i < _axisXMark.count; i++) {
        UIFont *font;
        CGFloat oneLineHeight;
        CGFloat mulLineHeight;
        CGFloat fontSize = 13.5;
        CGFloat oneColumnWidth = _axisX_width / _data.count;
        do {
            fontSize -= 0.5;
            font = [UIFont fontWithName:@"Courier" size:fontSize];
            oneLineHeight = [self getHeightOfString:@"fds" font:font andWidth:MAXFLOAT];
            mulLineHeight = [self getHeightOfString:_axisXMark[i] font:font andWidth:oneColumnWidth];
        } while (mulLineHeight > oneLineHeight);
        minFontSize = MIN(minFontSize, fontSize);
    }
    
    // 方案一，横排
    if(minFontSize > 7.0) {
        for (int i = 0; i < _axisXMark.count; i++) {
            UIFont *font;
            CGFloat oneLineHeight;
            CGFloat mulLineHeight;
            CGFloat fontSize = 13.5;
            CGFloat oneColumnWidth = _axisX_width / _data.count;
            do {
                fontSize -= 0.5;
                font = [UIFont fontWithName:@"Courier" size:fontSize];
                oneLineHeight = [self getHeightOfString:@"fds" font:font andWidth:MAXFLOAT];
                mulLineHeight = [self getHeightOfString:_axisXMark[i] font:font andWidth:oneColumnWidth];
            } while (mulLineHeight > oneLineHeight);
            
            CGFloat axisXLabelHeight = 20;
            CGFloat axisXLabelY = _axisY_top +_axisY_height;
            CGFloat axisXLabelWidth = oneColumnWidth;
            CGFloat axisXLabelX = _axisY_edge + oneColumnWidth * i;
            
            UILabel *label = [[UILabel alloc] init];
            label.tag = 1002;
            label.font = font;
            label.text = _axisXMark[i];
            label.textColor = [UIColor greenColor];
            label.textAlignment = NSTextAlignmentCenter;
            [label setFrame:CGRectMake(axisXLabelX, axisXLabelY, axisXLabelWidth, axisXLabelHeight)];
            [self addSubview:label];
        }
    }
    
    // 方案二，斜排
    else {
        for (int i = 0; i < _axisXMark.count; i++) {
            UIFont *font;
            CGFloat oneLineHeight;
            CGFloat mulLineHeight;
            CGFloat fontSize = 13.5;
            CGFloat oneColumnWidth = _axisX_width / _data.count;
            CGFloat maxWidth = _maxAxisYMarkWidth;
            do {
                fontSize -= 0.5;
                font = [UIFont fontWithName:@"Courier" size:fontSize];
                oneLineHeight = [self getHeightOfString:@"fds" font:font andWidth:MAXFLOAT];
                mulLineHeight = [self getHeightOfString:_axisXMark[i] font:font andWidth:maxWidth];
            } while (mulLineHeight > oneLineHeight);
            
            CGFloat axisXLabelHeight = 20;
            CGFloat axisXLabelY = _axisY_top +_axisY_height - axisXLabelHeight / 2;
            CGFloat axisXLabelWidth = maxWidth;
            CGFloat axisXLabelX = _axisY_edge + oneColumnWidth * i - axisXLabelWidth / 2 + oneColumnWidth / 2;
            
            UILabel *label = [[UILabel alloc] init];
            label.tag = 1002;
            label.font = font;
            label.text = _axisXMark[i];
            label.textColor = [UIColor greenColor];
            [label setFrame:CGRectMake(axisXLabelX, axisXLabelY, axisXLabelWidth, axisXLabelHeight)];
            label.layer.anchorPoint = CGPointMake(0, 0);
            label.transform = CGAffineTransformMakeRotation(M_PI / 180 * 40);
            [self addSubview:label];
        }
    }
}


#pragma mark 描点
- (void)addDataMark {
    // 描点
    CGFloat oneColumnWidth = _axisX_width / _data.count;
    CGFloat maxValue = [[_data valueForKeyPath:@"@max.floatValue"] floatValue];
    
    // 先移除之前的layer
    [_dataMarks enumerateObjectsUsingBlock:^(MarkModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if(obj.layer) {
            [obj.layer removeFromSuperlayer];
        }
    }];
    
    for (int i = 0; i < _data.count; i++) {
        MarkModel *pointMark = _dataMarks[i];
        CGFloat pointX = _axisY_edge + oneColumnWidth * i + oneColumnWidth / 2;
        CGFloat pointY = _axisY_top + _axisY_height - [_data[i] floatValue] / maxValue * _axisY_height;
        CGPoint pointXY = CGPointMake(pointX, pointY);
        pointMark.point = pointXY;
        [[UIColor redColor] set];
        CGFloat pointW = 10;
        CGFloat pointH = 10;
        UIBezierPath *bezierPath_point = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(pointXY.x - pointW / 2, pointXY.y - pointH / 2, pointW, pointH)];
        CAShapeLayer *pointLayer = [CAShapeLayer layer];
        pointLayer.strokeColor = [UIColor redColor].CGColor;
        pointLayer.path = bezierPath_point.CGPath;
        [self.layer addSublayer:pointLayer];
        pointMark.layer = pointLayer;
    }
}


#pragma mark 描点Label
- (void)addDataMarkLabel:(NSMutableArray *)pointMarkData {
    
    for (int i = (int)(self.subviews.count - 1); i >= 0; i--) {
        UIView *v = self.subviews[i];
        if(v.tag == 1001) [v removeFromSuperview];
    }
    for (int i = 0; i < _data.count; i++) {
        MarkModel *pointLabel = pointMarkData[i];
        UIFont *font = [UIFont fontWithName:@"Courier" size:13];
        UILabel *label = [[UILabel alloc] init];
        label.tag = 1001;
        [label setFrame:pointLabel.rect];
        label.text = pointLabel.text;
        label.textColor = [UIColor greenColor];
        label.font = font;
        [self addSubview:label];
    }
}


#pragma mark 画线
- (void)addLine {
    // 画线
    UIBezierPath *bezierPath_line = [UIBezierPath bezierPath];
    for (int i = 0; i < _dataMarks.count; i++) {
        MarkModel *dataMark = _dataMarks[i];
        if(i == 0) {
            [bezierPath_line moveToPoint:dataMark.point];
        } else {
            [bezierPath_line addLineToPoint:dataMark.point];
        }
    }
    if(!_lineChartLayer) {
        _lineChartLayer = [CAShapeLayer layer];
    }
    _lineChartLayer.lineWidth = 4;
    _lineChartLayer.fillColor = [UIColor clearColor].CGColor;
    _lineChartLayer.strokeColor = [UIColor colorWithRed:0.76f green:0.89f blue:0.89f alpha:1.00f].CGColor;
    _lineChartLayer.lineCap = kCALineCapRound;
    _lineChartLayer.lineJoin = kCALineJoinRound;
    _lineChartLayer.path = bezierPath_line.CGPath;
    [self.layer addSublayer:_lineChartLayer];
    // 线条动画
    CABasicAnimation *checkAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    checkAnimation.duration = 2.0f;
    checkAnimation.fromValue = @(0.0f);
    checkAnimation.toValue = @(1.0f);
    checkAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [_lineChartLayer addAnimation:checkAnimation forKey:@"checkAnimation"];
}


#pragma mark 点击重新绘制折线和背景
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    countq++;
    
    if (countq%2 == 0) {
        
        [_lineChartLayer removeFromSuperlayer];
        [_dataMarks enumerateObjectsUsingBlock:^(MarkModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj.layer removeFromSuperlayer];
        }];
        for (int i = (int)(self.subviews.count - 1); i >= 0; i--) {
            UIView *v = self.subviews[i];
            if(v.tag == 1001) [v removeFromSuperview];
        }
    } else {
        
        [self addDataMark];
        
        [self addLine];
        
        [self addDataMarkLabel:_dataMarks];
    }
}


- (CGFloat)getHeightOfString:(nullable NSString *)text font:(UIFont *)font andWidth:(CGFloat)width {
    UILabel *label = [[UILabel alloc] init];
    label.text = text;
    label.font = font;
    label.numberOfLines = 0;
    label.lineBreakMode = NSLineBreakByCharWrapping;
    CGSize sizeToFit = [label sizeThatFits:CGSizeMake(width, MAXFLOAT)];
    return sizeToFit.height;
}


- (CGFloat)getWidthOfString:(nullable NSString *)text font:(UIFont *)font {
    UILabel *label = [[UILabel alloc] init];
    label.text = text;
    label.font = font;
    label.numberOfLines = 0;
    label.lineBreakMode = NSLineBreakByCharWrapping;
    CGSize sizeToFit = [label sizeThatFits:CGSizeMake(MAXFLOAT, MAXFLOAT)];
    return sizeToFit.width;
}


- (nullable NSString *)formatFloat:(float)f {
    if (fmodf(f, 1)==0) {
        return [NSString stringWithFormat:@"%.0f",f];
    } else if (fmodf(f*10, 1)==0) {//如果有一位小数点
        return [NSString stringWithFormat:@"%.1f",f];
    } else if (fmodf(f*100, 1)==0) {//如果有两位小数点
        return [NSString stringWithFormat:@"%.2f",f];
    } else if (fmodf(f*1000, 1)==0) {
        return [NSString stringWithFormat:@"%.3f",f];
    } else if (fmodf(f*10000, 1)==0) {
        return [NSString stringWithFormat:@"%.4f",f];
    } else {
        return [NSString stringWithFormat:@"%.5f",f];
    }
}

@end
