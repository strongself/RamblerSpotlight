//
//  main.m
//  RamblerSpotlight
//
//  Created by k.zinovyev on 10/12/2016.
//  Copyright (c) 2016 k.zinovyev. All rights reserved.
//

@import UIKit;
#import "AppDelegate.h"

int main(int argc, char * argv[])
{
    @autoreleasepool {
        // Для того, чтобы процедура запуска приложения не мешала нормальному прогону тестов, подставляем фейковый AppDelegate
        // @link http://qualitycoding.org/app-delegate-for-tests/
        Class appDelegateClass;
        if (!NSClassFromString(@"XCTest")) {
            appDelegateClass = [AppDelegate class];
        } else {
            appDelegateClass = NSClassFromString(@"AppDelegateForTesting");
        }
        return UIApplicationMain(argc, argv, nil, NSStringFromClass(appDelegateClass));
    }
}
