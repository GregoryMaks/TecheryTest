//
//  LoginCoordinator.m
//  TecheryTwitter
//
//  Created by GregoryM on 9/6/16.
//  Copyright © 2016 None. All rights reserved.
//

#import "LoginCoordinator.h"

#import "LoginViewController.h"
#import "LoginViewModel.h"
#import "LoginViewModelCoordinatorDelegate.h"
#import "TwitterNetworkService.h"

#import "FeedCoordinator.h"


@interface LoginCoordinator () <LoginViewModelCoordinatorDelegate>

@property (nonatomic, strong) UIWindow *window;

@property (nonatomic, strong) TwitterNetworkService *twitterNetworkService;
@property (nonatomic, strong) LoginViewController *loginVC;

@end


@implementation LoginCoordinator

- (instancetype)initWithWindow:(UIWindow *)window {
    if (self = [super init]) {
        self.window = window;
    }
    return self;
}

- (void)start {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    self.loginVC = [storyboard instantiateInitialViewController];
    NSAssert(self.loginVC != nil, @"LoginVC should not be nil when instantiating");
    
    if (self.loginVC) {
        self.twitterNetworkService = [TwitterNetworkService new];
        
        LoginViewModel *loginViewModel = [[LoginViewModel alloc] initWithTwitterNetworkService:self.twitterNetworkService];
        loginViewModel.coordinatorDelegate = self;
        
        [self.loginVC setViewModelExternally:loginViewModel];
        
        self.window.rootViewController = self.loginVC;
    }
}

- (void)loginViewModelDidAuthenticate:(LoginViewModel *)viewModel {
    FeedCoordinator *feedCoordinator = [[FeedCoordinator alloc] initWithParentVC:self.loginVC
                                                           twitterNetworkService:self.twitterNetworkService];
    [feedCoordinator start];
}

- (void)loginViewModelShouldOpenExternalTwitterSetings:(LoginViewModel *)viewModel {
    NSURL *url = [NSURL URLWithString:@"prefs:root"];
    [[UIApplication sharedApplication] openURL:url];
}

@end
