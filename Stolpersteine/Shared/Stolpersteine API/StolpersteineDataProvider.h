//
//  StolpersteineDataProvider.h
//  Stolpersteine
//
//  Created by Jan Rose on 24.01.16.
//  Copyright © 2016 Option-U Software. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import <Foundation/Foundation.h>
#import "StolpersteineCache.h"
#import "StolpersteineSynchronizationController.h"

@class StolpersteineDataProvider;
@class Stolperstein;

@protocol StolpersteineDataProviderDelegate <NSObject>

@optional

- (void)dataProvider:(StolpersteineDataProvider*)provider didAddStolpersteine:(NSArray<Stolperstein*>*)stolpersteine;

- (void)dataProvider:(StolpersteineDataProvider *)provider didUpdateStolpersteine:(NSArray<Stolperstein*>*)stolpersteine;

- (void)dataProvider:(StolpersteineDataProvider *)provider didRemoveStolpersteine:(NSArray<Stolperstein*>*)stolpersteine;

@end

@interface StolpersteineDataProvider : NSObject

@property (nonatomic, weak) id<StolpersteineDataProviderDelegate> delegate;

@property (nonatomic, strong) StolpersteineCache* cache;

@property (nonatomic, strong) StolpersteineSynchronizationController* syncController;

- (instancetype)initWithSyncController:(StolpersteineSynchronizationController*)syncController
                                 cache:(StolpersteineCache*)cache;

- (void)loadAll;

- (void)loadInRegion:(MKCoordinateRegion*)mkRegion;

@end
