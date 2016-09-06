//
//  ReachabilityMock.h
//  TecheryTwitter
//
//  Created by GregoryM on 9/1/16.
//  Copyright © 2016 None. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ReachabilityProtocol.h"


@interface ReachabilityMock : NSObject <ReachabilityProtocol>

@property (nonatomic, assign) BOOL reachableReply;

- (void)callReachabilityBlockWithReachableStatus:(BOOL)reachable;

@end
