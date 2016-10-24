// Copyright (c) 2015 RAMBLER&Co
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
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "SpotlightAssembly.h"

#import "IndexerMonitor.h"
#import "FetchedResultsControllerChangeProvider.h"
#import "IndexerStateStorage.h"
#import "IndexerMonitorOperationQueueFactory.h"
#import "SpotlightCoreDataStackCoordinatorImplementation.h"
#import "ContextStorageImplementation.h"
#import "SpotlightCoreDataHandlerImplementation.h"
#import "ObjectIndexer.h"
#import <CoreSpotlight/CoreSpotlight.h>
#import "SpotlightEntityObject.h"
#import "ObjectIndexerBase.h"

@interface SpotlightAssembly ()

@end

@implementation SpotlightAssembly

#pragma mark - IndexMonitor

- (IndexerMonitor *)indexerMonitorWithEntitiesObjects:(NSArray *)objects
                                       contextStorage:(ContextStorageImplementation *)contextStorage
                                      searchableIndex:(CSSearchableIndex *)searchableIndex {
    
    NSArray<ChangeProvider> *providers = [self providersFromSpotlightEntititesObjects:objects
                                                                       contextStorage:contextStorage];
    NSArray<ObjectIndexer> *indexers = [self indexersFromSpotlightEntititesObjects:objects
                                                                   searchableIndex:searchableIndex];
    SpotlightCoreDataHandlerImplementation *spotlightCoreDataHandler = [[SpotlightCoreDataHandlerImplementation alloc] init];
    IndexerMonitorOperationQueueFactory *indexerMonitorOperationQueueFactory = [[IndexerMonitorOperationQueueFactory alloc] init];
    IndexerStateStorage *indexerStateStorage = [IndexerStateStorage stateStorageWithContextProvider:contextStorage
                                                                                    coreDataHandler:spotlightCoreDataHandler];
    
    IndexerMonitor *indexerMonitor = [IndexerMonitor monitorWithIndexers:[indexers copy]
                                                         changeProviders:[providers copy]
                                                            stateStorage:indexerStateStorage
                                                            queueFactory:indexerMonitorOperationQueueFactory
                                                         searchableIndex:searchableIndex];
    return indexerMonitor;
}


#pragma mark - CoreData objects

- (id<SpotlightCoreDataStackCoordinator>)spotlightCoreDataStackCoordinatorWithContextStorage:(ContextStorageImplementation *)contextFiller {
    return [SpotlightCoreDataStackCoordinatorImplementation coordinatorWithContextStorage:contextFiller];
}

- (ContextStorageImplementation *)contextStorageWithAppContext:(NSManagedObjectContext *)appContext {
    return [[ContextStorageImplementation alloc] initWithAppContext:appContext];
}

#pragma mark - Private

- (NSArray<ChangeProvider> *)providersFromSpotlightEntititesObjects:(NSArray *)objects
                                                     contextStorage:(ContextStorageImplementation *)contextStorage {
    NSMutableArray<ChangeProvider> *providers = [NSMutableArray<ChangeProvider> new];
    for (SpotlightEntityObject *object in objects) {
        id<ChangeProvider> provider =
        [FetchedResultsControllerChangeProvider changeProviderWithFetchRequestFactory:object.requestFactory
                                                                    objectTransformer:object.objectTransformer
                                                                      contextProvider:contextStorage];
        [providers addObject:provider];
    }
    return [providers copy];
}

- (NSArray<ObjectIndexer> *)indexersFromSpotlightEntititesObjects:(NSArray *)objects
                                                  searchableIndex:(CSSearchableIndex *) searchableIndex{
    NSMutableArray<ObjectIndexer> *indexers = [NSMutableArray<ObjectIndexer> new];
    for (SpotlightEntityObject *object in objects) {
        ObjectIndexerBase *indexer = object.objectIndexer;
        indexer.objectTransformer = object.objectTransformer;
        indexer.searchableIndex = searchableIndex;
        
        [indexers addObject:indexer];
    }
    return [indexers copy];

}

@end
