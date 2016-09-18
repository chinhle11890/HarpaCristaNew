//
//  CDUserInfo+CoreDataProperties.h
//  HarpaCrista
//
//  Created by Chinh Le on 9/18/16.
//  Copyright © 2016 Chinh Le. All rights reserved.
//

#import "CDUserInfo+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface CDUserInfo (CoreDataProperties)

+ (NSFetchRequest<CDUserInfo *> *)fetchRequest;

@property (nullable, nonatomic, retain) CDUser *user;
@property (nullable, nonatomic, retain) CDUser *follower;

@end

NS_ASSUME_NONNULL_END
