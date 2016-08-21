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


NSString * const FeedViewModelErrorDomain = @"FeedViewModelErrorDomain";


@interface FeedViewModel ()

@property (assign, readwrite) BOOL isFeedRefreshing;

@property (nonatomic, strong) TwitterNetworkDataModel *twitterModel;
@property (nonatomic, strong) TwitterFeedDataModel *twitterFeedModel;

@property (nonatomic, strong) NSArray<TwitterTweet *> *feed;

@end


@implementation FeedViewModel

- (RACSubject *)dataUpdated {
    static RACSubject *instance = nil;
    if (instance == nil) {
        instance = [RACSubject subject];
    }
    return instance;
}

- (instancetype)initWithTwitterModel:(TwitterNetworkDataModel *)twitterModel {
    if (self = [super init]) {
        self.twitterModel = twitterModel;
        self.twitterFeedModel = [[TwitterFeedDataModel alloc] initWithTwitterNetworkDM:twitterModel];
        
        self.isFeedRefreshing = NO;
        self.feed = [NSMutableArray new];
        
        [self refreshCachedTweets];
    }
    return self;
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
                
                // TEST
//                BOOL isNetworkReachable = [[Reachability reachabilityForInternetConnection] currentReachabilityStatus] != NotReachable;
//                if (!isNetworkReachable) {
//                    NSLog(@"Network is not reachable");
//                    [subscriber sendError:[NSError errorWithDomain:FeedViewModelErrorDomain
//                                                              code:FeedViewModel_NoInternetConnection
//                                                          userInfo:nil]];
//                    self.isFeedRefreshing = NO;
//                    return nil;
//                }
                
                // TODO: convert loadNewer to cold signal and chain them
                @weakify(self);
                [[self.twitterFeedModel loadNewerTweetsSignal] subscribeNext:^(NSNumber *newTweetsLoaded) {
                    @strongify(self);
                    
                    self.isFeedRefreshing = NO;
                    if ([newTweetsLoaded boolValue]) {
                        [self refreshCachedTweets];
                    }
                    [subscriber sendNext:newTweetsLoaded];
                    
                    [subscriber sendCompleted];
                }];
                
                return nil;
            }];
}

- (NSInteger)numberOfRowsInFeedTable {
    return self.feed.count;
}

- (void)fillCell:(FeedTableViewCell *)cell withDataForRowAtIndexPath:(NSIndexPath *)indexPath {
    TwitterTweet *tweet = (indexPath.row < self.feed.count) ? self.feed[indexPath.row] : nil;
    if (tweet != nil) {
        cell.tweetTextLabel.text = tweet.text;
        cell.tweetDataLabel.text = [[NSDate dateWithTimeIntervalSinceReferenceDate:tweet.createdAt] tweetDisplayDateString];
        
        // TODO: can be improved with AFNetworking or separate thread
        if (tweet.authorProfileImageUrl.length > 0) {
            NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:tweet.authorProfileImageUrl]];
            if (imageData != nil) {
                cell.tweetImageView.image = [UIImage imageWithData:imageData];
            }
        }
    }
}

#pragma mark Private

- (void)refreshCachedTweets {
    self.feed = [self.twitterFeedModel orderedTweets];
    [self.dataUpdated sendNext:nil];
}

@end
