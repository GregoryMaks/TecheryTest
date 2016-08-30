//
//  TwitterFeedService.m
//  TecheryTwitter
//
//  Created by GregoryM on 8/15/16.
//  Copyright © 2016 None. All rights reserved.
//

#import "TwitterFeedService.h"
#import "MagicalRecord/MagicalRecord.h"


static NSInteger const kDefaultTweetBatchSize = 20;


@interface TwitterFeedService ()

@property (nonatomic, readwrite, strong) TwitterNetworkService *networkDataModel;
@property (nonatomic, strong) TwitterUser *user;

@end


@implementation TwitterFeedService

- (instancetype)initWithTwitterNetworkDM:(TwitterNetworkService *)networkDM {
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
        
        long long int maxStoredTweetId = [self maxTweetIdForUser:self.user];
        NSLog(@"maxId = %lld", maxStoredTweetId != NSNotFound ? maxStoredTweetId : -1);
        
        // Reason for (maxStoredTweetId - 1): we should retrieve the duplicating tweet with maxStoredTweetId for merging logic
        NSString *sinceId = (maxStoredTweetId == NSNotFound) ? nil : [NSString stringWithFormat:@"%lld", maxStoredTweetId - 1];
        [self.networkDataModel retrieveHomeTimelineTweetsWithCount:@(kDefaultTweetBatchSize)
                                                           sinceId:sinceId
                                                             maxId:nil
                                                   completionBlock:^(NSArray<TwitterRawTweetDataModel *> *rawTweets, NSError *error)
         {
             if (error) {
                 NSLog(@"Error retrieving tweets, %@", [error localizedDescription]);
                 [subscriber sendError:error];
                 [subscriber sendCompleted];
                 return;
             }
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 
                 [[NSManagedObjectContext MR_defaultContext] MR_saveWithBlock:^(NSManagedObjectContext * _Nonnull localContext) {
                     TwitterUser *localUser = [self.user MR_inContext:localContext];
                     
                     BOOL tweetWithMaxStoredTweetIdPresentInResultSet = NO;
                     
                     for (TwitterRawTweetDataModel *rawTweet in rawTweets) {
                         if ([rawTweet.identifier longLongValue] == maxStoredTweetId) {
                             tweetWithMaxStoredTweetIdPresentInResultSet = YES;
                         }
                         else {
                             TwitterTweet *tweet = [TwitterTweet MR_createEntityInContext:localContext];
                             tweet.user = localUser;
                             [tweet fillFromNetworkDataModel:rawTweet];
                         }
                     }
                     
                     if (maxStoredTweetId != NSNotFound && tweetWithMaxStoredTweetIdPresentInResultSet == NO) {
                         // For now we are going to delete old tweets if newer create a gap between batches (old batch and new batch)
                         [self deleteTweetsWithIdLessOrEqualThan:maxStoredTweetId forUser:localUser inContext:localContext];
                     }
                     
                     NSLog(@"Saving new tweets to context...");
                     
                 } completion:^(BOOL contextDidSave, NSError * _Nullable error) {
                     NSLog(@"Saved status: %d, error: %@", contextDidSave, [error localizedDescription]);
                     
                     [subscriber sendNext:@(rawTweets.count > 0)];
                     [subscriber sendCompleted];
                 }];
             });
         }];
        
        return nil;
    }];
}

#pragma mark Private methods

- (void)getOrCreateTwitterUserFromAccount:(ACAccount *)account {
    NSString *username = account.username;
    
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

- (long long int)maxTweetIdForUser:(TwitterUser *)user {
    NSFetchRequest *req = [TwitterTweet MR_createFetchRequest];
    req.predicate = [NSPredicate predicateWithFormat:@"user = %@", self.user];
    req.propertiesToFetch = [TwitterTweet MR_propertiesNamed:@[@"identifier"]];
    req.resultType = NSDictionaryResultType;
    req.returnsDistinctResults = YES;
    req.fetchLimit = 1;
    req.sortDescriptors = [TwitterTweet MR_descendingSortDescriptors:@[@"identifier"]];
    
    NSError *error = nil;
    NSArray *result = [[NSManagedObjectContext MR_defaultContext] executeFetchRequest:req error:&error];
    
    if (error != nil || result == nil || result.count == 0) {
        return NSNotFound;
    }
    else {
        return [result[0][@"identifier"] longLongValue];
    }
}

- (void)deleteTweetsWithIdLessOrEqualThan:(long long int)identifier forUser:(TwitterUser *)user inContext:(NSManagedObjectContext *)context {
    NSError *error = nil;
    NSFetchRequest *request = [TwitterTweet MR_createFetchRequestInContext:context];
    request.predicate = [NSPredicate predicateWithFormat:@"user = %@ AND identifier <= %@", user, @(identifier)];
    NSArray *deleteArray = [context executeFetchRequest:request error:&error];
    if (deleteArray != nil && error == nil) {
        [deleteArray enumerateObjectsUsingBlock:^(NSManagedObject* _Nonnull object, NSUInteger idx, BOOL * _Nonnull stop) {
            [context deleteObject:object];
        }];
    }
    else {
        NSLog(@"Error deleting tweets, %@", [error localizedDescription]);
    }
}

@end
