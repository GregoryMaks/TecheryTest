//
//  ViewController.m
//  TecheryTwitter
//
//  Created by GregoryM on 8/11/16.
//  Copyright © 2016 None. All rights reserved.
//

#import "LoginViewController.h"
#import "LoginViewModelProtocol.h"
#import "LoginViewModelDelegate.h"
#import "LoginViewModel.h"
#import <ReactiveCocoa/ReactiveCocoa.h>


@interface LoginViewController () <LoginViewModelDelegate>

@property (nonatomic, strong) id <LoginViewModelProtocol> viewModel;

@property (weak, nonatomic) IBOutlet UILabel *statusTextLabel;
@property (weak, nonatomic) IBOutlet UIButton *auxiliaryButton;

@end


@implementation LoginViewController

#pragma mark ViewModel

- (void)setViewModelExternally:(id <LoginViewModelProtocol>)model {
    NSAssert(model != nil, @"Model should not be nil");
    self.viewModel = model;
    self.viewModel.delegate = self;
}

- (void)bindViewModel {
    @weakify(self);
    [RACObserve(self.viewModel, error)
     subscribeNext:^(NSNumber *errorType) {
         @strongify(self);
         switch([errorType integerValue]) {
             case LoginViewModelError_None: {
                 self.statusTextLabel.text = @"Connecting to twitter...";
                 self.auxiliaryButton.hidden = YES;
                 break;
             }
             case LoginViewModelError_AccessDenied: {
                 self.statusTextLabel.text = @"Please grant access to twitter account in system Settings";
                 self.auxiliaryButton.hidden = NO;
                 [self.auxiliaryButton setTitle:@"Goto settings" forState:UIControlStateNormal];

                 __block RACDisposable *signalForButton = [[self.auxiliaryButton rac_signalForControlEvents:UIControlEventTouchUpInside]
                                                           subscribeNext:^(UIButton *button) {
                                                               [self openSystemSettings];
                                                               [signalForButton dispose];
                                                           }];
                 break;
             }
             case LoginViewModelError_NoAccountExists: {
                 self.statusTextLabel.text = @"Please sign in to twitter account in settings";
                 self.auxiliaryButton.hidden = NO;
                 [self.auxiliaryButton setTitle:@"Goto settings" forState:UIControlStateNormal];
                 
                 __block RACDisposable *signalForButton = [[self.auxiliaryButton rac_signalForControlEvents:UIControlEventTouchUpInside]
                                                           subscribeNext:^(UIButton *button) {
                                                               [self openSystemSettings];
                                                               [signalForButton dispose];
                                                           }];
                 break;
             }
         }
    }];
}

#pragma mark Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self bindViewModel];
    
    // TODO
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(applicationDidBecomeActive:)
//                                                 name:UIApplicationDidBecomeActiveNotification
//                                               object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.viewModel connectToTwitterAccount];
}

//- (void)applicationDidBecomeActive:(NSNotification *)notif {
//    [self.viewModel connectToTwitterAccount];
//}

#pragma mark ModelViewDelegate

- (void)loginViewModel:(id <LoginViewModelProtocol>)viewModel needsToPerformSegueWithIdentifier:(NSString *)identifier {
    [self performSegueWithIdentifier:identifier sender:nil];
}

#pragma mark Storyboards

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [self.viewModel prepareViewController:segue.destinationViewController forSegueIdentifier:segue.identifier];
}

#pragma mark Private

- (void)openSystemSettings {
    NSURL *url = [NSURL URLWithString:@"prefs:root"];
    [[UIApplication sharedApplication] openURL:url];
}


@end
