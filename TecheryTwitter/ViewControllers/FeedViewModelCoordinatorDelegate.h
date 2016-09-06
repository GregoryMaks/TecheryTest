//
//  FeedViewModelCoordinatorDelegate.h
//  TecheryTwitter
//
//  Created by GregoryM on 9/6/16.
//  Copyright © 2016 None. All rights reserved.
//

#import "Coordinator.h"


@class FeedViewModel;


@protocol FeedViewModelCoordinatorDelegate <NSObject>
@required

- (void)feedViewModelNeedsToDisplayNewTweetDialog:(FeedViewModel *)viewModel;

@end
