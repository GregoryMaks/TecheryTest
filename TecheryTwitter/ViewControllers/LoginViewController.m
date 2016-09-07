//
//  ViewController.m
//  TecheryTwitter
//
//  Created by GregoryM on 8/11/16.
//  Copyright © 2016 None. All rights reserved.
//

#import "LoginViewController.h"
#import "LoginViewModelProtocol.h"
#import "LoginViewModel.h"
#import <ReactiveCocoa/ReactiveCocoa.h>


@interface LoginViewController ()

@property (strong) id <LoginViewModelProtocol> viewModel;

@property (weak) IBOutlet UILabel *statusTextLabel;
@property (weak) IBOutlet UIButton *auxiliaryButton;

@end


@implementation LoginViewController

#pragma mark ViewModel

- (void)setViewModelExternally:(id <LoginViewModelProtocol>)model {
    NSAssert(model != nil, @"Model should not be nil");
    self.viewModel = model;
}

- (void)bindViewModel {
    NSAssert(self.viewModel != nil, @"Model should not be nil");
    if (self.viewModel == nil) {
        return;
    }
    
    @weakify(self);
    [RACObserve(self.viewModel, error)
     subscribeNext:^(NSError *error) {
         @strongify(self);
         if (error == nil) {
             self.statusTextLabel.text = @"Connecting to twitter...";
             self.auxiliaryButton.hidden = YES;
         }
         else if (error.code == LoginViewModelErrorAccessDeniedCode) {
             self.statusTextLabel.text = @"Please grant access to twitter account in system Settings";
             self.auxiliaryButton.hidden = NO;
             [self.auxiliaryButton setTitle:@"Goto settings" forState:UIControlStateNormal];
             
             @weakify(self);
             // TODO: there should be a better way of chaining
             __block RACDisposable *signalForButton = [[self.auxiliaryButton rac_signalForControlEvents:UIControlEventTouchUpInside]
                                                       subscribeNext:^(UIButton *button) {
                                                           @strongify(self);
                                                           [self.viewModel navigateToExternalTwitterSettings];
                                                           [signalForButton dispose];
                                                       }];
         }
         else if (error.code == LoginViewModelErrorNoAccountExistsCode) {
             self.statusTextLabel.text = @"Please sign in to twitter account in settings";
             self.auxiliaryButton.hidden = NO;
             [self.auxiliaryButton setTitle:@"Goto settings" forState:UIControlStateNormal];
             
             @weakify(self);
             // TODO: there should be a better way of chaining
             __block RACDisposable *signalForButton = [[self.auxiliaryButton rac_signalForControlEvents:UIControlEventTouchUpInside]
                                                       subscribeNext:^(UIButton *button) {
                                                           @strongify(self);
                                                           [self.viewModel navigateToExternalTwitterSettings];
                                                           [signalForButton dispose];
                                                       }];
         }
    }];
    
    [self.viewModel connectToTwitterAccount];
}

#pragma mark Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self bindViewModel];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
}

#pragma mark Notifications

- (void)applicationDidBecomeActive:(NSNotification *)notif {
    if (self.viewModel.error != nil) {
        [self.viewModel connectToTwitterAccount];
    }
}

@end
