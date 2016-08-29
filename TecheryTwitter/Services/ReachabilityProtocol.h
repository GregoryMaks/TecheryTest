//
//  ReachabilityProtocol.h
//  TecheryTwitter
//
//  Created by GregoryM on 8/29/16.
//  Copyright (c) 2016 None. All rights reserved.
//

@protocol ReachabilityProtocol <NSObject>
@required

@property (nonatomic, copy) NetworkReachability reachabilityBlock;

+ (instancetype)reachabilityForInternetConnection;

- (BOOL)isReachable;

- (BOOL)startNotifier;
- (void)stopNotifier;

@end
