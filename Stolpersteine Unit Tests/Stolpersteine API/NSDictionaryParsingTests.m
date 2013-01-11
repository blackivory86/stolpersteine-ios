//
//  Stolpersteine_Unit_Tests.m
//  Stolpersteine Unit Tests
//
//  Created by Hoefele, Claus(choefele) on 11.01.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import "NSDictionaryParsingTests.h"

#import "NSDictionary+Parsing.h"
#import "Stolperstein.h"

// http://www.infinite-loop.dk/blog/2011/09/using-nsurlprotocol-for-injecting-test-data/
// http://www.infinite-loop.dk/blog/2011/04/unittesting-asynchronous-network-access/
// https://gist.github.com/2254570

@implementation NSDictionaryParsingTests

- (void)testNewStolperstein
{
    NSString *stolpersteinAsJSON =
        @"{"                                                    \
        @"    \"createdAt\": \"2012-12-23T22:57:07.519Z\","     \
        @"    \"updatedAt\": \"2012-12-23T22:57:07.519Z\","     \
        @"    \"description\": \"Beschreibung\","               \
        @"    \"_id\": \"50d78c43f737060b54000002\","           \
        @"    \"sources\": [],"                                 \
        @"    \"laidAt\": {"                                    \
        @"        \"year\": 2012,"                              \
        @"        \"month\": 11,"                               \
        @"        \"date\": 12"                                 \
        @"    },"                                               \
        @"    \"location\": {"                                  \
        @"        \"street\": \"Straße 1\","                    \
        @"        \"zipCode\": \"10000\","                      \
        @"        \"city\": \"Stadt\","                         \
        @"        \"coordinates\": {"                           \
        @"            \"longitude\": 1,"                        \
        @"            \"latitude\": 1"                          \
        @"        }"                                            \
        @"    },"                                               \
        @"    \"person\": {"                                    \
        @"        \"name\": \"Vorname Nachname\""               \
        @"    }"                                                \
        @"}";

    NSData *stolpersteinAsData = [stolpersteinAsJSON dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *stolpersteinAsDictionary = [NSJSONSerialization JSONObjectWithData:stolpersteinAsData options:0 error:NULL];
    Stolperstein *stolperstein = [stolpersteinAsDictionary newStolperstein];
    STAssertEqualObjects(stolperstein.id, @"50d78c43f737060b54000002", @"Wrong id");
}

@end
