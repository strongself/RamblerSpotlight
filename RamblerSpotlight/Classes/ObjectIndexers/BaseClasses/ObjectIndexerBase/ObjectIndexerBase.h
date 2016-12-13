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

#import "ObjectIndexer.h"

@class CSSearchableIndex;
@class CSSearchableItem;
@protocol ObjectTransformer;

/**
 @autor Egor Tolstoy
 
 Base indexer class with some abstract methods that needs to be overriden
 */
@interface ObjectIndexerBase : NSObject <ObjectIndexer>

@property (nonatomic, strong, nonnull) id<ObjectTransformer> objectTransformer;
@property (nonatomic, strong, nonnull) CSSearchableIndex *searchableIndex;

/**
 This method should return a CSSearchableItem for a certain object.
 
 @param object An object for indexing
 
 @return CSSearchableItem
 */
- (nullable CSSearchableItem *)searchableItemForObject:(nonnull id)object;

/**
 Check that object can be indexed by this class
 
 @param objectType Object's type
 
 @return BOOL
 */
- (BOOL)canIndexObjectWithType:(nonnull NSString *)objectType;

@end
