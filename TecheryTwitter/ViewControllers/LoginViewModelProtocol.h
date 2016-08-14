//
//  LoginViewModelProtocol.h
//  TecheryTwitter
//
//  Created by GregoryM on 8/12/16.
//  Copyright © 2016 None. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "TwitterNetworkDataModel.h"


@protocol LoginViewModelDelegate;


static NSString * const PresentFeedSegueIdentifier = @"PresentFeedSegue";


typedef NS_ENUM(NSInteger, LoginViewModelError) {
    LoginViewModelError_None = 0,
    LoginViewModelError_AccessDenied,
    LoginViewModelError_NoAccountExists
};


@protocol LoginViewModelProtocol <NSObject>

@property (nonatomic, readonly, assign) LoginViewModelError error;
@property (nonatomic, weak) id <LoginViewModelDelegate> delegate;


- (instancetype)initWithTwitterModel:(TwitterNetworkDataModel *)twitterModel;

- (void)connectToTwitterAccount;

- (void)prepareViewController:(UIViewController *)viewController forSegueIdentifier:(NSString *)segueIdentifier;

@end


