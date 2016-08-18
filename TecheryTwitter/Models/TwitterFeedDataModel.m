//
//  TwitterFeedDataModel.m
//  TecheryTwitter
//
//  Created by GregoryM on 8/15/16.
//  Copyright © 2016 None. All rights reserved.
//

#import "TwitterFeedDataModel.h"
#import "MagicalRecord/MagicalRecord.h"


static NSInteger const kDefaultTweetBatchSize = 20;


@interface TwitterFeedDataModel ()

@property (nonatomic, readwrite, strong) TwitterNetworkDataModel *networkDataModel;
@property (nonatomic, strong) TwitterUser *user;

@end


@implementation TwitterFeedDataModel

- (instancetype)initWithTwitterNetworkDM:(TwitterNetworkDataModel *)networkDM {
    if (self = [super init]) {
        self.networkDataModel = networkDM;
        
        [self getOrCreateTwitterUserFromAccount:self.networkDataModel.account];
    }
    return self;
}

- (NSInteger)numberOfTweetsForCurrentUser {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"user = %@", self.user];
    return [TwitterTweet MR_countOfEntitiesWithPredicate:predicate];
}

//- (NSArray<TwitterTweet *> *)tweetsStartingWithIdAndOlder:(NSNumber *)tweetId count:(NSInteger)count {
//    NSFetchRequest *request = [TwitterTweet MR_requestAllSortedBy:@"createdAt"
//                                                        ascending:NO
//                                                        inContext:[NSManagedObjectContext MR_defaultContext]];
//    if (tweetId != nil) {
//        request.predicate = [NSPredicate predicateWithFormat:@"user = %@ AND id <= %@", self.user, tweetId];
//    }
//    else {
//        request.predicate = [NSPredicate predicateWithFormat:@"user = %@", self.user, tweetId];
//    }
//    request.fetchLimit = count;
//    
//    NSError *error = nil;
//    NSArray<TwitterTweet *> *result = [[NSManagedObjectContext MR_defaultContext] executeFetchRequest:request
//                                                                                                error:&error];
//    if (result != nil && error == nil) {
//        return result;
//    }
//    else {
//        NSLog(@"error retrieving data from DB, %@", [error localizedDescription]);
//        return nil;
//    }
//}

- (NSArray<TwitterTweet *> *)orderedTweets {
    NSFetchRequest *request = [TwitterTweet MR_requestAllSortedBy:@"createdAt"
                                                        ascending:NO
                                                        inContext:[NSManagedObjectContext MR_defaultContext]];
    request.returnsObjectsAsFaults = YES;
    
    NSError *error = nil;
    NSArray<TwitterTweet *> *result = [[NSManagedObjectContext MR_defaultContext] executeFetchRequest:request
                                                                                                error:&error];
    if (result != nil && error == nil) {
        return result;
    }
    else {
        NSLog(@"error retrieving data from DB, %@", [error localizedDescription]);
        return nil;
    }
}


- (void)loadNewerTweetsWithCompletionBlock:(void(^)(BOOL newTweetsLoaded))completionBlock {
    NSLog(@"loadNewerTweets");
    
    long long int maxStoredTweetId = [self tweetIdWithPredicate:[NSPredicate predicateWithFormat:@"identifier = max(identifier)"]];
    NSLog(@"maxId = %lld", maxStoredTweetId != NSNotFound ? maxStoredTweetId : -1);
    
    NSString *sinceId = (maxStoredTweetId == NSNotFound) ? nil : [NSString stringWithFormat:@"%lld", maxStoredTweetId];
    [self.networkDataModel retrieveHomeTimelineTweetsWithCount:@(kDefaultTweetBatchSize)
                                                       sinceId:sinceId
                                                         maxId:nil
                                               completionBlock:^(NSArray<TwitterTweetNetworkDataModel *> *rawTweets, NSError *error)
     {
         if (error) {
             NSLog(@"error retrieving tweets, %@", [error localizedDescription]);
             return;
         }
         
         dispatch_async(dispatch_get_main_queue(), ^{
             for (TwitterTweetNetworkDataModel *rawTweet in rawTweets) {
                 TwitterTweet *tweet = [TwitterTweet MR_createEntity];
                 [tweet fillFromNetworkDataModel:rawTweet];
             }
             
             [[NSManagedObjectContext MR_defaultContext] MR_saveOnlySelfWithCompletion:nil];
             
             if (completionBlock != nil) {
                 completionBlock(rawTweets.count > 0);
             }
         });
     }];
}

- (void)loadOlderTweetsWithCompletionBlock:(void(^)(BOOL newTweetsLoaded))completionBlock {
    NSLog(@"loading older tweets");
    
    long long int minStoredTweetId = [self tweetIdWithPredicate:[NSPredicate predicateWithFormat:@"identifier = min(identifier)"]];
    NSLog(@"minId = %lld", minStoredTweetId != NSNotFound ? minStoredTweetId : -1);
    
    NSString *maxId = (minStoredTweetId == NSNotFound) ? nil : [NSString stringWithFormat:@"%lld", minStoredTweetId];
    [self.networkDataModel retrieveHomeTimelineTweetsWithCount:@(kDefaultTweetBatchSize)
                                                       sinceId:nil
                                                         maxId:maxId
                                               completionBlock:^(NSArray<TwitterTweetNetworkDataModel *> *rawTweets, NSError *error)
     {
         if (error) {
             NSLog(@"error retrieving tweets, %@", [error localizedDescription]);
             return;
         }
         
         dispatch_async(dispatch_get_main_queue(), ^{
             for (TwitterTweetNetworkDataModel *rawTweet in rawTweets) {
                 TwitterTweet *tweet = [TwitterTweet MR_createEntity];
                 [tweet fillFromNetworkDataModel:rawTweet];
             }
             
             [[NSManagedObjectContext MR_defaultContext] MR_saveOnlySelfWithCompletion:nil];
             
             if (completionBlock != nil) {
                 completionBlock(rawTweets.count > 0);
             }
         });
     }];
}


#pragma mark Private methods

- (void)getOrCreateTwitterUserFromAccount:(ACAccount *)account {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"username = %@", account.username];
    TwitterUser *user = [TwitterUser MR_findFirstWithPredicate:predicate
                                                     inContext:[NSManagedObjectContext MR_defaultContext]];
    if (user == nil) {
        user = [TwitterUser MR_createEntity];
        user.username = account.username;
    }
    self.user = user;
}

- (long long int)tweetIdWithPredicate:(NSPredicate *)predicate {
    NSFetchRequest *req = [TwitterTweet MR_createFetchRequest];
    req.predicate = predicate;
    req.propertiesToFetch = [TwitterTweet MR_propertiesNamed:@[@"identifier"]];
    
    NSError *error = nil;
    NSArray *result = [[NSManagedObjectContext MR_defaultContext] executeFetchRequest:req error:&error];
    
    if (error != nil || result == nil || result.count == 0) {
        return NSNotFound;
    }
    else {
        return [result[0] longLongValue];
    }
}

@end
