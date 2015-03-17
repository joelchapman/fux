//
//  JCProfileViewController.m
//  SoundShare
//
//  Created by Michael Rotondo on 2/21/12.
//  Copyright (c) 2012 Rototyping. All rights reserved.
//

#import "JCProfileViewController.h"
#import "JCAudioFile.h"
#import "SoundShareClient.h"
//#import "JCRecordRenderer.h"
#import "AFHTTPRequestOperation.h"
#import <CoreLocation/CoreLocation.h>
#import "JCCoordinates.h"

#import "mo-audio.h"
#import "FileRead.h"
#import "Stk.h"
#import <iostream>
#import <stdio.h>

#define SRATE 44100
#define FRAMESIZE 1024
#define NUMCHANNELS 2
#define DELAYTIME 10

stk::FileRead * fileReader = NULL;
stk::StkFrames * readBuffer;
static int sampleIndex = 0;

Float32 tempBuff[SRATE*DELAYTIME];

JCAudioFile otherUserRecording;
//JCName names;


//void audioCallback(Float32 * buff, UInt32 frameSize, void * userData);
void audioCallback(Float32 * buff, UInt32 frameSize, void * userData)
{
    bool didRead = false;
    memset( buff, 0, sizeof(SAMPLE)*FRAMESIZE*2 );
    if (fileReader && sampleIndex < fileReader->fileSize())
    {
        fileReader->read(*readBuffer, sampleIndex);
        sampleIndex += FRAMESIZE/2; // why on earth did i have to do this. audio is all messed up 3/16 21:26
        didRead = true;
    }
    for (int i = 0; i < frameSize; i++)
    {
        if (readBuffer && didRead)
        {
            buff[i * NUMCHANNELS] = buff[i * NUMCHANNELS + 1] = (*readBuffer)[i * NUMCHANNELS];
            tempBuff[i * NUMCHANNELS] = tempBuff[i * NUMCHANNELS + 1] = buff[i * NUMCHANNELS];
            
        }
        else
        {
            buff[i * NUMCHANNELS] = buff[i * NUMCHANNELS + 1] = 0;
        }
     //   std::cout << tempBuff[i] << std::endl;
    }

    otherUserRecording.setOtherUserRecording(tempBuff, 1);
}


@interface JCProfileViewController ()
{
    SoundShareClient * soundShareClient;
    CLLocationManager * locationManager;
}

- (void)refresh;
- (void)playSoundAtURL:(NSURL *)url;

@end

@implementation JCProfileViewController
@synthesize soundTableView;
@synthesize nameTextField, descriptionTextField;
@synthesize sounds;


-(void) playSoundAtURL:(NSURL *)url
{
    NSData * data = [NSData dataWithContentsOfURL:url];
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * path = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"audioprofile.wav"];
    NSLog(@"Tried to write to path: %@", path);
    [data writeToFile:path atomically:NO];
    
    readBuffer = new stk::StkFrames(FRAMESIZE, NUMCHANNELS);
    fileReader = new stk::FileRead([path UTF8String], false, NUMCHANNELS, 32, SRATE);
    fileReader->open([path UTF8String], false, NUMCHANNELS, 32, SRATE);
    sampleIndex = 0;
}

-(IBAction) stopAudio:(id)sender
{
    MoAudio::stop();
    NSLog(@"audioCallback has stopped");
}



-(IBAction) uploadSound:(id)sender
{
    [nameTextField resignFirstResponder];
    [descriptionTextField resignFirstResponder];

    NSArray * profileArray = [NSArray array];
    // UPLOAD A FILE
    NSMutableDictionary * parameters = [NSMutableDictionary dictionary];
    
    [parameters setObject:nameTextField.text forKey:@"name"];
   // JCName::setFirstName(nameTextField.text);
    
    [parameters setObject:descriptionTextField.text forKey:@"description"];
   // JCName::setLastName(descriptionTextField.text);
    
    float likes = 0;
    
    CLLocation * location = [locationManager location];
    CLLocationCoordinate2D coordinate = location.coordinate;
    CLLocationDegrees latitude = coordinate.latitude;
    CLLocationDegrees longitude = coordinate.longitude;
    
  //  [parameters setObject:[NSNumber numberWithInt:1] forKey:@"likes"];
    [parameters setObject:[NSNumber numberWithFloat:latitude] forKey:@"lat"];
    [parameters setObject:[NSNumber numberWithFloat:likes] forKey:@"long"];
    [parameters setObject:[[[UIDevice currentDevice] identifierForVendor] UUIDString] forKey:@"udid"];
    
    __weak JCProfileViewController * weakSelf = self;
    
    // log
    NSLog( @"attempting to upload..." );
    
    
    [soundShareClient POST:@"soundshare/sound"
                parameters:parameters
 constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {
     NSURL * fileURL = [[NSBundle mainBundle] URLForResource:@"audioprofile" withExtension:@"wav"];
     
     // generate a unique filename for recording upload
     NSData * fileData = [NSData dataWithContentsOfURL:fileURL];
     NSString * userName = nameTextField.text;
     NSString * uniqueAudioProfileTemp = [@"audioprofile_" stringByAppendingString: userName];
     NSString * uniqueAudioProfile = [uniqueAudioProfileTemp stringByAppendingString:@".wav"];
     
     [formData appendPartWithFileData:fileData name:@"soundfile" fileName:uniqueAudioProfile mimeType:@"audio/wav"];
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
    
    // start
    bool result = MoAudio::start( audioCallback, NULL );
    if( !result )
    {
        NSLog(@"Cannot start real-time audio!");
    }
    
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
    
    [[SoundShareClient sharedClient] GET:@"soundshare/sounds" parameters:nil success:^(__unused AFHTTPRequestOperation * operation, id JSON) {
        NSLog(@"GOT JSON: %@", JSON);
        
        NSMutableArray * mutableRecords = [NSMutableArray array];
        for (NSDictionary * sound in JSON) {
            [mutableRecords addObject:sound];
        }
        weakSelf.sounds = mutableRecords;
        [weakSelf.soundTableView reloadData];
    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"FAILURE, %@", error);
    }];
}

#pragma mark - UITableViewDataSource

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//-(IBAction) playOtherProfile:(id)sender
{
    int i = [indexPath indexAtPosition:1];  // The first index is the section, which will always be 0
  //  int i = 5;
    NSDictionary * soundJSON = [self.sounds objectAtIndex:i];
    NSDictionary * soundFields = [soundJSON objectForKey:@"fields"];
    NSString * soundPath = [soundFields objectForKey:@"path"];
    NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"%@soundshare/sounds/%@", kSoundShareBaseURLString, soundPath]];
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
