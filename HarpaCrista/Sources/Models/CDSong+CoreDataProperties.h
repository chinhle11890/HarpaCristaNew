//
//  CDSong+CoreDataProperties.h
//  HarpaCrista
//
//  Created by Chinh Le on 9/18/16.
//  Copyright © 2016 Chinh Le. All rights reserved.
//

#import "CDSong+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface CDSong (CoreDataProperties)

+ (NSFetchRequest<CDSong *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *cdChord;
@property (nullable, nonatomic, copy) NSNumber *cdIsFavorite;
@property (nullable, nonatomic, copy) NSNumber *cdSongID;
@property (nullable, nonatomic, copy) NSString *cdSongLink;
@property (nullable, nonatomic, copy) NSString *cdTitle;
@property (nullable, nonatomic, retain) NSSet<CDSongInfo *> *songInfo;

@end

@interface CDSong (CoreDataGeneratedAccessors)

- (void)addSongInfoObject:(CDSongInfo *)value;
- (void)removeSongInfoObject:(CDSongInfo *)value;
- (void)addSongInfo:(NSSet<CDSongInfo *> *)values;
- (void)removeSongInfo:(NSSet<CDSongInfo *> *)values;

@end

NS_ASSUME_NONNULL_END
