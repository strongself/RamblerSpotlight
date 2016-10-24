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
#import "SpotlightCoreDataHandlerImplementation.h"
#import "XCTestCase+RCFHelpers.h"
#import <MagicalRecord/MagicalRecord.h>
#import "IndexState.h"
#import "DataBase+CoreDataModel.h"

@interface SpotlightCoreDataHandlerTests : XCTestCase

@property (nonatomic, strong) SpotlightCoreDataHandlerImplementation *handler;

@end

@implementation SpotlightCoreDataHandlerTests

#pragma mark - Lifecircle

- (void)setUp {
    [super setUp];
    [MagicalRecord setupCoreDataStackWithInMemoryStore];
    
    self.handler = [SpotlightCoreDataHandlerImplementation new];
}

- (void)tearDown {
    self.handler = nil;
    
    [MagicalRecord cleanUp];
    [super tearDown];
}

#pragma mark - Tests

- (void)testThatHandlerFindFirstWithCreateCorrect {
    //given
    NSString *entityName = NSStringFromClass([User class]);
    NSString *attribute = @"name";
    NSString *value = @"type";
    
    //when
    User *user = [self.handler findFirstOrCreateWithEntityName:entityName
                                      byAttribute:attribute
                                        withValue:value
                                        inContext:[NSManagedObjectContext MR_defaultContext]];
    
    //then
    XCTAssertNotNil(user);
    XCTAssertEqual(value, user.name);
}

- (void)testThatHandlerFindFirstWithoutCreateCorrect {
    //given
    NSString *entityName = NSStringFromClass([User class]);
    NSString *attribute = @"name";
    NSString *value = @"type";
    __block User *expectedUser = nil;
    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        expectedUser = [User MR_createEntity];
        expectedUser.name = value;
    }];
    
    //when
    User *resultUser = [self.handler findFirstOrCreateWithEntityName:entityName
                                      byAttribute:attribute
                                        withValue:value
                                        inContext:[NSManagedObjectContext MR_defaultContext]];
    
    //then
    XCTAssertNotNil(resultUser);
    XCTAssertEqual(expectedUser, resultUser);
    XCTAssertEqual(expectedUser.name, resultUser.name);
}

- (void)testThatHandlerFindFirstCorrect {
    //given
    NSString *entityName = NSStringFromClass([User class]);
    NSString *value = @"type";
    __block User *expectedUser = nil;
    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        expectedUser = [User MR_createEntity];
        expectedUser.name = value;
    }];
    
    //when
    User *resultUser = [self.handler findFirstWithEntityName:entityName
                                                   inContext:[NSManagedObjectContext MR_defaultContext]];

    //then
    XCTAssertNotNil(resultUser);
    XCTAssertEqual(expectedUser, resultUser);
    XCTAssertEqual(expectedUser.name, resultUser.name);
}

- (void)testThatHandlerFindFirstWithPredicateCorrect {
    //given
    NSString *entityName = NSStringFromClass([User class]);
    NSString *attribute = @"name";
    NSString *value = @"type";
    __block User *expectedUser = nil;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", attribute, value];
    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        expectedUser = [User MR_createEntity];
        expectedUser.name = value;
    }];
    
    //when
    User *resultUser = [self.handler findFirstWithPredicate:predicate
                                                 entityName:entityName
                                                   sortedBy:attribute
                                                  ascending:YES
                                                  inContext:[NSManagedObjectContext MR_defaultContext]];
    
    //then
    XCTAssertNotNil(resultUser);
    XCTAssertEqual(expectedUser, resultUser);
    XCTAssertEqual(expectedUser.name, resultUser.name);
}

@end
