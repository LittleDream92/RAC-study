//
//  ViewController.m
//  RAC1-3
//
//  Created by Meng Fan on 16/9/19.
//  Copyright © 2016年 Meng Fan. All rights reserved.
//

#import "ViewController.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "RACReturnSignal.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *textField;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    //七、RAC-bind绑定
    [self bindAction];
    
    //八、filter过滤
    [self filterAction];
    
    //九、map映射
    [self mapAction];
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 7、bind
- (void)bindAction {
    //绑定的实现思路：拦截API从而可以对数据进行操作，，而影响返回数据。
    
    //1、创建信号
    RACSubject *subject = [RACSubject subject];
    //2、绑定信号
    RACSignal *bindSignal = [subject bind:^RACStreamBindBlock{
        // block调用时刻：只要绑定信号订阅就会调用。不做什么事情，
        return ^RACSignal *(id value, BOOL *stop) {
            // 一般在这个block中做事 ，发数据的时候会来到这个block。
            // 只要源信号（subject）发送数据，就会调用block
            // block作用：处理源信号内容
            // value:源信号发送的内容，
            
            NSLog(@"接收到原信号的内容：%@", value);
            
            value = @3;
            //返回信号，不能为nil,如果非要返回空---则empty或 alloc init。
            // 把返回的值包装成信号
            return [RACReturnSignal return:value];
        };
    }];
    
    //3、订阅绑定信号
    [bindSignal subscribeNext:^(id x) {
        NSLog(@"接收到处理完的信号：%@", x);
    }];
    
    //4、发送信号
    [subject sendNext:@"123"];
}

#pragma mark - 8、filter
- (void)filterAction {
    //过滤有好多种，我们分别从不同的情况进行分析学习
    
    //跳跃：应用场景：当后台返回的数据钱敏几个没有用到的时候
    [self skipAction];
    
    //distinctUntilChanged:-- 如果当前的值跟上一次的值一样，就不会被订阅到
    [self distinctUtilChangedAction];
    
    // take:可以屏蔽一些值,去前面几个值---这里take为2 则只拿到前两个值
    [self take];
    
    [self takeLast];
    
    [self takeUntil];
    
    [self ignore];
    
    [self fliter];
}

- (void)skipAction {
    RACSubject *subject = [RACSubject subject];
    
    //跳过前两个
    [[subject skip:2] subscribeNext:^(id x) {
        NSLog(@"skip:%@", x);
    }];
    [subject sendNext:@1];
    [subject sendNext:@2];
    [subject sendNext:@3];
    [subject sendNext:@4];
}

- (void)distinctUtilChangedAction {
    RACSubject *subject = [RACSubject subject];
    [[subject distinctUntilChanged] subscribeNext:^(id x) {
        NSLog(@"distinctUtilChanged:%@", x);
    }];
    // 发送信号
    [subject sendNext:@1];
    [subject sendNext:@2];
    [subject sendNext:@2]; // 不会被订阅
}

// take:可以屏蔽一些值,去前面几个值---这里take为2 则只拿到前两个值
- (void)take {
    RACSubject *subject = [RACSubject subject];
    [[subject take:2] subscribeNext:^(id x) {
        NSLog(@"take:%@", x);
    }];
    // 发送信号
    [subject sendNext:@1];
    [subject sendNext:@2];
    [subject sendNext:@3];
}

//takeLast:和take的用法一样，不过他取的是最后的几个值，如下，则取的是最后两个值
//注意点:takeLast 一定要调用sendCompleted，告诉他发送完成了，这样才能取到最后的几个值
- (void)takeLast {
    RACSubject *subject = [RACSubject subject];
    [[subject takeLast:2] subscribeNext:^(id x) {
        NSLog(@"takeLast:%@", x);
    }];
    // 发送信号
    [subject sendNext:@1];
    [subject sendNext:@2];
    [subject sendNext:@3];
    [subject sendCompleted];
}

// takeUntil:---给takeUntil传的是哪个信号，那么当这个信号发送信号或sendCompleted，就不能再接受源信号的内容了。
- (void)takeUntil {
    RACSubject *subject = [RACSubject subject];
    RACSubject *subject2 = [RACSubject subject];
    [[subject takeUntil:subject2] subscribeNext:^(id x) {
        NSLog(@"takeUntil:%@", x);
    }];
    // 发送信号
    [subject sendNext:@1];
    [subject sendNext:@2];
    [subject2 sendNext:@3];  // 1
    //    [subject2 sendCompleted]; // 或2
    [subject sendNext:@4];
}

// ignore: 忽略掉一些值
- (void)ignore {
    //ignore:忽略一些值
    //ignoreValues:表示忽略所有的值
    // 1.创建信号
    RACSubject *subject = [RACSubject subject];
    // 2.忽略一些值
    RACSignal *ignoreSignal = [subject ignore:@2]; // ignoreValues:表示忽略所有的值
    // 3.订阅信号
    [ignoreSignal subscribeNext:^(id x) {
        NSLog(@"ignore:%@", x);
    }];
    // 4.发送数据
    [subject sendNext:@2];
    [subject sendNext:@3];
    
}

// 一般和文本框一起用，添加过滤条件
- (void)fliter {
    // 只有当文本框的内容长度大于5，才获取文本框里的内容
    [[self.textField.rac_textSignal filter:^BOOL(id value) {
        // value 源信号的内容
        return [value length] > 5;
        // 返回值 就是过滤条件。只有满足这个条件才能获取到内容
    }] subscribeNext:^(id x) {
        NSLog(@"fliter:%@", x);
    }];
}

#pragma mark - 9、map  映射
- (void)mapAction {
    
}

@end
