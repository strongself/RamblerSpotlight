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
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <Foundation/Foundation.h>

@class NSManagedObjectContext;

/**
 @author Egor Tolstoy
 
 Describes an object responsible for storing CoreData contexts during app lifecycle
 */
@protocol ContextFiller <NSObject>

/**
 @author Egor Tolstoy
 
 This method retains a given context and stores it during the app lifecycle
 
 @param context NSManagedObjectContext
 */
- (void)setupSpotlightPrimaryContext:(NSManagedObjectContext *)context;

/**
 @author Konstantin Zinovyev
 
 This method retains a given context that used in app and stores it during the app lifecycle
 
 @param context NSManagedObjectContext
 */
- (void)setupAppContext:(NSManagedObjectContext *)context;

@end
