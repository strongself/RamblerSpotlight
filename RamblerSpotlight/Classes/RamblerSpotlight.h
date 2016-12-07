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

#import <Foundation/Foundation.h>
#import <CoreSpotlight/CoreSpotlight.h>

#import "ObjectTransformer.h"
#import "ChangeProviderFetchRequestFactory.h"
#import "ObjectIndexerBase.h"
#import "ObjectTransformerConstants.h"
#import "SpotlightIndexerConstants.h"
#import "SpotlightEntityObject.h"

@class CSSearchableIndex;
@class NSManagedObjectContext;

/**
 Main component
 */
@interface RamblerSpotlight : NSObject

/**
 This method setups all of the components
 
 @param entityObjects Array which contains SpotlightEntityObjects
 @param appContext      A storage which contains NSManagedObjectContexts
 @param searchableIndex CSSearchableIndex's object
 */
- (void)setupSpotlightWithSpotlightEntityObjects:(NSArray *)entityObjects
                                        appContext:(NSManagedObjectContext *)appContext
                                   searchableIndex:(CSSearchableIndex *)searchableIndex;

/**
 This method deletes RamblerSpotlight's database
 */
- (void)deleteSpotlightDatabase;

/**
 Initiates monitoring start
 */
- (void)startMonitoring;

/**
 Initiates monitoring end
 */
- (void)stopMonitoring;

@end
