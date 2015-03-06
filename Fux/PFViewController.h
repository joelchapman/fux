//
//  PFViewController.h
//  GLoiler
//
//  Created by Ge Wang on 1/15/15.
//  Copyright (c) 2015 Ge Wang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PFViewController : UIViewController

@property (strong, nonatomic) IBOutlet UITableView *soundTableView;
@property (strong, nonatomic) IBOutlet UITextField *nameTextField;
@property (strong, nonatomic) IBOutlet UITextField *descriptionTextField;
@property (strong, nonatomic) NSArray *sounds;

@end

