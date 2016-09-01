//
//  TwitterNetworkServiceMock.h
//  TecheryTwitter
//
//  Created by GregoryM on 9/1/16.
//  Copyright © 2016 None. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Kiwi/Kiwi.h>


@interface TwitterNetworkServiceMock : KWMock

@property (nonatomic, assign) BOOL connectGrantedReply;
@property (nonatomic, assign) BOOL connectAccountAvailableReply;

@end
