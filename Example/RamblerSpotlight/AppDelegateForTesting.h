//
//  AppDelegateForTesting.h
//  RamblerSpotlight
//
//  Created by k.zinovyev on 14.10.16.
//  Copyright © 2016 Rambler&Co. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 @author Egor Tolstoy
 
 Фейковый AppDelegate, подставляемый в случае прогона тестов
 */
@interface AppDelegateForTesting : NSObject

@property (nonatomic, strong) UIWindow *window;

@end
