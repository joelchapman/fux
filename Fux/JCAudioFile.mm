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

#define SRATE 44100
#define DELAYTIME 10

JCAudioFile::JCAudioFile()
{
    recording = (float*)malloc(SRATE*DELAYTIME*sizeof(float));
}

void JCAudioFile::setRecording( float tempBuffer[], int TRACKS )
{
    memcpy(recording, tempBuffer, sizeof(float)*SRATE*DELAYTIME);
}

int JCAudioFile::bufferSize()
{
    return SRATE*DELAYTIME;
}