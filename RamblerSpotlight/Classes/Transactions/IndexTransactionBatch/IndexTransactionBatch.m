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

#import "IndexTransactionBatch.h"

@interface IndexTransactionBatch ()

@property (nonatomic, copy, readwrite, nullable) NSOrderedSet *insertIdentifiers;
@property (nonatomic, copy, readwrite, nullable) NSOrderedSet *updateIdentifiers;
@property (nonatomic, copy, readwrite, nullable) NSOrderedSet *deleteIdentifiers;
@property (nonatomic, copy, readwrite, nullable) NSOrderedSet *moveIdentifiers;
@property (nonatomic, copy, readwrite, nonnull) NSString *objectType;

@end

@implementation IndexTransactionBatch

#pragma mark - Initialization

- (instancetype)initWithObjectType:(nonnull NSString *)objectType
                 insertIdentifiers:(nullable NSOrderedSet *)insertIdentifiers
                 updateIdentifiers:(nullable NSOrderedSet *)updateIdentifiers
                 deleteIdentifiers:(nullable NSOrderedSet *)deleteIdentifiers
                   moveIdentifiers:(nullable NSOrderedSet *)moveIdentifiers {
    self = [super init];
    if (self) {
        _objectType = objectType;
        _insertIdentifiers = insertIdentifiers;
        _updateIdentifiers = updateIdentifiers;
        _deleteIdentifiers = deleteIdentifiers;
        _moveIdentifiers = moveIdentifiers;
    }
    return self;
}

+ (instancetype)batchWithObjectType:(nonnull NSString *)objectType
                  insertIdentifiers:(nullable NSOrderedSet *)insertIdentifiers
                  updateIdentifiers:(nullable NSOrderedSet *)updateIdentifiers
                  deleteIdentifiers:(nullable NSOrderedSet *)deleteIdentifiers
                    moveIdentifiers:(nullable NSOrderedSet *)moveIdentifiers {
    return [[self alloc] initWithObjectType:objectType
                          insertIdentifiers:insertIdentifiers
                          updateIdentifiers:updateIdentifiers
                          deleteIdentifiers:deleteIdentifiers
                            moveIdentifiers:moveIdentifiers];
}

#pragma mark - Public methods

- (BOOL)isEmpty {
    return self.insertIdentifiers.count == 0u &&
        self.updateIdentifiers.count == 0u &&
        self.deleteIdentifiers.count == 0u &&
        self.moveIdentifiers.count == 0u;
}

@end
