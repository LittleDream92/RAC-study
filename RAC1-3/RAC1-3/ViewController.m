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

@property (weak, nonatomic) IBOutlet UITextField *account;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UIButton *logonBtn;

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
    
    //十、combine 组合
    [self combineAction];
    
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
//在实际开发中，若我们想要拦截服务器返回的数据，给数据拼接特定的东西或想对数据进行操作从而更改返回值，类似于这样的情况下，我们便可以考虑用RAC的映射。
- (void)mapAction {
    
    [self map];
    [self flatMap];
    [self flattenMap2];
}

- (void)map {
    //创建信号
    RACSubject *subject = [RACSubject subject];
    //绑定信号
    RACSubject *bingSignal = [subject map:^id(id value) {
        //返回的类型就是你需要映射的值
        return [NSString stringWithFormat:@"1+%@", value];
    }];
    
    //订阅绑定信号
    [bingSignal subscribeNext:^(id x) {
        NSLog(@"map:%@", x);
    }];
    
    //发送信号
    [subject sendNext:@"234"];
}

- (void)flatMap {
    // 创建信号
    RACSubject *subject = [RACSubject subject];
    // 绑定信号
    RACSignal *bindSignal = [subject flattenMap:^RACStream *(id value) {
        // block：只要源信号发送内容就会调用
        // value: 就是源信号发送的内容
        // 返回信号用来包装成修改内容的值
        return [RACReturnSignal return:value];
        
    }];
    
    // flattenMap中返回的是什么信号，订阅的就是什么信号(那么，x的值等于value的值，如果我们操纵value的值那么x也会随之而变)
    // 订阅信号
    [bindSignal subscribeNext:^(id x) {
        NSLog(@"flattenMap:%@", x);
    }];
    
    // 发送数据
    [subject sendNext:@"123"];
}

- (void)flattenMap2 {
    // flattenMap 主要用于信号中的信号
    // 创建信号
    RACSubject *signalofSignals = [RACSubject subject];
    RACSubject *signal = [RACSubject subject];

    // 订阅信号
    //方式1
    //    [signalofSignals subscribeNext:^(id x) {
    //
    //        [x subscribeNext:^(id x) {
    //            NSLog(@"%@", x);
    //        }];
    //    }];
    // 方式2
    //    [signalofSignals.switchToLatest  ];
    // 方式3
    //   RACSignal *bignSignal = [signalofSignals flattenMap:^RACStream *(id value) {
    //
    //        //value:就是源信号发送内容
    //        return value;
    //    }];
    //    [bignSignal subscribeNext:^(id x) {
    //        NSLog(@"%@", x);
    //    }];
    // 方式4--------也是开发中常用的
    [[signalofSignals flattenMap:^RACStream *(id value) {
        return value;
    }] subscribeNext:^(id x) {
        NSLog(@"flattenMap2:%@", x);
    }];
    
    // 发送信号
    [signalofSignals sendNext:signal];
    [signal sendNext:@"123"];
}

#pragma mark - 10、combine 组合
- (void)combineAction {
    [self combineLatest];
    
    [self zipWith];
    
    [self merge];
    
    [self then];
    
    [self concat];
}

//把多个信号聚合成你想要的信号，使用场景：登录界面的账号密码输入框都有值时才能点击登陆按钮
//思路：把所有输入框的信号聚合成按钮是否能点击的信号
- (void)combineLatest {
    RACSignal *combineSignal = [RACSignal combineLatest:@[self.account.rac_textSignal, self.password.rac_textSignal] reduce:^id(NSString *account, NSString *pwd){
        //reduce里的参数一定要和combineLatest数组里的一一对应。
        // block: 只要源信号发送内容，就会调用，组合成一个新值。
        NSLog(@"%@ %@", account, pwd);
        return @(account.length && pwd.length);
    }];
    
//    // 订阅信号
//    [combinSignal subscribeNext:^(id x) {
//        self.loginBtn.enabled = [x boolValue];
//    }];    // ----这样写有些麻烦，可以简化为下边的RAC宏
    RAC(self.logonBtn, enabled) = combineSignal;
    
}

//zipWith:把两个信号压缩成一个信号，只有当两个信号同时发出信号内容时，并且把两个信号的内容合并成一个元祖，才会触发压缩流的next事件。
- (void)zipWith {
    
    //创建信号A/B
    RACSubject *signalA = [RACSubject subject];
    RACSubject *signalB = [RACSubject subject];
    
    //压缩成一个信号
    // **-zipWith-**: 当一个界面多个请求的时候，要等所有请求完成才更新UI
    // 等所有信号都发送内容的时候才会调用
    RACSignal *zipSignal = [signalA zipWith:signalB];
    
    [zipSignal subscribeNext:^(id x) {
        //所有的值都被包装成了元组
        NSLog(@"zipSignal:%@", x);
    }];
    
    // 发送信号 交互顺序，元组内元素的顺序不会变，跟发送的顺序无关，而是跟压缩的顺序有关[signalA zipWith:signalB]---先是A后是B
    [signalB sendNext:@2];
    [signalA sendNext:@1];  //print:{1, 2}跟谁先发出信号无关
}


// 任何一个信号请求完成都会被订阅到
// merge:多个信号合并成一个信号，任何一个信号有新值就会调用
- (void)merge {
    //创建信号A/B
    RACSubject *signalA = [RACSubject subject];
    RACSubject *signalB = [RACSubject subject];
    
    //组合信号
    RACSignal *mergeSignal = [signalA merge:signalB];
    
    // 订阅信号
    [mergeSignal subscribeNext:^(id x) {
        NSLog(@"mergeSignal:%@", x);
    }];
    
    // 发送信号---交换位置则数据结果顺序也会交换
    [signalB sendNext:@"下部分"];
    [signalA sendNext:@"上部分"];
}


// then --- 使用需求：有两部分数据：想让上部分先进行网络请求但是过滤掉数据，然后进行下部分的，拿到下部分数据
- (void)then {
    // 创建信号A
    RACSignal *signalA = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        // 发送请求
        NSLog(@"then----发送上部分请求---afn");
        
        [subscriber sendNext:@"上部分数据"];
        [subscriber sendCompleted]; // 必须要调用sendCompleted方法！
        return nil;
    }];

    // 创建信号B，
    RACSignal *signalsB = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        // 发送请求
        NSLog(@"then--发送下部分请求--afn");
        [subscriber sendNext:@"下部分数据"];
        return nil;
    }];
    
    // 创建组合信号
    // then;忽略掉第一个信号的所有值
    RACSignal *thenSignal = [signalA then:^RACSignal *{
        // 返回的信号就是要组合的信号
        return signalsB;
    }];

    // 订阅信号
    [thenSignal subscribeNext:^(id x) {
        NSLog(@"then:%@", x);
    }];
}


// concat----- 使用需求：有两部分数据：想让上部分先执行，完了之后再让下部分执行（都可获取值）
- (void)concat {
    // 创建信号A
    RACSignal *signalA = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        // 发送请求
        NSLog(@"concat----发送上部分请求---afn");
        
        [subscriber sendNext:@"上部分数据"];
        [subscriber sendCompleted]; // 必须要调用sendCompleted方法！
        return nil;
    }];

    // 创建信号B，
    RACSignal *signalsB = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        // 发送请求
        NSLog(@"concat--发送下部分请求--afn");
        [subscriber sendNext:@"下部分数据"];
        return nil;
    }];
    
    // concat:按顺序去链接
    //**-注意-**：concat，第一个信号必须要调用sendCompleted
    // 创建组合信号
    RACSignal *concatSignal = [signalA concat:signalsB];
    // 订阅组合信号
    [concatSignal subscribeNext:^(id x) {
        NSLog(@"concat:%@",x);
    }];
    
//    2016-09-20 10:46:22.950 RAC1-3[1183:25658] concat----发送上部分请求---afn
//    2016-09-20 10:46:22.950 RAC1-3[1183:25658] concat:上部分数据
//    2016-09-20 10:46:22.950 RAC1-3[1183:25658] concat--发送下部分请求--afn
//    2016-09-20 10:46:22.950 RAC1-3[1183:25658] concat:下部分数据
}

@end
