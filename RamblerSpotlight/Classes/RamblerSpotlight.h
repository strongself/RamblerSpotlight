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
 @author Konstantin Zinovyev
 
 Main component
 */
@interface RamblerSpotlight : NSObject

/**
 @author Konstantin Zinovyev

 This method setup all of the component
 
 @param entitiesObjects Array which contains SpotlightEntitiesObjects
 @param appContext      A storage which contains NSManagedObjectContexts
 @param searchableIndex CSSearchableIndex's object
 */
- (void)setupSpotlightWithSpotlightEntitiesObjects:(NSArray *)entitiesObjects
                                        appContext:(NSManagedObjectContext *)appContext
                                   searchableIndex:(CSSearchableIndex *)searchableIndex;

/**
 @author Konstantin Zinovyev
 
 This method delete all of the component
 */
- (void)deleteSpotlightDatabase;

/**
 @author Konstantin Zinovyev
 
 Initiates monitoring start
 */
- (void)startMonitoring;

/**
 @author Konstantin Zinovyev
 
 Initiates monitoring end
 */
- (void)stopMonitoring;

@end
