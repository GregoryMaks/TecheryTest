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


@class TwitterNetworkDataModel;
@class FeedTableViewCell;
@class TwitterTweet;


extern NSString * const FeedViewModelErrorDomain;
typedef NS_ENUM(NSInteger, FeedViewModelErrorCode) {
    FeedViewModel_NoInternetConnection = 0
};


@protocol FeedViewModelProtocol <NSObject>
@required

@property (assign, readonly) BOOL isFeedRefreshing;
@property (strong, readonly) RACSubject *dataUpdated;

@property (copy, readonly) NSString *twitterUsername;
@property (assign, readonly) BOOL isOnline;


- (instancetype)initWithTwitterModel:(TwitterNetworkDataModel *)twitterModel;

- (RACSignal *)refreshFeedSignal;

- (NSInteger)numberOfRowsInFeedTable;
- (TwitterTweet *)tweetForRowAtIndexPath:(NSIndexPath *)indexPath;

@end
