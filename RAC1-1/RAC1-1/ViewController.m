//
//  ViewController.m
//  RAC1-1
//
//  Created by Meng Fan on 16/9/19.
//  Copyright © 2016年 Meng Fan. All rights reserved.
//

#import "ViewController.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "SubjectViewController.h"

@interface ViewController ()

@property (nonatomic, strong) UIButton *subjectBtn;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    
//    //***************** 我是华丽的分割线 *****************
//    //一、RACSignal
//    /*理论：
//     信号可以看做是传递信号的工具，当数据发生变化时，信号会发送改变的信息，以通知信号的订阅者执行方法。默认一个信号是冷信号，即使值改变也不会触发，只有订阅了这个信号才会变成热信号，值改变了才会触发。
//        核心：信号类
//        作用：只要数据改变，就会把数据包装成信号传递出去
//        触发条件：数据改变，信号发出
//        执行方法：通知信号的订阅者
//        实现思路：当一个信号被订阅，创建订阅者，并把nextBlock保存到订阅者里面；
//                创建信号会调用[RACDynamicSignal createSignal:didSubscribe];
//                发送信号时[subscriber sendNext:value];
//                订阅者会调用nextBlock
//     */
//    
//    //***************** 我是华丽的分割线 *****************
//    //1、创建信号
//    RACSignal *signal1 = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
//        //3、发送信号
//        [subscriber sendNext:@"This is signal1"];
//        
//        [subscriber sendCompleted];
//        //4、取消信号：若信号要被取消，就必须返回取消信号的类
//        return [RACDisposable disposableWithBlock:^{
//            NSLog(@"cancel signal1");
//        }];
//    }];
//    
//    //2、订阅信号:返回值是一个取消订阅信号的类
//    RACDisposable *disposable1 = [signal1 subscribeNext:^(id x) {
//        //signal1发送信号后，就会调用这个nextBlock
//        NSLog(@"signal======%@", x);
//    } error:^(NSError *error) {
//        NSLog(@"signal1 error=====%@", error);
//    } completed:^{
//        NSLog(@"signal1 =====complete");
//    }];
//    //取消订阅
//    [disposable1 dispose];
//    
//    //疑问：1、发送完信号一定要取消信号吗？   不一定，也可以返回nil
//    //     2、返回取消信号和[disposable1 dispose];要同时都有吗？ 不造，谁知道答案可以告诉我！
    
    
    //二
    [self setUpViews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - setUpViews
- (void)setUpViews {
    self.subjectBtn.frame = CGRectMake(10, 100, 100, 30);
    [self.view addSubview:self.subjectBtn];
    
    [[self.subjectBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        SubjectViewController *vc = [[SubjectViewController alloc] init];
        
        vc.subject = [RACSubject subject];
        [vc.subject subscribeNext:^(id x) {
            NSLog(@"subject====%@", x);
            // 这里的x便是sendNext发送过来的信号
        }];
        
        [self.navigationController pushViewController:vc animated:YES];
    }];
}

#pragma mark - lazyloading
-(UIButton *)subjectBtn {
    if (!_subjectBtn) {
        _subjectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _subjectBtn.backgroundColor = [UIColor brownColor];
        [_subjectBtn setTitle:@"push" forState:UIControlStateNormal];
    }
    return _subjectBtn;
}

@end
