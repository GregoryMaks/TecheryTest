//
//  TwitterNetworkService.m
//  TecheryTwitter
//
//  Created by GregoryM on 8/14/16.
//  Copyright © 2016 None. All rights reserved.
//

#import "TwitterNetworkService.h"
#import "RawTweetDataModel.h"
@import Social;


NSString * const TwitterNetworkServiceErrorDomain = @"TwitterNetworkServiceErrorDomain";


@interface TwitterNetworkService ()

@property (readwrite, strong) ACAccountStore *accountStore;
@property (readwrite, strong) ACAccount *account;
@property (readwrite, strong) NSDictionary *profileInfo;

@end


@implementation TwitterNetworkService

- (void)connectToTwitterAccountWithResultBlock:(void(^)(BOOL isGranted, BOOL isAccountAvailable))resultBlock {
    self.accountStore = [[ACAccountStore alloc] init];
    ACAccountType *twitterAccountType = [self.accountStore
                                         accountTypeWithAccountTypeIdentifier:
                                         ACAccountTypeIdentifierTwitter];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.accountStore requestAccessToAccountsWithType:twitterAccountType
                                                   options:nil
                                                completion:^(BOOL granted, NSError *error)
         {
             if (granted) {
                 NSArray *twitterAccounts = [self.accountStore accountsWithAccountType:twitterAccountType];
                 
                 self.account = [twitterAccounts lastObject];
                 if (self.account) {
                     if (resultBlock) {
                         resultBlock(YES, YES);
                     }
                 }
                 else {
                     if (resultBlock) {
                         resultBlock(YES, NO);
                     }
                 }
             }
             else {
                 if (resultBlock) {
                     resultBlock(NO, NO);
                 }
             }
         }];
    });
}

- (void)retriveTwitterProfileInfoWithResultBlock:(void(^)(BOOL success, NSError *error))resultBlock {
    NSAssert(self.account != nil, @"account is nil");
    if (self.account == nil) {
        if (resultBlock) {
            resultBlock(NO, nil);
        }
        return;
    }
    
    NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/1.1/users/show.json"];
    NSDictionary *params = @{ @"screen_name" : self.account.username };
    
    SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                            requestMethod:SLRequestMethodGET
                                                      URL:url parameters:params];
    request.account = self.account;
    
    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error)
    {
        if (urlResponse.statusCode == 200) {
            NSError *jsonError = nil;
            NSDictionary *responseJSON = [NSJSONSerialization JSONObjectWithData:responseData
                                                                         options:NSJSONReadingMutableLeaves
                                                                           error:&jsonError];
            if (jsonError == nil) {
                self.profileInfo = responseJSON;
                if (resultBlock) {
                    resultBlock(YES, nil);
                }
                
            }
            else {
                if (resultBlock) {
                    resultBlock(NO, jsonError);
                }
            }
        }
        else {
            if (resultBlock) {
                if (error == nil) {
                    error = [NSError errorWithDomain:TwitterNetworkServiceErrorDomain
                                                code:TwitterNetworkServiceError_HTTPStatusError
                                            userInfo:@{ NSLocalizedDescriptionKey : [NSString stringWithFormat:@"HTTP Status: %ld", urlResponse.statusCode]}];
                }
                resultBlock(NO, error);
            }
        }
    }];
}

- (void)retrieveHomeTimelineTweetsWithCount:(NSNumber *)count
                                    sinceId:(NSString *)sinceId
                                      maxId:(NSString *)maxId
                            completionBlock:(void(^)(NSArray<RawTweetDataModel *> *rawTweets, NSError *error))completionBlock {
    
    NSAssert(self.account != nil, @"account is nil");
    if (self.account == nil) {
        if (completionBlock) {
            completionBlock(nil, nil);
        }
        return;
    }
    
    NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/1.1/statuses/home_timeline.json"];
    NSMutableDictionary *params = [@{ @"exclude_replies" : @"true" } mutableCopy];
    if (count) {
        params[@"count"] = [count stringValue];
    }
    if (sinceId) {
        params[@"since_id"] = sinceId;
    }
    if (maxId) {
        params[@"max_id"] = maxId;
    }
    
    SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                            requestMethod:SLRequestMethodGET
                                                      URL:url parameters:params];
    request.account = self.account;
    
    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error)
     {
         if (urlResponse.statusCode == 200) {
             NSError *jsonError = nil;
             id responseJSON = [NSJSONSerialization JSONObjectWithData:responseData
                                                               options:NSJSONReadingMutableLeaves
                                                                 error:&jsonError];
             BOOL success = NO;
             if (jsonError == nil) {
                 if ([responseJSON isKindOfClass:[NSArray class]]) {
                     if (completionBlock) {
                         completionBlock([self parsedTweetModelsFromRawArray:responseJSON], nil);
                     }
                     success = YES;
                 }
             }
             
             if (success == NO && completionBlock) {
                 completionBlock(nil, error);
             }
         }
         else {
             if (completionBlock) {
                 if (error == nil) {
                     error = [NSError errorWithDomain:TwitterNetworkServiceErrorDomain
                                                 code:TwitterNetworkServiceError_HTTPStatusError
                                             userInfo:@{ NSLocalizedDescriptionKey : [NSString stringWithFormat:@"HTTP Status: %ld", urlResponse.statusCode]}];
                 }
                 completionBlock(nil, error);
             }
         }
     }];
}

- (NSArray<RawTweetDataModel *> *)parsedTweetModelsFromRawArray:(NSArray *)rawData {
    NSMutableArray<RawTweetDataModel *> *result = [NSMutableArray new];
    for (NSDictionary *rawTweet in rawData) {
        [result addObject:[[RawTweetDataModel alloc] initWithDictionary:rawTweet]];
    }
    return (NSArray<RawTweetDataModel *> *)[result copy];
}

@end
