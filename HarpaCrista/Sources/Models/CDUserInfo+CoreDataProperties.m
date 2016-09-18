//
//  CDUserInfo+CoreDataProperties.m
//  HarpaCrista
//
//  Created by Chinh Le on 9/18/16.
//  Copyright © 2016 Chinh Le. All rights reserved.
//

#import "CDUserInfo+CoreDataProperties.h"

@implementation CDUserInfo (CoreDataProperties)

+ (NSFetchRequest<CDUserInfo *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"CDUserInfo"];
}

@dynamic user;
@dynamic follower;

@end
