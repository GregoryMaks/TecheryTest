//
//  FeedViewController.m
//  TecheryTwitter
//
//  Created by GregoryM on 8/11/16.
//  Copyright © 2016 None. All rights reserved.
//

#import "FeedViewController.h"
#import "FeedViewModel.h"


@interface FeedViewController ()

@property (nonatomic, strong) id <FeedViewModelProtocol> viewModel;

@end


@implementation FeedViewController

#pragma mark ViewModel

- (id <FeedViewModelProtocol>)viewModel {
    // For easier usage
    if (_viewModel == nil) {
        [self bindViewModel:[[FeedViewModel alloc] init]];
    }
    return _viewModel;
}

- (void)setViewModelExternally:(id <FeedViewModelProtocol>)model {
    NSAssert(model != nil, @"Model should not be nil");
    if (_viewModel != nil) {
        [self unbindViewModel];
    }
    [self bindViewModel:model];
}

- (void)bindViewModel:(id <FeedViewModelProtocol>)viewModel {
    self.viewModel = viewModel;
//    self.viewModel.delegate = self;
}

- (void)unbindViewModel {
//    self.viewModel.delegate = nil;
    self.viewModel = nil;
}

#pragma mark Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.viewModel gatherTwittedProfileData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
