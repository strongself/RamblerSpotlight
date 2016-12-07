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

@class IndexTransactionBatch;
@protocol ChangeProviderFetchRequestFactory;
@protocol ObjectTransformer;

typedef void(^IndexerErrorBlock)(NSError *error);

/**
 Responsible for indexing data of specific class
 */
@protocol ObjectIndexer <NSObject>


/**
 Create operation by IndexBatch

 @param batch IndexBatch
 @param block Completion block

 @return NSOperation
 */
- (NSOperation *)operationForIndexBatch:(IndexTransactionBatch *)batch
                    withCompletionBlock:(IndexerErrorBlock)block;

/**
 Check that object can be indexed by this class
 
 @param objectType Object's type
 
 @return BOOL
 */
- (BOOL)canIndexObjectWithType:(NSString *)objectType;

/**
 Returns a unique identifier for an indexing object. This identifier may look like MyCustomClass_12_1233
 
 @param object Object for indexing
 
 @return Unique object identifier
 */
- (NSString *)identifierForObject:(id)object;

@end
