//
//  CDSongInfo+CoreDataProperties.m
//  HarpaCrista
//
//  Created by Chinh Le on 9/18/16.
//  Copyright © 2016 Chinh Le. All rights reserved.
//

#import "CDSongInfo+CoreDataProperties.h"

@implementation CDSongInfo (CoreDataProperties)

+ (NSFetchRequest<CDSongInfo *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"CDSongInfo"];
}

@dynamic playlist;
@dynamic song;

@end
