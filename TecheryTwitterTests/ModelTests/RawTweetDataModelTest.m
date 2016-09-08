//
//  RawTweetDataModelTest.m
//  TecheryTwitter
//
//  Created by GregoryM on 8/30/16.
//  Copyright © 2016 None. All rights reserved.
//

#import "Kiwi.h"
#import "RawTweetDataModel.h"
#import "NSDate+Twitter.h"


SPEC_BEGIN(RawTweetDataModelSpec)

describe(@"When initializing with dictionary", ^{
    it(@"should initialize correctly", ^{
        NSString *identifier = @"<identifier>";
        NSString *text = @"<text>";
        NSDate *date = [NSDate date];
        NSString *dateString = [date tweetDisplayDateStringWithTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
        
        NSURL *url = [NSURL URLWithString:@"http://test_user.com"];
        
        NSDictionary *dict = @{ @"id_str": identifier,
                                @"text": text,
                                @"created_at": dateString,
                                @"user": @{ @"profile_image_url": url } };
        
        RawTweetDataModel *model = [[RawTweetDataModel alloc] initWithDictionary:dict];
        
        [[model.identifier should] equal:identifier];
        [[model.text should] equal:text];
        [[[model.createdAt description] should] equal:[date description]];
        [[model.authorProfileImageUrl should] equal:url];
    });
});

SPEC_END