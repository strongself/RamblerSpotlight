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
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY RSIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "RamblerSpotlight_Testable.h"
#import "IndexerMonitor.h"
#import "SpotlightCoreDataStackCoordinator.h"

@interface RamblerSpotlightTests : XCTestCase

@property (nonatomic, strong) RamblerSpotlight *ramblerSpotlight;

@end

@implementation RamblerSpotlightTests

#pragma mark - Lifecircle

- (void)setUp {
    [super setUp];
    
    self.ramblerSpotlight = [[RamblerSpotlight alloc] init];
}

- (void)tearDown {
    self.ramblerSpotlight = nil;
    
    [super tearDown];
}

#pragma mark - Tests

- (void)testThatSpotlightStartMonitoringCorrect {
    //given
    id mockIndexerMonitor = OCMClassMock([IndexerMonitor class]);
    self.ramblerSpotlight.indexerMonitor = mockIndexerMonitor;
    
    //when
    [self.ramblerSpotlight startMonitoring];
    
    //then
    OCMVerify([mockIndexerMonitor startMonitoring]);
}

- (void)testThatSpotlightStopMonitoringCorrect {
    //given
    id mockIndexerMonitor = OCMClassMock([IndexerMonitor class]);
    self.ramblerSpotlight.indexerMonitor = mockIndexerMonitor;
    
    //when
    [self.ramblerSpotlight stopMonitoring];
    
    //then
    OCMVerify([mockIndexerMonitor stopMonitoring]);
}

- (void)testThatSpotlightDeleteDatabaseCorrect {
    //given
    id mockIndexerMonitor = OCMClassMock([IndexerMonitor class]);
    self.ramblerSpotlight.indexerMonitor = mockIndexerMonitor;
    
    id mockCoordinator = OCMProtocolMock(@protocol(SpotlightCoreDataStackCoordinator));
    self.ramblerSpotlight.spotlightCoreDataStackCoordinator = mockCoordinator;
    
    //when
    [self.ramblerSpotlight deleteSpotlightDatabase];
    
    //then
    OCMVerify([mockIndexerMonitor stopMonitoring]);
    OCMVerify([mockIndexerMonitor deleteAllDataFromSpotlight]);
    OCMVerify([mockCoordinator clearDatabaseFilesSpotlight]);
    XCTAssertNil(self.ramblerSpotlight.indexerMonitor);
}

- (void)testThatSpotlightSetupCorrect {
    //given
    
    //when
    [self.ramblerSpotlight setupSpotlightWithSpotlightEntitiesObjects:nil
                                                           appContext:nil
                                                      searchableIndex:nil];
    
    //then
    XCTAssertTrue([self.ramblerSpotlight.indexerMonitor isMemberOfClass:[IndexerMonitor class]]);
    XCTAssertTrue([self.ramblerSpotlight.spotlightCoreDataStackCoordinator conformsToProtocol:@protocol(SpotlightCoreDataStackCoordinator)]);
}

@end
