//
//  StolpersteineDataProvider.m
//  Stolpersteine
//
//  Created by Jan Rose on 24.01.16.
//  Copyright © 2016 Option-U Software. All rights reserved.
//

#import "StolpersteineDataProvider.h"
#import "StolpersteinSynchronizationControllerDelegate.h"

@interface StolpersteineDataProvider () <StolpersteineSynchronizationControllerDelegate>

@end

@implementation StolpersteineDataProvider

- (instancetype)initWithSyncController:(StolpersteineSynchronizationController*)syncController
                                 cache:(StolpersteineCache*)cache
{
    self = [super init];
    
    if (self)
    {
        self.syncController = syncController;
        self.syncController.delegate = self;
        self.cache = cache;
    }
    
    return self;
}

- (void)loadAll
{
    NSAssert(self.delegate, @"querying the cache without a delegate is just wasting resources");
    
    [self.syncController synchronize];
}

- (void)loadInRegion:(MKCoordinateRegion*)mkRegion
{
    NSAssert(self.delegate, @"querying the cache without a delegate is just wasting resources");
}

#pragma mark StolpersteineSynchronizationController

- (void)stolpersteinSynchronizationController:(StolpersteineSynchronizationController*)stolpersteinSynchronizationController didAddStolpersteine:(NSArray<Stolperstein*>*)stolpersteine
{
    //TODO: compare and update cache
    if([self.delegate respondsToSelector:@selector(dataProvider:didAddStolpersteine:)])
    {
        //for now we just pass along - change if the cache is implemented
        [self.delegate dataProvider:self didAddStolpersteine:stolpersteine];
    }
}

- (void)stolpersteinSynchronizationController:(StolpersteineSynchronizationController *)stolpersteinSynchronizationController didRemoveStolpersteine:(NSArray<Stolperstein*>*)stolpersteine
{
    //TODO: remove from cache?
    
    if([self.delegate respondsToSelector:@selector(dataProvider:didRemoveStolpersteine:)])
    {
        //for now we just pass along - change if the cache is implemented
        [self.delegate dataProvider:self didRemoveStolpersteine:stolpersteine];
    }
}

@end
