//
//  main.m
//  TecheryTwitter
//
//  Created by GregoryM on 8/11/16.
//  Copyright © 2016 None. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "EmptyTestsAppDelegate.h"

//int main(int argc, char * argv[]) {
//    @autoreleasepool {
//        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
//    }
//}

int main(int argc, char* argv[]) {
    int returnValue;
    
    @autoreleasepool {
        BOOL inTests = (NSClassFromString(@"SenTestCase") != nil ||
                        NSClassFromString(@"XCTest") != nil);
        
        if (inTests) {
            //use a special empty delegate when we are inside the tests
            returnValue = UIApplicationMain(argc, argv, nil, NSStringFromClass([EmptyTestsAppDelegate class]));
        }
        else {
            //use the normal delegate
            returnValue = UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
        }
    }
    
    return returnValue;
}