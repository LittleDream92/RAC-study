//
//  ViewController.m
//  RAC1-4
//
//  Created by Meng Fan on 16/9/20.
//  Copyright © 2016年 Meng Fan. All rights reserved.
//

#import "ViewController.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "LoginViewModel.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UITextField *account;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;

@property (nonatomic, strong) LoginViewModel *viewModel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // MVVM:
    // VM:视图模型----处理展示的业务逻辑  最好不要包括视图
    // 每一个控制器都对应一个VM模型
    // MVVM:开发中先创建VM，把业务逻辑处理好，然后在控制器里执行
    [self operationAction];
    [self loginEvent];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//逻辑操作
- (void)operationAction {
    //1、给视图模型的帐号和密码绑定信息
    RAC(self.viewModel, account) = self.account.rac_textSignal;
    RAC(self.viewModel, pwd) = self.password.rac_textSignal;
}

- (void)loginEvent {
    // 1.处理文本框业务逻辑--- 设置按钮是否能点击
    RAC(self.loginBtn, enabled) = self.viewModel.loginEnableSignal;
    // 2.监听登录按钮点击
    [[self.loginBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        NSLog(@"点击登录按钮");
        // 处理登录事件
        [self.viewModel.loginCommand execute:nil];
        
    }];
}


#pragma mark - lazyloading
-(LoginViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[LoginViewModel alloc] init];
    }
    return _viewModel;
}

@end
