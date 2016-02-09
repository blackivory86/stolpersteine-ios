//
//  Stolperstein+CoreDataProperties.h
//  
//
//  Created by Jan Rose on 23.01.16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Stolperstein.h"

NS_ASSUME_NONNULL_BEGIN

@interface Stolperstein (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *stolpersteinID;
@property (nonatomic) UInt32 type;
@property (nullable, nonatomic, retain) NSString *sourceName;
@property (nullable, nonatomic, retain) NSString *sourceURL;
@property (nullable, nonatomic, retain) NSString *personFirstName;
@property (nullable, nonatomic, retain) NSString *personLastName;
@property (nullable, nonatomic, retain) NSString *biographyURL;
@property (nullable, nonatomic, retain) NSString *locationStreet;
@property (nullable, nonatomic, retain) NSString *locationZipCode;
@property (nullable, nonatomic, retain) NSString *locationCity;
@property (nonatomic) double locationLatitude;
@property (nonatomic) double locationLongitude;
@property (nullable, nonatomic, retain) NSString *title;
@property (nullable, nonatomic, retain) NSString *subtitle;

@end

NS_ASSUME_NONNULL_END
