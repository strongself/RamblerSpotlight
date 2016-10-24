//
//  RSAppDelegate.m
//  RamblerSpotlight
//
//  Created by k.zinovyev on 10/12/2016.
//  Copyright (c) 2016 k.zinovyev. All rights reserved.
//

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
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:bundle];
    
    UINavigationController *navigationController = (UINavigationController *)[storyboard instantiateInitialViewController];
    self.window.rootViewController = navigationController;
    [self.window makeKeyAndVisible];
    
    MasterViewController *controller = (MasterViewController *)navigationController.topViewController;
    controller.managedObjectContext = self.persistentContainer.viewContext;
    
    
    self.ramblerSpotlight = [[RamblerSpotlight alloc] init];
    UserChangeProviderFetchRequestFactory *factory = [UserChangeProviderFetchRequestFactory new];
    UserObjectIndexer *indexer = [UserObjectIndexer new];
    UserObjectTransformer *transformer = [UserObjectTransformer new];
    self.transformer = transformer;
    transformer.context = controller.managedObjectContext;
    SpotlightEntityObject *entity = [SpotlightEntityObject entityObjectWithObjectTransformer:transformer
                                                                              requestFactory:factory
                                                                               objectIndexer:indexer];
    [self.ramblerSpotlight setupSpotlightWithSpotlightEntitiesObjects:@[entity]
                                                           appContext:controller.managedObjectContext
                                                      searchableIndex:[CSSearchableIndex defaultSearchableIndex]];
    [self.ramblerSpotlight startMonitoring];
    
    
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
        
        
    } else
        if ([navigationController.topViewController isKindOfClass:[DetailViewController class]]) {
            DetailViewController *viewController = (DetailViewController *)navigationController.topViewController;
            viewController.detailItem = user;
    }
    
    return YES;
}

#pragma mark - Core Data stack

@synthesize persistentContainer = _persistentContainer;

- (NSPersistentContainer *)persistentContainer {
    // The persistent container for the application. This implementation creates and returns a container, having loaded the store for the application to it.
    @synchronized (self) {
        if (_persistentContainer == nil) {
            _persistentContainer = [[NSPersistentContainer alloc] initWithName:@"DataBase"];
            [_persistentContainer loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *storeDescription, NSError *error) {
                if (error != nil) {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    
                    /*
                     Typical reasons for an error here include:
                     * The parent directory does not exist, cannot be created, or disallows writing.
                     * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                     * The device is out of space.
                     * The store could not be migrated to the current model version.
                     Check the error message to determine what the actual problem was.
                     */
                    NSLog(@"Unresolved error %@, %@", error, error.userInfo);
                    abort();
                }
            }];
        }
    }
    
    return _persistentContainer;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *context = self.persistentContainer.viewContext;
    NSError *error = nil;
    if ([context hasChanges] && ![context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
        abort();
    }
}

@end
