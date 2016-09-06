//
//  TwitterNetworkServiceMock.m
//  TecheryTwitter
//
//  Created by GregoryM on 9/1/16.
//  Copyright © 2016 None. All rights reserved.
//

#import "TwitterNetworkServiceMock.h"
#import "TwitterNetworkService.h"


@interface TwitterNetworkServiceMock ()
@end


@implementation TwitterNetworkServiceMock

@synthesize accountMock;

- (KWMock *)accountMock {
    @synchronized (self) {
        if (accountMock == nil) {
            accountMock = [ACAccount nullMock];
        }
        return accountMock;
    }
}

- (ACAccount *)account {
    return (ACAccount *)self.accountMock;
}

- (instancetype)init {
    self = [super initAsNullMockForClass:[TwitterNetworkService class]];
    if (self) {
    }
    return self;
}

- (void)connectToTwitterAccountWithResultBlock:(void(^)(BOOL isGranted, BOOL isAccountAvailable))resultBlock {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        resultBlock(self.connectGrantedReply, self.connectAccountAvailableReply);
    });
}

@end
