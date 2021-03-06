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

#import <Foundation/Foundation.h>

@protocol ContextFiller;
@protocol ContextProvider;
@protocol SpotlightCoreDataStackCoordinator;
@protocol ChangeProviderDelegate;
@class CSSearchableIndex;
@class NSManagedObjectContext;
@class SpotlightEntityObject;

/**
 Factory provides methods for creating all RamblerSpotlight's components
 */
@interface SpotlightAssembly : NSObject

/**
 Create IndexerMonitor object
 
 @param objects         Array which contains SpotlightEntityObjects
 @param contextStorage  A storage which contains NSManagedObjectContexts
 @param searchableIndex CSSearchableIndex's object

 @return IndexerMonitor
 */
- (nonnull id<ChangeProviderDelegate>)indexerMonitorWithEntityObjects:(nonnull NSArray<SpotlightEntityObject *> *)objects
                                                       contextStorage:(nonnull id<ContextProvider, ContextFiller>)contextStorage
                                                      searchableIndex:(nonnull CSSearchableIndex *)searchableIndex;

/**
 Create SpotlightCoreDataStackCoordinator object
 
 @param contextFiller A storage which contains NSManagedObjectContexts

 @return SpotlightCoreDataStackCoordinator
 */
- (nonnull id<SpotlightCoreDataStackCoordinator>)spotlightCoreDataStackCoordinatorWithContextStorage:(nonnull id<ContextProvider, ContextFiller>)contextStorage;

/**
 Create ContextStorage object
 
 @param appContext Context that used in application

 @return contextStorage
 */
- (nonnull id<ContextProvider, ContextFiller>)contextStorageWithAppContext:(nonnull NSManagedObjectContext *)appContext;

@end
