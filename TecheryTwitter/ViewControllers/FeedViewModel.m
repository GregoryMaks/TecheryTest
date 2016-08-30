//
//  FeedViewModel.m
//  TecheryTwitter
//
//  Created by GregoryM on 8/13/16.
//  Copyright © 2016 None. All rights reserved.
//

#import "FeedViewModel.h"
@import Social;
#import "TwitterFeedDataModel.h"
#import "FeedTableViewCell.h"
#import "NSDate+Twitter.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "Reachability.h"
#import "ReachabilityProtocol.h"


NSString * const FeedViewModelErrorDomain = @"FeedViewModelErrorDomain";


@interface FeedViewModel ()

@property (assign, readwrite) BOOL isFeedRefreshing;
@property (strong, readwrite) RACSubject *dataUpdatedSignal;
@property (strong, readwrite) RACSubject *errorOccuredSignal;

@property (copy, readwrite) NSString *twitterUsername;
@property (assign, readwrite) BOOL isOnline;

@property (copy) Class reachabilityClass;
@property (strong) id<ReachabilityProtocol> reachability;

@property (nonatomic, strong) TwitterNetworkDataModel *twitterModel;
@property (nonatomic, strong) TwitterFeedDataModel *twitterFeedModel;

@property (nonatomic, strong) NSArray<TwitterTweet *> *feed;

@end


@implementation FeedViewModel

@synthesize delegate;

- (instancetype)initWithTwitterModel:(TwitterNetworkDataModel *)twitterModel {
    return [self initWithTwitterModel:twitterModel reachabilityClass:[Reachability class]];
}

- (instancetype)initWithTwitterModel:(TwitterNetworkDataModel *)twitterModel reachabilityClass:(Class)reachabilityClass {
    if (self = [super init]) {
        self.twitterModel = twitterModel;
        self.twitterFeedModel = [[TwitterFeedDataModel alloc] initWithTwitterNetworkDM:twitterModel];
        
        self.dataUpdatedSignal = [RACSubject subject];
        self.errorOccuredSignal = [RACSubject subject];
        
        self.twitterUsername = self.twitterModel.account.username;
        
        self.reachability = [reachabilityClass reachabilityForInternetConnection];
        self.isOnline = ([self.reachability isReachable]);
        
        @weakify(self);
        self.reachability.reachabilityBlock = ^(Reachability * reachability, SCNetworkConnectionFlags flags) {
            @strongify(self);
            BOOL newOnlineStatus = [reachability isReachable];
            
            @weakify(self);
            if (!self.isOnline && newOnlineStatus) {
                [[self refreshFeedSignal] subscribeNext:^(id x) {} error:^(NSError *error) {
                    @strongify(self);
                    [self.errorOccuredSignal sendNext:error];
                }];
            }
            
            self.isOnline = newOnlineStatus;
        };
        [self.reachability startNotifier];
        
        self.isFeedRefreshing = NO;
        self.feed = [NSMutableArray new];
        
        [self refreshCachedTweets];
    }
    return self;
}

- (void)dealloc {
    [self.reachability stopNotifier];
}

- (RACSignal *)refreshFeedSignal {
    @weakify(self);
    return [RACSignal
            createSignal:^ RACDisposable * (id<RACSubscriber> subscriber) {
                @strongify(self);
                NSLog(@"Refreshing feed");
                
                if (self.isFeedRefreshing) {
                    NSLog(@"Feed is already refreshing");
                    [subscriber sendCompleted];
                    return nil;
                }
                self.isFeedRefreshing = YES;
                
                BOOL isNetworkReachable = [self.reachability isReachable];
                if (!isNetworkReachable) {
                    NSLog(@"Network is not reachable");
                    [subscriber sendError:[NSError errorWithDomain:FeedViewModelErrorDomain
                                                              code:FeedViewModel_NoInternetConnection
                                                          userInfo:@{ NSLocalizedDescriptionKey : @"Internet connection is down" }]];
                    self.isFeedRefreshing = NO;
                    return nil;
                }
                
                // TODO: convert loadNewer to cold signal and chain them
                @weakify(self);
                [[self.twitterFeedModel loadNewerTweetsSignal] subscribeNext:^(NSNumber *newTweetsLoaded) {
                    @strongify(self);
                    
                    self.isFeedRefreshing = NO;
                    if ([newTweetsLoaded boolValue]) {
                        [self refreshCachedTweets];
                    }
                    [subscriber sendNext:newTweetsLoaded];
                } error:^(NSError *error) {
                    [subscriber sendError:error];
                } completed:^{
                    [subscriber sendCompleted];
                }];
                
                return nil;
            }];
}

- (NSInteger)numberOfRowsInFeedTable {
    return self.feed.count;
}

- (TwitterTweet *)tweetForRowAtIndexPath:(NSIndexPath *)indexPath {
    return (indexPath.row < self.feed.count) ? self.feed[indexPath.row] : nil;
}

- (void)initiateNewTweetCreation {
    if (self.delegate == nil) {
        return;
    }
    
    [self.delegate feedViewModelNeedsToDisplayNewTweetDialog:self];
}

- (void)initiateNewSuccessfulTweetAftereffects {
    @weakify(self);
    [[self refreshFeedSignal] subscribeNext:^(id x) {} error:^(NSError *error) {
        @strongify(self);
        [self.errorOccuredSignal sendNext:error];
    }];
}

#pragma mark Private

- (void)refreshCachedTweets {
    self.feed = [self.twitterFeedModel orderedTweets];
    [self.dataUpdatedSignal sendNext:nil];
}

@end
