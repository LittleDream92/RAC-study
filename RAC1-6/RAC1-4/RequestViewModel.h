//
//  RequestViewModel.h
//  RAC1-4
//
//  Created by Meng Fan on 16/9/20.
//  Copyright © 2016年 Meng Fan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <AFNetworking.h>

@interface RequestViewModel : NSObject

@property (nonatomic, strong, readonly) RACCommand *requestCommand;

@end
