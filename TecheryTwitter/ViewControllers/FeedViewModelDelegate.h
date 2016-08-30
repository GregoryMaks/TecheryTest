//
//  FeedViewModelDelegate.h
//  TecheryTwitter
//
//  Created by GregoryM on 8/28/16.
//  Copyright © 2016 None. All rights reserved.
//


@class FeedViewModel;


@protocol FeedViewModelDelegate <NSObject>
@required

- (void)feedViewModelNeedsToDisplayNewTweetDialog:(FeedViewModel *)viewModel;

@end