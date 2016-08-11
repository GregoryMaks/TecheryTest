//
//  FeedTableViewCell.h
//  TecheryTwitter
//
//  Created by GregoryM on 8/11/16.
//  Copyright © 2016 None. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FeedTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *tweetImageView;
@property (weak, nonatomic) IBOutlet UILabel *tweetTextLabel;

@end
