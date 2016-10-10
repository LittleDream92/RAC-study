//
//  SubscribeViewModel.h
//  RACCommandDemo
//
//  Created by Meng Fan on 16/10/10.
//  Copyright © 2016年 Meng Fan. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SubscribeViewModel : NSObject

@property (nonatomic, strong) RACCommand *subscribeCommand;

//
@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *statusMessage;

@end
