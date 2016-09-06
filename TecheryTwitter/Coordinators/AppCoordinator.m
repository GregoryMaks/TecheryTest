//
//  AppCoordinator.m
//  TecheryTwitter
//
//  Created by GregoryM on 9/6/16.
//  Copyright © 2016 None. All rights reserved.
//


#import "AppCoordinator.h"
#import "LoginCoordinator.h"


@interface AppCoordinator ()

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) LoginCoordinator *loginCoordinator;

@end


@implementation AppCoordinator

- (instancetype)initWithWindow:(UIWindow *)window {
    if (self = [super init]) {
        self.window = window;
    }
    return self;
}

- (void)start {
    [self showLogin];
}

- (void)showLogin {
    self.loginCoordinator = [[LoginCoordinator alloc] initWithWindow:self.window];
    [self.loginCoordinator start];
}

@end
