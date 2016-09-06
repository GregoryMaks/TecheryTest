//
//  LoginViewModel.m
//  TecheryTwitter
//
//  Created by GregoryM on 8/11/16.
//  Copyright © 2016 None. All rights reserved.
//


#import "LoginViewModel.h"
@import Accounts;

#import "FeedViewController.h"
#import "TwitterNetworkService.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "FeedViewModel.h"
#import "FeedViewController.h"


@interface LoginViewModel ()

@property (readwrite, assign) LoginViewModelError error;

@property (strong) TwitterNetworkService *twitterNetworkService;

@end


@implementation LoginViewModel

@synthesize error;
@synthesize coordinatorDelegate;


- (instancetype)initWithTwitterNetworkService:(TwitterNetworkService *)twitterNetworkService {
    self = [super init];
    if (self) {
        self.error = LoginViewModelError_None;
        self.twitterNetworkService = twitterNetworkService;
    }
    return self;
}

- (void)connectToTwitterAccount {
    self.error = LoginViewModelError_None;
    
    [self.twitterNetworkService connectToTwitterAccountWithResultBlock:^(BOOL isGranted, BOOL isAccountAvailable) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (isGranted) {
                NSLog(@"Granted primary access");
                if (isAccountAvailable) {
                    NSLog(@"Account available");
                    [self openFeedController];
                }
                else {
                    NSLog(@"Account non existent");
                    self.error = LoginViewModelError_NoAccountExists;
                }
            }
            else {
                NSLog(@"Primary access denied");
                self.error = LoginViewModelError_AccessDenied;
            }
        });
    }];
}

- (void)navigateToExternalTwitterSettings {
    NSAssert(self.coordinatorDelegate != nil, @"Delegate not set");
    if (self.coordinatorDelegate != nil) {
        [self.coordinatorDelegate loginViewModelShouldOpenExternalTwitterSetings:self];
    }
}

#pragma mark Private methods

- (void)openFeedController {
    NSAssert(self.coordinatorDelegate != nil, @"Delegate not set");
    if (self.coordinatorDelegate != nil) {
        [self.coordinatorDelegate loginViewModelDidAuthenticate:self];
    }
}

@end
