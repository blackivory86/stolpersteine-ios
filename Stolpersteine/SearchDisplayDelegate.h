//
//  SearchDisplayDelegate.h
//  Stolpersteine
//
//  Created by Claus on 28.01.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SearchDisplayController;

@protocol SearchDisplayDelegate <NSObject>

@optional
- (BOOL)searchDisplayController:(SearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString;

@end
