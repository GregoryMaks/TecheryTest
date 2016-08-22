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

- (NSArray<TwitterTweet *> *)orderedTweets {
    NSFetchRequest *request = [TwitterTweet MR_requestAllSortedBy:@"createdAt"
                                                        ascending:NO
                                                        inContext:[NSManagedObjectContext MR_defaultContext]];
    request.predicate = [NSPredicate predicateWithFormat:@"user = %@", self.user];
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


- (RACSignal *)loadNewerTweetsSignal {
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self);
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
                 [subscriber sendError:error];
                 return;
             }
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 for (TwitterTweetNetworkDataModel *rawTweet in rawTweets) {
                     TwitterTweet *tweet = [TwitterTweet MR_createEntity];
                     tweet.user = self.user;
                     [tweet fillFromNetworkDataModel:rawTweet];
                 }
                 
                 [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
                 
                 [subscriber sendNext:@(rawTweets.count > 0)];
                 [subscriber sendCompleted];
             });
         }];
        
        return nil;
    }];
}

- (RACSignal *)loadOlderTweetsSignal {
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self);

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
                 [subscriber sendError:error];
                 return;
             }
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 for (TwitterTweetNetworkDataModel *rawTweet in rawTweets) {
                     TwitterTweet *tweet = [TwitterTweet MR_createEntity];
                     tweet.user = self.user;
                     [tweet fillFromNetworkDataModel:rawTweet];
                 }
                 
                 [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
                 
                 [subscriber sendNext:@(rawTweets.count > 0)];
                 [subscriber sendCompleted];
             });
         }];
        
        return nil;
    }];
}

- (void)TEST_makeSureOneTweetExists {
    NSFetchRequest *req = [TwitterTweet MR_createFetchRequest];
    req.predicate = [NSPredicate predicateWithFormat:@"user = %@", self.user];
    req.resultType = NSCountResultType;
    
    NSError *error = nil;
    NSArray *result = [[NSManagedObjectContext MR_defaultContext] executeFetchRequest:req error:&error];
    BOOL exists = NO;
    if (result != nil && error == nil) {
        exists = [result[0] boolValue];
    }
    
    if (!exists) {
        TwitterTweet *tweet = [TwitterTweet MR_createEntity];
        tweet.user = self.user;
        tweet.identifier = 12345678;
        tweet.text = @"test tweet No. 1";
        tweet.authorProfileImageUrl = nil;
        tweet.createdAt = [[NSDate date] timeIntervalSinceReferenceDate];
        
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    }
}

- (void)TEST_coreDataFetch {
    long long int tweetId = [self tweetIdWithPredicate:[NSPredicate predicateWithFormat:@"identifier = min(identifier)"]];
    NSLog(@"id = %lld", tweetId);
}

#pragma mark Private methods

- (void)getOrCreateTwitterUserFromAccount:(ACAccount *)account {
    NSString *username = account.username;
    // TEST
//    username = @"testtw";
    // TEST
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"username = %@", username];
    TwitterUser *user = [TwitterUser MR_findFirstWithPredicate:predicate
                                                     inContext:[NSManagedObjectContext MR_defaultContext]];
    if (user == nil) {
        user = [TwitterUser MR_createEntity];
        user.username = username;
    }
    self.user = user;
    
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
}

- (long long int)tweetIdWithPredicate:(NSPredicate *)predicate {
    NSFetchRequest *req = [TwitterTweet MR_createFetchRequest];
    req.predicate = predicate;
    req.propertiesToFetch = [TwitterTweet MR_propertiesNamed:@[@"identifier"]];
    req.resultType = NSDictionaryResultType;
    req.returnsDistinctResults = YES;
    
    NSError *error = nil;
    NSArray *result = [[NSManagedObjectContext MR_defaultContext] executeFetchRequest:req error:&error];
    
    if (error != nil || result == nil || result.count == 0) {
        return NSNotFound;
    }
    else {
        return [result[0][@"identifier"] longLongValue];
    }
}

@end
