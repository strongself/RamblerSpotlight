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

#import "AppDelegate.h"
#import "DetailViewController.h"
#import "MasterViewController.h"

#import <RamblerSpotlight/RamblerSpotlight.h>
#import "UserChangeProviderFetchRequestFactory.h"
#import "UserObjectIndexer.h"
#import "UserObjectTransformer.h"

@interface AppDelegate () <UISplitViewControllerDelegate>

@property (nonatomic, strong) RamblerSpotlight *ramblerSpotlight;
@property (nonatomic, strong) UserObjectTransformer *transformer;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSManagedObjectContext *context = self.persistentContainer.viewContext;
    UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
    MasterViewController *controller = (MasterViewController *)navigationController.topViewController;
    controller.managedObjectContext = context;
    
    [self setupRamblerSpotlightWithContext:context];
    
    return YES;
}

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray * _Nullable))restorationHandler {
    
    NSDictionary *userInfo = userActivity.userInfo;
    NSString *identifier = userInfo[CSSearchableItemActivityIdentifier];
    User *user = [self.transformer objectForIdentifier:identifier];

    UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
    if ([navigationController.topViewController isKindOfClass:[MasterViewController class]]) {
        
        // alpha
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        DetailViewController *viewController = (DetailViewController *)[storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([DetailViewController class])];
        viewController.detailItem = user;
        [navigationController pushViewController:viewController animated:YES];
        
        return YES;
    }
    
    if ([navigationController.topViewController isKindOfClass:[DetailViewController class]]) {
        DetailViewController *viewController = (DetailViewController *)navigationController.topViewController;
        viewController.detailItem = user;
        return YES;
    }
    
    return NO;
}

#pragma mark - Core Data

@synthesize persistentContainer = _persistentContainer;

- (NSPersistentContainer *)persistentContainer {
    @synchronized (self) {
        if (_persistentContainer == nil) {
            _persistentContainer = [[NSPersistentContainer alloc] initWithName:@"DataBase"];
            [_persistentContainer loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *storeDescription, NSError *error) {
                if (error != nil) {
                    NSLog(@"Unresolved error %@, %@", error, error.userInfo);
                    abort();
                }
            }];
        }
    }
    return _persistentContainer;
}

- (void)saveContext {
    NSManagedObjectContext *context = self.persistentContainer.viewContext;
    NSError *error = nil;
    if ([context hasChanges] && ![context save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
        abort();
    }
}

#pragma mark - Private methods
    
- (void)setupRamblerSpotlightWithContext:(NSManagedObjectContext *)context {
    self.ramblerSpotlight = [[RamblerSpotlight alloc] init];
    UserChangeProviderFetchRequestFactory *factory = [UserChangeProviderFetchRequestFactory new];
    UserObjectIndexer *indexer = [UserObjectIndexer new];
    UserObjectTransformer *transformer = [UserObjectTransformer new];
    
    self.transformer = transformer;
    transformer.context = context;
    
    SpotlightEntityObject *entity = [SpotlightEntityObject entityObjectWithObjectTransformer:transformer
                                                                              requestFactory:factory
                                                                               objectIndexer:indexer];
    [self.ramblerSpotlight setupSpotlightWithSpotlightEntityObjects:@[entity]
                                                         appContext:context
                                                    searchableIndex:[CSSearchableIndex defaultSearchableIndex]];
    [self.ramblerSpotlight startMonitoring];
}
@end
