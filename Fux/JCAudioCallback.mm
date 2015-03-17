//
//  JCAudioCallback.mm
//  Fux
//
//  Created by Joel Chapman on 3/16/15.
//  Copyright (c) 2015 Joel Chapman. All rights reserved.
//

#include "JCAudioCallback.h"
#import "mo-audio.h"
#import "mo-gfx.h"

// Screen Info
static CGRect screenRect = [[UIScreen mainScreen] bounds];
static CGFloat screenWidth = screenRect.size.width;
static CGFloat screenHeight = screenRect.size.height;

// Audio Defines
#define SRATE 44100
#define FRAMESIZE 1024
#define DELAYTIME 10
#define NUM_CHANNELS 2

// Audio Variables
SAMPLE g_vertices[FRAMESIZE*2]; //used for drawing waveforms
static UInt32 g_numFrames;
static GLfloat g_waveformWidth = 300;
//static GLfloat g_gfxWidth = screenWidth;
static GLfloat g_gfxHeight = screenHeight;
static Float32 delayedBuffer[SRATE*DELAYTIME]; //temp buffer to record audio

// Program globals
static bool g_listen = false; //when true, records audio
static bool g_play = false; // when true, plays audio

JCAudioCallback::JCAudioCallback() {
    JCAudioCallback::j = 0;
    JCAudioCallback::k = j + 1;

};

int JCAudioCallback::getJ()
{
    return JCAudioCallback::j;
}

int JCAudioCallback::getK()
{
    return JCAudioCallback::k;
}

//-----------------------------------------------------------------------------
// Name: audio_callback()
// Desc: audio callback
//-----------------------------------------------------------------------------
//static int j = 0;
//static int k = j + 1; // k will "tick" ever second
void JCAudioCallback::audioCallback( Float32 * buffer, UInt32 numFrames, void * userData )
{
    // our x
    SAMPLE x = 0;
    // increment
    SAMPLE inc = g_waveformWidth / numFrames;
    memset( g_vertices, 0, sizeof(SAMPLE)*FRAMESIZE*2 );
    
    for( int i = 0; i < numFrames; i++ )
    {
        
        // set to current x value
        g_vertices[NUM_CHANNELS*i] = x;
        // increment x
        x += inc;
        // set the y coordinate (with scaling)
        g_vertices[NUM_CHANNELS*i+1] = buffer[NUM_CHANNELS*i] * 2 * g_gfxHeight;
        
        // when record button is pressed
        if (g_listen)
        {
            delayedBuffer[JCAudioCallback::j] = buffer[i*NUM_CHANNELS+1];
            
            if(JCAudioCallback::j<(SRATE*DELAYTIME-1))
            {
                JCAudioCallback::j++;
                if (JCAudioCallback::j % SRATE == 0) JCAudioCallback::k++; // tick by "mod"ing every SRATE passing
            }
            else
            {
                g_listen = false;
                
                JCAudioCallback::j = 0;
                JCAudioCallback::k = JCAudioCallback::j + 1;
            }
        }
        
        // when play button is pressed
        if (g_play) {
            
            if(JCAudioCallback::j<(SRATE*DELAYTIME-1))
            {
                JCAudioCallback::j++;
                if (JCAudioCallback::j % SRATE == 0) JCAudioCallback::k++;
            }
            else
            {
                g_play = false;
                JCAudioCallback::j = 0;
                JCAudioCallback::k = JCAudioCallback::j + 1;
            }
        }
        buffer[i*NUM_CHANNELS] = buffer[i*NUM_CHANNELS+1] = delayedBuffer[JCAudioCallback::j]; // play shit
    }
    // save the num frames
    g_numFrames = numFrames;
}