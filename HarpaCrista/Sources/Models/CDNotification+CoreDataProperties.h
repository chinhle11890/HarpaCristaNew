//
//  CDNotification+CoreDataProperties.h
//  HarpaCrista
//
//  Created by Chinh Le on 9/18/16.
//  Copyright © 2016 Chinh Le. All rights reserved.
//

#import "CDNotification+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface CDNotification (CoreDataProperties)

+ (NSFetchRequest<CDNotification *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *cdDetail;

@end

NS_ASSUME_NONNULL_END
