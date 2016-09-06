//
//  RawTweetDataModel.h
//  TecheryTwitter
//
//  Created by GregoryM on 8/16/16.
//  Copyright © 2016 None. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface RawTweetDataModel : NSObject

@property (copy, readonly) NSString *identifier;
@property (copy, readonly) NSString *text;
@property (strong, readonly) NSDate *createdAt;
@property (copy, readonly) NSString *authorProfileImageUrl;

- (id)initWithDictionary:(NSDictionary *)dictionary;

@end
