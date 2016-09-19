//
//  SubjectViewController.m
//  RAC1-1
//
//  Created by Meng Fan on 16/9/19.
//  Copyright © 2016年 Meng Fan. All rights reserved.
//

#import "SubjectViewController.h"
#import "ViewController.h"

//#import <ReactiveCocoa/ReactiveCocoa.h>

@interface SubjectViewController ()

@property (nonatomic, strong) UIButton *popBtn;

@end

@implementation SubjectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor lightGrayColor];
    [self setUpViews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - setUpViews
- (void)setUpViews {
    self.popBtn.frame = CGRectMake(10, 100, 100, 30);
    [self.view addSubview:self.popBtn];
    
    //target事件
    [[self.popBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        [self.subject sendNext:@"subjectVC"];
        [self.navigationController popViewControllerAnimated:YES];
    }];
    //RAC最基本的入门使用技巧就是对事件的监听，target－action
    /*
     监听textfild的文字改变还有更简单的写法：
     [[self.textFild rac_textSignal] subscribeNext:^(id x) {
         NSLog(@"%@",x);
     }];
     
     给label添加一个手势动作，也可以由RAC来完成：
     UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
     [[tap rac_gestureSignal] subscribeNext:^(id x) {
         NSLog(@"tap");
     }];
     [self.view addGestureRecognizer:tap];
     
     给button添加事件：
     [[self.OKBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
         NSLog(@"OK按钮被点击");
     }];
     */
}

/**
 *  总结：
 我们完全可以用RACSubject代替代理/通知，确实方便许多
 这里我们点击TwoViewController的pop的时候 将字符串"ws"传给了ViewController的button的title。
 步骤：
 // 1.创建信号
 RACSubject *subject = [RACSubject subject];
 
 // 2.订阅信号
 [subject subscribeNext:^(id x) {
     // block:当有数据发出的时候就会调用
     // block:处理数据
     NSLog(@"%@",x);
 }];
 
 // 3.发送信号
 [subject sendNext:value];
 
 **注意：~~**
     RACSubject和RACReplaySubject的区别
     RACSubject必须要先订阅信号之后才能发送信号， 而RACReplaySubject可以先发送信号后订阅.
     RACSubject 代码中体现为：先走TwoViewController的sendNext，后走ViewController的subscribeNext订阅
     RACReplaySubject 代码中体现为：先走ViewController的subscribeNext订阅，后走TwoViewController的sendNext可按实际情况各取所需。
 
 */

#pragma mark - lazyloading
-(UIButton *)popBtn {
    if (!_popBtn) {
        _popBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _popBtn.backgroundColor = [UIColor cyanColor];
        [_popBtn setTitle:@"pop" forState:UIControlStateNormal];
    }
    return _popBtn;
}

@end
