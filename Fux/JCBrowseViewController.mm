//
//  JCBrowseViewController.mm
//  Fux
//
//  Created by Joel Chapman on 3/16/15.
//  Copyright (c) 2015 Joel Chapman. All rights reserved.
//  Using boiler-plate code from "Gloiler" (including MOMU) by Ge Wang.
//

#import "JCBrowseViewController.h"
#import "JCBrowseRenderer.h"
#import "JCAudioFile.h"
#import "mo-glut.h"
#import "mo-audio.h"
#import <iostream>
#import "FileRead.h"
#import "Stk.h"
#import <iostream>
#import <stdio.h>

#define SRATE 44100
#define FRAMESIZE 1024
#define NUMCHANNELS 2
#define DELAYTIME 10


@interface JCBrowseViewController () {
    
}

@property (strong, nonatomic) EAGLContext *context;
@property (strong, nonatomic) GLKBaseEffect *effect;

- (void)setupGL;
- (void)tearDownGL;

@end

@implementation JCBrowseViewController

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
    JCBrowseInit();
}


- (void)viewDidLayoutSubviews
{
    JCBrowseSetDims( self.view.bounds.size.width, self.view.bounds.size.height );
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

-(IBAction) play:(id)sender
{
    [browse_play play:sender];
}

-(IBAction) slowDown:(id)sender
{
    [browse_play slowDown:sender];
    
}

-(IBAction) speedUp:(id)sender
{
    [browse_play speedUp:sender];
    
}

-(IBAction) doSomethingCrazy:(id)sender
{
    [browse_play doSomethingCrazy:sender];
    
}

-(IBAction) normal:(id)sender
{
    [browse_play normal:sender];
    
}

-(void) outputFirstName:(NSString *) first
{
    [browse_play outputFirstName:first];
}

-(void) outputLastName:(NSString *) last
{
    [browse_play outputLastName:last];
}

#pragma mark - GLKView and GLKViewController delegate methods

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    JCBrowseRender();
}

@end
