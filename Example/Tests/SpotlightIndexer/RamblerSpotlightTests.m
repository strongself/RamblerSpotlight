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
#import "RamblerSpotlight_Testable.h"
#import "IndexerMonitor.h"
#import "SpotlightCoreDataStackCoordinator.h"

@interface RamblerSpotlightTests : XCTestCase

@property (nonatomic, strong) RamblerSpotlight *ramblerSpotlight;
@property (nonatomic, strong) id mockIndexerMonitor;
    
@end

@implementation RamblerSpotlightTests

#pragma mark - Lifecircle

- (void)setUp {
    [super setUp];
    
    id mockIndexerMonitor = OCMClassMock([IndexerMonitor class]);
    
    self.ramblerSpotlight = [[RamblerSpotlight alloc] init];
    self.ramblerSpotlight.indexerMonitor = mockIndexerMonitor;
    
}

- (void)tearDown {
    self.ramblerSpotlight = nil;
    
    self.mockIndexerMonitor = nil;
    [self.mockIndexerMonitor stopMocking];
    
    [super tearDown];
}

#pragma mark - Tests

- (void)testThatSpotlightStartsMonitoringCorrectly {
    //given
    
    //when
    [self.ramblerSpotlight startMonitoring];
    
    //then
    OCMVerify([self.mockIndexerMonitor startMonitoring]);
}

- (void)testThatSpotlightStopsMonitoringCorrectly {
    //given

    //when
    [self.ramblerSpotlight stopMonitoring];
    
    //then
    OCMVerify([self.mockIndexerMonitor stopMonitoring]);
}

- (void)testThatSpotlightDeleteDatabaseCorrectly {
    //given

    id mockCoordinator = OCMProtocolMock(@protocol(SpotlightCoreDataStackCoordinator));
    self.ramblerSpotlight.spotlightCoreDataStackCoordinator = mockCoordinator;
    
    //when
    [self.ramblerSpotlight deleteSpotlightDatabase];
    
    //then
    OCMVerify([self.mockIndexerMonitor stopMonitoring]);
    OCMVerify([self.mockIndexerMonitor deleteAllDataFromSpotlight]);
    OCMVerify([mockCoordinator clearDatabaseFilesSpotlight]);
    XCTAssertNil(self.ramblerSpotlight.indexerMonitor);
}

- (void)testThatSpotlightSetupsCorrectly {
    //given
    
    //when
    [self.ramblerSpotlight setupSpotlightWithSpotlightEntityObjects:nil
                                                         appContext:nil
                                                    searchableIndex:nil];
    
    //then
    XCTAssertTrue([self.ramblerSpotlight.indexerMonitor isMemberOfClass:[IndexerMonitor class]]);
    XCTAssertTrue([self.ramblerSpotlight.spotlightCoreDataStackCoordinator conformsToProtocol:@protocol(SpotlightCoreDataStackCoordinator)]);
}

@end
