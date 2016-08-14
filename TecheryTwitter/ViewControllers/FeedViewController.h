//
//  FeedViewController.h
//  TecheryTwitter
//
//  Created by GregoryM on 8/11/16.
//  Copyright © 2016 None. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol FeedViewModelProtocol;


@interface FeedViewController : UITableViewController

- (void)setViewModelExternally:(id <FeedViewModelProtocol>)model;

@end
