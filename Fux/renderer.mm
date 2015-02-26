//
//  renderer.cpp
//  GLoiler
//
//  Created by Ge Wang on 1/21/14.
//  Copyright (c) 2014 Ge Wang. All rights reserved.
//

#import "renderer.h"
#import "mo-audio.h"
#import "mo-gfx.h"
#import "mo-touch.h"


#define SRATE 24000
#define FRAMESIZE 512
#define NUM_CHANNELS 2

// global variables
GLfloat g_waveformWidth = 300;
GLfloat g_gfxWidth = 320;
GLfloat g_gfxHeight = 568;

// buffer
SAMPLE g_vertices[FRAMESIZE*2];
UInt32 g_numFrames;




//-----------------------------------------------------------------------------
// name: audio_callback()
// desc: audio callback, yeah
//-----------------------------------------------------------------------------
void audio_callback( Float32 * buffer, UInt32 numFrames, void * userData )
{
    // our x
    SAMPLE x = 0;
    // increment
    SAMPLE inc = g_waveformWidth / numFrames;

    // zero!!!
    memset( g_vertices, 0, sizeof(SAMPLE)*FRAMESIZE*2 );
    
    for( int i = 0; i < numFrames; i++ )
    {
        // set to current x value
        g_vertices[2*i] = x;
        // increment x
        x += inc;
        // set the y coordinate (with scaling)
        g_vertices[2*i+1] = buffer[2*i] * 2 * g_gfxHeight;
        // zero
        buffer[2*i] = buffer[2*i+1] = 0;
    }
    
    // save the num frames
    g_numFrames = numFrames;
    
    // NSLog( @"." );
}




//-----------------------------------------------------------------------------
// name: touch_callback()
// desc: the touch call back
//-----------------------------------------------------------------------------
void touch_callback( NSSet * touches, UIView * view,
                     std::vector<MoTouchTrack> & tracks,
                     void * data)
{
    // points
    CGPoint pt;
    CGPoint prev;
    
    // number of touches in set
    NSUInteger n = [touches count];
    NSLog( @"total number of touches: %d", (int)n );
    
    // iterate over all touch events
    for( UITouch * touch in touches )
    {
        // get the location (in window)
        pt = [touch locationInView:view];
        prev = [touch previousLocationInView:view];
        
        // check the touch phase
        switch( touch.phase )
        {
                // begin
            case UITouchPhaseBegan:
            {
                NSLog( @"touch began... %f %f", pt.x, pt.y );
                break;
            }
            case UITouchPhaseStationary:
            {
                NSLog( @"touch stationary... %f %f", pt.x, pt.y );
                break;
            }
            case UITouchPhaseMoved:
            {
                NSLog( @"touch moved... %f %f", pt.x, pt.y );
                break;
            }
                // ended or cancelled
            case UITouchPhaseEnded:
            {
                NSLog( @"touch ended... %f %f", pt.x, pt.y );
                break;
            }
            case UITouchPhaseCancelled:
            {
                NSLog( @"touch cancelled... %f %f", pt.x, pt.y );
                break;
            }
                // should not get here
            default:
                break;
        }
    }
}

// initialize the engine (audio, grx, interaction)
void GLoilerInit()
{
    NSLog( @"init..." );
    
    // set touch callback
    MoTouch::addCallback( touch_callback, NULL );

    // init
    bool result = MoAudio::init( SRATE, FRAMESIZE, NUM_CHANNELS );
    if( !result )
    {
        // do not do this:
        int * p = 0;
        *p = 0;
    }
    // start
    result = MoAudio::start( audio_callback, NULL );
    if( !result )
    {
        // do not do this:
        int * p = 0;
        *p = 0;
    }
}

// set graphics dimensions
void GLoilerSetDims( float width, float height )
{
    NSLog( @"set dims: %f %f", width, height );
}

// draw next frame of graphics
void GLoilerRender()
{
    // NSLog( @"render..." );
    
    // projection
    glMatrixMode( GL_PROJECTION );
    // reset
    glLoadIdentity();
    // alternate
    // GLfloat ratio = g_gfxHeight / g_gfxWidth;
    // glOrthof( -1, 1, -ratio, ratio, -1, 1 );
    // orthographic
    glOrthof( -g_gfxWidth/2, g_gfxWidth/2, -g_gfxHeight/2, g_gfxHeight/2, -1.0f, 1.0f );
    // modelview
    glMatrixMode( GL_MODELVIEW );
    // reset
    // glLoadIdentity();
    
    glClearColor( 0, 0, 0, 1 );
    glClear( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT );

    // push
    glPushMatrix();

    // center it
    glTranslatef( -g_waveformWidth / 2, 0, 0 );
    
    // set the vertex array pointer
    glVertexPointer( 2, GL_FLOAT, 0, g_vertices );
    glEnableClientState( GL_VERTEX_ARRAY );
    
    // color
    glColor4f( 1, 1, 0, 1 );
    // draw the thing
    glDrawArrays( GL_LINE_STRIP, 0, g_numFrames/2 );

    // color
    glColor4f( 0, 1, 0, 1 );
    // draw the thing
    glDrawArrays( GL_LINE_STRIP, g_numFrames/2-1, g_numFrames/2 );

    // pop
    glPopMatrix();
}

