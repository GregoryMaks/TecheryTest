//
//  TwitterTweet+CoreDataProperties.h
//  TecheryTwitter
//
//  Created by GregoryM on 8/17/16.
//  Copyright © 2016 None. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "TwitterTweet.h"

NS_ASSUME_NONNULL_BEGIN

@interface TwitterTweet (CoreDataProperties)

@property (nonatomic) int64_t identifier;
@property (nullable, nonatomic, retain) NSString *text;
@property (nonatomic) NSTimeInterval createdAt;
@property (nullable, nonatomic, retain) NSString *authorProfileImageUrl;
@property (nullable, nonatomic, retain) TwitterUser *user;

@end

NS_ASSUME_NONNULL_END
