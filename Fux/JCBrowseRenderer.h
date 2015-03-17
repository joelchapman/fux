//
//  JCBrowseRenderer.h
//  Fux
//
//  Created by Joel Chapman on 3/16/15.
//  Copyright (c) 2015 Joel Chapman. All rights reserved.
//  Using boiler-plate code from "Gloiler" (including MOMU) by Ge Wang.
//

#ifndef __JCBrowse__renderer__
#define __JCBrowse__renderer__

#import <UIKit/UIKit.h>

// initialize the engine (audio, grx, interaction)
void JCBrowseInit();

// TODO: cleanup

// set graphics dimensions
void JCBrowseSetDims( float width, float height );

// draw next frame of graphics
void JCBrowseRender();


// record interface
@interface browse_play : NSObject
+(void) play:(id)sender;
+(void) browse_playSoundAtURL;

+(void) slowDown:(id)sender;
+(void) speedUp:(id)sender;
+(void) doSomethingCrazy:(id)sender;
+(void) normal:(id)sender;

+(void) outputFirstName:(NSString *)first;
+(void) outputLastName:(NSString *)last;

@property (strong, nonatomic) NSArray *browse_sounds;
@end

#endif /* defined(__JCBrowse__renderer__) */
