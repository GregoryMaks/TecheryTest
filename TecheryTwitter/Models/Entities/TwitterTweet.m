//
//  TwitterTweet.m
//  TecheryTwitter
//
//  Created by GregoryM on 8/15/16.
//  Copyright © 2016 None. All rights reserved.
//

#import "TwitterTweet.h"
#import "TwitterUser.h"

@implementation TwitterTweet

- (void)fillFromNetworkDataModel:(TwitterTweetNetworkDataModel *)model {
    self.identifier = [model.identifier longLongValue];
    self.text = model.text;
    self.createdAt = [model.createdAt timeIntervalSinceReferenceDate];
    self.authorProfileImageUrl = model.authorProfileImageUrl;
}

@end
