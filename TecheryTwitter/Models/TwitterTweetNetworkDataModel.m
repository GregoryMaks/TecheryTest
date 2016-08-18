//
//  TwitterTweetNetworkDataModel.m
//  TecheryTwitter
//
//  Created by GregoryM on 8/16/16.
//  Copyright © 2016 None. All rights reserved.
//

#import "TwitterTweetNetworkDataModel.h"
#import "NSDate+Twitter.h"


@interface TwitterTweetNetworkDataModel ()

@property (nonatomic, copy, readwrite) NSString *identifier;
@property (nonatomic, copy, readwrite) NSString *text;
@property (nonatomic, strong, readwrite) NSDate *createdAt;
@property (nonatomic, copy, readwrite) NSString *authorProfileImageUrl;

@end


@implementation TwitterTweetNetworkDataModel

- (id)initWithDictionary:(NSDictionary *)dictionary {
    if (self = [super init]) {
        self.identifier = dictionary[@"id_str"];
        self.text = dictionary[@"text"];
        self.createdAt = [NSDate parseTwitterDate:dictionary[@"created_at"]];
        self.authorProfileImageUrl = dictionary[@"user"][@"profile_image_url"];
    }
    return self;
}

@end
