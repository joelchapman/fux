//
//  JCRecordRenderer.mm
//  Fux
//
//  Created by Joel Chapman on 2/26/15.
//  Copyright (c) 2015 Joel Chapman. All rights reserved.
//  Using boiler-plate code from "Gloiler" (including MOMU) by Ge Wang.
//

#import "JCRecordRenderer.h"
#import "mo-audio.h"
#import "mo-gfx.h"
#import "mo-fun.h"
#import "mo-touch.h"
#import "JCAudioFile.h"
#import "GLEntity.h"
#import "JCCoordinates.h"
#import "JCAudioFile.h"

#import <iostream>

using namespace std;

// Audio Defines
#define SRATE 44100
#define FRAMESIZE 1024
#define DELAYTIME 10
#define NUM_CHANNELS 2

#define NUM_PROGRESS 1
#define NUM_BUTTONS 1
#define NUM_ENCOURAGEMENTS 1
#define NUM_ENCOURAGEMENT_PNGS 10
#define Z_CLOSE 4.0

// Screen Info
static CGRect screenRect = [[UIScreen mainScreen] bounds];
static CGFloat screenWidth = screenRect.size.width;
static CGFloat screenHeight = screenRect.size.height;

static GLfloat g_waveformWidth = 300;
static GLfloat g_gfxWidth = screenWidth;
static GLfloat g_gfxHeight = screenHeight;

// Audio Variables
SAMPLE g_vertices[FRAMESIZE*2]; //used for drawing waveforms
static UInt32 g_numFrames;
int delaySize = JCAudioFile::bufferSize();
static Float32 delayedBuffer[SRATE*DELAYTIME]; //temp buffer to record audio
const char * fpath = "/Users/Joel/Documents/Academic/College/Coterm\ Year/256b/Fux/Fux/Supporting\ Files/Recordings/audio_profile.m4a";

// Texture globals
static GLuint g_texture[1];
static int g_rand_texture;

// Program globals
static bool g_listen = false; //when true, records audio
static bool g_next_encouragement = false;
static bool g_play = false; // when true, plays audio

// Class instantiations
GLEntity g_progress;
GLEntity g_button;
GLEntity g_encouragements[NUM_ENCOURAGEMENTS];
JCCoordinates g_coords;
JCAudioFile userRecording;

//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
// OBJECTIVE C STUFF
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
@implementation flarg : NSObject

+(void) record:(id)sender
{
    g_listen = true;
}

+(void) play:(id)sender
{
    g_play = true;
}

+(void) save:(id)sender
{
    userRecording.setRecording(delayedBuffer, 1); // save audio
    userRecording.writeBufferToAudioFile(userRecording.getRecording(delayedBuffer, 1), fpath, 1, true);
}

@end



//-----------------------------------------------------------------------------
// Name: audio_callback()
// Desc: audio callback
//-----------------------------------------------------------------------------
static int j = 0;
static int k = j + 1; // k will "tick" ever second
void audio_callback( Float32 * buffer, UInt32 numFrames, void * userData )
{
    // our x
    SAMPLE x = 0;
    // increment
    SAMPLE inc = g_waveformWidth / numFrames;
    memset( g_vertices, 0, sizeof(SAMPLE)*FRAMESIZE*2 );
    
    for( int i = 0; i < numFrames; i++ )
    {
        
        // set to current x value
        g_vertices[2*i] = x;
        // increment x
        x += inc;
        // set the y coordinate (with scaling)
        g_vertices[2*i+1] = buffer[2*i] * 2 * g_gfxHeight;
        
        // when record button is pressed
        if (g_listen)
        {
                delayedBuffer[j] = buffer[i*2+1];
                
                if(j<(SRATE*DELAYTIME-1))
                {
                    j++;
                    if (j % SRATE == 0) k++; // tick by "mod"ing every SRATE passing
                }
                else
                {
                    g_listen = false;
                    
                    j = 0;
                    k = j + 1;
                }
        }
        
        // when play button is pressed
        if (g_play) {
            
            if(j<(SRATE*DELAYTIME-1))
            {
                j++;
                if (j % SRATE == 0) k++;
            }
            else
            {
                g_play = false;
                j = 0;
                k = j + 1;
            }
        }
       buffer[i*2] = buffer[i*2+1] = delayedBuffer[j]; // play shit
    }
    // save the num frames
    g_numFrames = numFrames;
}


//-----------------------------------------------------------------------------
// Name: isTouchingButton(CGPoint pt)
// Desc: Decides whether or not touch is in radius of button activity
//-----------------------------------------------------------------------------
bool isTouchingButton(CGPoint pt)
{
    
    return true;
}


//-----------------------------------------------------------------------------
// Name: touch_callback()
// Desc: the touch call back
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
//                if (pt.x == g_button.loc.z + 0.5) {
//                    g_listen = true;
//                }
                
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
           //     g_listen = false;
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


//-----------------------------------------------------------------------------
// Name: loadTextures()
// Desc: loads the right texture based on the ol' switcheroo
//-----------------------------------------------------------------------------
void loadTextures()
{
    int switcheroo;
    
    if (k < 10) switcheroo = j/SRATE + 1;
    else if (k == 10) switcheroo = k;

    // if recording...
    if (g_listen) {
        switch (switcheroo) {
            case 0:
                MoGfx::loadTexture(@"progress_10", @"png");
                break;
                
            case 1:
                MoGfx::loadTexture(@"progress_red_9", @"png");
                break;
                
            case 2:
                MoGfx::loadTexture(@"progress_red_8", @"png");
                break;
                
            case 3:
                MoGfx::loadTexture(@"progress_red_7", @"png");
                break;
                
            case 4:
                MoGfx::loadTexture(@"progress_red_6", @"png");
                break;
                
            case 5:
                MoGfx::loadTexture(@"progress_red_5", @"png");
                break;
                
            case 6:
                MoGfx::loadTexture(@"progress_red_4", @"png");
                break;
                
            case 7:
                MoGfx::loadTexture(@"progress_red_3", @"png");
                break;
                
            case 8:
                MoGfx::loadTexture(@"progress_red_2", @"png");
                break;
                
            case 9:
                MoGfx::loadTexture(@"progress_red_1", @"png");
                break;
                
            case 10:
                MoGfx::loadTexture(@"progress_red_0", @"png");
                break;
                
            default:
                MoGfx::loadTexture(@"progress_10", @"png");
                break;
        }
    } else if (g_play) {
        switch (switcheroo) {
            case 0:
                MoGfx::loadTexture(@"progress_10", @"png");
                break;
                
            case 1:
                MoGfx::loadTexture(@"progress_9", @"png");
                break;
                
            case 2:
                MoGfx::loadTexture(@"progress_8", @"png");
                break;
                
            case 3:
                MoGfx::loadTexture(@"progress_7", @"png");
                break;
                
            case 4:
                MoGfx::loadTexture(@"progress_6", @"png");
                break;
                
            case 5:
                MoGfx::loadTexture(@"progress_5", @"png");
                break;
                
            case 6:
                MoGfx::loadTexture(@"progress_4", @"png");
                break;
                
            case 7:
                MoGfx::loadTexture(@"progress_3", @"png");
                break;
                
            case 8:
                MoGfx::loadTexture(@"progress_2", @"png");
                break;
                
            case 9:
                MoGfx::loadTexture(@"progress_1", @"png");
                break;
                
            case 10:
                MoGfx::loadTexture(@"progress_0", @"png");
                break;
                
            default:
                MoGfx::loadTexture(@"progress_0", @"png");
                break;
        }
    } else MoGfx::loadTexture(@"progress_10", @"png");


}


//-----------------------------------------------------------------------------
// Name: loadEncouragements()
// Desc: loads various encouragments when user records profile
//-----------------------------------------------------------------------------
void loadEncouragements()
{
    switch (g_rand_texture) {
        case 1:
            MoGfx::loadTexture(@"bangin", @"png");
            break;
            
        case 2:
            MoGfx::loadTexture(@"hawt", @"png");
            break;
            
        case 3:
            MoGfx::loadTexture(@"sexier", @"png");
            break;
            
        case 4:
            MoGfx::loadTexture(@"sexy", @"png");
            break;
            
        case 5:
            MoGfx::loadTexture(@"smagin", @"png");
            break;
            
        case 6:
            MoGfx::loadTexture(@"someone", @"png");
            break;
            
        case 7:
            MoGfx::loadTexture(@"style", @"png");
            break;
            
        case 8:
            MoGfx::loadTexture(@"thang", @"png");
            break;

        case 9:
            MoGfx::loadTexture(@"the_one", @"png");
            break;
            
        case 10:
            MoGfx::loadTexture(@"you_got_this", @"png");
            break;
            
        default:
            MoGfx::loadTexture(@"sexy", @"png");
            break;
    }
}


//-----------------------------------------------------------------------------
// name: draw()
// desc: draws stuff to the screen (progress bar, record button)
//-----------------------------------------------------------------------------
void draw(GLEntity entity, int num)
{
    // for each entity
    for( int i = 0; i < num; i++ )
    {
        glPushMatrix();
        
        // translate
        glTranslatef( entity.loc.x, entity.loc.y, entity.loc.z );
        glScalef( entity.sca.x, entity.sca.y, entity.sca.z );
        
        //color
        GLfloat val = 1;
        
        glColor4f(entity.col.x, entity.col.y, entity.col.z, val);
        
        // vertex
        glVertexPointer( 2, GL_FLOAT, 0, g_coords.squareVertices );
        glEnableClientState(GL_VERTEX_ARRAY );
        
        // normal
        glNormalPointer( GL_FLOAT, 0, g_coords.normals );
        glEnableClientState( GL_NORMAL_ARRAY );
        
        // texture coordinate
        glTexCoordPointer( 2, GL_FLOAT, 0, g_coords.texCoords );
        glEnableClientState( GL_TEXTURE_COORD_ARRAY );
        
        // triangle strip
        glDrawArrays( GL_TRIANGLE_STRIP, 0, 4 );
        
        glPopMatrix();
    }
}

//-----------------------------------------------------------------------------
// Name: drawEncouragements()
// Desc: specific to encouragements, which are in motion and randomly placed
//-----------------------------------------------------------------------------
void drawEncouragements()
{
    loadEncouragements();
    
    // for each entity
    for( int i = 0; i < NUM_ENCOURAGEMENTS; i++ )
    {
        glPushMatrix();
        
        if (g_next_encouragement == true) {
            g_rand_texture = MoFun::rand2f(1, NUM_ENCOURAGEMENT_PNGS);
            g_encouragements[i].setRandomCoords();
        }
        
        g_next_encouragement = false;
        
        // translate
        glTranslatef( g_encouragements[i].loc.x, g_encouragements[i].loc.y, g_encouragements[i].loc.z );
        glScalef( g_encouragements[i].sca.x, g_encouragements[i].sca.y, g_encouragements[i].sca.z );
        
        //color
        GLfloat val = 1 - fabs(g_encouragements[i].loc.z)/Z_CLOSE;
        float v = val;
        glColor4f(g_encouragements[i].col.x*v, g_encouragements[i].col.y*v, g_encouragements[i].col.z*v, val);
        
        g_encouragements[i].loc.z += 0.2;
        g_encouragements[i].sca.x += 0.2;
        g_encouragements[i].sca.y += 0.3;
        
        if (g_encouragements[i].loc.z > Z_CLOSE) {
            g_encouragements[i].setRandomCoords();
            g_next_encouragement = true;
        }
        
        // vertex
        glVertexPointer( 2, GL_FLOAT, 0, g_coords.squareVertices );
        glEnableClientState(GL_VERTEX_ARRAY );
        
        // normal
        glNormalPointer( GL_FLOAT, 0, g_coords.normals );
        glEnableClientState( GL_NORMAL_ARRAY );
        
        // texture coordinate
        glTexCoordPointer( 2, GL_FLOAT, 0, g_coords.texCoords );
        glEnableClientState( GL_TEXTURE_COORD_ARRAY );
        
        // triangle strip
        glDrawArrays( GL_TRIANGLE_STRIP, 0, 4 );
        
        glPopMatrix();
    }
}


//-----------------------------------------------------------------------------
// Name: drawButton()
// Desc: record button
//-----------------------------------------------------------------------------
void drawButton()
{
    MoGfx::loadTexture(@"record_button", @"png");
  //  draw(g_button, NUM_BUTTONS);
}

//-----------------------------------------------------------------------------
// Name: drawProgressBar()
// Desc: progress bar
//-----------------------------------------------------------------------------
void drawProgressBar()
{
    loadTextures();
    draw(g_progress, NUM_PROGRESS);
}


//-----------------------------------------------------------------------------
// Name: drawRecordScreen()
// Desc: calls functions to draw everything you see on the record screen
//-----------------------------------------------------------------------------
void drawRecordScreen()
{
    drawProgressBar();
    drawButton();
    if (g_listen) {
        drawEncouragements();
    }
}


//-----------------------------------------------------------------------------
// Name: initializeProgress()
// Desc: Set coordinates of progress bar using class GLEntity
//-----------------------------------------------------------------------------
void initializeProgress()
{
    g_progress.setProgressCoords();
}


//-----------------------------------------------------------------------------
// Name: initializeButton()
// Desc: Set coordinates of record button using class GLEntity
//-----------------------------------------------------------------------------
void initializeButton()
{
    g_button.setButtonCoords();
}


//-----------------------------------------------------------------------------
// Name: initializeEncouragements()
// Desc: Set random coordinates of encouragements using class GLEntity
//-----------------------------------------------------------------------------
void initializeEncouragements()
{
    for (int i = 0; i < NUM_ENCOURAGEMENTS; i++) {
        g_encouragements[i].setRandomCoords();
    }
}


//-----------------------------------------------------------------------------
// Name: initializeTextures()
// Desc: Calls functions to initialize coordinates
//-----------------------------------------------------------------------------
void initializeTextures()
{
    
    initializeProgress();
    initializeButton();
    initializeEncouragements();
}


//-----------------------------------------------------------------------------
// Name: drawWaveforms()
// Desc: Draws a time domain-amplitude graph in real time
//-----------------------------------------------------------------------------
void drawWaveforms()
{
    // push
    glPushMatrix();
    
    // center it
    // glTranslatef( -g_waveformWidth / 2, 0, 4 );
    glTranslatef( 0, 0, 4 );
    //   glScalef(0.2, 0.2, 0.2);
    
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


//-----------------------------------------------------------------------------
// Name: GLoilerInitVisual()
// Desc: GL stuff / MoGfx perspectives
//-----------------------------------------------------------------------------
void GLoilerInitVisual()
{
    // projection
    glMatrixMode( GL_PROJECTION );
    
    // reset
    glLoadIdentity();
    
    // orthographic
    glOrthof( -g_gfxWidth/2, g_gfxWidth/2, -g_gfxHeight/2, g_gfxHeight/2, -1.0f, 1.0f );
    
    // perspective projection
    MoGfx::perspective( 70, screenWidth/screenHeight, .01, 100 );
    
    // modelview
    glMatrixMode( GL_MODELVIEW );
    
    // look
    MoGfx::lookAt( 0, 0, 6, 0, 0, 0, 0, 1, 0 );
    
    // enable texture mapping
    glEnable( GL_TEXTURE_2D );
    // enable blending
    glEnable( GL_BLEND );
    // blend function
    glBlendFunc( GL_ONE, GL_ONE );
    //   glBlendFunc( GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA );
    
    // generate texture name
    glGenTextures( 1, &g_texture[0] );
    // bind the texture
    glBindTexture( GL_TEXTURE_2D, g_texture[0] );
    // setting parameters
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
    
    
    //init GLEntities
    initializeTextures();
}


//-----------------------------------------------------------------------------
// Name: GLoilerInitTouch()
// Desc: Add touch callback
//-----------------------------------------------------------------------------
void GLoilerInitTouch()
{
    // set touch callback
    MoTouch::addCallback( touch_callback, NULL );
}

void GLoilerInitAudio()
{
    memset( delayedBuffer, 0, sizeof SRATE*DELAYTIME );
    
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

//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
// Below are the three functions called by JCRecordViewController.mm
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------


//-----------------------------------------------------------------------------
// Name: JCRecordInit()
// Desc: Initialize the engine (audio, gfx, interaction)
//-----------------------------------------------------------------------------
void JCRecordInit()
{
    NSLog( @"init..." );
    
    GLoilerInitVisual();
    GLoilerInitTouch();
    GLoilerInitAudio();
}


//-----------------------------------------------------------------------------
// Name: JCRecordSetDims( float width, float height )
// Desc: Set graphics dimensions
//-----------------------------------------------------------------------------
void JCRecordSetDims( float width, float height )
{
    NSLog( @"set dims: %f %f", width, height );
}


//-----------------------------------------------------------------------------
// Name: JCRecordRender()
// Desc: Draw next frame of graphics
//-----------------------------------------------------------------------------
void JCRecordRender()
{
    // clear
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    
    //    drawWaveforms();
    drawRecordScreen();
}