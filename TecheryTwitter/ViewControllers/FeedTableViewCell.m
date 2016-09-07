//
//  FeedTableViewCell.m
//  TecheryTwitter
//
//  Created by GregoryM on 8/11/16.
//  Copyright © 2016 None. All rights reserved.
//

#import "FeedTableViewCell.h"


@interface FeedTableViewCell ()

@property (nonatomic, strong) NSURLSessionDataTask *imageLoadingTask;

@end


@implementation FeedTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)prepareForReuse {
    if (self.imageLoadingTask == nil) {
        [self.imageLoadingTask cancel];
        self.imageLoadingTask = nil;
    }
    
    [super prepareForReuse];
}

- (void)loadImageAtURL:(NSURL *)authorImageURL {
    if (self.imageLoadingTask == nil) {
        [self.imageLoadingTask cancel];
    }
    
    self.imageLoadingTask =
    [[NSURLSession sharedSession] dataTaskWithURL:authorImageURL
                                completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                    if (error != nil) {
                                        NSLog(@"Error loading userpic, %@", [error localizedDescription]);
                                        return;
                                    }
                                    
                                    UIImage *image = [UIImage imageWithData:data];
                                    if (image != nil) {
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            self.tweetImageView.image = image;
                                            self.tweetImageView.layer.cornerRadius = 4;
                                        });
                                    }
                                }];
    [self.imageLoadingTask resume];
}

@end
