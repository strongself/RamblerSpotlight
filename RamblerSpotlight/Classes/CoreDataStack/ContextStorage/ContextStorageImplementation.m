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

#import "ContextStorageImplementation.h"

#import <CoreData/CoreData.h>

@interface ContextStorageImplementation ()

    @property (nonatomic, strong) NSManagedObjectContext *spotlightPrimaryContext;
    @property (nonatomic, strong) NSManagedObjectContext *appContext;

@end

@implementation ContextStorageImplementation

- (instancetype)initWithAppContext:(NSManagedObjectContext *)appContext {
    self = [super init];
    if (self) {
        _appContext = appContext;
    }
    return self;
}

#pragma mark - <ContextFiller>

- (void)setupSpotlightPrimaryContext:(NSManagedObjectContext *)context
                          appContext:(NSManagedObjectContext *)appContext {
    self.spotlightPrimaryContext = context;
    self.appContext = appContext;
}

- (void)setupSpotlightPrimaryContext:(NSManagedObjectContext *)context {
    self.spotlightPrimaryContext = context;
}
    
- (void)setupAppContext:(NSManagedObjectContext *)context {
    self.appContext = context;
}

#pragma mark - <ContextProvider>

- (NSManagedObjectContext *)obtainSpotlightPrimaryContext {
    return self.spotlightPrimaryContext;
}
    
- (NSManagedObjectContext *)obtainAppContext {
    return self.appContext;
}

@end
