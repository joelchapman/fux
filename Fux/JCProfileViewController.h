//
//  JCProfileViewController.h
//  Fux
//
//  Created by Joel Chapman on 3/5/15.
//  Copyright (c) 2015 Joel Chapman. All rights reserved.
//  Using code from "Soundshare" by Michael Rotondo.
//

#import <UIKit/UIKit.h>

@interface JCProfileViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UITableView *soundTableView;
@property (strong, nonatomic) IBOutlet UITextField *nameTextField;
@property (strong, nonatomic) IBOutlet UITextField *descriptionTextField;
@property (strong, nonatomic) NSArray *sounds;

@end

