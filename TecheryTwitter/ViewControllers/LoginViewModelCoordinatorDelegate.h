//
//  LoginViewModelCoordinatorDelegate.h
//  TecheryTwitter
//
//  Created by GregoryM on 9/6/16.
//  Copyright © 2016 None. All rights reserved.
//


#import <Foundation/Foundation.h>


@class LoginViewModel;


@protocol LoginViewModelCoordinatorDelegate
@required

- (void)loginViewModelDidAuthenticate:(LoginViewModel *)viewModel;
- (void)loginViewModelShouldOpenExternalTwitterSetings:(LoginViewModel *)viewModel;

@end
