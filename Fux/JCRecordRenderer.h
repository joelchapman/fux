//
//  JCRecordRenderer.h
//  Fux
//
//  Created by Joel Chapman on 2/22/15.
//  Copyright (c) 2015 Joel Chapman. All rights reserved.
//  Using boiler-plate code from "Gloiler" (including MOMU) by Ge Wang.
//

#ifndef __JCRecord__renderer__
#define __JCRecord__renderer__

#import <UIKit/UIKit.h>

// initialize the engine (audio, grx, interaction)
void JCRecordInit();

// TODO: cleanup

// set graphics dimensions
void JCRecordSetDims( float width, float height );

// draw next frame of graphics
void JCRecordRender();

// record
@interface flarg : NSObject
+(void) record:(id)sender;
+(void) play:(id)sender;
+(void) save:(id)sender;
@end

#endif /* defined(__GLoiler__renderer__) */
