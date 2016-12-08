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
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "IndexerMonitor.h"
#import <CoreSpotlight/CoreSpotlight.h>
#import "ChangeProvider.h"
#import "ObjectIndexer.h"
#import "IndexTransaction.h"
#import "IndexTransactionBatch.h"
#import "IndexerStateStorage.h"
#import "IndexerMonitorOperationQueueFactory.h"

@interface IndexerMonitor ()

@property (nonatomic, copy) NSArray<id<ObjectIndexer>> *indexers;
@property (nonatomic, copy) NSArray<id<ChangeProvider>> *changeProviders;
@property (nonatomic, strong) IndexerStateStorage *stateStorage;
@property (nonatomic, strong) IndexerMonitorOperationQueueFactory *queueFactory;
@property (nonatomic, strong) NSOperationQueue *operationQueue;
@property (nonatomic, strong) CSSearchableIndex *searchableIndex;

@end

@implementation IndexerMonitor

#pragma mark - Initialization

- (instancetype)initWithIndexers:(nonnull NSArray<id<ObjectIndexer>> *)indexers
                 changeProviders:(nonnull NSArray<id<ChangeProvider>> *)changeProviders
                    stateStorage:(nonnull IndexerStateStorage *)stateStorage
                    queueFactory:(nonnull IndexerMonitorOperationQueueFactory *)queueFactory
                 searchableIndex:(nonnull CSSearchableIndex *)searchableIndex {
    self = [super init];
    if (self) {
        _indexers = indexers;
        _changeProviders = changeProviders;
        _stateStorage = stateStorage;
        _queueFactory = queueFactory;
        _searchableIndex = searchableIndex;
    }
    return self;
}

+ (instancetype)monitorWithIndexers:(nonnull NSArray <id<ObjectIndexer>> *)indexers
                    changeProviders:(nonnull NSArray <id<ChangeProvider>> *)changeProviders
                       stateStorage:(nonnull IndexerStateStorage *)stateStorage
                       queueFactory:(nonnull IndexerMonitorOperationQueueFactory *)queueFactory
                    searchableIndex:(nonnull CSSearchableIndex *)searchableIndex {
    
    IndexerMonitor *indexerMonitor = [[self alloc] initWithIndexers:indexers
                                                    changeProviders:changeProviders
                                                       stateStorage:stateStorage
                                                       queueFactory:queueFactory
                                                    searchableIndex:searchableIndex];
    for (id<ChangeProvider> provider in changeProviders) {
        [provider setDelegate:indexerMonitor];
    }
    return indexerMonitor;
}

#pragma mark - Public methods

- (void)startMonitoring {
    if (!self.operationQueue) {
        self.operationQueue = [self.queueFactory createIndexerOperationQueue];
    }
    
    for (id<ChangeProvider> changeProvider in self.changeProviders) {
        changeProvider.delegate = self;
        [changeProvider startMonitoring];
    }

    [self performInitialIndexingIfNeeded];
}

- (void)stopMonitoring {
    for (id<ChangeProvider> changeProvider in self.changeProviders) {
        [changeProvider stopMonitoring];
    }
    [self.operationQueue cancelAllOperations];
}

- (void)deleteAllDataFromSpotlight {
    [self.searchableIndex deleteAllSearchableItemsWithCompletionHandler:nil];
}

#pragma mark - <ChangeProviderDelegate>

- (void)changeProvider:(nullable id<ChangeProvider>)changeProvider
  didGetChangeWithType:(ChangeProviderChangeType)changeType
         forObjectType:(nonnull NSString *)objectType
      objectIdentifier:(nonnull NSString *)objectIdentifier {
    IndexTransaction *transaction = [IndexTransaction transactionWithIdentifier:objectIdentifier
                                                                     objectType:objectType
                                                                     changeType:changeType];
    [self.stateStorage insertTransaction:transaction];
}

- (void)didFinishChangingObjectsInChangeProvider:(nullable id<ChangeProvider>)changeProvider {
    [self processIndexing];
}

#pragma mark - Private methods

- (void)performInitialIndexingIfNeeded {
    BOOL needed = [self.stateStorage shouldPerformInitialIndexing];
    if (needed) {
        NSMutableArray *allTransactions = [NSMutableArray new];
        for (id<ChangeProvider> changeProvider in self.changeProviders) {
            __block NSMutableArray *providerTransactions = [NSMutableArray new];
            [changeProvider processObjectsForInitialIndexingWithBlock:^(NSString *objectType, NSString *objectIdentifier) {
                IndexTransaction *transaction = [IndexTransaction transactionWithIdentifier:objectIdentifier
                                                                                 objectType:objectType
                                                                                 changeType:ChangeProviderChangeTypeInsert];
                [providerTransactions addObject:transaction];
            }];
            [allTransactions addObject:providerTransactions];
        }
        [self.stateStorage insertTransactionsArray:[allTransactions copy]
                                        changeType:ChangeProviderChangeTypeInsert];
        [self processIndexing];
    }
}

- (void)processIndexing {
    IndexTransactionBatch *batch = [self.stateStorage obtainTransactionBatch];
    if (!batch || [batch isEmpty]) {
        return;
    }
    id<ObjectIndexer> indexer = [self obtainIndexerForObjectType:batch.objectType];
    
    __weak typeof(self)weakSelf = self;
    NSOperation *indexOperation = [indexer operationForIndexBatch:batch
                                              withCompletionBlock:^(NSError *error) {
                                                  __strong typeof(self)strongSelf = weakSelf;
                                                  [strongSelf.stateStorage removeProcessedBatch:batch];
                                                  [strongSelf processIndexing];
                                              }];
    [self.operationQueue addOperation:indexOperation];
}

- (id<ObjectIndexer>)obtainIndexerForObjectType:(nonnull NSString *)objectType {
    id<ObjectIndexer> result = nil;
    for (id<ObjectIndexer> indexer in self.indexers) {
        if ([indexer canIndexObjectWithType:objectType]) {
            result = indexer;
            break;
        }
    }
    return result;
}

@end
