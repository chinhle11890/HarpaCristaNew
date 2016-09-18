//
//  CDArticle+CoreDataProperties.h
//  HarpaCrista
//
//  Created by Chinh Le on 9/18/16.
//  Copyright © 2016 Chinh Le. All rights reserved.
//

#import "CDArticle+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface CDArticle (CoreDataProperties)

+ (NSFetchRequest<CDArticle *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *cdDescription;
@property (nullable, nonatomic, copy) NSString *cdDetail;
@property (nullable, nonatomic, retain) NSData *cdPhoto;
@property (nullable, nonatomic, copy) NSString *cdTitle;

@end

NS_ASSUME_NONNULL_END
