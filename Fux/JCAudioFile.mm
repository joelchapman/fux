//
//  JCAudioFile.mm
//  Fux
//
//  Created by Joel Chapman on 3/2/15.
//  Copyright (c) 2015 Joel Chapman. All rights reserved.
//

#import "JCAudioFile.h"
#import <stdlib.h>
#import "mo-fun.h"
#import <AudioToolbox/AudioToolbox.h>
#import <iostream>
#import "mo-def.h"

using namespace std;

#define SRATE 44100
#define DELAYTIME 10
#define NUM_CHANNELS 2
#define BITS_PER_CHANNEL 32

JCAudioFile::JCAudioFile()
{
    recording = (float*)malloc(SRATE*DELAYTIME*NUM_CHANNELS*sizeof(Float32));
}

void JCAudioFile::setRecording( Float32 tempBuffer[], int TRACKS )
{
    memcpy(recording, tempBuffer, sizeof(Float32)*SRATE*DELAYTIME*NUM_CHANNELS);
}

float * JCAudioFile::getRecording( Float32 tempBuffer[], int TRACKS )
{
    static float r[SRATE*DELAYTIME*NUM_CHANNELS];
    for (int i = 0; i < SRATE*DELAYTIME; i++) {
        r[i*NUM_CHANNELS] = r[i*NUM_CHANNELS + 1] = tempBuffer[i*NUM_CHANNELS];
    }
    return r;
}

int JCAudioFile::bufferSize()
{
    return SRATE*DELAYTIME;
}


// void writeBufferToAudioFile adapted from writeNoiseToAudioFile, written by Adam Stark
void JCAudioFile::writeBufferToAudioFile(Float32 buffer[], const char * fName, int mChannels, bool compress_with_m4a)
{
    OSStatus err; // to record errors from ExtAudioFile API functions
    
    
    // create file path as CStringRef
    CFStringRef fPath;
    fPath = CFStringCreateWithCString(kCFAllocatorDefault,
                                      fName,
                                      kCFStringEncodingMacRoman);
    
    
    // specify total number of samples per channel
    UInt32 totalFramesInFile = SRATE*DELAYTIME;
    
    /////////////////////////////////////////////////////////////////////////////
    ////////////// Set up Audio Buffer List For Interleaved Audio ///////////////
    /////////////////////////////////////////////////////////////////////////////
    
    AudioBufferList outputData;
    outputData.mNumberBuffers = 1;
    outputData.mBuffers[0].mNumberChannels = mChannels;
    outputData.mBuffers[0].mDataByteSize = sizeof(float)*totalFramesInFile*mChannels;
    
    
    
    /////////////////////////////////////////////////////////////////////////////
    //////// Synthesise Noise and Put It In The AudioBufferList /////////////////
    /////////////////////////////////////////////////////////////////////////////
    
    // create an array to hold our audio
    float audioFile[totalFramesInFile*mChannels];
    
    // fill the array with random numbers (white noise)
    for (int i = 0; i < totalFramesInFile*mChannels; i++)
    {
        audioFile[i] = buffer[i];
        // (yes, I know this noise has a DC offset, bad)
    }
    
    // set the AudioBuffer to point to the array containing the noise
    outputData.mBuffers[0].mData = &audioFile;
    
    
    /////////////////////////////////////////////////////////////////////////////
    ////////////////// Specify The Output Audio File Format /////////////////////
    /////////////////////////////////////////////////////////////////////////////
    
    
    // the client format will describe the output audio file
    AudioStreamBasicDescription clientFormat;
    
    // the file type identifier tells the ExtAudioFile API what kind of file we want created
    AudioFileTypeID fileType;
    
    // if compress_with_m4a is tru then set up for m4a file format
    if (compress_with_m4a)
    {
        // the file type identifier tells the ExtAudioFile API what kind of file we want created
        // this creates a m4a file type
        fileType = kAudioFileM4AType;
        
        // Here we specify the M4A format
        clientFormat.mSampleRate         = SRATE;
        clientFormat.mFormatID           = kAudioFormatMPEG4AAC;
        clientFormat.mFormatFlags        = kMPEG4Object_AAC_Main;
        clientFormat.mChannelsPerFrame   = mChannels;
        clientFormat.mBytesPerPacket     = 0;
        clientFormat.mBytesPerFrame      = 0;
        clientFormat.mFramesPerPacket    = 1024;
        clientFormat.mBitsPerChannel     = 0;
        clientFormat.mReserved           = 0;
    }
    else // else encode as PCM
    {
        // this creates a wav file type
        fileType = kAudioFileWAVEType;
        
        // This function audiomatically generates the audio format according to certain arguments
        FillOutASBDForLPCM(clientFormat,SRATE,mChannels,BITS_PER_CHANNEL,BITS_PER_CHANNEL,true,false,false);
    }

    
    
    
    /////////////////////////////////////////////////////////////////////////////
    ///////////////// Specify The Format of Our Audio Samples ///////////////////
    /////////////////////////////////////////////////////////////////////////////
    
    // the local format describes the format the samples we will give to the ExtAudioFile API
    AudioStreamBasicDescription localFormat;
    FillOutASBDForLPCM (localFormat,SRATE,mChannels,BITS_PER_CHANNEL,BITS_PER_CHANNEL,true,false,false);
    
    
    
    /////////////////////////////////////////////////////////////////////////////
    ///////////////// Create the Audio File and Open It /////////////////////////
    /////////////////////////////////////////////////////////////////////////////
    
    // create the audio file reference
    ExtAudioFileRef audiofileRef;
    
    // create a fileURL from our path
    CFURLRef fileURL = CFURLCreateWithFileSystemPath(kCFAllocatorDefault,fPath,kCFURLPOSIXPathStyle,false);
    
    // open the file for writing
    err = ExtAudioFileCreateWithURL((CFURLRef)fileURL, fileType, &clientFormat, NULL, kAudioFileFlags_EraseFile, &audiofileRef);
    
    if (err != noErr)
    {
        cout << "Problem when creating audio file: " << err << "\n";
    }
    
    
    /////////////////////////////////////////////////////////////////////////////
    ///// Tell the ExtAudioFile API what format we'll be sending samples in /////
    /////////////////////////////////////////////////////////////////////////////
    
    // Tell the ExtAudioFile API what format we'll be sending samples in
    err = ExtAudioFileSetProperty(audiofileRef, kExtAudioFileProperty_ClientDataFormat, sizeof(localFormat), &localFormat);
    
    if (err != noErr)
    {
        cout << "Problem setting audio format: " << err << "\n";
    }
    
    /////////////////////////////////////////////////////////////////////////////
    ///////// Write the Contents of the AudioBufferList to the AudioFile ////////
    /////////////////////////////////////////////////////////////////////////////
    
    UInt32 rFrames = (UInt32)totalFramesInFile;
    // write the data
    err = ExtAudioFileWrite(audiofileRef, rFrames, &outputData);
    
    if (err != noErr)
    {
        cout << "Problem writing audio file: " << err << "\n";
    }
    
    
    /////////////////////////////////////////////////////////////////////////////
    ////////////// Close the Audio File and Get Rid Of The Reference ////////////
    /////////////////////////////////////////////////////////////////////////////
    
    // close the file
    ExtAudioFileDispose(audiofileRef);
    
    
    cout << "Audio profile saved!" << endl;
}