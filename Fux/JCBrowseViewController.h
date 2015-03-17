//
//  JCBrowseViewController.h
//  Fux
//
//  Created by Joel Chapman on 3/14/15.
//  Copyright (c) 2015 Joel Chapman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import <CoreMotion/CoreMotion.h>

@interface JCBrowseViewController: GLKViewController

@property (strong, nonatomic) IBOutlet UILabel *firstName;
@property (strong, nonatomic) IBOutlet UILabel *lastName;

@end
