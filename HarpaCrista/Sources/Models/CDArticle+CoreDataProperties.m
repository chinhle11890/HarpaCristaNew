//
//  CDArticle+CoreDataProperties.m
//  HarpaCrista
//
//  Created by Chinh Le on 9/18/16.
//  Copyright © 2016 Chinh Le. All rights reserved.
//

#import "CDArticle+CoreDataProperties.h"

@implementation CDArticle (CoreDataProperties)

+ (NSFetchRequest<CDArticle *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"CDArticle"];
}

@dynamic cdDescription;
@dynamic cdDetail;
@dynamic cdPhoto;
@dynamic cdTitle;

@end
