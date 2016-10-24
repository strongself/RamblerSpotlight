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
#import <CoreData/CoreData.h>
#import "SpotlightCoreDataStackCoordinatorImplementation.h"
#import "ContextStorageImplementation.h"

static NSString *const RSDataModelName = @"SpotlightIndexer";

@interface CoreDataCoordinatorTests : XCTestCase

@property (nonatomic, strong) SpotlightCoreDataStackCoordinatorImplementation *coordinator;
@property (nonatomic, strong) id mockContextStorage;

@end

@implementation CoreDataCoordinatorTests

#pragma mark - Lifecircle

- (void)setUp {
    [super setUp];
    
    self.mockContextStorage = [[ContextStorageImplementation alloc] initWithAppContext:nil];
    self.coordinator = [SpotlightCoreDataStackCoordinatorImplementation coordinatorWithContextStorage:self.mockContextStorage];
}

- (void)tearDown {
    if ([self isExistDataBase]) {
        [self.coordinator clearDatabaseFilesSpotlight];
    }

    self.mockContextStorage = nil;
    self.coordinator = nil;
    
    [super tearDown];
}

#pragma mark - Tests

- (void)testThatCoordinatorSetAppContextCorrect {
    //given
    id context = @"";
    
    //when
    [self.coordinator setAppCoreDataContext:context];
    
    //then
    NSManagedObjectContext *resultContext = [self.mockContextStorage obtainAppContext];
    XCTAssertEqual(resultContext, context);
}

- (void)testThatCoordinatorSetupCoreDataCorrect {
    //given
    
    //when
    [self.coordinator setupCoreDataStack];
    
    //then
    XCTAssertTrue([self isExistDataBase]);
}

- (void)testThatCoordinatorDeleteCoreDataCorrect {
    //given
    [self.coordinator setupCoreDataStack];
    
    //when
    [self.coordinator clearDatabaseFilesSpotlight];
    
    //then
    XCTAssertFalse([self isExistDataBase]);
}

#pragma mark - Additional methods

- (BOOL)isExistDataBase {
    NSURL *modelURL = [self modelURLDataBase];
    return [[NSFileManager defaultManager] fileExistsAtPath:modelURL.path];
}

- (NSURL *)modelURLDataBase {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *documentsURL = [[fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSString *databaseFilename = [NSString stringWithFormat:@"%@.sqlite", RSDataModelName];
    NSURL *storeURL = [documentsURL URLByAppendingPathComponent:databaseFilename];
    return storeURL;
}
@end
