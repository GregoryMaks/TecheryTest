//
//  LoginViewModelTest.m
//  TecheryTwitter
//
//  Created by GregoryM on 8/31/16.
//  Copyright © 2016 None. All rights reserved.
//

#import "Kiwi.h"
#import <MagicalRecord/MagicalRecord.h>

#import "LoginViewModel.h"
#import "LoginViewModelProtocol.h"
#import "LoginViewModelDelegate.h"

#import "FeedViewController.h"

#import "TwitterNetworkServiceMock.h"


SPEC_BEGIN(LoginViewModelSpec)

describe(@"When initializing", ^{
    let(twitterServiceMock, ^{
        return [[TwitterNetworkServiceMock alloc] init];
    });
    let(viewModel, ^{
        return [[LoginViewModel alloc] initWithTwitterModel:(id)twitterServiceMock];
    });
    
    it(@"should initialize correctly", ^{
        [[theValue(viewModel.error) should] equal:theValue(LoginViewModelError_None)];
    });
});

describe(@"When connecting to twitter account", ^{
    let(twitterServiceMock, ^{
        return [[TwitterNetworkServiceMock alloc] init];
    });
    let(viewModel, ^{
        return [[LoginViewModel alloc] initWithTwitterModel:(id)twitterServiceMock];
    });
    
    it(@"should proceed if granted and available", ^{
        id delegateMock = [KWMock mockForProtocol:@protocol(LoginViewModelDelegate)];
        viewModel.delegate = delegateMock;
        
        twitterServiceMock.connectGrantedReply = YES;
        twitterServiceMock.connectAccountAvailableReply = YES;
        
        [[delegateMock shouldEventually] receive:@selector(loginViewModel:needsToPerformSegueWithIdentifier:)
                         withArguments:viewModel, PresentFeedSegueIdentifier, nil];
        
        [viewModel connectToTwitterAccount];
    });
    
    it(@"should give error if granted, but not available", ^{
        twitterServiceMock.connectGrantedReply = YES;
        twitterServiceMock.connectAccountAvailableReply = NO;
        
        [viewModel connectToTwitterAccount];
        
        [[expectFutureValue(theValue(viewModel.error)) shouldEventually] equal:theValue(LoginViewModelError_NoAccountExists)];
    });
    
    it(@"should give error if not granted", ^{
        twitterServiceMock.connectGrantedReply = NO;
        twitterServiceMock.connectAccountAvailableReply = YES;
        
        [viewModel connectToTwitterAccount];
        
        [[expectFutureValue(theValue(viewModel.error)) shouldEventually] equal:theValue(LoginViewModelError_AccessDenied)];
    });
});

describe(@"When preparing for segue", ^{
    let(twitterServiceMock, ^{
        return [[TwitterNetworkServiceMock alloc] init];
    });
    let(viewModel, ^{
        return [[LoginViewModel alloc] initWithTwitterModel:(id)twitterServiceMock];
    });
    beforeEach(^{
        [MagicalRecord setupCoreDataStackWithInMemoryStore];
    });
    
    afterEach(^{
        [MagicalRecord cleanUp];
    });
    
    it(@"should prepare correctly for PresentFeedSegueIdentifier", ^{
        FeedViewController *feedVCMock = [FeedViewController nullMock];
        UINavigationController *navVCMock = [[UINavigationController alloc] initWithRootViewController:feedVCMock];
        
        [[feedVCMock shouldEventually] receive:@selector(setViewModelExternally:)
                                 withArguments:any(), nil];
        
        [viewModel prepareViewController:navVCMock forSegueIdentifier:PresentFeedSegueIdentifier];
    });
});


SPEC_END