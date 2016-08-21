//
//  TwitterFeedDataModel.h
//  TecheryTwitter
//
//  Created by GregoryM on 8/15/16.
//  Copyright © 2016 None. All rights reserved.
//

#import <Foundation/Foundation.h>
@import Accounts;
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "TwitterUser.h"
#import "TwitterTweet.h"
#import "TwitterNetworkDataModel.h"


/**
 The class is designed to work with Twitter Feed
 It gives the ability to retrieve the feed data without worrying about working with twitter API or local cache storage directly
 */
@interface TwitterFeedDataModel : NSObject

@property (nonatomic, readonly, strong) TwitterNetworkDataModel *networkDataModel;


- (instancetype)initWithTwitterNetworkDM:(TwitterNetworkDataModel *)networkDM;

- (NSInteger)numberOfTweetsForCurrentUser;

///**
// Retrieves all tweets since tweet with id == sinceId (newer tweets with id > sinceId). If 'tweetId' is nil, will return all tweets from the beginning.
// */
//- (NSArray<TwitterTweet *> *)newerTweetsSinceId:(NSNumber *)sinceId;
//
///**
// Retrieves all tweets older than maxId (older tweets . If 'tweetId' is nil, will return from the beginning.
// */
//- (NSArray<TwitterTweet *> *)olderTweetsWithMaxId:(NSNumber *)maxId;

- (NSArray<TwitterTweet *> *)orderedTweets;

/**
 Loads tweets from the top
 Signal result: (BOOL)areNewTweetsLoaded
 */
- (RACSignal *)loadNewerTweetsSignal;

/**
 Loads additional tweets from the bottom
 Signal result: (BOOL)areNewTweetsLoaded
 */
- (RACSignal *)loadOlderTweetsSignal;

- (void)TEST_makeSureOneTweetExists;
- (void)TEST_coreDataFetch;

@end
