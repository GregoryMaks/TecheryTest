//
//  TwitterTweet.h
//  TecheryTwitter
//
//  Created by GregoryM on 8/15/16.
//  Copyright © 2016 None. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "TwitterTweetNetworkDataModel.h"

@class TwitterUser;

NS_ASSUME_NONNULL_BEGIN

@interface TwitterTweet : NSManagedObject

- (void)fillFromNetworkDataModel:(TwitterTweetNetworkDataModel *)model;

@end

NS_ASSUME_NONNULL_END

#import "TwitterTweet+CoreDataProperties.h"
