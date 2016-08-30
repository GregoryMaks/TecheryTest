//
//  RawTweetDataModel.h
//  TecheryTwitter
//
//  Created by GregoryM on 8/16/16.
//  Copyright © 2016 None. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface RawTweetDataModel : NSObject

@property (nonatomic, copy, readonly) NSString *identifier;
@property (nonatomic, copy, readonly) NSString *text;
@property (nonatomic, strong, readonly) NSDate *createdAt;
@property (nonatomic, copy, readonly) NSString *authorProfileImageUrl;

- (id)initWithDictionary:(NSDictionary *)dictionary;

@end
