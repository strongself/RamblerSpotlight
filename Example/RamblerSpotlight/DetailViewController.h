//
//  DetailViewController.h
//  RamblerSpotlight
//
//  Created by k.zinovyev on 12.10.16.
//  Copyright © 2016 Rambler&Co. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataBase+CoreDataModel.h"

@interface DetailViewController : UIViewController

@property (strong, nonatomic) User *detailItem;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@end

