//
//  FeedCoordinator.m
//  TecheryTwitter
//
//  Created by GregoryM on 9/6/16.
//  Copyright © 2016 None. All rights reserved.
//

#import "FeedCoordinator.h"
@import Social;

#import "FeedViewController.h"
#import "FeedViewModel.h"
#import "FeedViewModelCoordinatorDelegate.h"
#import "TwitterNetworkService.h"


static NSString * const kFeedNavigationViewControllerIdentifier = @"FeedNavigationViewController";
static NSTimeInterval kDelayToRefreshFeedAfterPostingTweet = 2.0;


@interface FeedCoordinator () <FeedViewModelCoordinatorDelegate>

@property (nonatomic, weak  ) UIViewController *parentVC;
@property (nonatomic, strong) TwitterNetworkService *twitterNetworkService;

@property (nonatomic, strong) UINavigationController *navController;
@property (nonatomic, strong) FeedViewController *feedVC;

@end


@implementation FeedCoordinator

- (instancetype)initWithParentVC:(UIViewController *)parentVC
           twitterNetworkService:(TwitterNetworkService *)twitterNetworkService {
    if (self = [super init]) {
        self.parentVC = parentVC;
        self.twitterNetworkService = twitterNetworkService;
    }
    return self;
}

- (void)start {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    self.navController = [storyboard instantiateViewControllerWithIdentifier:kFeedNavigationViewControllerIdentifier];
    if (self.navController) {
        self.feedVC = self.navController.viewControllers[0];
        NSAssert(self.feedVC != nil, @"NavigationController should contain FeedViewController as root");
        
        if (self.feedVC) {
            FeedViewModel *viewModel = [[FeedViewModel alloc] initWithTwitterNetworkService:self.twitterNetworkService];
            [self.feedVC setViewModelExternally:viewModel];
            
            self.parentVC.modalPresentationStyle = UIModalPresentationFullScreen;
            [self.parentVC presentViewController:self.navController animated:YES completion:nil];
        }
    }
}

#pragma mark FeedViewModelCoordinatorDelegate

- (void)feedViewModelNeedsToDisplayNewTweetDialog:(FeedViewModel *)viewModel {
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
        SLComposeViewController *tweetSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        tweetSheet.completionHandler = ^(SLComposeViewControllerResult result) {
            if (result == SLComposeViewControllerResultDone) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kDelayToRefreshFeedAfterPostingTweet * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [viewModel initiateNewSuccessfulTweetAftereffects];
                });
            }
        };
        [self.feedVC presentViewController:tweetSheet animated:YES completion:nil];
    }
}

@end
