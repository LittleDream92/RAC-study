//
//  ViewController.m
//  RAC1-2
//
//  Created by Meng Fan on 16/9/19.
//  Copyright © 2016年 Meng Fan. All rights reserved.
//

#import "ViewController.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UITextField *input;

@property (nonatomic, strong) RACSignal *signal;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    //四、RACMulticastConnection
    /*
     类似于通知那样，发送一个通知，同时有多个接收者，RAC可以用RACMulticastConnection来实现
     */
    [self racConnectAction];
    
    
    //五、RACCommand
    /*
     RAC中用于处理事件的类，可以把事件如何处理，事件中的数据如何传递，包装到这个类中，他可以很方便的监控事件的执行过程，比如看事件有没有执行完毕
     使用场景：监听按钮点击，网络请求
     */
    [self commandAction];
    
    
    //六、RAC常用的宏
    [self racCommonSetting];
}


#pragma mark - 4、RACMulticastConnection
/*
- (void)racConnectAction {
    
//     不用RACMulticastConnection的普通写法，缺点：每订阅一次信号就得重新创建并且发送请求，这样不友好
    
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSLog(@"发送请求啦");
        //发送信号
        [subscriber sendNext:@"racConnectAction"];
        return nil;
    }];
    
    [signal subscribeNext:^(id x) {
        NSLog(@"1:%@", x);
    }];
    
    [signal subscribeNext:^(id x) {
        NSLog(@"2:%@", x);
    }];
    
    [signal subscribeNext:^(id x) {
        NSLog(@"3:%@", x);
    }];
    
//    2016-09-19 14:45:16.791 RAC1-2[8912:242492] 发送请求啦
//    2016-09-19 14:45:16.792 RAC1-2[8912:242492] 1:racConnectAction
//    2016-09-19 14:45:16.792 RAC1-2[8912:242492] 发送请求啦
//    2016-09-19 14:45:16.792 RAC1-2[8912:242492] 2:racConnectAction
//    2016-09-19 14:45:16.792 RAC1-2[8912:242492] 发送请求啦
//    2016-09-19 14:45:16.792 RAC1-2[8912:242492] 3:racConnectAction

}
 
 */


- (void)racConnectAction {
//      比较好的做法，使用RACMulticastConnection，无论有多少个订阅者，无论订阅多少次，我都只发送一遍
    //1、发送请求，用一个信号内包装，不管有多少个订阅者，只发送一次请求
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSLog(@"发送请求啦");
        //发送信号
        [subscriber sendNext:@"racConnectAction"];
        return nil;
    }];

    //创建连接类
    RACMulticastConnection *connection = [signal publish];
    [connection.signal subscribeNext:^(id x) {
        NSLog(@"1:%@", x);
    }];
    [connection.signal subscribeNext:^(id x) {
        NSLog(@"2:%@", x);
    }];
    [connection.signal subscribeNext:^(id x) {
        NSLog(@"3:%@", x);
    }];
    //3、连接，只有连接了才会把信号源变成热信号
    [connection connect];

//    2016-09-19 14:44:07.639 RAC1-2[8867:241433] 发送请求啦
//    2016-09-19 14:44:07.640 RAC1-2[8867:241433] 1:racConnectAction
//    2016-09-19 14:44:07.640 RAC1-2[8867:241433] 2:racConnectAction
//    2016-09-19 14:44:07.640 RAC1-2[8867:241433] 3:racConnectAction
}

#pragma mark - 5、RACCommand
//普通做法
/*
- (void)commandAction {
    //RACCommand：处理事件，不能返回空的信号
    //1、创建命令
    RACCommand *command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        //block调用，执行命令的时候就会调用; input:执行命令的参数
        NSLog(@"%@", input);
        
        //此处返回不能为nil
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            [subscriber sendNext:@"执行命令产生的数据"];
            return nil;
        }];
    }];
    
    
    //如何拿到执行命令中产生的数据？
    //订阅命令内部
    //方式一：直接订阅执行命令返回的信号
    
    //2、执行命令
    // 这里其实用到的是replaySubject 可以先发送命令再订阅
    RACSignal *signal = [command execute:@2];
    [signal subscribeNext:^(id x) {
        NSLog(@"command:%@", x);
    }];
    
}
*/

//一般做法
/*
- (void)commandAction {
    //1、创建命令
    RACCommand *command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        //block调用，执行命令的时候就会调用; input:执行命令的参数
        NSLog(@"%@", input);
        
        //此处返回不能为nil
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            [subscriber sendNext:@"执行命令产生的数据"];
            return nil;
        }];
    }];
    
    //方式二
    //订阅信号
    //⚠️：此处必须先订阅再发送命令
    //executionSignals：信号源，信号中信号，signalofsignals:信号，发送数据就是信号
    [command.executionSignals subscribeNext:^(id x) {
        [x subscribeNext:^(id x) {
            NSLog(@"command:%@", x);
        }];
    }];
    //2、执行命令
    [command execute:@2];
}
 
 */

//高级做法
/*
- (void)commandAction {
    //1、创建命令
    RACCommand *command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        //block调用，执行命令的时候就会调用; input:执行命令的参数
        NSLog(@"%@", input);
        
        //此处返回不能为nil
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            [subscriber sendNext:@"执行命令产生的数据"];
            return nil;
        }];
    }];
    
    //方式三
    //switchToLatest获取最新发送的信号，只能用于信号中信号。
    [command.executionSignals.switchToLatest subscribeNext:^(id x) {
        NSLog(@"command:%@", x);
    }];
    //2、执行命令
    [command execute:@2];
}
 */

// switchToLatest
/*
- (void)commandAction {
    //1、创建信号中信号
    RACSubject *signalofSignals = [RACSubject subject];
    RACSubject *signalA = [RACSubject subject];
    
    //switchToLatest:获取信号中信号发送的最新信号
    [signalofSignals.switchToLatest subscribeNext:^(id x) {
        NSLog(@"command:%@", x);
    }];
              
    //2、发送信号
    [signalofSignals sendNext:signalA];
    [signalA sendNext:@4];
}
 */

//监听事件有没有完成
- (void)commandAction {
    //⚠️：当前命令内部发送数据完成，一定要主动发送完成
    //1、创建命令
    RACCommand *command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        //block调用：执行命令的时候就会调用
        NSLog(@"%@", input);
        
        //这里的返回值不能为nil
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            //发送数据
            [subscriber sendNext:@"这到底是什么数据哇"];
            
            //发送完成
            [subscriber sendCompleted];
            
            return nil;
        }];
    }];
    
    
    //监听上边这件事情有没有完成
    [command.executing subscribeNext:^(id x) {
        if ([x boolValue] == YES) {
            NSLog(@"当前正在执行, 进度:%@", x);
        }else {
            NSLog(@"执行完成/没有执行");
        }
    }];
    
    //2、执行命令
    [command execute:@1];
}


#pragma mark - 6、RAC常用的宏
//RAC有很多强大而方便的宏
- (void)racCommonSetting {
    [self test1];
    [self test2];
    [self test3];
    [self test4];
}

- (void)test1 {
    //绑定某一对象的某个属性，发出信号时，该对象的属性值做出相应操作
    //例如：给label的text属性绑定一个文本框改变的信号
//    [self.input.rac_textSignal subscribeNext:^(id x) {
//        self.label.text = x;
//    }];
    
    //宏定义的简化写法
    RAC(self.label, text) = self.input.rac_textSignal;
    //监听label
    [RACObserve(self.label, text) subscribeNext:^(id x) {
        NSLog(@"test1:label的文字变了");
    }];

}

/**
    KVO
    RACObserveL:快速的监听某个对象的某个属性改变
     返回的是一个信号,对象的某个属性改变的信号
 */
- (void)test2 {
    [RACObserve(self.view, center) subscribeNext:^(id x) {
        NSLog(@"test2:%@", x);
    }];
}

//循环引用问题
- (void)test3 {
    @weakify(self)
    
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self)
        NSLog(@"test3:%@", self.view);
        return nil;
    }];
    _signal = signal;
}


/**
 * 元祖
 * 快速包装一个元组
 * 把包装的类型放在宏的参数里面,就会自动包装
 */
- (void)test4 {
    RACTuple *tuple = RACTuplePack(@1, @2);
    // 宏的参数类型要和元祖中元素类型一致， 右边为要解析的元祖。
    
    RACTupleUnpack(NSNumber *num1, NSNumber *num2, NSNumber *num3) = tuple;
    NSLog(@"1:%@, 2:%@, 3:%@", num1, num2, num3);
    
    //即使需要解析的元祖里只有两个元素，而我写的解析出来三个元素，依旧没有崩溃，打印： 1:1, 2:2, 3:(null)
    
}

#pragma mark -
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
 


@end
