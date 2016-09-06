//
//  TwitterUser+CoreDataProperties.h
//  TecheryTwitter
//
//  Created by GregoryM on 9/6/16.
//  Copyright © 2016 None. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "TwitterUser.h"
#import "TwitterTweet.h"

NS_ASSUME_NONNULL_BEGIN

@interface TwitterUser (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *username;
@property (nullable, nonatomic, retain) NSSet<TwitterTweet *> *tweets;

@end

@interface TwitterUser (CoreDataGeneratedAccessors)

- (void)addTweetsObject:(TwitterTweet *)value;
- (void)removeTweetsObject:(TwitterTweet *)value;
- (void)addTweets:(NSSet<TwitterTweet *> *)values;
- (void)removeTweets:(NSSet<TwitterTweet *> *)values;

@end

NS_ASSUME_NONNULL_END
