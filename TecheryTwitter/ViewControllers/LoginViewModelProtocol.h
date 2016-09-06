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


typedef NS_ENUM(NSInteger, LoginViewModelError) {
    LoginViewModelError_None = 0,
    LoginViewModelError_AccessDenied,
    LoginViewModelError_NoAccountExists
};


@protocol LoginViewModelProtocol <NSObject>

@property (assign, readonly) LoginViewModelError error;

@property (weak) id <LoginViewModelCoordinatorDelegate> coordinatorDelegate;


- (instancetype)initWithTwitterNetworkService:(TwitterNetworkService *)twitterNetworkService;

- (void)connectToTwitterAccount;

- (void)navigateToExternalTwitterSettings;

@end


