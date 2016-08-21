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


extern NSString * const FeedViewModelErrorDomain;
typedef NS_ENUM(NSInteger, FeedViewModelErrorCode) {
    FeedViewModel_NoInternetConnection = 0
};


@protocol FeedViewModelProtocol <NSObject>
@required

@property (assign, readonly) BOOL isFeedRefreshing;
@property (strong, readonly) RACSubject *dataUpdated;
@property (copy, readonly) NSString *twitterUsername;

- (instancetype)initWithTwitterModel:(TwitterNetworkDataModel *)twitterModel;

- (RACSignal *)refreshFeedSignal;

- (NSInteger)numberOfRowsInFeedTable;
- (void)fillCell:(FeedTableViewCell *)cell withDataForRowAtIndexPath:(NSIndexPath *)indexPath;

@end
