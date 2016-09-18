//
//  CDInstrument+CoreDataProperties.m
//  HarpaCrista
//
//  Created by Chinh Le on 9/18/16.
//  Copyright © 2016 Chinh Le. All rights reserved.
//

#import "CDInstrument+CoreDataProperties.h"

@implementation CDInstrument (CoreDataProperties)

+ (NSFetchRequest<CDInstrument *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"CDInstrument"];
}

@dynamic cdAvatar;
@dynamic cdIsFavorite;
@dynamic cdName;

@end
