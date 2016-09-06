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
#import "TwitterFeedService.h"


NSArray<TwitterTweet *> * populateDBWithSampleTweets () {
    TwitterUser *user = [TwitterUser MR_createEntity];
    user.username = @"twitter-user";
    
    NSDate *refDate = [NSDate date];
    NSTimeInterval oneDay = ((60 * 60) * 24);
    
    TwitterTweet *tweet1 = [TwitterTweet MR_createEntity];
    tweet1.identifier = 1;
    tweet1.text = @"tweet1";
    tweet1.createdAt = [refDate timeIntervalSinceReferenceDate];
    tweet1.authorProfileImageUrl = @"www.url1.com";
    tweet1.user = user;
    
    TwitterTweet *tweet2 = [TwitterTweet MR_createEntity];
    tweet2.identifier = 1;
    tweet2.text = @"tweet2";
    tweet1.createdAt = [refDate timeIntervalSinceReferenceDate] - oneDay;
    tweet2.authorProfileImageUrl = @"www.url2.com";
    tweet2.user = user;
    
    TwitterTweet *tweet3 = [TwitterTweet MR_createEntity];
    tweet3.identifier = 1;
    tweet3.text = @"tweet3";
    tweet3.createdAt = [refDate timeIntervalSinceReferenceDate] - (2 * oneDay);
    tweet3.authorProfileImageUrl = @"www.url3.com";
    tweet3.user = user;
    
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    
    return @[tweet1, tweet2, tweet3];
}


SPEC_BEGIN(FeedViewModelSpec)

describe(@"When initializing", ^{
    let(twitterNetworkServiceMock, ^{
        TwitterNetworkServiceMock *mock = [[TwitterNetworkServiceMock alloc] init];
        mock.connectGrantedReply = YES;
        mock.connectAccountAvailableReply = YES;
        return (TwitterNetworkService *)mock;
    });
    let(twitterFeedServiceMock, ^{
        return [TwitterFeedService nullMock];
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
        FeedViewModel *viewModel = [[FeedViewModel alloc] initWithTwitterNetworkService:twitterNetworkServiceMock
                                                                     twitterFeedService:twitterFeedServiceMock
                                                                           reachability:reachabilityMock];
        
        [[theValue(viewModel.isOnline) should] beYes];
    });
    
    it(@"and is offline, behaves correctly", ^{
        reachabilityMock.reachableReply = NO;
        FeedViewModel *viewModel = [[FeedViewModel alloc] initWithTwitterNetworkService:twitterNetworkServiceMock
                                                                     twitterFeedService:twitterFeedServiceMock
                                                                           reachability:reachabilityMock];
        
        [[theValue(viewModel.isOnline) should] beNo];
    });
    
    context(@"with default parameters", ^{
        it(@"feed should be empty", ^{
            reachabilityMock.reachableReply = YES;
            FeedViewModel *viewModel = [[FeedViewModel alloc] initWithTwitterNetworkService:twitterNetworkServiceMock
                                                                         twitterFeedService:twitterFeedServiceMock
                                                                               reachability:reachabilityMock];
            
            [[theValue(viewModel.isFeedRefreshing) should] beNo];
            [[theValue([viewModel numberOfRowsInFeedTable]) should] equal:theValue(0)];
        });
        
        it(@"twitter username should be correct", ^{
            reachabilityMock.reachableReply = YES;
            FeedViewModel *viewModel = [[FeedViewModel alloc] initWithTwitterNetworkService:twitterNetworkServiceMock
                                                                         twitterFeedService:twitterFeedServiceMock
                                                                               reachability:reachabilityMock];
            
            NSString *userName = @"<testusername>";
            [twitterNetworkServiceMock.account stub:@selector(username) andReturn:userName];
            
            [[viewModel.twitterUsername should] equal:userName];
        });
    });
});

describe(@"When network status changes", ^{
    let(twitterNetworkServiceMock, ^{
        TwitterNetworkServiceMock *mock = [[TwitterNetworkServiceMock alloc] init];
        mock.connectGrantedReply = YES;
        mock.connectAccountAvailableReply = YES;
        return (TwitterNetworkService *)mock;
    });
    let(twitterFeedServiceMock, ^{
        return [TwitterFeedService nullMock];
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
            FeedViewModel *viewModel = [[FeedViewModel alloc] initWithTwitterNetworkService:twitterNetworkServiceMock
                                                                         twitterFeedService:twitterFeedServiceMock
                                                                               reachability:reachabilityMock];
            
            reachabilityMock.reachableReply = YES;
            [reachabilityMock callReachabilityBlockWithReachableStatus:YES];
            
            [[theValue(viewModel.isOnline) should] beYes];
        });
        
        it(@"should refresh feed", ^{
            reachabilityMock.reachableReply = NO;
            FeedViewModel *viewModel = [[FeedViewModel alloc] initWithTwitterNetworkService:twitterNetworkServiceMock
                                                                         twitterFeedService:twitterFeedServiceMock
                                                                               reachability:reachabilityMock];
            
            [[viewModel should] receive:@selector(refreshFeedSignal)];
            
            reachabilityMock.reachableReply = YES;
            [reachabilityMock callReachabilityBlockWithReachableStatus:YES];
        });
    });
    
    context(@"to 'offline'", ^{
        it(@"should reflect", ^{
            reachabilityMock.reachableReply = YES;
            FeedViewModel *viewModel = [[FeedViewModel alloc] initWithTwitterNetworkService:twitterNetworkServiceMock
                                                                         twitterFeedService:twitterFeedServiceMock
                                                                               reachability:reachabilityMock];
            
            reachabilityMock.reachableReply = NO;
            [reachabilityMock callReachabilityBlockWithReachableStatus:NO];
            
            [[theValue(viewModel.isOnline) should] beNo];
        });
    });
});

describe(@"When feed is updated", ^{
    let(twitterNetworkServiceMock, ^{
        TwitterNetworkServiceMock *mock = [[TwitterNetworkServiceMock alloc] init];
        mock.connectGrantedReply = YES;
        mock.connectAccountAvailableReply = YES;
        return (TwitterNetworkService *)mock;
    });
    let(twitterFeedServiceMock, ^{
        return [TwitterFeedService nullMock];
    });
    let(reachabilityMock, ^{
        ReachabilityMock *reachability = [[ReachabilityMock alloc] init];
        reachability.reachableReply = YES;
        return reachability;
    });
    let(viewModel, ^{
        return [[FeedViewModel alloc] initWithTwitterNetworkService:twitterNetworkServiceMock
                                                 twitterFeedService:twitterFeedServiceMock
                                                       reachability:reachabilityMock];
    });
    
    beforeEach(^{
        [MagicalRecord setupCoreDataStackWithInMemoryStore];
    });
    
    afterEach(^{
        [MagicalRecord cleanUp];
    });
    
    context(@"without initial data", ^{
        context(@"without new data", ^{
            it(@"feed should remain unchanged", ^{
                RACSignal *mockSignal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
                    [subscriber sendNext:@(0)];
                    [subscriber sendCompleted];
                    return nil;
                }];
                [twitterFeedServiceMock stub:@selector(loadNewerTweetsSignal) andReturn:mockSignal];
                [twitterFeedServiceMock stub:@selector(orderedTweets) andReturn:nil];
                [twitterFeedServiceMock stub:@selector(numberOfTweetsForCurrentUser) andReturn:theValue(0)];
                
                // Perform actions
                RACSignal *signal = [viewModel refreshFeedSignal];

                BOOL success = NO;
                NSError *error = nil;
                NSNumber *result = [signal asynchronousFirstOrDefault:nil success:&success error:&error];
                
                [[theValue(success) should] beTrue];
                [[error should] beNil];
                
                [[result should] equal:@(0)];
                
                // Verify result
                [[theValue([viewModel numberOfRowsInFeedTable]) should] equal:theValue(0)];
            });
        });
        
        context(@"with new data", ^{
            it(@"feed should contain new data", ^{
                // Prepare data
                NSArray<TwitterTweet *> *tweets = populateDBWithSampleTweets();
                
                [twitterFeedServiceMock stub:@selector(orderedTweets) andReturn:tweets];
                [twitterFeedServiceMock stub:@selector(numberOfTweetsForCurrentUser) andReturn:theValue(tweets.count)];
                
                // Mock signal
                RACSignal *mockSignal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
                    [subscriber sendNext:@(tweets.count)];
                    [subscriber sendCompleted];
                    return nil;
                }];
                [twitterFeedServiceMock stub:@selector(loadNewerTweetsSignal) andReturn:mockSignal];
                
                // Perform actions
                RACSignal *signal = [viewModel refreshFeedSignal];
                
                BOOL success = NO;
                NSError *error = nil;
                NSNumber *result = [signal asynchronousFirstOrDefault:nil success:&success error:&error];
                
                [[theValue(success) should] beTrue];
                [[error should] beNil];
                
                [[result should] equal:@(tweets.count)];
                
                // Verify result
                [[theValue([viewModel numberOfRowsInFeedTable]) shouldEventually] equal:theValue(tweets.count)];
                for (int i = 0; i < [tweets count]; ++i) {
                    [[[viewModel tweetForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]]
                      shouldEventually] equal:tweets[i]];
                }
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