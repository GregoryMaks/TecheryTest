//
//  FeedViewModel.m
//  TecheryTwitter
//
//  Created by GregoryM on 8/13/16.
//  Copyright © 2016 None. All rights reserved.
//

#import "FeedViewModel.h"
@import Social;


@interface FeedViewModel ()

@property (nonatomic, strong) TwitterNetworkDataModel *twitterModel;

@end


@implementation FeedViewModel

- (instancetype)initWithTwitterModel:(TwitterNetworkDataModel *)twitterModel {
    if (self = [super init]) {
        self.twitterModel = twitterModel;
    }
    return self;
}

- (void)gatherTwittedProfileData {
}

@end
