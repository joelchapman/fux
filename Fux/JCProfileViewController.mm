//
//  JCProfileViewController.mm
//  Fux
//
//  Created by Joel Chapman on 3/5/15.
//  Copyright (c) 2015 Joel Chapman. All rights reserved.
//  Using code from "Soundshare" by Michael Rotondo.
//

#import "JCProfileViewController.h"
#import "mo-glut.h"
#import "SoundShareClient.h"
#import "AFHTTPRequestOperation.h"
#import "Stk.h"
#import "FileRead.h"

#import <iostream>
#import <CoreLocation/CoreLocation.h>

#define SRATE 44100
#define FRAMESIZE 1024
#define NUM_CHANNELS 2

stk::FileRead *fileReader = NULL;
stk::StkFrames *readBuffer;
static int sampleIndex = 0;

@interface JCProfileViewController () {
    SoundShareClient *soundShareClient;
    CLLocationManager *locationManager;
}

- (void)refresh;
- (void)playSoundAtURL:(NSURL *)url;

@end

@implementation JCProfileViewController
@synthesize soundTableView;
@synthesize nameTextField, descriptionTextField;
@synthesize sounds;

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// NETWORK FUNCTIONS FROM AFNETOWRK
- (void)playSoundAtURL:(NSURL *)url
{
    NSData *data = [NSData dataWithContentsOfURL:url];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"stuff.wav"];
    NSLog(@"Tried to write to path: %@", path);
    [data writeToFile:path atomically:NO];
    
    readBuffer = new stk::StkFrames(FRAMESIZE, 2);
    fileReader = new stk::FileRead();
    fileReader->open([path UTF8String]);
    sampleIndex = 0;
}


- (IBAction)uploadSound:(id)sender
{
    [nameTextField resignFirstResponder];
    [descriptionTextField resignFirstResponder];
    
    // UPLOAD A FILE
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:nameTextField.text forKey:@"name"];
    [parameters setObject:descriptionTextField.text forKey:@"description"];
    
    
    CLLocation *location = [locationManager location];
    CLLocationCoordinate2D coordinate = location.coordinate;
    CLLocationDegrees latitude = coordinate.latitude;
    CLLocationDegrees longitude = coordinate.longitude;
    [parameters setObject:[NSNumber numberWithFloat:latitude] forKey:@"lat"];
    [parameters setObject:[NSNumber numberWithFloat:longitude] forKey:@"long"];
    [parameters setObject:[[[UIDevice currentDevice] identifierForVendor] UUIDString] forKey:@"udid"];
    
    __weak JCProfileViewController *weakSelf = self;
    
    // log
    NSLog( @"attempting to upload..." );
    [soundShareClient POST:@"soundshare/sound"
                parameters:parameters
 constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {
     NSURL *fileURL = [[NSBundle mainBundle] URLForResource:@"turn" withExtension:@"wav"];
     NSData *fileData = [NSData dataWithContentsOfURL:fileURL];
     [formData appendPartWithFileData:fileData name:@"soundfile" fileName:@"turn.wav" mimeType:@"audio/wav"];
 }
                   success:^(AFHTTPRequestOperation *operation, id responseObject) {
                       [weakSelf refresh];
                   }
                   failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                       NSLog(@"FAILURE TO UPLOAD: %@", error);
                   }
     ];
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    locationManager = [[CLLocationManager alloc] init];
    [locationManager startUpdatingLocation];
    
    soundShareClient = [SoundShareClient sharedClient];

    [self refresh];
}


- (void )refresh
{
    __weak JCProfileViewController *weakSelf = self;
    [[SoundShareClient sharedClient] GET:@"soundshare/sounds" parameters:nil success:^(__unused AFHTTPRequestOperation *operation, id JSON) {
        NSLog(@"GOT JSON: %@", JSON);
        
        NSMutableArray *mutableRecords = [NSMutableArray array];
        for (NSDictionary *sound in JSON) {
            [mutableRecords addObject:sound];
        }
        weakSelf.sounds = mutableRecords;
    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"FAILURE, %@", error);
    }];
}

#pragma mark - UITableViewDataSource

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int i = [indexPath indexAtPosition:1];  // The first index is the section, which will always be 0
    
    NSDictionary *soundJSON = [self.sounds objectAtIndex:i];
    NSDictionary *soundFields = [soundJSON objectForKey:@"fields"];
    NSString *soundPath = [soundFields objectForKey:@"path"];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@soundshare/sounds/%@", kSoundShareBaseURLString, soundPath]];
    NSLog(@"URL: %@", url);
    [self playSoundAtURL:url];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.sounds count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *soundCellIdentifier = @"Sound";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:soundCellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:soundCellIdentifier];
    }
    
    int i = [indexPath indexAtPosition:1];  // The first index is the section, which will always be 0
    
    NSDictionary *soundJSON = [self.sounds objectAtIndex:i];
    NSDictionary *soundFields = [soundJSON objectForKey:@"fields"];
    cell.textLabel.text = [soundFields objectForKey:@"name"];
    cell.detailTextLabel.text = [soundFields objectForKey:@"description"];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}


@end
