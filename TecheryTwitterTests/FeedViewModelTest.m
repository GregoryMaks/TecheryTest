//
//  FeedViewModelTest.m
//  TecheryTwitter
//
//  Created by GregoryM on 9/1/16.
//  Copyright © 2016 None. All rights reserved.
//

#import "Kiwi.h"
#import <MagicalRecord/MagicalRecord.h>

#import "FeedViewModel.h"
#import "ReachabilityMock.h"
#import "TwitterNetworkService.h"
#import "TwitterNetworkServiceMock.h"


SPEC_BEGIN(FeedViewModelSpec)

describe(@"When initializing", ^{
    let(twitterServiceMock, ^{
        TwitterNetworkServiceMock *mock = [[TwitterNetworkServiceMock alloc] init];
        mock.connectGrantedReply = YES;
        mock.connectAccountAvailableReply = YES;
        return (TwitterNetworkService *)mock;
    });
    let(reachabilityMock, ^{
        return [[ReachabilityMock alloc] init];
    });
    
    beforeEach(^{
        [MagicalRecord setupCoreDataStackWithInMemoryStore];
    });
    
    afterEach(^{
        [MagicalRecord cleanUp];
    });
    
    it(@"and is online, behaves correctly", ^{
        reachabilityMock.reachableReply = YES;
        FeedViewModel *viewModel = [[FeedViewModel alloc] initWithTwitterModel:twitterServiceMock
                                                                  reachability:reachabilityMock];
        
        [[theValue(viewModel.isOnline) should] beYes];
    });
    
    it(@"and is offline, behaves correctly", ^{
        reachabilityMock.reachableReply = NO;
        FeedViewModel *viewModel = [[FeedViewModel alloc] initWithTwitterModel:twitterServiceMock
                                                                  reachability:reachabilityMock];
        
        [[theValue(viewModel.isOnline) should] beNo];
    });
    
    context(@"with default parameters", ^{
        it(@"feed should be empty", ^{
            reachabilityMock.reachableReply = YES;
            FeedViewModel *viewModel = [[FeedViewModel alloc] initWithTwitterModel:twitterServiceMock
                                                                      reachability:reachabilityMock];
            
            [[theValue(viewModel.isFeedRefreshing) should] beNo];
            [[theValue([viewModel numberOfRowsInFeedTable]) should] equal:theValue(0)];
        });
    
        it(@"twitter username should be correct", ^{
            reachabilityMock.reachableReply = YES;
            FeedViewModel *viewModel = [[FeedViewModel alloc] initWithTwitterModel:twitterServiceMock
                                                                      reachability:reachabilityMock];
            
            NSString *userName = @"<testusername>";
            [twitterServiceMock.account stub:@selector(username) andReturn:userName];
            
            [[viewModel.twitterUsername should] equal:userName];
        });
    });
});

describe(@"When network status changes", ^{
    let(twitterServiceMock, ^{
        TwitterNetworkServiceMock *mock = [[TwitterNetworkServiceMock alloc] init];
        mock.connectGrantedReply = YES;
        mock.connectAccountAvailableReply = YES;
        return (TwitterNetworkService *)mock;
    });
    let(reachabilityMock, ^{
        ReachabilityMock *reachability = [[ReachabilityMock alloc] init];
        return reachability;
    });
    
    beforeEach(^{
        [MagicalRecord setupCoreDataStackWithInMemoryStore];
    });
    
    afterEach(^{
        [MagicalRecord cleanUp];
    });
    
    context(@"to 'online'", ^{
        it(@"should reflect", ^{
            reachabilityMock.reachableReply = NO;
            FeedViewModel *viewModel = [[FeedViewModel alloc] initWithTwitterModel:twitterServiceMock
                                                                      reachability:reachabilityMock];
            
            reachabilityMock.reachableReply = YES;
            [reachabilityMock callReachabilityBlockWithReachableStatus:YES];

            [[theValue(viewModel.isOnline) should] beYes];
        });
        
        it(@"should refresh feed", ^{
            reachabilityMock.reachableReply = NO;
            FeedViewModel *viewModel = [[FeedViewModel alloc] initWithTwitterModel:twitterServiceMock
                                                                      reachability:reachabilityMock];
            
            [[viewModel should] receive:@selector(refreshFeedSignal)];
            
            reachabilityMock.reachableReply = YES;
            [reachabilityMock callReachabilityBlockWithReachableStatus:YES];
        });
    });
    
    context(@"to 'offline'", ^{
        it(@"should reflect", ^{
            reachabilityMock.reachableReply = YES;
            FeedViewModel *viewModel = [[FeedViewModel alloc] initWithTwitterModel:twitterServiceMock
                                                                      reachability:reachabilityMock];
            
            reachabilityMock.reachableReply = NO;
            [reachabilityMock callReachabilityBlockWithReachableStatus:NO];
            
            [[theValue(viewModel.isOnline) should] beNo];
        });
    });
});

describe(@"When feed is updated", ^{
    context(@"without initial data", ^{
        context(@"without new data", ^{
            pending(@"feed should remain unchanged", ^{
            });
        });
        
        context(@"with new data", ^{
            pending(@"feed should contain new data", ^{
            });
        });
    });
    
    context(@"with initial data", ^{
        context(@"without new data", ^{
            pending(@"feed should remain unchanged", ^{
            });
        });
        
        context(@"with new data", ^{
            pending (@"of entities <= batch size", ^{
            });
            
            pending (@"of entities > batch size", ^{
            });
        });
    });
});

SPEC_END