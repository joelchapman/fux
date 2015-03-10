//
//  JCProfileViewController.m
//  SoundShare
//
//  Created by Michael Rotondo on 2/21/12.
//  Copyright (c) 2012 Rototyping. All rights reserved.
//

#import "JCProfileViewController.h"
#import "SoundShareClient.h"
#import "JCRecordRenderer.h"
#import "AFHTTPRequestOperation.h"
#import <CoreLocation/CoreLocation.h>

#import "mo-audio.h"
#import "FileRead.h"
#import "Stk.h"
#import <iostream>

#define SRATE 44100
#define FRAMESIZE 512
#define NUMCHANNELS 2

stk::FileRead * fileReader = NULL;
stk::StkFrames * readBuffer;

@interface JCProfileViewController ()
{
    SoundShareClient * soundShareClient;
    CLLocationManager * locationManager;
}

- (void)refresh;

@end

@implementation JCProfileViewController
@synthesize soundTableView;
@synthesize nameTextField, descriptionTextField;
@synthesize sounds;


-(IBAction) uploadSound:(id)sender
{
    [nameTextField resignFirstResponder];
    [descriptionTextField resignFirstResponder];
    
    // UPLOAD A FILE
    NSMutableDictionary * parameters = [NSMutableDictionary dictionary];
    
    [parameters setObject:nameTextField.text forKey:@"name"];
    [parameters setObject:descriptionTextField.text forKey:@"description"];
    
    CLLocation * location = [locationManager location];
    CLLocationCoordinate2D coordinate = location.coordinate;
    CLLocationDegrees latitude = coordinate.latitude;
    CLLocationDegrees longitude = coordinate.longitude;
    
    [parameters setObject:[NSNumber numberWithFloat:latitude] forKey:@"lat"];
    [parameters setObject:[NSNumber numberWithFloat:longitude] forKey:@"long"];
    [parameters setObject:[[[UIDevice currentDevice] identifierForVendor] UUIDString] forKey:@"udid"];
    
    __weak JCProfileViewController * weakSelf = self;
    
    // log
    NSLog( @"attempting to upload..." );
    
    
    [soundShareClient POST:@"soundshare/sound"
                parameters:parameters
 constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {
     NSURL * fileURL = [[NSBundle mainBundle] URLForResource:@"audioprofile" withExtension:@"m4a"];
     NSData * fileData = [NSData dataWithContentsOfURL:fileURL];
  //  NSString * newString = [[NSString alloc] initWithData:fileData encoding:NSUTF8StringEncoding];
   //  std::cout << newString << std::endl;
     
     [formData appendPartWithFileData:fileData name:@"soundfile" fileName:@"audioprofile.m4a" mimeType:@"audio/m4a"];
 }
                   success:^(AFHTTPRequestOperation * operation, id responseObject) {
                       [weakSelf refresh];
                   }
                   failure:^(AFHTTPRequestOperation * operation, NSError * error) {
                       NSLog(@"FAILURE TO UPLOAD: %@", error);
                   }
     ];
    
}

-(void) didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

-(void) viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    locationManager = [[CLLocationManager alloc] init];
    [locationManager startUpdatingLocation];
    
    stk::Stk::setSampleRate(SRATE);
    //! Toggle display of WARNING and STATUS messages.
    stk::Stk::showWarnings( true );
    //! Toggle display of error messages before throwing exceptions.
    stk::Stk::printErrors( true );
    
    soundShareClient = [SoundShareClient sharedClient];
    
    self.soundTableView.delegate = self;
    self.soundTableView.dataSource = self;
    [self refresh];
}

-(void) viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [nameTextField becomeFirstResponder];
    [descriptionTextField becomeFirstResponder];
    
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

-(void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

-(BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

#pragma mark - Sound getting

-(void) refresh
{
    __weak JCProfileViewController * weakSelf = self;
    
    [[SoundShareClient sharedClient] GET:@"soundshare/sounds" parameters:nil success:^(__unused AFHTTPRequestOperation *operation, id JSON) {
        NSLog(@"GOT JSON: %@", JSON);
        
        NSMutableArray *mutableRecords = [NSMutableArray array];
        for (NSDictionary *sound in JSON) {
            [mutableRecords addObject:sound];
        }
        weakSelf.sounds = mutableRecords;
        [weakSelf.soundTableView reloadData];
    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"FAILURE, %@", error);
    }];
}

@end
