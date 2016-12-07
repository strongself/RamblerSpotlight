// Copyright (c) 2016 RAMBLER&Co
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY RSIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "RamblerSpotlight.h"

#import "SpotlightAssembly.h"
#import "IndexerMonitor.h"
#import "SpotlightCoreDataStackCoordinator.h"
#import "ContextStorageImplementation.h"

@protocol ChangeProvider;
@protocol ObjectIndexer;
@protocol ObjectTransformer;

@interface RamblerSpotlight ()

@property (nonatomic, strong) IndexerMonitor *indexerMonitor;
@property (nonatomic, strong) id<SpotlightCoreDataStackCoordinator> spotlightCoreDataStackCoordinator;

@end

@implementation RamblerSpotlight

- (void)setupSpotlightWithSpotlightEntityObjects:(NSArray<SpotlightEntityObject *> *)entityObjects
                                      appContext:(NSManagedObjectContext *)appContext
                                 searchableIndex:(CSSearchableIndex *)searchableIndex {
    SpotlightAssembly *spotlightFactory = [SpotlightAssembly new];
    
    ContextStorageImplementation *contextStorage = [spotlightFactory contextStorageWithAppContext:appContext];
    id<SpotlightCoreDataStackCoordinator> coordinator = [spotlightFactory spotlightCoreDataStackCoordinatorWithContextStorage:contextStorage];
    [coordinator setupCoreDataStack];
    
    IndexerMonitor *indexerMonitor = [spotlightFactory indexerMonitorWithEntityObjects:entityObjects
                                                                        contextStorage:contextStorage
                                                                       searchableIndex:searchableIndex];
    self.indexerMonitor = indexerMonitor;
    self.spotlightCoreDataStackCoordinator = coordinator;
}

- (void)deleteSpotlightDatabase {
    [self.indexerMonitor stopMonitoring];
    [self.indexerMonitor deleteAllDataFromSpotlight];
    [self.spotlightCoreDataStackCoordinator clearDatabaseFilesSpotlight];
    
    self.indexerMonitor = nil;
    self.spotlightCoreDataStackCoordinator = nil;
}

- (void)startMonitoring {
    [self.indexerMonitor startMonitoring];
}

- (void)stopMonitoring {
    [self.indexerMonitor stopMonitoring];
}

@end
