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
#import "LoginViewModelCoordinatorDelegate.h"

#import "FeedViewController.h"

#import "TwitterNetworkServiceMock.h"


SPEC_BEGIN(LoginViewModelSpec)

describe(@"When initializing", ^{
    let(twitterServiceMock, ^{
        return [[TwitterNetworkServiceMock alloc] init];
    });
    let(viewModel, ^{
        return [[LoginViewModel alloc] initWithTwitterNetworkService:(id)twitterServiceMock];
    });
    
    it(@"should initialize correctly", ^{
        [[viewModel.error should] beNil];
    });
});

describe(@"When connecting to twitter account", ^{
    let(twitterServiceMock, ^{
        return [[TwitterNetworkServiceMock alloc] init];
    });
    let(delegateMock, ^{
        return [KWMock mockForProtocol:@protocol(LoginViewModelCoordinatorDelegate)];
    });
    let(viewModel, ^{
        LoginViewModel *viewModel = [[LoginViewModel alloc] initWithTwitterNetworkService:(id)twitterServiceMock];
        viewModel.coordinatorDelegate = delegateMock;
        return viewModel;
    });
    
    it(@"should proceed if granted and available", ^{
        twitterServiceMock.connectGrantedReply = YES;
        twitterServiceMock.connectAccountAvailableReply = YES;
        
        [[delegateMock shouldEventually] receive:@selector(loginViewModelDidAuthenticate:)];
        
        [viewModel connectToTwitterAccount];
    });
    
    it(@"should give error if granted, but not available", ^{
        twitterServiceMock.connectGrantedReply = YES;
        twitterServiceMock.connectAccountAvailableReply = NO;
        
        [viewModel connectToTwitterAccount];
        
        [[expectFutureValue(theValue(viewModel.error.code)) shouldEventually] equal:theValue(LoginViewModelErrorNoAccountExistsCode)];
    });
    
    it(@"should give error if not granted", ^{
        twitterServiceMock.connectGrantedReply = NO;
        twitterServiceMock.connectAccountAvailableReply = YES;
        
        [viewModel connectToTwitterAccount];
        
        [[expectFutureValue(theValue(viewModel.error.code)) shouldEventually] equal:theValue(LoginViewModelErrorAccessDeniedCode)];
    });
});

describe(@"When navigating away", ^{
    let(twitterServiceMock, ^{
        return [[TwitterNetworkServiceMock alloc] init];
    });
    let(delegateMock, ^{
        return [KWMock mockForProtocol:@protocol(LoginViewModelCoordinatorDelegate)];
    });
    let(viewModel, ^{
        LoginViewModel *viewModel = [[LoginViewModel alloc] initWithTwitterNetworkService:(id)twitterServiceMock];
        viewModel.coordinatorDelegate = delegateMock;
        return viewModel;
    });
    beforeEach(^{
        [MagicalRecord setupCoreDataStackWithInMemoryStore];
    });
    
    afterEach(^{
        [MagicalRecord cleanUp];
    });
    
    it(@"should call coordinator method correctly", ^{
        [[delegateMock shouldEventually] receive:@selector(loginViewModelShouldOpenExternalTwitterSetings:)];
        
        [viewModel navigateToExternalTwitterSettings];
    });
});


SPEC_END