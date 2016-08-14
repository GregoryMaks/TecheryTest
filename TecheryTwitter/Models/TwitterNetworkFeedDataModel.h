//
//  TwitterNetworkFeedDataModel.h
//  TecheryTwitter
//
//  Created by GregoryM on 8/15/16.
//  Copyright © 2016 None. All rights reserved.
//

#import <Foundation/Foundation.h>
@import Accounts;


@interface TwitterNetworkFeedDataModel : NSObject

@property (nonatomic, readonly, strong) ACAccount *account;


- (instancetype)initWithTwitterAccount:(ACAccount *)account;

@end
