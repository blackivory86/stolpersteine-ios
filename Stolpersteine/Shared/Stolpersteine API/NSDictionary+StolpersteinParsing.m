//
//  NSDictionary+Parsing.m
//  Stolpersteine
//
//  Created by Hoefele, Claus(choefele) on 11.01.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import "NSDictionary+StolpersteinParsing.h"

#import "Stolperstein.h"

@implementation NSDictionary (Parsing)

- (Stolperstein *)newStolperstein
{
    Stolperstein *stolperstein = [[Stolperstein alloc] init];
    stolperstein.id = [self valueForKeyPath:@"id"];
    stolperstein.text = [self valueForKeyPath:@"description"];
    stolperstein.personFirstName = [self valueForKeyPath:@"person.firstName"];
    stolperstein.personLastName = [self valueForKeyPath:@"person.lastName"];
    stolperstein.personBiographyURLString = [self valueForKeyPath:@"person.biographyUrl"];
    stolperstein.locationStreet = [self valueForKeyPath:@"location.street"];
    stolperstein.locationZipCode = [self valueForKeyPath:@"location.zipCode"];
    stolperstein.locationCity = [self valueForKeyPath:@"location.city"];
    
    NSString *latitudeAsString = [self valueForKeyPath:@"location.coordinates.latitude"];
    NSString *longitudeAsString = [self valueForKeyPath:@"location.coordinates.longitude"];
    stolperstein.locationCoordinate = CLLocationCoordinate2DMake(latitudeAsString.doubleValue, longitudeAsString.doubleValue);
    
    return stolperstein;
}

@end
