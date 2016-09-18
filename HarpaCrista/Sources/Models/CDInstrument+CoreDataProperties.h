//
//  CDInstrument+CoreDataProperties.h
//  HarpaCrista
//
//  Created by Chinh Le on 9/18/16.
//  Copyright © 2016 Chinh Le. All rights reserved.
//

#import "CDInstrument+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface CDInstrument (CoreDataProperties)

+ (NSFetchRequest<CDInstrument *> *)fetchRequest;

@property (nullable, nonatomic, retain) NSData *cdAvatar;
@property (nullable, nonatomic, copy) NSNumber *cdIsFavorite;
@property (nullable, nonatomic, copy) NSString *cdName;

@end

NS_ASSUME_NONNULL_END
