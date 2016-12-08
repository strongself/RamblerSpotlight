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

#import "ObjectIndexerBase.h"
#import "RamblerSpotlight.h"

#import "ObjectTransformer.h"
#import "ChangeProviderFetchRequestFactory.h"
#import "IndexTransactionBatch.h"

#import <CoreSpotlight/CoreSpotlight.h>

@implementation ObjectIndexerBase

#pragma mark - <ObjectIndexer>

- (NSOperation *)operationForIndexBatch:(nonnull IndexTransactionBatch *)batch
                    withCompletionBlock:(nonnull IndexerErrorBlock)block {
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        NSMutableArray *items = [NSMutableArray array];
        
        NSMutableOrderedSet *indexSet = [NSMutableOrderedSet new];
        [indexSet addObjectsFromArray:[batch.insertIdentifiers array]];
        [indexSet addObjectsFromArray:[batch.updateIdentifiers array]];
        
        NSArray *deleteIdentifiers = [batch.deleteIdentifiers array];
        [indexSet removeObjectsInArray:deleteIdentifiers];
        
        for (NSString *identifier in indexSet) {
            id object = [self.objectTransformer objectForIdentifier:identifier];
            if (object) {
                CSSearchableItem *item = [self searchableItemForObject:object];
                if (item) {
                    [items addObject:item];
                }
            }
        }
        
        __weak typeof(self)weakSelf = self;
        [self.searchableIndex indexSearchableItems:items
                                 completionHandler:^(NSError * _Nullable error) {
                                     __strong typeof(self)strongSelf = weakSelf;
                                     if (error) {
                                         block(error);
                                         return;
                                     }
                                     [strongSelf.searchableIndex deleteSearchableItemsWithIdentifiers:deleteIdentifiers
                                                                              completionHandler:^(NSError * _Nullable error) {
                                                                                  block(error);
                                                                              }];
                                 }];
    }];
    return operation;
}

- (NSString *)identifierForObject:(nonnull id)object {
    return [self.objectTransformer identifierForObject:object];
}

#pragma mark - Abstract methods

- (BOOL)canIndexObjectWithType:(nonnull NSString *)objectType {
    [NSException raise:NSInternalInconsistencyException
                format:@"You should override this method in a custom subclass"];
    return NO;
}

- (CSSearchableItem *)searchableItemForObject:(nonnull id)object {
    [NSException raise:NSInternalInconsistencyException
                format:@"You should override this method in a custom subclass"];
    return nil;
}

@end
