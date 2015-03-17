//
//  JCBrowseRenderer.mm
//  Fux
//
//  Created by Joel Chapman on 3/16/15.
//  Copyright (c) 2015 Joel Chapman. All rights reserved.
//  Using boiler-plate code from "Gloiler" (including MOMU) by Ge Wang.
//

#import "JCBrowseRenderer.h"
#import "JCCoordinates.h"
#import "JCRecordRenderer.h"
#import "JCAudioFile.h"
#import "GLEntity.h"
#import "mo-audio.h"
#import "mo-gfx.h"
#import "mo-fun.h"
#import "mo-touch.h"
#import "Stk.h"
#import "FileRead.h"
#import "SoundShareClient.h"

#import <iostream>

using namespace std;

// Audio Defines
#define SRATE 44100
#define FRAMESIZE 1024
#define DELAYTIME 10
#define NUM_CHANNELS 2

#define NUM_FLIERS 2
#define NUM_FLIER_PNGS 10

#define SOLO 1
#define NUM_PROGRESS 1
#define NUM_BUTTONS 1

#define Z_CLOSE 4.0

// Screen Info
static CGRect screenRect = [[UIScreen mainScreen] bounds];
static CGFloat screenWidth = screenRect.size.width;
static CGFloat screenHeight = screenRect.size.height;

static GLfloat g_waveformWidth = 300;
static GLfloat g_gfxWidth = screenWidth;
static GLfloat g_gfxHeight = screenHeight;

// Audio Variables
SAMPLE g_browse_vertices[FRAMESIZE*2]; //used for drawing waveforms
static UInt32 g_numFrames;
static Float32 browse_otherUserBuffer[SRATE*DELAYTIME*NUM_CHANNELS]; //other user's buffer
static Float32 temp_buffer[SRATE*DELAYTIME*NUM_CHANNELS];

// Texture globals
static GLuint g_browse_texture[1];
static int g_browse_rand_texture;

// Program globals
static bool g_browse_listen = false; //when true, records audio
static bool g_browse_next_flier = false;
static bool g_browse_play = false; // when true, plays audio

static bool g_browse_slowdown = false;
static bool g_browse_speedup = false;
static bool g_browse_crazy = false;
int g_browse_frameFactor = 2;
NSString * justTheName = @""; // extracted user name

// Class instantiations
JCCoordinates g_browse_coords;
GLEntity g_browse_progress;
GLEntity g_browse_entity;
GLEntity g_browse_fliers[NUM_FLIERS];
JCAudioFile otherUserAudio;
//JCName names;


stk::FileRead * browse_fileReader = NULL;
stk::StkFrames * browse_readBuffer;
static int sampleIndex = 0;

Float32 g_browse_t = 0.0;
Float32 g_browse_f = 30;

//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
// OBJECTIVE C STUFF
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
@implementation browse_play : NSObject
@synthesize browse_sounds;

+(void) play:(id)sender
{
    g_browse_play = true;
}

+(void) slowDown:(id)sender
{
    g_browse_speedup = false;
    g_browse_slowdown = true;
}

+(void) speedUp:(id)sender
{
    g_browse_slowdown = false;
    g_browse_speedup = true;
}

+(void) doSomethingCrazy:(id)sender
{
    g_browse_crazy = true;
    g_browse_f = MoFun::rand2f(30,800);
}

+(void) normal:(id)sender
{
    g_browse_speedup = false;
    g_browse_slowdown = false;
    g_browse_crazy = false;
    g_browse_frameFactor = 2;
}

+(void) outputFirstName:(NSString*)first
{
    first = justTheName;
}

+(void) outputLastName:(NSString *)last
{
    last = @"Cope";
}

@end


//-----------------------------------------------------------------------------
// Name: audio_callback()
// Desc: audio callback
//-----------------------------------------------------------------------------
static int j = 0;
static int k = j + 1; // k will "tick" ever second
void browse_audio_callback( Float32 * buffer, UInt32 numFrames, void * userData )
{
    Float32 ringMod;
    if (g_browse_speedup) {
        g_browse_frameFactor = 1;
    }
    if (g_browse_slowdown) {
        g_browse_frameFactor = 4;
    }
    if (g_browse_speedup == false && g_browse_slowdown == false) {
        g_browse_frameFactor = 2;
    }
    
    bool didRead = false;
    memset( buffer, 0, sizeof(SAMPLE)*FRAMESIZE*2 );
    if (browse_fileReader && sampleIndex < browse_fileReader->fileSize())
    {
        browse_fileReader->read(*browse_readBuffer, sampleIndex);
        sampleIndex += FRAMESIZE/g_browse_frameFactor; // why on earth did i have to do this. audio is all messed up 3/16 21:26
        didRead = true;
    }
    for (int i = 0; i < numFrames; i++)
    {
        // when play button is pressed
        if (g_browse_play) {
            
            if(j<(SRATE*DELAYTIME-1))
            {
                j++;
                if (j % SRATE == 0) k++;
            }
            else
            {
                g_browse_play = false;
                j = 0;
                k = j + 1;
            }
        }
        // if crazy is pressed
        if (g_browse_crazy) {
            // generate sine wave for ring mod
            ringMod = ::sin( TWO_PI * g_browse_f * g_browse_t / SRATE );
            // advance time
            g_browse_t += 1.0;
        } else ringMod = 1;

        if (browse_readBuffer && didRead)
        {
            buffer[i * NUM_CHANNELS] = buffer[i * NUM_CHANNELS + 1] = ringMod*(*browse_readBuffer)[i * NUM_CHANNELS];
            
        }
        else
        {
            buffer[i * NUM_CHANNELS] = buffer[i * NUM_CHANNELS + 1] = 0;
        }
    }
}


void browse_playSoundAtURL(NSURL * url)
{
    NSLog(@"URL: %@", url);
    
    // extract user's name
    NSString * usersName = [url absoluteString];
    NSString * noDotWav = [usersName substringToIndex:[usersName length] - 4];
    justTheName = [noDotWav substringFromIndex:54];
  //  NSString * noDotWav = [justTheNameDotWav substringToIndex:[noDotWav length] - 4];
    //justTheName = [justTheNameNoDotWav UTF8String];
    
    NSData * data = [NSData dataWithContentsOfURL:url];
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * path = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"audioprofile.wav"];
    NSLog(@"Tried to write to path: %@", path);
    [data writeToFile:path atomically:NO];
    
    browse_readBuffer = new stk::StkFrames(FRAMESIZE, NUM_CHANNELS);
    browse_fileReader = new stk::FileRead([path UTF8String], false, NUM_CHANNELS, 32, SRATE);
    browse_fileReader->open([path UTF8String], false, NUM_CHANNELS, 32, SRATE);
    sampleIndex = 0;
}


//-----------------------------------------------------------------------------
// Name: touch_callback()
// Desc: the touch call back
//-----------------------------------------------------------------------------
void browse_touch_callback( NSSet * touches, UIView * view,
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
                g_browse_play = true;
                NSString * soundPath = @"audio_profile_Stud.wav";
                NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"%@soundshare/sounds/%@", kSoundShareBaseURLString, soundPath]];
                browse_playSoundAtURL(url);
                
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
void browse_loadProgressTextures()
{
    int switcheroo;
    if (k < 10) switcheroo = j/SRATE + 1;
    else if (k == 10) switcheroo = k;
    
    // if recording...
    if (g_browse_listen) {
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
    } else if (g_browse_play) {
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
void browse_loadEncouragements()
{
    switch (g_browse_rand_texture) {
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
void browse_draw(GLEntity entity, int num)
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
        glVertexPointer( 2, GL_FLOAT, 0, g_browse_coords.squareVertices );
        glEnableClientState(GL_VERTEX_ARRAY );
        
        // normal
        glNormalPointer( GL_FLOAT, 0, g_browse_coords.normals );
        glEnableClientState( GL_NORMAL_ARRAY );
        
        // texture coordinate
        glTexCoordPointer( 2, GL_FLOAT, 0, g_browse_coords.texCoords );
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
void browse_drawEncouragements()
{
    browse_loadEncouragements();
    
    // for each entity
    for( int i = 0; i < NUM_FLIERS; i++ )
    {
        glPushMatrix();
        
        if (g_browse_next_flier == true) {
            g_browse_rand_texture = MoFun::rand2f(1, NUM_FLIER_PNGS);
            g_browse_fliers[i].setRandomCoords();
        }
        
        g_browse_next_flier = false;
        
        // translate
        glTranslatef( g_browse_fliers[i].loc.x, g_browse_fliers[i].loc.y, g_browse_fliers[i].loc.z );
        glScalef( g_browse_fliers[i].sca.x, g_browse_fliers[i].sca.y, g_browse_fliers[i].sca.z );
        
        //color
        GLfloat val = 1 - fabs(g_browse_fliers[i].loc.z)/Z_CLOSE;
        float v = val;
        glColor4f(g_browse_fliers[i].col.x*v, g_browse_fliers[i].col.y*v, g_browse_fliers[i].col.z*v, val);
        
        g_browse_fliers[i].loc.z += 0.2;
        g_browse_fliers[i].sca.x += 0.2;
        g_browse_fliers[i].sca.y += 0.3;
        
        if (g_browse_fliers[i].loc.z > Z_CLOSE) {
            g_browse_fliers[i].setRandomCoords();
            g_browse_next_flier = true;
        }
        
        // vertex
        glVertexPointer( 2, GL_FLOAT, 0, g_browse_coords.squareVertices );
        glEnableClientState(GL_VERTEX_ARRAY );
        
        // normal
        glNormalPointer( GL_FLOAT, 0, g_browse_coords.normals );
        glEnableClientState( GL_NORMAL_ARRAY );
        
        // texture coordinate
        glTexCoordPointer( 2, GL_FLOAT, 0, g_browse_coords.texCoords );
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
void browse_drawButton()
{
  //  MoGfx::loadTexture(@"record_button", @"png");
  //  draw(g_button, NUM_BUTTONS);
}

//-----------------------------------------------------------------------------
// Name: drawProgressBar()
// Desc: progress bar
//-----------------------------------------------------------------------------
void browse_drawProgressBar()
{
    browse_loadProgressTextures();
    browse_draw(g_browse_progress, NUM_PROGRESS);
}


//-----------------------------------------------------------------------------
// Name: drawTitle()
// Desc: title
//-----------------------------------------------------------------------------
void browse_drawTitle()
{
 //   MoGfx::loadTexture(@"title", @"png");
//    draw(g_title, SOLO);

}


//-----------------------------------------------------------------------------
// Name: drawRecordScreen()
// Desc: calls functions to draw everything you see on the record screen
//-----------------------------------------------------------------------------
void browse_drawRecordScreen()
{
  //  browse_drawTitle();
    browse_drawProgressBar();
  //  browse_drawButton();
    if (g_browse_play) {
        browse_drawEncouragements();
    }
}


//-----------------------------------------------------------------------------
// Name: initializeProgress()
// Desc: Set coordinates of progress bar using class GLEntity
//-----------------------------------------------------------------------------
void browse_initializeProgress()
{
    g_browse_progress.setProgressCoords();
}



//-----------------------------------------------------------------------------
// Name: initializeEncouragements()
// Desc: Set random coordinates of encouragements using class GLEntity
//-----------------------------------------------------------------------------
void browse_initializeEncouragements()
{
    for (int i = 0; i < NUM_FLIERS; i++) {
        g_browse_fliers[i].setRandomCoords();
    }
}


//-----------------------------------------------------------------------------
// Name: initializeTextures()
// Desc: Calls functions to initialize coordinates
//-----------------------------------------------------------------------------
void browse_initializeTextures()
{
    browse_initializeProgress();
 //   initializeButton();
    browse_initializeEncouragements();
}



//-----------------------------------------------------------------------------
// Name: GLoilerInitVisual()
// Desc: GL stuff / MoGfx perspectives
//-----------------------------------------------------------------------------
void browse_GLoilerInitVisual()
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
    glGenTextures( 1, &g_browse_texture[0] );
    // bind the texture
    glBindTexture( GL_TEXTURE_2D, g_browse_texture[0] );
    // setting parameters
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
    
    
    //init GLEntities
    browse_initializeTextures();
}


//-----------------------------------------------------------------------------
// Name: GLoilerInitTouch()
// Desc: Add touch callback
//-----------------------------------------------------------------------------
void browse_GLoilerInitTouch()
{
    // set touch callback
    MoTouch::addCallback( browse_touch_callback, NULL );
}

void browse_GLoilerInitAudio()
{
    memset( browse_otherUserBuffer, 0, sizeof SRATE*DELAYTIME );
    
    float r[SRATE*DELAYTIME*NUM_CHANNELS];
    for (int i = 0; i < SRATE*DELAYTIME; i++) {
    //    temp_buffer[i*NUM_CHANNELS] = temp_buffer[i*NUM_CHANNELS + 1] = *otherUserAudio.getOtherUserRecording();
    }
    
    // start
    bool result = MoAudio::start( browse_audio_callback , NULL );
    if( !result )
    {
        NSLog(@"Unable to start real-time audio!");
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
void JCBrowseInit()
{
    NSLog( @"init..." );
    
    browse_GLoilerInitVisual();
    browse_GLoilerInitTouch();
    browse_GLoilerInitAudio();
}


//-----------------------------------------------------------------------------
// Name: JCRecordSetDims( float width, float height )
// Desc: Set graphics dimensions
//-----------------------------------------------------------------------------
void JCBrowseSetDims( float width, float height )
{
    NSLog( @"set dims: %f %f", width, height );
}


//-----------------------------------------------------------------------------
// Name: JCRecordRender()
// Desc: Draw next frame of graphics
//-----------------------------------------------------------------------------
void JCBrowseRender()
{
    // clear
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    
    //    drawWaveforms();
    browse_drawRecordScreen();
}