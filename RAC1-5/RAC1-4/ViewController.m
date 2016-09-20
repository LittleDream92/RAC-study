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
    
    //逻辑操作
    [self operationAction];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//逻辑操作
- (void)operationAction {
    
    //MVVM
    //vm：视图模型——处理展示的业务逻辑
    //每个控制器都对应一个VM模型
    
    //组合信号
    RACSignal *loginEnableSignal = [RACSignal combineLatest:@[self.account.rac_textSignal, self.password.rac_textSignal] reduce:^id(NSString *account, NSString *pwd){
        return @(account.length && pwd.length);
    }];
    //loginBtn是否可用
    RAC(self.loginBtn, enabled) = loginEnableSignal;
    
    //创建登陆命令
    RACCommand *command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        // block调用：执行命令就会调用
        // block作用：事件处理
        // 发送登录请求
        NSLog(@"发送登录请求");
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                //发送数据
                [subscriber sendNext:@"发送登陆的数据"];
                [subscriber sendCompleted]; //一定得写
            });
        
           return nil;
        }];
    }];
    
    // 获取登陆命令中的信号源
    [command.executionSignals.switchToLatest subscribeNext:^(id x) {
        NSLog(@"%@", x);
    }];
    
    // 监听命令执行过程
    [[command.executing skip:1] subscribeNext:^(id x)  {    // 跳过第一步（没有执行这步）
        if ([x boolValue] == YES) {
            NSLog(@"--正在执行");
            // 显示蒙版
        }else { //执行完成
            NSLog(@"执行完成");
            // 取消蒙版
        }
    }];
    
    // 监听登录按钮点击
    [[self.loginBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        NSLog(@"点击登录按钮");
        // 处理登录事件
        [command execute:nil];
    }];
}

//2016-09-20 11:15:04.279 RAC1-4[2115:53158] 点击登录按钮
//2016-09-20 11:15:04.296 RAC1-4[2115:53158] 发送登录请求
//2016-09-20 11:15:04.489 RAC1-4[2115:53158] --正在执行
//2016-09-20 11:15:04.991 RAC1-4[2115:53158] 发送登陆的数据
//2016-09-20 11:15:04.991 RAC1-4[2115:53158] 执行完成

#pragma mark - lazyloading
-(LoginViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[LoginViewModel alloc] init];
    }
    return _viewModel;
}

@end
