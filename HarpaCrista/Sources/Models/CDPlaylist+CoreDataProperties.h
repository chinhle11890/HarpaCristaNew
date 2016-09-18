//
//  CDPlaylist+CoreDataProperties.h
//  HarpaCrista
//
//  Created by Chinh Le on 9/18/16.
//  Copyright © 2016 Chinh Le. All rights reserved.
//

#import "CDPlaylist+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface CDPlaylist (CoreDataProperties)

+ (NSFetchRequest<CDPlaylist *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *cdName;
@property (nullable, nonatomic, retain) NSSet<CDSongInfo *> *songInfo;

@end

@interface CDPlaylist (CoreDataGeneratedAccessors)

- (void)addSongInfoObject:(CDSongInfo *)value;
- (void)removeSongInfoObject:(CDSongInfo *)value;
- (void)addSongInfo:(NSSet<CDSongInfo *> *)values;
- (void)removeSongInfo:(NSSet<CDSongInfo *> *)values;

@end

NS_ASSUME_NONNULL_END
