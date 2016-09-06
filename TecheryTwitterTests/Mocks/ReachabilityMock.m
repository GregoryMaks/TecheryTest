//
//  ReachabilityMock.m
//  TecheryTwitter
//
//  Created by GregoryM on 9/1/16.
//  Copyright © 2016 None. All rights reserved.
//

#import "ReachabilityMock.h"
#import "Reachability.h"
@import SystemConfiguration;


@implementation ReachabilityMock

@synthesize reachabilityBlock;

+ (instancetype)reachabilityForInternetConnection {
    return [[self alloc] init];
}

- (void)callReachabilityBlockWithReachableStatus:(BOOL)reachable {
    if (self.reachabilityBlock != nil) {
        self.reachabilityBlock((id)self, kSCNetworkReachabilityFlagsReachable);
    }
}

- (BOOL)isReachable {
    return self.reachableReply;
}

- (BOOL)startNotifier {
    return YES;
}

- (void)stopNotifier {
}

@end
