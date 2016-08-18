//
//  TwitterUser+CoreDataProperties.h
//  TecheryTwitter
//
//  Created by GregoryM on 8/15/16.
//  Copyright © 2016 None. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "TwitterUser.h"

NS_ASSUME_NONNULL_BEGIN

@interface TwitterUser (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *username;
@property (nullable, nonatomic, retain) NSManagedObject *tweets;

@end

NS_ASSUME_NONNULL_END
