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

@property (nonatomic, readwrite, assign) LoginViewModelError error;

@property (nonatomic, strong) TwitterNetworkService *twitterNetworkService;

@end


@implementation LoginViewModel

@synthesize error;
@synthesize delegate;

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

- (void)prepareViewController:(UIViewController *)viewController forSegueIdentifier:(NSString *)segueIdentifier {
    if ([segueIdentifier isEqualToString:PresentFeedSegueIdentifier]) {
        UINavigationController *navController = (UINavigationController *)viewController;
        FeedViewController *feedVC = navController.viewControllers[0];
        NSAssert(feedVC != nil, @"NavigationController should contain FeedViewController as root");
        if (feedVC != nil) {
            FeedViewModel *viewModel = [[FeedViewModel alloc] initWithTwitterNetworkService:self.twitterNetworkService];
            [feedVC setViewModelExternally:viewModel];
        }
    }
}

#pragma mark Private methods

- (void)openFeedController {
    NSAssert(self.delegate != nil, @"Delegate not set");
    if (self.delegate != nil) {
        [self.delegate loginViewModel:self needsToPerformSegueWithIdentifier:PresentFeedSegueIdentifier];
    }
}

@end
