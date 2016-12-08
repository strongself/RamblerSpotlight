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

#import <XCTest/XCTest.h>
#import <MagicalRecord/MagicalRecord.h>
#import <OCMock/OCMock.h>

#import "XCTestCase+RCFHelpers.h"

#import "IndexerStateStorage.h"
#import "IndexTransaction.h"
#import "IndexTransactionBatch.h"
#import "ChangeProviderChangeType.h"
#import "IndexState.h"
#import "ContextProvider.h"
#import "SpotlightCoreDataHandler.h"
#import "SpotlightCoreDataStackCoordinatorImplementation.h"
#import "SpotlightAssembly_Testable.h"

@interface IndexerStateStorageTests : XCTestCase

@property (nonatomic, strong) IndexerStateStorage *stateStorage;
@property (nonatomic, strong) id mockContextProvider;
@property (nonatomic, strong) id mockDataHandler;

@property (nonatomic, strong) SpotlightCoreDataStackCoordinatorImplementation *coordinator;
@property (nonatomic, strong) id context;

@end

@implementation IndexerStateStorageTests

#pragma mark - Lifecircle

- (void)setUp {
    [super setUp];
    self.coordinator = [self setupCoreDataStackForTests];
    self.context =  [self.coordinator.contextStorage obtainSpotlightPrimaryContext];
    
    self.mockContextProvider = OCMProtocolMock(@protocol(ContextProvider));
    self.mockDataHandler = OCMProtocolMock(@protocol(SpotlightCoreDataHandler));
    OCMStub([self.mockContextProvider obtainSpotlightPrimaryContext]).andReturn(self.context);

    self.stateStorage = [IndexerStateStorage stateStorageWithContextProvider:self.mockContextProvider
                                                             coreDataHandler:self.mockDataHandler];
}

- (void)tearDown {
    [self tearDownCoreDataStackWithCoordinator:self.coordinator];
    
    self.stateStorage = nil;
    
    self.mockContextProvider = nil;
    self.mockDataHandler = nil;
    
    self.coordinator = nil;
    self.context = nil;
    [super tearDown];
}

#pragma mark - Tests

- (void)testThatStateStorageInsertsSingleTransaction {
    // given
    NSString *const RSTestIdentifier = @"1234";
    NSString *const RSTestObjectType = @"user";
    IndexTransaction *transaction = [IndexTransaction transactionWithIdentifier:RSTestIdentifier
                                                                     objectType:RSTestObjectType
                                                                     changeType:ChangeProviderChangeTypeInsert];
    
    __block IndexState *expectedState = nil;
    [self.context MR_saveWithBlockAndWait:^(NSManagedObjectContext * _Nonnull localContext) {
            expectedState = [IndexState MR_createEntityInContext:self.context];
            expectedState.objectType = RSTestObjectType;
    }];
    
    OCMStub([self.mockDataHandler findFirstOrCreateWithEntityName:OCMOCK_ANY
                                                      byAttribute:OCMOCK_ANY
                                                        withValue:OCMOCK_ANY
                                                        inContext:OCMOCK_ANY]).andReturn(expectedState);
    
    // when
    [self.stateStorage insertTransaction:transaction];
    
    // then
    IndexState *resulState = [IndexState MR_findFirstInContext:self.context];
    XCTAssertEqualObjects(resulState.objectType, RSTestObjectType);
    XCTAssertEqualObjects([resulState.insertIdentifiers firstObject], RSTestIdentifier);
    XCTAssertNotNil(resulState.lastChangeDate);
}

- (void)testThatStateStorageInsertsMultipleTransactions {
    // given
    NSUInteger const RSTestIdentifiersCount = 5;
    NSUInteger const RSTestTransactionArraysCount = 10;
    NSArray *testArray = [self generateTransactionArraysWithCount:RSTestTransactionArraysCount
                                                       innerCount:RSTestIdentifiersCount];
    NSArray *states = [IndexState MR_findAllInContext:self.context];

    // when
    [self.stateStorage insertTransactionsArray:testArray
                                    changeType:ChangeProviderChangeTypeInsert];
    
    // then
    states = [IndexState MR_findAllInContext:self.context];
    XCTAssertEqual(states.count, RSTestTransactionArraysCount);
    
    for (IndexState *state in states) {
        XCTAssertEqual(state.insertIdentifiers.count, RSTestIdentifiersCount);
        XCTAssertNotNil(state.lastChangeDate);
    }
}

- (void)testThatIndexerStorageReturnsTransactionBatch {
    // given
    NSUInteger const RSTestTransactionsCount = 10;
    NSString *const RSTestObjectType = @"user";
    NSArray *testArray = [self generateTransactionsWithCount:RSTestTransactionsCount
                                                  objectType:RSTestObjectType];
    for (IndexTransaction *transaction in testArray) {
        [self.stateStorage insertTransaction:transaction];
    }
    __block IndexState *expectedState = nil;
    [self.context MR_saveWithBlockAndWait:^(NSManagedObjectContext * _Nonnull localContext) {
        expectedState = [IndexState MR_createEntityInContext:self.context];
        expectedState.objectType = RSTestObjectType;
        expectedState.insertIdentifiers = [NSMutableOrderedSet orderedSetWithArray:testArray];
    }];
    
    OCMStub([self.mockDataHandler findFirstWithPredicate:OCMOCK_ANY
                                              entityName:OCMOCK_ANY
                                                sortedBy:OCMOCK_ANY
                                               ascending:OCMOCK_ANY
                                               inContext:OCMOCK_ANY]).andReturn(expectedState);
    // when
    IndexTransactionBatch *result = [self.stateStorage obtainTransactionBatch];
    
    // then
    XCTAssertEqual(result.insertIdentifiers.count, RSTestTransactionsCount);
    XCTAssertEqualObjects(result.objectType, RSTestObjectType);
}

- (void)testThatStateStorageRemovesProcessedBatch {
    // given
    NSUInteger const RSTestTransactionsCount = 10;
    NSString *const RSTestObjectType = @"user";
    NSArray *testArray = [self generateTransactionsWithCount:RSTestTransactionsCount
                                                  objectType:RSTestObjectType];
    for (IndexTransaction *transaction in testArray) {
        [self.stateStorage insertTransaction:transaction];
    }
    
    __block IndexState *expectedState = nil;
    [self.context MR_saveWithBlockAndWait:^(NSManagedObjectContext * _Nonnull localContext) {
        expectedState = [IndexState MR_createEntityInContext:self.context];
        expectedState.objectType = RSTestObjectType;
        expectedState.insertIdentifiers = [NSMutableOrderedSet orderedSetWithArray:testArray];
    }];
    OCMStub([self.mockDataHandler findFirstWithPredicate:OCMOCK_ANY
                                              entityName:OCMOCK_ANY
                                                sortedBy:OCMOCK_ANY
                                               ascending:OCMOCK_ANY
                                               inContext:OCMOCK_ANY]).andReturn(expectedState);
    
    IndexTransactionBatch *batch = [self.stateStorage obtainTransactionBatch];
    
    OCMStub([self.mockDataHandler findFirstOrCreateWithEntityName:OCMOCK_ANY
                                                      byAttribute:OCMOCK_ANY
                                                        withValue:OCMOCK_ANY
                                                        inContext:OCMOCK_ANY]).andReturn(expectedState);
    
    // when
    [self.stateStorage removeProcessedBatch:batch];
    
    // then
    IndexState *state = [IndexState MR_findFirstInContext:self.context];
    IndexTransactionBatch *result = [self.stateStorage obtainTransactionBatch];
    XCTAssertNil(result);
    XCTAssertEqual([state.numberOfIdentifiers integerValue], 0);
}

- (void)testThatStateStorageDetectsWhenWeShouldPerformInitialIndexing {
    // given

    OCMStub([self.mockDataHandler findFirstWithEntityName:OCMOCK_ANY
                                                inContext:OCMOCK_ANY]).andReturn(nil);
    // when
    BOOL result = [self.stateStorage shouldPerformInitialIndexing];
    
    // then
    XCTAssertTrue(result);
}

- (void)testThatStateStorageDetectsWhenWeShouldNotPerformInitialIndexing {
    // given
    __block IndexState *expectedState = nil;
    [self.context MR_saveWithBlockAndWait:^(NSManagedObjectContext * _Nonnull localContext) {
        expectedState = [IndexState MR_createEntityInContext:self.context];
    }];
    OCMStub([self.mockDataHandler findFirstWithEntityName:OCMOCK_ANY
                                                inContext:OCMOCK_ANY]).andReturn(expectedState);
    
    // when
    BOOL result = [self.stateStorage shouldPerformInitialIndexing];
    
    // then
    XCTAssertFalse(result);
}

#pragma mark - Additional methods

- (NSArray <NSArray *>*)generateTransactionArraysWithCount:(NSUInteger)count
                                                innerCount:(NSUInteger)innerCount {
    NSMutableArray *result = [NSMutableArray new];
    
    for (NSUInteger i = 0; i < count; i++) {
        NSString *objectType = [[NSUUID UUID] UUIDString];
        NSArray *array = [self generateTransactionsWithCount:innerCount
                                                  objectType:objectType];
        [self.context MR_saveWithBlockAndWait:^(NSManagedObjectContext * _Nonnull localContext) {
            IndexState *state = [IndexState MR_createEntityInContext:self.context];
            OCMStub([self.mockDataHandler findFirstOrCreateWithEntityName:OCMOCK_ANY
                                                              byAttribute:OCMOCK_ANY
                                                                withValue:objectType
                                                                inContext:OCMOCK_ANY]).andReturn(state);
        }];
        [result addObject:array];
    }
    
    return [result copy];
}

- (NSArray *)generateTransactionsWithCount:(NSUInteger)count
                                objectType:(NSString *)objectType {
    NSMutableArray *mutableTransactions = [NSMutableArray new];
    for (NSUInteger i = 0; i < count; i++) {
        IndexTransaction *transaction = [IndexTransaction transactionWithIdentifier:[[NSUUID UUID] UUIDString]
                                                                         objectType:objectType
                                                                         changeType:ChangeProviderChangeTypeInsert];
        [mutableTransactions addObject:transaction];
    }
    return [mutableTransactions copy];
}

- (IndexTransactionBatch *)generateTransactionBatchForTestPurposesWithObjectType:(NSString *)objectType
                                                               insertIdentifiers:(NSOrderedSet *)insertIdentifiers {
    IndexTransactionBatch *batch = [IndexTransactionBatch batchWithObjectType:objectType
                                                            insertIdentifiers:insertIdentifiers
                                                            updateIdentifiers:nil
                                                            deleteIdentifiers:nil
                                                              moveIdentifiers:nil];
    
    return batch;
}

@end
