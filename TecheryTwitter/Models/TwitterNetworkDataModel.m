//
//  TwitterNetworkDataModel.m
//  TecheryTwitter
//
//  Created by GregoryM on 8/14/16.
//  Copyright © 2016 None. All rights reserved.
//

#import "TwitterNetworkDataModel.h"
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
            NSDictionary *responseJSON = [NSJSONSerialization
                                          JSONObjectWithData:responseData
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

- (TwitterNetworkFeedDataModel *)feedDataModel {
    NSAssert(self.account != nil, @"account is nil");
    if (self.account == nil) {
        return nil;
    }
    
    return [[TwitterNetworkFeedDataModel alloc] initWithTwitterAccount:self.account];
}

@end
