//
//  TwitterNetworkFeedDataModel.m
//  TecheryTwitter
//
//  Created by GregoryM on 8/15/16.
//  Copyright © 2016 None. All rights reserved.
//

#import "TwitterNetworkFeedDataModel.h"


@interface TwitterNetworkFeedDataModel ()

@property (nonatomic, readwrite, strong) ACAccount *account;

@end


@implementation TwitterNetworkFeedDataModel

- (instancetype)initWithTwitterAccount:(ACAccount *)account {
    if (self = [super init]) {
        self.account = account;
    }
    return self;
}

- (void)test {
    // https://api.twitter.com/1.1/statuses/user_timeline.json
}

@end
