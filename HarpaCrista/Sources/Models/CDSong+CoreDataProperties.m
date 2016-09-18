//
//  CDSong+CoreDataProperties.m
//  HarpaCrista
//
//  Created by Chinh Le on 9/18/16.
//  Copyright © 2016 Chinh Le. All rights reserved.
//

#import "CDSong+CoreDataProperties.h"

@implementation CDSong (CoreDataProperties)

+ (NSFetchRequest<CDSong *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"CDSong"];
}

@dynamic cdChord;
@dynamic cdIsFavorite;
@dynamic cdSongID;
@dynamic cdSongLink;
@dynamic cdTitle;
@dynamic songInfo;

@end
