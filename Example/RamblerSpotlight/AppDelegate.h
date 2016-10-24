//
//  RSAppDelegate.h
//  RamblerSpotlight
//
//  Created by k.zinovyev on 10/12/2016.
//  Copyright (c) 2016 k.zinovyev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

