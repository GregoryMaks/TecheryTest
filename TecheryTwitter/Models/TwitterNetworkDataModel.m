//
//  TwitterNetworkDataModel.m
//  TecheryTwitter
//
//  Created by GregoryM on 8/14/16.
//  Copyright © 2016 None. All rights reserved.
//

#import "TwitterNetworkDataModel.h"
#import "TwitterTweetNetworkDataModel.h"
@import Social;


@interface TwitterNetworkDataModel ()

@property (nonatomic, readwrite, strong) ACAccountStore *accountStore;
@property (nonatomic, readwrite, strong) ACAccount *account;
@property (nonatomic, readwrite, strong) NSDictionary *profileInfo;

@end


@implementation TwitterNetworkDataModel

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
        // TODO: Move status code check to category on NSHTTPURLResponse
        if (urlResponse.statusCode == 200 && error == nil) {
            NSError *jsonError = nil;
            NSDictionary *responseJSON = [NSJSONSerialization JSONObjectWithData:responseData
                                                                         options:NSJSONReadingMutableLeaves
                                                                           error:&jsonError];
            if (jsonError == nil) {
                self.profileInfo = responseJSON;
                NSLog(@"profile info = %@", self.profileInfo);
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
                resultBlock(NO, error);
            }
        }
    }];
}

- (void)retrieveHomeTimelineTweetsWithCount:(NSNumber *)count
                                    sinceId:(NSString *)sinceId
                                      maxId:(NSString *)maxId
                            completionBlock:(void(^)(NSArray<TwitterTweetNetworkDataModel *> *rawTweets, NSError *error))completionBlock {
    
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
         if (urlResponse.statusCode == 200 && error == nil) {
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
                 completionBlock(nil, error);
             }
         }
     }];
}

- (NSArray<TwitterTweetNetworkDataModel *> *)parsedTweetModelsFromRawArray:(NSArray *)rawData {
    NSMutableArray<TwitterTweetNetworkDataModel *> *result = [NSMutableArray new];
    for (NSDictionary *rawTweet in rawData) {
        [result addObject:[[TwitterTweetNetworkDataModel alloc] initWithDictionary:rawTweet]];
    }
    return (NSArray<TwitterTweetNetworkDataModel *> *)[result copy];
}

@end
