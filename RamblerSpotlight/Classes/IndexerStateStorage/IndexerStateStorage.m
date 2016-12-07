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

#import "IndexerStateStorage.h"

#import "IndexTransaction.h"
#import "IndexTransactionBatch.h"
#import "IndexState.h"
#import "ContextProvider.h"
#import "SpotlightCoreDataHandler.h"

static NSUInteger const RSTransactionBatchSize = 1000u;
static NSUInteger const RSPositionInsertInBatch = 0u;
static NSUInteger const RSPositionUpdateInBatch = 1u;
static NSUInteger const RSPositionDeleteInBatch = 2u;
static NSUInteger const RSPositionMoveInBatch = 3u;

@interface IndexerStateStorage ()

@property (nonatomic, strong) id<ContextProvider> contextProvider;
@property (nonatomic, strong) id<SpotlightCoreDataHandler> coreDataHandler;

@end

@implementation IndexerStateStorage

#pragma mark - Initialization

- (instancetype)initWithContextProvider:(id<ContextProvider>)contextProvider
                        coreDataHandler:(id<SpotlightCoreDataHandler>)coreDataHandler {
    self = [super init];
    if (self) {
        _contextProvider = contextProvider;
        _coreDataHandler = coreDataHandler;
    }
    return self;
}

+ (instancetype)stateStorageWithContextProvider:(id<ContextProvider>)contextProvider
                                coreDataHandler:(id<SpotlightCoreDataHandler>)coreDataHandler;{
    return [[self alloc] initWithContextProvider:contextProvider
                                 coreDataHandler:coreDataHandler];
}

#pragma mark - Public methods

- (void)insertTransaction:(IndexTransaction *)transaction {
    NSManagedObjectContext *context = [self.contextProvider obtainSpotlightPrimaryContext];
    [context performBlockAndWait:^{
        IndexState *state = [self.coreDataHandler findFirstOrCreateWithEntityName:NSStringFromClass([IndexState class])
                                                                      byAttribute:NSStringFromSelector(@selector(objectType))
                                                                        withValue:transaction.objectType
                                                                        inContext:context];
        [state insertIdentifier:transaction.identifier
                        forType:transaction.changeType];
        state.lastChangeDate = [NSDate date];
        [context save:nil];
    }];
}

- (void)insertTransactionsArray:(NSArray<NSArray *> *)transactionsArray
                     changeType:(ChangeProviderChangeType)changeType {
    NSManagedObjectContext *context = [self.contextProvider obtainSpotlightPrimaryContext];
    [context performBlockAndWait:^{
        for (NSArray *transactions in transactionsArray) {
            if (transactions.count) {
                NSString *objectType = [[transactions firstObject] objectType];
                IndexState *state = [self.coreDataHandler findFirstOrCreateWithEntityName:NSStringFromClass([IndexState class])
                                                                              byAttribute:NSStringFromSelector(@selector(objectType))
                                                                                withValue:objectType
                                                                                inContext:context];
                NSArray *identifiers = [transactions valueForKey:NSStringFromSelector(@selector(identifier))];
                [state insertIdentifiers:identifiers
                                 forType:changeType];
                state.lastChangeDate = [NSDate date];
            }
        }
        [context save:nil];
    }];
}

- (IndexTransactionBatch *)obtainTransactionBatch {
    NSManagedObjectContext *context = [self.contextProvider obtainSpotlightPrimaryContext];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K > 0", NSStringFromSelector(@selector(numberOfIdentifiers))];
    
    IndexState *state = [self.coreDataHandler findFirstWithPredicate:predicate
                                                          entityName:NSStringFromClass([IndexState class])
                                                            sortedBy:NSStringFromSelector(@selector(lastChangeDate))
                                                           ascending:YES
                                                           inContext:context];
    
    if (state.insertIdentifiers.count == 0u &&
        state.updateIdentifiers.count == 0u &&
        state.deleteIdentifiers.count == 0u &&
        state.moveIdentifiers.count == 0u) {
        return nil;
    }
    
    NSArray *setArray = @[state.insertIdentifiers ?: [NSOrderedSet new],
                          state.updateIdentifiers ?: [NSOrderedSet new],
                          state.deleteIdentifiers ?: [NSOrderedSet new],
                          state.moveIdentifiers ?: [NSOrderedSet new]];
    
    NSMutableArray *sliceSetsArray = [NSMutableArray new];
    
    for (NSOrderedSet *set in setArray) {
        NSArray *array = [set array];
        NSUInteger length = MIN(array.count, RSTransactionBatchSize);
        NSRange range = NSMakeRange(0, length);
        NSArray *sliceArray = [array subarrayWithRange:range];
        NSOrderedSet *sliceSet = [[NSOrderedSet alloc] initWithArray:sliceArray];
        [sliceSetsArray addObject:sliceSet];
    }
    
    return [IndexTransactionBatch batchWithObjectType:state.objectType
                                    insertIdentifiers:sliceSetsArray[RSPositionInsertInBatch]
                                    updateIdentifiers:sliceSetsArray[RSPositionUpdateInBatch]
                                    deleteIdentifiers:sliceSetsArray[RSPositionDeleteInBatch]
                                      moveIdentifiers:sliceSetsArray[RSPositionMoveInBatch]];
}

- (void)removeProcessedBatch:(IndexTransactionBatch *)batch {
    NSManagedObjectContext *context = [self.contextProvider obtainSpotlightPrimaryContext];
    [context performBlockAndWait:^{
        IndexState *state = [self.coreDataHandler findFirstOrCreateWithEntityName:NSStringFromClass([IndexState class])
                                                                      byAttribute:NSStringFromSelector(@selector(objectType))
                                                              withValue:batch.objectType
                                                              inContext:context];
        
        NSArray *changeTypes = @[@(NSFetchedResultsChangeInsert),
                                 @(NSFetchedResultsChangeUpdate),
                                 @(NSFetchedResultsChangeMove),
                                 @(NSFetchedResultsChangeDelete)];
        
        NSArray *batchChanges = @[batch.insertIdentifiers,
                                  batch.updateIdentifiers,
                                  batch.moveIdentifiers,
                                  batch.deleteIdentifiers];
        
        [changeTypes enumerateObjectsUsingBlock:^(NSNumber *changeTypeNumber, NSUInteger idx, BOOL * _Nonnull stop) {
            NSFetchedResultsChangeType changeType = [changeTypeNumber unsignedIntegerValue];
            NSOrderedSet *identifiers = batchChanges[idx];
            NSArray *identifierArray = [identifiers array];
            [state removeIdentifiers:identifierArray
                             forType:changeType];
        }];
        
        state.lastChangeDate = [NSDate date];
    }];
}

- (BOOL)shouldPerformInitialIndexing {
    NSManagedObjectContext *context = [self.contextProvider obtainSpotlightPrimaryContext];
    IndexState *state = [self.coreDataHandler findFirstWithEntityName:NSStringFromClass([IndexState class])
                                                            inContext:context];
    return state == nil;
}

@end
