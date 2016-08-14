//
//  FeedViewModelProtocol.h
//  TecheryTwitter
//
//  Created by GregoryM on 8/13/16.
//  Copyright © 2016 None. All rights reserved.
//

#import <Foundation/Foundation.h>
@import Accounts;


@class TwitterNetworkDataModel;


@protocol FeedViewModelProtocol <NSObject>

- (instancetype)initWithTwitterModel:(TwitterNetworkDataModel *)twitterModel;

- (void)gatherTwittedProfileData;

@end
