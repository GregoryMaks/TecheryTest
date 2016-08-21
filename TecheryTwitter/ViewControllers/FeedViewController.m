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

@property (nonatomic, strong) UILabel *emptyFeedLabel;

@end


@implementation FeedViewController

- (UILabel *)emptyFeedLabel {
    if (_emptyFeedLabel == nil) {
        _emptyFeedLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        
        _emptyFeedLabel.text = @"Feed is empty. Please pull down to refresh.";
        _emptyFeedLabel.textColor = [UIColor blackColor];
        _emptyFeedLabel.numberOfLines = 0;
        _emptyFeedLabel.textAlignment = NSTextAlignmentCenter;
        _emptyFeedLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return _emptyFeedLabel;
}

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
    
    [RACObserve(self.viewModel, isFeedRefreshing) subscribeNext:^(NSNumber *value) {
        @strongify(self);
        if (value.boolValue && !self.refreshControl.isRefreshing) {
            [self.refreshControl beginRefreshing];
        }
        else if (!value.boolValue && self.refreshControl.isRefreshing) {
            [self.refreshControl endRefreshing];
        }
    }];
}

- (void)unbindViewModel {
    self.viewModel = nil;
}

#pragma mark Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    
    @weakify(self);
    [[self.refreshControl rac_signalForControlEvents:UIControlEventValueChanged]
     subscribeNext:^(UIRefreshControl *control) {
         @strongify(self);
         [self.viewModel refreshFeed];
     }];
    
    [self.viewModel refreshFeed];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([self.viewModel numberOfRowsInFeedTable] > 0) {
        self.tableView.backgroundView = nil;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        
        return 1;
    }
    else {
        self.tableView.backgroundView = self.emptyFeedLabel;
        self.emptyFeedLabel.frame = CGRectMake(0, 0, self.tableView.bounds.size.width, self.tableView.bounds.size.height);
        
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        return 0;
    }
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
