//
//  renderer.h
//  GLamor
//
//  Created by Ge Wang on 1/21/14.
//  Copyright (c) 2014 Ge Wang. All rights reserved.
//

#ifndef __GLoiler__renderer__
#define __GLoiler__renderer__

#import <UIKit/UIKit.h>

// initialize the engine (audio, grx, interaction)
void GLoilerInit();

// TODO: cleanup

// set graphics dimensions
void GLoilerSetDims( float width, float height );

// draw next frame of graphics
void GLoilerRender();

// record
@interface flarg : NSObject
+(void) record:(id)sender;
+(void) play:(id)sender;
+(void) upload:(id)sender;
@end

//bool listen();

#endif /* defined(__GLoiler__renderer__) */
