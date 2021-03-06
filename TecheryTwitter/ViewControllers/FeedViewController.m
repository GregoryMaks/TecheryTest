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
@import Social;


static NSString * const kLoadMoreFeedTableViewCell = @"LoadMoreFeedTableViewCell";


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

- (void)setViewModelExternally:(id <FeedViewModelProtocol>)model {
    NSAssert(model != nil, @"Model should not be nil");
    self.viewModel = model;
}

- (void)bindViewModel {
    NSAssert(self.viewModel != nil, @"Model should not be nil");
    if (self.viewModel == nil) {
        return;
    }
    
    @weakify(self);
    [self.viewModel.dataUpdatedSignal subscribeNext:^(id parameter) {
        @strongify(self);
        [self.tableView reloadData];
    }];
    
    [self.viewModel.errorOccuredSignal subscribeNext:^(NSError *error) {
        @strongify(self);
        [self processError:error];
    }];
    
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
    self.tableView.estimatedRowHeight = 100;    // Any default number will do
    
    self.tableView.allowsSelection = NO;
    
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
    RACSignal *refreshSignal = [self.viewModel refreshFeedSignal];
    refreshSignal = [refreshSignal deliverOn:[RACScheduler mainThreadScheduler]];
    [refreshSignal subscribeNext:^(id x) {}
                           error:^(NSError *error) {
        @strongify(self);
        [self processError:error];
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
    return [self.viewModel numberOfRowsInFeedTable];// + 1;    // Load more button, disabled for now
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < [self.viewModel numberOfRowsInFeedTable]) {
        FeedTableViewCell *cell =
            (FeedTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:NSStringFromClass([FeedTableViewCell class])];
        
        TwitterTweet *tweet = [self.viewModel tweetForRowAtIndexPath:indexPath];
        if (tweet != nil) {
            cell.tweetTextLabel.text = tweet.text;
            cell.tweetDataLabel.text = [[NSDate dateWithTimeIntervalSinceReferenceDate:tweet.createdAt] tweetDisplayDateStringWithTimeZone:[NSTimeZone systemTimeZone]];
            
            if (tweet.authorProfileImageUrl.length > 0) {
                [cell loadImageAtURL:[NSURL URLWithString:tweet.authorProfileImageUrl]];
            }
        }
        return cell;
    }
    else {
        return [self.tableView dequeueReusableCellWithIdentifier:kLoadMoreFeedTableViewCell];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= [self.viewModel numberOfRowsInFeedTable]) {
        NSLog(@"not implemented");
    }
}

#pragma mark Actions

- (IBAction)createNewTweetButtonClicked:(id)sender {
    [self.viewModel initiateNewTweetCreation];
}

#pragma mark Private

- (void)processError:(NSError *)error {
    if (error.code == FeedViewModel_NoInternetConnection) {
        NSLog(@"No internet connection");
    }
    else {
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"Error"
                                                                       message:[error localizedDescription]
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alertVC addAction:[UIAlertAction actionWithTitle:@"Ok"
                                                    style:UIAlertActionStyleCancel
                                                  handler:nil]];
        [self presentViewController:alertVC animated:YES completion:nil];
    }
}

@end
