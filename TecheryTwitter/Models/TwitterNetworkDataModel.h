//
//  TwitterNetworkDataModel.h
//  TecheryTwitter
//
//  Created by GregoryM on 8/14/16.
//  Copyright © 2016 None. All rights reserved.
//

#import <Foundation/Foundation.h>
@import Accounts;


// TODO: how to mock the model later for testing?
@interface TwitterNetworkDataModel : NSObject

@property (nonatomic, readonly, strong) ACAccountStore *accountStore;
@property (nonatomic, readonly, strong) ACAccount *account;

- (void)connectToTwitterAccountWithResultBlock:(void(^)(BOOL isGranted, BOOL isAccountAvailable))resultBlock;
- (void)retriveTwitterProfileInfoWithResultBlock:(void(^)(BOOL success, NSError *error))resultBlock;

@end
