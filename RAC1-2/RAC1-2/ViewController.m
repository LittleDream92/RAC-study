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

#pragma mark -
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
 


@end
