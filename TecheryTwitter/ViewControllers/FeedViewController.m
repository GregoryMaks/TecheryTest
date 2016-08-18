//
//  FeedViewController.m
//  TecheryTwitter
//
//  Created by GregoryM on 8/11/16.
//  Copyright © 2016 None. All rights reserved.
//

#import "FeedViewController.h"
#import "FeedViewModel.h"
#import "FeedTableViewCell.h"


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

    @weakify(self);
    [self.viewModel.dataUpdated subscribeNext:^(id parameter) {
        @strongify(self);
        [self.tableView reloadData];
    }];
//    self.viewModel.delegate = self;
}

- (void)unbindViewModel {
//    self.viewModel.delegate = nil;
    self.viewModel = nil;
}

#pragma mark Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.viewModel refreshFeed];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.viewModel numberOfRowsInFeedTable];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FeedTableViewCell *cell =
        (FeedTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:NSStringFromClass([FeedTableViewCell class])];
    
    [self.viewModel fillCell:cell withDataForRowAtIndexPath:indexPath];
    
    return cell;
}

@end
