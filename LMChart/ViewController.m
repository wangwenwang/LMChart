//
//  ViewController.m
//  LMChart
//
//  Created by 凯东源 on 2017/11/8.
//  Copyright © 2017年 LM. All rights reserved.
//

#import "ViewController.h"
#import "PolylineView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    PolylineView *polyLine = [[PolylineView alloc]initWithFrame:CGRectMake(0,0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width)];
    [self.view addSubview:polyLine];
    
    // 模拟数据
    NSArray *data = @[@200, @812.562, @342.8, @500];
    NSArray *axisXMark = @[@"1月份", @"2月份", @"3月份", @"4月份"];
    polyLine.data = data;
    polyLine.axisXMark = axisXMark;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
