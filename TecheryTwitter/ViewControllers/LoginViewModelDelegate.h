//
//  LoginViewModelDelegate.h
//  TecheryTwitter
//
//  Created by GregoryM on 8/13/16.
//  Copyright © 2016 None. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol LoginViewModelDelegate <NSObject>
@required

- (void)loginViewModel:(id <LoginViewModelProtocol>)viewModel needsToPerformSegueWithIdentifier:(NSString *)identifier;

@end