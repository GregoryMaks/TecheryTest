////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//  NSDate+Twitter.m
//  TecheryTwitter
//
//  Created by GregoryM on 8/16/16.
//  Copyright 2016 None. All rights reserved.
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#import "NSDate+Twitter.h"


@implementation NSDate (Twitter)

+ (NSDate *)parseTwitterDate:(NSString *)dateString {
    // "Wed Aug 29 17:12:58 +0000 2012"
    
    // For performance reasons
    static NSDateFormatter *dateTimeFormatter = nil;
    if (dateTimeFormatter == nil) {
        dateTimeFormatter = [[NSDateFormatter alloc] init];
        [dateTimeFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
        [dateTimeFormatter setDateFormat:@"EEE MMM d HH:mm:ss Z y"];
    }
    
    NSDate *date = nil;
    NSError *error = nil;
    if (NO == [dateTimeFormatter getObjectValue:&date forString:dateString range:nil error:&error]) {
        NSLog(@"Date '%@' could not be parsed: %@", dateString, error);
    }
    return date;
}

- (NSString *)tweetDisplayDateString {
    static NSDateFormatter *dateTimeFormatter = nil;
    if (dateTimeFormatter == nil) {
        dateTimeFormatter = [[NSDateFormatter alloc] init];
        [dateTimeFormatter setDateFormat:@"HH:mm d MMM YYYY"];
    }
    
    return [dateTimeFormatter stringFromDate:self];
}

@end
