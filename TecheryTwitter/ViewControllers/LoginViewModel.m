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
#import "TwitterNetworkDataModel.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "FeedViewModel.h"
#import "FeedViewController.h"


@interface LoginViewModel ()

@property (nonatomic, readwrite, assign) LoginViewModelError error;

@property (nonatomic, strong) TwitterNetworkDataModel *twitterModel;

@end


@implementation LoginViewModel

@synthesize error;
@synthesize delegate;

- (instancetype)initWithTwitterModel:(TwitterNetworkDataModel *)twitterModel {
    self = [super init];
    if (self) {
        self.error = LoginViewModelError_None;
        self.twitterModel = twitterModel;
    }
    return self;
}

- (void)connectToTwitterAccount {
    // TEST
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self openFeedController];
    });
    
    return;
    // TEST
    
    self.error = LoginViewModelError_None;
    
    [self.twitterModel connectToTwitterAccountWithResultBlock:^(BOOL isGranted, BOOL isAccountAvailable) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (isGranted) {
                NSLog(@"Granted primary access");
                if (isAccountAvailable) {
                    NSLog(@"Account available");
                    [self openFeedController];
                }
                else {
                    NSLog(@"Account non existant");
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
            FeedViewModel *viewModel = [[FeedViewModel alloc] initWithTwitterModel:self.twitterModel];
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
