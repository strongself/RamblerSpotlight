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

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "SearchableIndexMock.h"

#import "IndexerMonitor.h"
#import "ObjectIndexer.h"
#import "ChangeProvider.h"
#import "IndexerStateStorage.h"
#import "IndexerMonitorOperationQueueFactory.h"
#import "ChangeProviderDelegate.h"
#import "IndexTransaction.h"
#import "IndexTransactionBatch.h"

@interface IndexerMonitorTests : XCTestCase

@property (nonatomic, strong) IndexerMonitor *monitor;

@property (nonatomic, strong) id mockIndexer;
@property (nonatomic, strong) id mockChangeProvider;
@property (nonatomic, strong) id mockStateStorage;
@property (nonatomic, strong) id mockQueueFactory;
@property (nonatomic, strong) id mockOperationQueue;
@property (nonatomic, strong) SearchableIndexMock *mockIndex;

@end

@implementation IndexerMonitorTests

- (void)setUp {
    [super setUp];
    
    self.mockIndexer = OCMProtocolMock(@protocol(ObjectIndexer));
    self.mockChangeProvider = OCMProtocolMock(@protocol(ChangeProvider));
    self.mockStateStorage = OCMClassMock([IndexerStateStorage class]);
    
    self.mockQueueFactory = OCMClassMock([IndexerMonitorOperationQueueFactory class]);
    self.mockOperationQueue = OCMClassMock([NSOperationQueue class]);
    self.mockIndex = [SearchableIndexMock new];
    
    OCMStub([self.mockQueueFactory createIndexerOperationQueue]).andReturn(self.mockOperationQueue);
    
    self.monitor = [IndexerMonitor monitorWithIndexers:@[self.mockIndexer]
                                       changeProviders:@[self.mockChangeProvider]
                                          stateStorage:self.mockStateStorage
                                          queueFactory:self.mockQueueFactory
                                       searchableIndex:self.mockIndex];
}

- (void)tearDown {
    self.monitor = nil;
    
    self.mockIndexer = nil;
    self.mockChangeProvider = nil;
    
    [self.mockStateStorage stopMocking];
    self.mockStateStorage = nil;
    
    [self.mockQueueFactory stopMocking];
    self.mockQueueFactory = nil;
    
    [self.mockOperationQueue stopMocking];
    self.mockOperationQueue = nil;
    
    [(id)self.mockIndexer stopMocking];
    self.mockIndexer = nil;
    
    [super tearDown];
}

- (void)testThatMonitorStartsMonitoring {
    // given
    
    
    // when
    [self.monitor startMonitoring];
    
    // then
    OCMVerify([self.mockQueueFactory createIndexerOperationQueue]);
    OCMVerify([self.mockChangeProvider startMonitoring]);
    OCMVerify([self.mockChangeProvider setDelegate:(id)self.monitor]);
}

- (void)testThatMonitorChecksForInitialIndexingNeedOnStart {
    // given
    
    
    // when
    [self.monitor startMonitoring];
    
    // then
    OCMVerify([self.mockStateStorage shouldPerformInitialIndexing]);
}

- (void)testThatMonitorStartsInitialIndexingIfNeeded {
    // given
    OCMStub([self.mockStateStorage shouldPerformInitialIndexing]).andReturn(YES);
    
    // when
    [self.monitor startMonitoring];
    
    // then
    OCMVerify([self.mockChangeProvider processObjectsForInitialIndexingWithBlock:OCMOCK_ANY]);
    OCMVerify([self.mockStateStorage insertTransactionsArray:OCMOCK_ANY
                                                  changeType:ChangeProviderChangeInsert]);
}

- (void)testThatMonitorStopsMonitoring {
    // given
    [self.monitor startMonitoring];
    
    // when
    [self.monitor stopMonitoring];
    
    // then
    OCMVerify([self.mockChangeProvider stopMonitoring]);
    OCMVerify([self.mockOperationQueue cancelAllOperations]);
}

- (void)testThatMonitorHandlesChangeUserFromChangeProvider {
    // given
    NSString *const RSTestObjectType = @"User";
    NSString *const RSTestObjectIdentifier = [[NSUUID UUID] UUIDString];
    
    // when
    [self.monitor changeProvider:self.mockChangeProvider
            didGetChangeWithType:ChangeProviderChangeInsert
                   forObjectType:RSTestObjectType
                objectIdentifier:RSTestObjectIdentifier];
    
    // then
    OCMVerify([self.mockStateStorage insertTransaction:OCMOCK_ANY]);
}

- (void)testThatMonitorHandlesFinishChangingUserFromChangeProvider {
    // given
    NSString *const RSTestObjectType = @"User";
    OCMStub([self.mockIndexer canIndexObjectWithType:RSTestObjectType]).andReturn(YES);
    
    IndexTransactionBatch *batch = [self generateBatchForTestPurposesWithObjectType:RSTestObjectType];
    OCMStub([self.mockStateStorage obtainTransactionBatch]).andReturn(batch);
    
    id mockOperation = [NSObject new];
    OCMStub([self.mockIndexer operationForIndexBatch:OCMOCK_ANY
                                 withCompletionBlock:OCMOCK_ANY]).andReturn(mockOperation);
    
    // when
    [self.monitor startMonitoring];
    [self.monitor didFinishChangingObjectsInChangeProvider:self.mockChangeProvider];
    
    // then
    OCMVerify([self.mockOperationQueue addOperation:mockOperation]);
}

#pragma mark - Helper methods

- (IndexTransactionBatch *)generateBatchForTestPurposesWithObjectType:(NSString *)objectType {
    IndexTransactionBatch *batch = [IndexTransactionBatch batchWithObjectType:objectType
                                                            insertIdentifiers:nil
                                                            updateIdentifiers:[NSOrderedSet orderedSetWithArray:@[@"1"]]
                                                            deleteIdentifiers:nil
                                                              moveIdentifiers:nil];
    return batch;
}

@end
