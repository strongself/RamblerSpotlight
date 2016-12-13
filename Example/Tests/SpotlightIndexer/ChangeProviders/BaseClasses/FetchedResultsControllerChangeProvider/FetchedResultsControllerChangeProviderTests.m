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

#import "XCTestCase+RCFHelpers.h"
#import <MagicalRecord/MagicalRecord.h>
#import "DataBase+CoreDataModel.h"
#import "FetchedResultsControllerChangeProvider.h"
#import "ChangeProviderFetchRequestFactory.h"
#import "ObjectTransformer.h"
#import "ChangeProviderDelegate.h"
#import "ContextProvider.h"

@interface FetchedResultsControllerChangeProviderTests : XCTestCase

@property (nonatomic, strong) FetchedResultsControllerChangeProvider *provider;
@property (nonatomic, strong) id mockRequestFactory;
@property (nonatomic, strong) id mockObjectTransformer;
@property (nonatomic, strong) id mockDelegate;
@property (nonatomic, strong) id mockContextProvider;
@end

@implementation FetchedResultsControllerChangeProviderTests

#pragma mark - Lifecircle

- (void)setUp {
    [super setUp];
    
    [MagicalRecord setupCoreDataStackWithInMemoryStore];
    
    self.mockRequestFactory = OCMProtocolMock(@protocol(ChangeProviderFetchRequestFactory));
    self.mockObjectTransformer = OCMProtocolMock(@protocol(ObjectTransformer));
    self.mockDelegate = OCMProtocolMock(@protocol(ChangeProviderDelegate));
    self.mockContextProvider = OCMProtocolMock(@protocol(ContextProvider));
    
    self.provider = [FetchedResultsControllerChangeProvider changeProviderWithFetchRequestFactory:self.mockRequestFactory
                                                                                objectTransformer:self.mockObjectTransformer contextProvider:self.mockContextProvider];
    self.provider.delegate = self.mockDelegate;
}

- (void)tearDown {
    self.provider = nil;
    
    self.mockRequestFactory = nil;
    self.mockObjectTransformer = nil;
    self.mockDelegate = nil;
    self.mockContextProvider = nil;
    
    [MagicalRecord cleanUp];
    
    [super tearDown];
}

#pragma mark - Tests

- (void)testThatProviderAsksForFetchRequestOnMonitoringStart {
    // given
    [self stubRequestFactory];
    OCMStub([self.mockContextProvider obtainAppContext]).andReturn([NSManagedObjectContext MR_defaultContext]);
    // when
    [self.provider startMonitoring];
    
    // then
    OCMVerify([self.mockRequestFactory obtainFetchRequestForIndexing]);
}

- (void)testThatProviderProcessesObjectsForInitialIndexing {
    // given
    [self generateUserForTestPurposes];
    [self stubRequestFactory];
    OCMStub([self.mockContextProvider obtainAppContext]).andReturn([NSManagedObjectContext MR_defaultContext]);
    [self.provider startMonitoring];
    
    // when
    __block NSString *result;
    [self.provider processObjectsForInitialIndexingWithBlock:^(NSString *objectType, NSString *objectIdentifier) {
        result = objectType;
    }];
    
    // then
    XCTAssertEqualObjects(result, NSStringFromClass([User class]));
}

#pragma mark - Additional methods

- (void)stubRequestFactory {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([User class])];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:NSStringFromSelector(@selector(name)) ascending:YES]];
    OCMStub([self.mockRequestFactory obtainFetchRequestForIndexing]).andReturn(request);
}

- (User *)generateUserForTestPurposes {
    NSManagedObjectContext *rootSavingContext = [NSManagedObjectContext MR_defaultContext];
    __block User *user = nil;
    [rootSavingContext performBlockAndWait:^{
        user = [User MR_createEntityInContext:rootSavingContext];
        user.name = @"";
        [rootSavingContext MR_saveToPersistentStoreAndWait];
    }];
    return user;
}

@end
