//
//  CDNotification+CoreDataProperties.m
//  HarpaCrista
//
//  Created by Chinh Le on 9/18/16.
//  Copyright © 2016 Chinh Le. All rights reserved.
//

#import "CDNotification+CoreDataProperties.h"

@implementation CDNotification (CoreDataProperties)

+ (NSFetchRequest<CDNotification *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"CDNotification"];
}

@dynamic cdDetail;

@end
