////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//  NSDate+Twitter.h
//  TecheryTwitter
//
//  Created by GregoryM on 8/16/16.
//  Copyright 2016 None. All rights reserved.
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#import <Foundation/Foundation.h>


@interface NSDate (Twitter)

+ (NSDate *)parseTwitterDate:(NSString *)dateString;

- (NSString *)tweetDisplayDateStringWithTimeZone:(NSTimeZone *)timeZone;

@end
