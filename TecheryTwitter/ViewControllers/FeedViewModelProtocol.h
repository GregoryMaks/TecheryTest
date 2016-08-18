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


@protocol FeedViewModelProtocol <NSObject>
@required

@property (nonatomic, strong, readonly) RACSubject *dataUpdated;

- (instancetype)initWithTwitterModel:(TwitterNetworkDataModel *)twitterModel;

- (void)refreshFeed;

- (NSInteger)numberOfRowsInFeedTable;
- (void)fillCell:(FeedTableViewCell *)cell withDataForRowAtIndexPath:(NSIndexPath *)indexPath;

@end
