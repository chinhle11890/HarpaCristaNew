//
//  CDUser+CoreDataProperties.h
//  HarpaCrista
//
//  Created by Chinh Le on 9/18/16.
//  Copyright © 2016 Chinh Le. All rights reserved.
//

#import "CDUser+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface CDUser (CoreDataProperties)

+ (NSFetchRequest<CDUser *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *cdAddress;
@property (nullable, nonatomic, copy) NSString *cdAvatar;
@property (nullable, nonatomic, copy) NSString *cdBio;
@property (nullable, nonatomic, copy) NSString *cdCountry;
@property (nullable, nonatomic, copy) NSString *cdEmail;
@property (nullable, nonatomic, copy) NSString *cdFirstName;
@property (nullable, nonatomic, copy) NSString *cdLastName;
@property (nullable, nonatomic, copy) NSString *cdPhone;
@property (nullable, nonatomic, copy) NSString *cdState;
@property (nullable, nonatomic, copy) NSString *cdInstrument;
@property (nullable, nonatomic, copy) NSString *cdSocial;
@property (nullable, nonatomic, copy) NSString *cdSong;
@property (nullable, nonatomic, copy) NSString *cdUserId;
@property (nullable, nonatomic, retain) CDUserInfo *followedInfo;
@property (nullable, nonatomic, retain) NSSet<CDUserInfo *> *followerInfo;

@end

@interface CDUser (CoreDataGeneratedAccessors)

- (void)addFollowerInfoObject:(CDUserInfo *)value;
- (void)removeFollowerInfoObject:(CDUserInfo *)value;
- (void)addFollowerInfo:(NSSet<CDUserInfo *> *)values;
- (void)removeFollowerInfo:(NSSet<CDUserInfo *> *)values;

@end

NS_ASSUME_NONNULL_END
