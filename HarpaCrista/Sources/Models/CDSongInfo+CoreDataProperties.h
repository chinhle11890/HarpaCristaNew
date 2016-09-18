//
//  CDSongInfo+CoreDataProperties.h
//  HarpaCrista
//
//  Created by Chinh Le on 9/18/16.
//  Copyright © 2016 Chinh Le. All rights reserved.
//

#import "CDSongInfo+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface CDSongInfo (CoreDataProperties)

+ (NSFetchRequest<CDSongInfo *> *)fetchRequest;

@property (nullable, nonatomic, retain) CDPlaylist *playlist;
@property (nullable, nonatomic, retain) CDSong *song;

@end

NS_ASSUME_NONNULL_END
