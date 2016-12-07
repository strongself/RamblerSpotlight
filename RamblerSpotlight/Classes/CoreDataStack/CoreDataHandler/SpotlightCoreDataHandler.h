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

@class NSManagedObjectContext;
@class NSString;

/**
 Protocol provide methods for searching and creating objects in CoreData
 */
@protocol SpotlightCoreDataHandler <NSObject>

/**
 Find first object for concrete entity in context
 
 @param entityName Name entity
 @param inContext    App context

 @return Founded object
 */
- (id)findFirstWithEntityName:(NSString *)entityName
                    inContext:(NSManagedObjectContext *)context;

/**
 Find first object for concrete entity in context
 
 @param entityName Name entity
 @param attribute Name attribute
 @param withValue Value attribute
 @param inContext    App context
 
 @return Founded object
 */
- (id)findFirstOrCreateWithEntityName:(NSString *)entityName
                          byAttribute:(NSString *)attribute
                            withValue:(id)searchValue
                            inContext:(NSManagedObjectContext *)context;

/**
 Find first object by predicate for concrete entity in context
 
 @param predicate predicate for request
 @param entityName Name entity
 @param sortedBy Name attribute for sorted
 @param ascending ascending
 @param inContext    App context
 
 @return Founded object
 */
- (id)findFirstWithPredicate:(NSPredicate *)searchTerm
                  entityName:(NSString *)entityName
                    sortedBy:(NSString *)property
                   ascending:(BOOL)ascending
                   inContext:(NSManagedObjectContext *)context;

@end
