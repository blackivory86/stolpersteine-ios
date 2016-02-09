//
//  Stolperstein.h
//  
//
//  Created by Jan Rose on 23.01.16.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

typedef NS_ENUM(NSInteger, StolpersteinType) {
    StolpersteinTypeStolperstein,
    StolpersteinTypeStolperschwelle
};

NS_ASSUME_NONNULL_BEGIN

@interface Stolperstein : NSManagedObject

@end

NS_ASSUME_NONNULL_END

#import "Stolperstein+CoreDataProperties.h"
