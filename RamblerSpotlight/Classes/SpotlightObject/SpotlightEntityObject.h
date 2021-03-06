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

@protocol ObjectTransformer;
@protocol ChangeProviderFetchRequestFactory;
@protocol ObjectIndexer;

/**
 Object contains all dependencies that need to index concrete app's entity
 */
@interface SpotlightEntityObject : NSObject

/**
 Object responsible for transforming indexing object to identifier and backwards
 */
@property (nonatomic, strong, readonly, nonnull) id<ObjectTransformer> objectTransformer;
/**
 Factory providing fetch requests for ChangeProvider
 */
@property (nonatomic, strong, readonly, nonnull) id<ChangeProviderFetchRequestFactory> requestFactory;
/**
 Responsible for indexing data of specific class
 */
@property (nonatomic, strong, readonly, nonnull) id<ObjectIndexer> objectIndexer;

+ (nullable instancetype)entityObjectWithObjectTransformer:(nonnull id<ObjectTransformer>)objectTransformer
                                            requestFactory:(nonnull id<ChangeProviderFetchRequestFactory>)requestFactory
                                             objectIndexer:(nonnull id<ObjectIndexer>)objectIndexer;
@end
