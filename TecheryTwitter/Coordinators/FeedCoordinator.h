//
//  FeedCoordinator.h
//  TecheryTwitter
//
//  Created by GregoryM on 9/6/16.
//  Copyright © 2016 None. All rights reserved.
//

#import "Coordinator.h"
#import <UIKit/UIKit.h>


@class TwitterNetworkService;


@interface FeedCoordinator : Coordinator

- (instancetype)initWithParentVC:(UIViewController *)parentVC
           twitterNetworkService:(TwitterNetworkService *)twitterNetworkService;

@end
