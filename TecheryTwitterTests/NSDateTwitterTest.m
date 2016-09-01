//
//  NSDateTwitterTest.m
//  TecheryTwitter
//
//  Created by GregoryM on 8/29/16.
//  Copyright 2016 None. All rights reserved.
//

#import "Kiwi.h"
#import "NSDate+Twitter.h"


SPEC_BEGIN(NSDateTwitterSpec)

describe(@"When parsing twitter date from string", ^{
    it(@"should parse correct date", ^{
        NSString *str = @"Wed Aug 29 17:12:58 +0000 2012";
        
        NSDate *date = [NSDate parseTwitterDate:str];
        
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        [calendar setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
        
        NSDateComponents *comps = [calendar components:
                                   NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear |
                                   NSCalendarUnitWeekday |
                                   NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond
                                             fromDate:date];
        
        [[theValue(comps.day) should] equal:theValue(29)];
        [[theValue(comps.month) should] equal:theValue(8)];
        [[theValue(comps.year) should] equal:theValue(2012)];
        [[theValue(comps.weekday) should] equal:theValue(4)];
        
        [[theValue(comps.hour) should] equal:theValue(17)];
        [[theValue(comps.minute) should] equal:theValue(12)];
        [[theValue(comps.second) should] equal:theValue(58)];
    });
    
    it(@"should not parse incorrect date", ^{
        NSString *str = @"08/29/2012 17:12:58";
        
        NSDate *date = [NSDate parseTwitterDate:str];
        [[date should] beNil];
    });
});

describe(@"When converting date to twitter string", ^{
    it(@"should return correct string", ^{
        NSDateComponents *comps = [[NSDateComponents alloc] init];
        comps.day = 29;
        comps.month = 8;
        comps.year = 2012;
        
        comps.hour = 17;
        comps.minute = 12;
        comps.second = 58;
        
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        [calendar setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
        NSDate *date = [calendar dateFromComponents:comps];
        
        NSString *str = [date tweetDisplayDateStringWithTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
        
        [[str should] equal:@"Wed Aug 29 17:12:58 +0000 2012"];
    });
});

SPEC_END