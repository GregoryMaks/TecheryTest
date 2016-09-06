//
//  TwitterFeedService.h
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
#import "TwitterNetworkService.h"


/**
 The class is designed to work with Twitter Feed
 It gives the ability to retrieve the feed data without worrying about working with twitter API or local cache storage directly
 */
@interface TwitterFeedService : NSObject

@property (readonly, strong) TwitterNetworkService *twitterNetworkService;


- (instancetype)initWithTwitterNetworkService:(TwitterNetworkService *)twitterNetworkService;

- (NSInteger)numberOfTweetsForCurrentUser;

- (NSArray<TwitterTweet *> *)orderedTweets;

/**
 Loads tweets from the top
 Signal result: (BOOL)areNewTweetsLoaded
 */
- (RACSignal *)loadNewerTweetsSignal;

@end
