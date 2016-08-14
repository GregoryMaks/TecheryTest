//
//  ViewController.h
//  TecheryTwitter
//
//  Created by GregoryM on 8/11/16.
//  Copyright © 2016 None. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginViewModelProtocol.h"


@interface LoginViewController : UIViewController

- (void)setViewModelExternally:(id <LoginViewModelProtocol>)model;

@end

