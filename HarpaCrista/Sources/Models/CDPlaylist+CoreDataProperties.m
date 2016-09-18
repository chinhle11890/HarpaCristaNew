//
//  CDPlaylist+CoreDataProperties.m
//  HarpaCrista
//
//  Created by Chinh Le on 9/18/16.
//  Copyright © 2016 Chinh Le. All rights reserved.
//

#import "CDPlaylist+CoreDataProperties.h"

@implementation CDPlaylist (CoreDataProperties)

+ (NSFetchRequest<CDPlaylist *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"CDPlaylist"];
}

@dynamic cdName;
@dynamic songInfo;

@end
