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

#import "SpotlightCoreDataHandlerImplementation.h"
#import <CoreData/CoreData.h>

static NSUInteger const RSLFetchBatchSize = 20u;
static NSUInteger const RSLFetchBatchLimit = 1u;

@implementation SpotlightCoreDataHandlerImplementation

#pragma mark - SpotlightCoreDataHandler

- (id)findFirstWithEntityName:(nonnull NSString *)entityName
                    inContext:(nonnull NSManagedObjectContext *)context {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:entityName];
    __block NSArray *results = nil;
    [context performBlockAndWait:^{
        NSError *error = nil;
        results = [context executeFetchRequest:request
                                         error:&error];
    }];
    if ([results count] == 0u) {
        return nil;
    }
    return [results firstObject];
}

- (id)findFirstWithPredicate:(nullable NSPredicate *)predicate
                  entityName:(nonnull NSString *)entityName
                    sortedBy:(nullable NSString *)property
                   ascending:(BOOL)ascending
                   inContext:(nonnull NSManagedObjectContext *)context {
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:entityName];
    [request setFetchBatchSize:RSLFetchBatchSize];
    [request setFetchLimit:RSLFetchBatchLimit];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:property
                                                                   ascending:ascending];
    [request setSortDescriptors:@[sortDescriptor]];
    if (predicate != nil) {
        [request setPredicate:predicate];
    }
    
    NSError *error = nil;
    NSArray *results = [context executeFetchRequest:request
                                              error:&error];
    
    if ([results count] == 0u) {
        return nil;
    }
    return [results firstObject];
}


- (id)findFirstOrCreateWithEntityName:(nonnull NSString *)entityName
                          byAttribute:(nonnull NSString *)attribute
                            withValue:(nonnull id)searchValue
                            inContext:(nonnull NSManagedObjectContext *)context {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:entityName];
    [request setFetchLimit:RSLFetchBatchLimit];
    [request setPredicate:[NSPredicate predicateWithFormat:@"%K = %@", attribute, searchValue]];
    
    NSError *error = nil;
    NSArray *results = [context executeFetchRequest:request
                                              error:&error];
    if ([results count] != 0) {
        return [results firstObject];
    }
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName
                                              inManagedObjectContext:context];
    Class class = NSClassFromString(entityName);
    id result = [[class alloc] initWithEntity:entity
               insertIntoManagedObjectContext:context];
    [result setValue:searchValue forKey:attribute];
    
    return result;
}

@end
