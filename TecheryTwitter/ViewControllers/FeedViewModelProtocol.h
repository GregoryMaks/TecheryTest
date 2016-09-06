//
//  FeedViewModelProtocol.h
//  TecheryTwitter
//
//  Created by GregoryM on 8/13/16.
//  Copyright © 2016 None. All rights reserved.
//

@import Foundation;
@import Accounts;
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "FeedViewModelDelegate.h"


@class TwitterNetworkService;
@class FeedTableViewCell;
@class TwitterTweet;
@protocol ReachabilityProtocol;


extern NSString * const FeedViewModelErrorDomain;
typedef NS_ENUM(NSInteger, FeedViewModelErrorCode) {
    FeedViewModel_NoInternetConnection = 0
};


@protocol FeedViewModelProtocol <NSObject>
@required

@property (nonatomic, weak) id <FeedViewModelDelegate> delegate;

@property (assign, readonly) BOOL isFeedRefreshing;
@property (strong, readonly) RACSubject *dataUpdatedSignal;   ///< hot signal for notifying about new data
@property (strong, readonly) RACSubject *errorOccuredSignal;    ///< hot signal for displaying errors to user, paramer NSError*

@property (copy, readonly) NSString *twitterUsername;
@property (assign, readonly) BOOL isOnline;


- (instancetype)initWithTwitterModel:(TwitterNetworkService *)twitterModel;
- (instancetype)initWithTwitterModel:(TwitterNetworkService *)twitterModel reachability:(id <ReachabilityProtocol>)reachability;

- (RACSignal *)refreshFeedSignal;

- (NSInteger)numberOfRowsInFeedTable;
- (TwitterTweet *)tweetForRowAtIndexPath:(NSIndexPath *)indexPath;

- (void)initiateNewTweetCreation;
- (void)initiateNewSuccessfulTweetAftereffects;

@end
