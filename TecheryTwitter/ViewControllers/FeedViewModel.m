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


@interface FeedViewModel ()

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
        
        self.feed = [NSMutableArray new];
        
        [self refreshCachedTweets];
    }
    return self;
}

- (void)refreshFeed {
    @weakify(self);
    [self.twitterFeedModel loadNewerTweetsWithCompletionBlock:^(BOOL newTweetsLoaded) {
        if (newTweetsLoaded) {
            @strongify(self);
            
            [self refreshCachedTweets];
            [self.dataUpdated sendNext:nil];
        }
    }];
}

- (NSInteger)numberOfRowsInFeedTable {
    return self.feed.count;
}

- (void)fillCell:(FeedTableViewCell *)cell withDataForRowAtIndexPath:(NSIndexPath *)indexPath {
    TwitterTweet *tweet = (indexPath.row < self.feed.count) ? self.feed[indexPath.row] : nil;
    if (tweet != nil) {
        cell.tweetTextLabel.text = tweet.text;
        
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
}

@end
