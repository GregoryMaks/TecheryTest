//
//  LoginViewModelProtocol.h
//  TecheryTwitter
//
//  Created by GregoryM on 8/12/16.
//  Copyright © 2016 None. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "TwitterNetworkService.h"
#import "LoginViewModelCoordinatorDelegate.h"


@protocol LoginViewModelDelegate;


static NSString * const PresentFeedSegueIdentifier = @"PresentFeedSegue";


static NSString * const LoginViewModelErrorDomain = @"LoginViewModelErrorDomain";

static NSInteger const LoginViewModelErrorAccessDeniedCode = 1;
static NSInteger const LoginViewModelErrorNoAccountExistsCode = 2;


@protocol LoginViewModelProtocol <NSObject>

@property (strong, readonly) NSError *error;

@property (weak) id <LoginViewModelCoordinatorDelegate> coordinatorDelegate;


- (instancetype)initWithTwitterNetworkService:(TwitterNetworkService *)twitterNetworkService;

- (void)connectToTwitterAccount;

- (void)navigateToExternalTwitterSettings;

@end


