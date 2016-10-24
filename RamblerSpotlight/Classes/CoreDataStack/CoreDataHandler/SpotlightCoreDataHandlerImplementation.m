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

#import "SpotlightCoreDataHandlerImplementation.h"
#import <CoreData/CoreData.h>

@implementation SpotlightCoreDataHandlerImplementation

#pragma mark - SpotlightCoreDataHandler

- (id)findFirstWithEntityName:(NSString *)entityName
                    inContext:(NSManagedObjectContext *)context {
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:entityName];
    __block NSArray *results = nil;
    [context performBlockAndWait:^{
        NSError *error = nil;
        results = [context executeFetchRequest:request error:&error];
    }];
    if ([results count] == 0) {
        return nil;
    }
    return [results firstObject];
}

- (id)findFirstWithPredicate:(NSPredicate *)searchTerm
                  entityName:(NSString *)entityName
                    sortedBy:(NSString *)property
                   ascending:(BOOL)ascending
                   inContext:(NSManagedObjectContext *)context {
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName
                                              inManagedObjectContext:context];
    [request setEntity:entity];
    if (searchTerm) {
        [request setPredicate:searchTerm];
    }
    [request setFetchBatchSize:20];
    
    NSMutableArray *sortDescriptors = [[NSMutableArray alloc] init];
    NSArray *sortKeys = [property componentsSeparatedByString:@","];
    for (__strong NSString *sortKey in sortKeys) {
        NSArray *sortComponents = [sortKey componentsSeparatedByString:@":"];
        if (sortComponents.count > 1) {
            NSString *customAscending = sortComponents.lastObject;
            ascending = customAscending.boolValue;
            sortKey = sortComponents[0];
        }
        
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortKey ascending:ascending];
        [sortDescriptors addObject:sortDescriptor];
    }
    
    [request setSortDescriptors:sortDescriptors];
    [request setFetchLimit:1];
    
    __block NSArray *results = nil;
    [context performBlockAndWait:^{
        NSError *error = nil;
        results = [context executeFetchRequest:request error:&error];
    }];
    
    if ([results count] == 0) {
        return nil;
    }
    return [results firstObject];
}


- (id)findFirstOrCreateWithEntityName:(NSString *)entityName
                          byAttribute:(NSString *)attribute
                            withValue:(id)searchValue
                            inContext:(NSManagedObjectContext *)context {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName
                                              inManagedObjectContext:context];
    [request setEntity:entity];
    [request setPredicate:[NSPredicate predicateWithFormat:@"%K = %@", attribute, searchValue]];
    [request setFetchLimit:1];
    
    __block NSArray *results = nil;
    [context performBlockAndWait:^{
        NSError *error = nil;
        results = [context executeFetchRequest:request
                                         error:&error];
    }];
    id result = nil;
    if ([results count] != 0) {
        return [results firstObject];
    }
    entity = [NSEntityDescription entityForName:entityName
                         inManagedObjectContext:context];
    Class class = NSClassFromString(entityName);
    result = [[class alloc] initWithEntity:entity insertIntoManagedObjectContext:context];
    [result setValue:searchValue forKey:attribute];
    
    return result;
}

@end
