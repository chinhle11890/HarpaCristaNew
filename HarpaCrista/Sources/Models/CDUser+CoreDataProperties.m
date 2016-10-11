//
//  CDUser+CoreDataProperties.m
//  HarpaCrista
//
//  Created by Chinh Le on 9/18/16.
//  Copyright © 2016 Chinh Le. All rights reserved.
//

#import "CDUser+CoreDataProperties.h"

@implementation CDUser (CoreDataProperties)

+ (NSFetchRequest<CDUser *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"CDUser"];
}

@dynamic cdAddress;
@dynamic cdAvatar;
@dynamic cdBio;
@dynamic cdCountry;
@dynamic cdEmail;
@dynamic cdFirstName;
@dynamic cdLastName;
@dynamic cdPhone;
@dynamic cdState;
@dynamic cdInstrument;
@dynamic cdSocial;
@dynamic cdSong;
@dynamic cdUserId;
@dynamic followedInfo;
@dynamic followerInfo;

@end
