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
#import "TwitterTweet.h"
#import "NSDate+Twitter.h"


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
    // Default model
    // TODO: maybe delegate to C in MVVM-C
    if (_viewModel == nil) {
        _viewModel = [[FeedViewModel alloc] init];
    }
    return _viewModel;
}

- (void)setViewModelExternally:(id <FeedViewModelProtocol>)model {
    NSAssert(model != nil, @"Model should not be nil");
    self.viewModel = model;
}

- (void)bindViewModel {
    @weakify(self);
    [self.viewModel.dataUpdated subscribeNext:^(id parameter) {
        @strongify(self);
        [self.tableView reloadData];
    }];
    
    // TODO: how to unlink from signal when rebinding?
    [RACObserve(self.viewModel, isFeedRefreshing) subscribeNext:^(NSNumber *value) {
        @strongify(self);
        if (self.refreshControl == nil) {
            return;
        }
        
        BOOL isRefreshing = self.viewModel.isFeedRefreshing;
        if (isRefreshing && !self.refreshControl.isRefreshing) {
            [self.refreshControl beginRefreshing];
        }
        else if (!isRefreshing && self.refreshControl.isRefreshing) {
            [self.refreshControl endRefreshing];
        }
    }];
    
    RAC(self.navigationItem, title, @"Loading...") =
    [[[RACObserve(self.viewModel, twitterUsername) combineLatestWith:RACObserve(self.viewModel, isOnline)
       ] map:^id(RACTuple *value) {
         return [NSString stringWithFormat:@"%@%@", value.first ?: @"", [value.second boolValue] ? @"" : @" (offline)"];
    }] deliverOn:[RACScheduler mainThreadScheduler]];
}

#pragma mark Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self bindViewModel];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 100;
    
    @weakify(self);
    [[self.refreshControl rac_signalForControlEvents:UIControlEventValueChanged]
     subscribeNext:^(UIRefreshControl *control) {
         @strongify(self);
         [self refreshFeed];
     }];
    
    [self refreshFeed];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)refreshFeed {
    @weakify(self);
    [[self.viewModel refreshFeedSignal] subscribeNext:^(NSNumber *newTweetsLoaded) {
        @strongify(self);
        if ([newTweetsLoaded boolValue]) {
            [self.tableView reloadData];
        }
    }];
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
    
    TwitterTweet *tweet = [self.viewModel tweetForRowAtIndexPath:indexPath];
    if (tweet != nil) {
        cell.tweetTextLabel.text = tweet.text;
        cell.tweetDataLabel.text = [[NSDate dateWithTimeIntervalSinceReferenceDate:tweet.createdAt] tweetDisplayDateString];
        
        // TODO: can be improved with AFNetworking or separate thread
        if (tweet.authorProfileImageUrl.length > 0) {
            [cell loadImageAtURL:[NSURL URLWithString:tweet.authorProfileImageUrl]];
        }
    }
    
    return cell;
}

@end
