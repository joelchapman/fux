//
//  JCRecordViewController.mm
//  Fux
//
//  Created by Joel Chapman on 2/22/15.
//  Copyright (c) 2015 Joel Chapman. All rights reserved.
//  Using boiler-plate code from "Gloiler" (including MOMU) by Ge Wang.
//

#import "JCRecordViewController.h"
#import "JCRecordRenderer.h"
#import "JCAudioFile.h"
#import "mo-glut.h"
#import "mo-audio.h"
#import <iostream>


@interface JCRecordViewController () {

}

@property (strong, nonatomic) EAGLContext *context;
@property (strong, nonatomic) GLKBaseEffect *effect;

- (void)setupGL;
- (void)tearDownGL;

@end

@implementation JCRecordViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
    
    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    
    [self setupGL];
    
    // initialize
    JCRecordInit();
}


- (void)viewDidLayoutSubviews
{
    JCRecordSetDims( self.view.bounds.size.width, self.view.bounds.size.height );
}


- (void)dealloc
{
    [self tearDownGL];
    
    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    if ([self isViewLoaded] && ([[self view] window] == nil)) {
        self.view = nil;
        
        [self tearDownGL];
        
        if ([EAGLContext currentContext] == self.context) {
            [EAGLContext setCurrentContext:nil];
        }
        self.context = nil;
    }
}

- (void)setupGL
{
    [EAGLContext setCurrentContext:self.context];
}

- (void)tearDownGL
{
    [EAGLContext setCurrentContext:self.context];
    self.effect = nil;
}

-(IBAction) record:(id)sender
{
    [flarg record:sender];
}

-(IBAction) play:(id)sender
{
    [flarg play:sender];
}

-(IBAction) save:(id)sender
{
    MoAudio::stop();
    NSLog(@"audio_callback has stopped");
    [flarg save:sender];
    
}




#pragma mark - GLKView and GLKViewController delegate methods

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    JCRecordRender();
}

@end
