//
//  ViewController.m
//  RAC1-4
//
//  Created by Meng Fan on 16/9/20.
//  Copyright © 2016年 Meng Fan. All rights reserved.
//

#import "ViewController.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "RequestViewModel.h"

@interface ViewController ()

@property (nonatomic, strong) RequestViewModel *viewModel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //逻辑操作
    [self operationAction];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//逻辑操作
- (void)operationAction {
    //发送网络请求
    RACSignal *signal = [self.viewModel.requestCommand execute:nil];
    [signal subscribeNext:^(id x) {
        NSLog(@"controller:%@", x);
    }];
}

#pragma mark - lazyloading
-(RequestViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[RequestViewModel alloc] init];
    }
    return _viewModel;
}

@end
