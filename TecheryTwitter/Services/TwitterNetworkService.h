//
//  TwitterNetworkService.h
//  TecheryTwitter
//
//  Created by GregoryM on 8/14/16.
//  Copyright © 2016 None. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TwitterRawTweetDataModel.h"
@import Accounts;


extern NSString * const TwitterNetworkServiceErrorDomain;

typedef NS_ENUM(NSInteger, TwitterNetworkServiceErrorCode) {
    TwitterNetworkServiceError_HTTPStatusError = 0
};


/**
 The class is designed to work with Twitter API through network
 */
@interface TwitterNetworkService : NSObject

@property (nonatomic, readonly, strong) ACAccountStore *accountStore;
@property (nonatomic, readonly, strong) ACAccount *account;
@property (nonatomic, readonly, strong) NSDictionary *profileInfo;


- (void)connectToTwitterAccountWithResultBlock:(void(^)(BOOL isGranted, BOOL isAccountAvailable))resultBlock;
- (void)retriveTwitterProfileInfoWithResultBlock:(void(^)(BOOL success, NSError *error))resultBlock;

- (void)retrieveHomeTimelineTweetsWithCount:(NSNumber *)count
                                    sinceId:(NSString *)sinceId
                                      maxId:(NSString *)maxId
                            completionBlock:(void(^)(NSArray<TwitterRawTweetDataModel *> *rawTweets, NSError *error))completionBlock;

@end
