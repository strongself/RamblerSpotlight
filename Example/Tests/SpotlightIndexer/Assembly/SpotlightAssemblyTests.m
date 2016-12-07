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
#import <OCMock/OCMock.h>
#import <CoreData/CoreData.h>
#import <CoreSpotlight/CoreSpotlight.h>
#import "SpotlightAssembly.h"
#import "ContextStorageImplementation.h"
#import "SpotlightCoreDataStackCoordinatorImplementation.h"
#import "SpotlightAssembly_Testable.h"
#import "ChangeProvider.h"
#import "ObjectIndexer.h"
#import "IndexerMonitorOperationQueueFactory.h"
#import "IndexerStateStorage.h"
#import "SpotlightEntityObject.h"
#import "ObjectIndexerBase.h"

@interface SpotlightAssemblyTests : XCTestCase

@property (nonatomic, strong) SpotlightAssembly *assembly;

@end

@implementation SpotlightAssemblyTests

#pragma mark - Lifecircle

- (void)setUp {
    [super setUp];
    
    self.assembly = [SpotlightAssembly  new];
}

- (void)tearDown {
    self.assembly = nil;
    
    [super tearDown];
}

#pragma mark - Tests

- (void)testThatAssemblyCreatesContextStorageCorrectly {
    //given
    id context = @"";
    
    //when
    ContextStorageImplementation *result = [self.assembly contextStorageWithAppContext:context];
    
    //then
    XCTAssertTrue([result isMemberOfClass:[ContextStorageImplementation class]]);
    XCTAssertEqual(result.appContext, context);
}

- (void)testThatAssemblyCreatesCoreDataStackCorrectle {
    //given
    id contextStorage = @"";
    
    //when
    SpotlightCoreDataStackCoordinatorImplementation *result = [self.assembly spotlightCoreDataStackCoordinatorWithContextStorage:contextStorage];
    
    //then
    XCTAssertTrue([result isMemberOfClass:[SpotlightCoreDataStackCoordinatorImplementation class]]);
    XCTAssertEqual(result.contextStorage, contextStorage);
}

- (void)testThatAssemblyCreatesIndexerMonitorCorrectly {
    //given
    NSUInteger countEntities = 5u;
    NSArray *entities = [self createSpotlightEntitiesObjectWothCount:countEntities];
    id mockContextStorage = OCMClassMock([ContextStorageImplementation class]);
    id mockSearchableIndex = OCMClassMock([CSSearchableIndex class]);
    
    //when
    IndexerMonitor *result = [self.assembly indexerMonitorWithEntitiesObjects:entities
                                                               contextStorage:mockContextStorage
                                                              searchableIndex:mockSearchableIndex];
    
    //then
    XCTAssertTrue([result isMemberOfClass:[IndexerMonitor class]]);
    XCTAssertEqual(result.searchableIndex, mockSearchableIndex);
    XCTAssertEqual([result.indexers count], countEntities);
    XCTAssertEqual([result.changeProviders count], countEntities);
    XCTAssertTrue([result.indexers[0] conformsToProtocol:@protocol(ObjectIndexer)]);
    XCTAssertTrue([result.changeProviders[0] conformsToProtocol:@protocol(ChangeProvider)]);
    XCTAssertTrue([result.queueFactory isMemberOfClass:[IndexerMonitorOperationQueueFactory class]]);
    XCTAssertTrue([result.stateStorage isMemberOfClass:[IndexerStateStorage class]]);
}

#pragma mark - Additional methods

- (NSArray *)createSpotlightEntitiesObjectWothCount:(NSUInteger)count {
    NSMutableArray *entities = [NSMutableArray new];
    for (NSUInteger i = 0; i < count; ++i) {
        SpotlightEntityObject *entity = [SpotlightEntityObject entityObjectWithObjectTransformer:nil
                                                                                  requestFactory:nil
                                                                                   objectIndexer:[ObjectIndexerBase new]];
        [entities addObject:entity];
    }
    return [entities copy];
}

@end
