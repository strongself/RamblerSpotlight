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

#import "SpotlightCoreDataStackCoordinatorImplementation.h"

#import "ContextFiller.h"
#import "ContextProvider.h"

#import <CoreData/CoreData.h>

static NSString *const RSDataModelName = @"SpotlightIndexer";
static NSString *const RSDataModelType = @"momd";
static NSString *const RSDataBaseType = @"sqlite";
static NSString *const RSBundleName = @"RamblerSpotlightDataBase";
static NSString *const RSBundleType = @"bundle";

@interface SpotlightCoreDataStackCoordinatorImplementation ()

@property (nonatomic, strong, readwrite) id<ContextFiller, ContextProvider> contextStorage;
@property (nonatomic, strong, readwrite) NSFileManager *fileManager;

@end

@implementation SpotlightCoreDataStackCoordinatorImplementation

#pragma mark - Initialization

- (instancetype)initWithContextStorage:(nonnull id<ContextFiller, ContextProvider>)contextStorage
                           fileManager:(nonnull NSFileManager *)fileManager {
    self = [super init];
    if (self) {
        _contextStorage = contextStorage;
        _fileManager = fileManager;
    }
    return self;
}

+ (instancetype)coordinatorWithContextStorage:(nonnull id<ContextFiller, ContextProvider>)contextStorage
                                  fileManager:(nonnull NSFileManager *)fileManager {
    return [[self alloc] initWithContextStorage:contextStorage
                                    fileManager:fileManager];
}

#pragma mark - <SpotlightCoreDataStackCoordinator>

- (void)setupCoreDataStack {
    
    NSURL *bundleURL = [[NSBundle bundleForClass:[self class]] URLForResource:RSBundleName
                                                                withExtension:RSBundleType];
    NSBundle *bundle = [NSBundle bundleWithURL:bundleURL];
    NSURL *modelURL = [bundle URLForResource:RSDataModelName
                                              withExtension:RSDataModelType];
    NSManagedObjectModel *managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];

    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];
    NSManagedObjectContext *defaultContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [defaultContext setPersistentStoreCoordinator:coordinator];
    [self.contextStorage setupSpotlightPrimaryContext:defaultContext];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *documentsURL = [[fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSString *databaseFilename = [NSString stringWithFormat:@"%@.%@", RSDataModelName, RSDataBaseType];
    NSURL *storeURL = [documentsURL URLByAppendingPathComponent:databaseFilename];
    
        NSPersistentStoreCoordinator *persistentStoreCoordinator = [defaultContext persistentStoreCoordinator];
        [persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                 configuration:nil
                                                           URL:storeURL
                                                       options:0
                                                         error:nil];
}

- (void)updateAppCoreDataContext:(nonnull NSManagedObjectContext *)context {
    [self.contextStorage setupAppContext:context];
}

- (void)clearDatabaseFilesSpotlight {
    NSManagedObjectContext *context = [self.contextStorage obtainSpotlightPrimaryContext];
    [self.contextStorage setupSpotlightPrimaryContext:nil];
    [self.contextStorage setupAppContext:nil];
    
    NSPersistentStoreCoordinator *storeCoordinator = context.persistentStoreCoordinator;
    
    NSArray<NSPersistentStore *> *stores = storeCoordinator.persistentStores;
    
    for(NSPersistentStore *store in stores) {
        [storeCoordinator removePersistentStore:store error:nil];
        [self.fileManager removeItemAtPath:store.URL.path error:nil];
    }
}

@end
