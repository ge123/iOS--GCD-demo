//
//  ViewController.m
//  test-mutilThread
//
//  Created by 高召葛 on 2019/5/15.
//  Copyright © 2019 高召葛. All rights reserved.
//

#import "ViewController.h"
#import "GZGDCThreadManager.h"


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[GZGDCThreadManager shareInstence] execute];
}





@end
