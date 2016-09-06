//
//  RawTweetDataModel.m
//  TecheryTwitter
//
//  Created by GregoryM on 8/16/16.
//  Copyright © 2016 None. All rights reserved.
//

#import "RawTweetDataModel.h"
#import "NSDate+Twitter.h"


@interface RawTweetDataModel ()

@property (copy, readwrite) NSString *identifier;
@property (copy, readwrite) NSString *text;
@property (strong, readwrite) NSDate *createdAt;
@property (copy, readwrite) NSString *authorProfileImageUrl;

@end


@implementation RawTweetDataModel

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
