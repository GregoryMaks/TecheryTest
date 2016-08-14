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
    NSURL *url = [NSURL URLWithString:@"http://api.twitter.com/1.1/users/show.json"];
    NSDictionary *params = nil;
    
    SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                            requestMethod:SLRequestMethodGET
                                                      URL:url parameters:params];
    request.account = self.account;
    
    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error)
    {
        if (error) {
//            NSString *errorMessage = [NSString stringWithFormat:@"There was an error reading your Twitter feed. %@",
//                                      [error localizedDescription]];
//            
//            [[AppDelegate instance] showError:errorMessage];
        }
        else {
//            NSError *jsonError;
//            NSDictionary *responseJSON = [NSJSONSerialization
//                                          JSONObjectWithData:responseData
//                                          options:NSJSONReadingMutableLeaves
//                                          error:&jsonError];
//            
//            dispatch_async(dispatch_get_main_queue(), ^{
//                self.profile = responseJSON;
//                [self setupProfile];
//            });
        }
    }];
}

@end
